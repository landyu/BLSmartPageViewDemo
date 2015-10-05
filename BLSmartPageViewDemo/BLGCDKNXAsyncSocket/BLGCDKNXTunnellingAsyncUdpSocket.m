//
//  BLGCDKNXAsyncUdpSocket.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/9/28.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLGCDKNXTunnellingAsyncUdpSocket.h"
#import "GlobalMacro.h"
#import "GCDAsyncUdpSocket.h"
#import "Utils.h"

enum TunnellingSocketError
{
    TunnellingSocketNoError = 0,         // Never used
    TunnellingSocketConnectRequestTimeoutError = 1,
    TunnellingSocketConnectResponseNoConnectionError = 2,
    TunnellingSocketConnectResponseOtherError = 3,
    TunnellingSocketConnectionStateResponseWait = 4,
    TunnellingRequestAckResponseStateWait = 5,
    TunnellingRequestAckResponseStateOtherError = 6,
    
    TunnellingSocketConnectResponseConnectionTypeError = 0x22,  //The requested connection type is not supported by the KNXnet/IP Server device.
    TunnellingSocketConnectResponseConnectionOptionError = 0x23, //One or more requested connection options are not supported by the KNXnet/IP Server device.
    TunnellingSocketConnectResponseNoMoreConnectionsError = 0x24, //The KNXnet/IP Server device cannot accept the new data connection because its maximum amount of concurrent connections is already occupied.
    TunnellingSocketConnectResponseNoMoreUniqueConnectionsError = 0x25,
    TunnellingSocketConnectionStateResponseConnectionIdError = 0x21, //The KNXnet/IP Server device cannot find an active data connection with the specified ID.
    TunnellingSocketConnectionStateResponseDataConnectionError = 0x26, //The KNXnet/IP Server device detects an error concerning the data connection with the specified ID.
    TunnellingSocketConnectionStateResponseKnxConnectionError = 0x27, //The KNXnet/IP Server device detects an error concerning the KNX subnetwork connection with the specified ID.
    
};
typedef enum TunnellingSocketError TunnellingSocketError;

@interface BLGCDKNXTunnellingAsyncUdpSocket()
{
    uint16_t clientBindPort;
    NSString *serverAddr;
    uint16_t serverPort;
    //dispatch_queue_t delegateQueue;
    
    long tunnellingSocketTag;
    unsigned int CID;
    unsigned char SC;
    
    TunnellingSocketError tunnellingConnectState;
    TunnellingSocketError heartBeatState;
    
    BOOL connectionStateResponseTimeoutFlag;
    BOOL needReconnect;
    
    NSTimer *connectionStateResponseTimeout; //10s
    NSTimer *tunnellingHeartBeatTimer;
    NSTimer *tunnellingReconnectTimer; //1s
    
    NSUInteger connectionStateRequestRepeatCounter; //3
    NSUInteger tunnellingRequestRepeatCounter; //2
    
    GCDAsyncUdpSocket *tunnellingUdpSocket;
}
@end

@class BLGCDKNXAsyncUdpSendPacket;

@implementation BLGCDKNXTunnellingAsyncUdpSocket

#pragma mark - life cycle
+ (instancetype)sharedInstance
{
    // 1
    static BLGCDKNXTunnellingAsyncUdpSocket *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[BLGCDKNXTunnellingAsyncUdpSocket alloc] init];
    });
    return _sharedInstance;
}



#pragma mark - GCDAsyncUdpSocketDelegate
//- (BOOL)sendKnxDataWithGroupAddress:(NSString *)groupAddress objectValue:(NSString *)value valueLength:(NSString *)valueLength commandType:(NSString *)commandType
//{
//    return YES;
//}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    Byte *testByte = (Byte *)[data bytes];
    
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",testByte[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    
    if (hexStr)
    {
        if ((testByte[0] == 0x06) && (testByte[1] == 0x10) && (testByte[2] == 0x02) && (testByte[3] == 0x06)) //connect response
        {
            if((tunnellingConnectState  != TunnellingSocketConnectResponseNoConnectionError) || (connectionStateResponseTimeoutFlag == YES))
            {
                return;
            }
            
            switch (testByte[7])
            {
                case TunnellingSocketNoError:
                {
                    CID = testByte[6];
                    SC = 0;
                    tunnellingConnectState = TunnellingSocketNoError; //Connect Sucess
                    //[udpHeartBeat setFireDate:[NSDate distantPast]];  //start heart beat
                    LogInfo(@"Connect Sucess code %d CID : %u", testByte[7] , CID);  //CID
                    break;
                }
                case TunnellingSocketConnectResponseNoMoreConnectionsError:
                {
                    LogInfo(@"Connect Failed  E_NO_MORE_CONNECTIONS code %d", testByte[7]);
                    tunnellingConnectState = TunnellingSocketConnectResponseNoMoreConnectionsError;
                    break;
                }
                case TunnellingSocketConnectResponseNoMoreUniqueConnectionsError:
                {
                    LogInfo(@"Connect Failed  E_NO_MORE_UNIQUE_CONNECTIONS code %d", testByte[7]);
                    tunnellingConnectState = TunnellingSocketConnectResponseNoMoreUniqueConnectionsError;
                    break;
                }
                case TunnellingSocketConnectResponseConnectionOptionError:
                {
                    LogInfo(@"Connect Failed  E_CONNECTION_OPTION code %d", testByte[7]);
                    tunnellingConnectState = TunnellingSocketConnectResponseConnectionOptionError;
                    break;
                }
                case TunnellingSocketConnectResponseConnectionTypeError:
                {
                    LogInfo(@"Connect Failed  E_CONNECTION_TYPE code %d", testByte[7]);
                    tunnellingConnectState = TunnellingSocketConnectResponseConnectionTypeError;
                    break;
                }
                default:
                    LogInfo(@"Connect Failed  Other Error code %d", testByte[7]);
                    tunnellingConnectState = TunnellingSocketConnectResponseOtherError;
                    break;
            }
        }
        else if((testByte[0] == 0x06) && (testByte[1] == 0x10) && (testByte[2] == 0x02) && (testByte[3] == 0x0A))
        {
            if (testByte[6] == CID)
            {
                [self disconnectServer];
                LogInfo(@"Disconnect  CID : %u", CID);  //CID
            }
        }
        else if((testByte[0] == 0x06) && (testByte[1] == 0x10) && (testByte[2] == 0x02) && (testByte[3] == 0x08)) //heart beat response
        {
            if (testByte[6] == CID)
            {
                switch (testByte[7])
                {
                    case TunnellingSocketNoError:
                    {
                        NSLog(@"Connect state  Response No Error");
                        heartBeatState = TunnellingSocketNoError;
                        break;
                    }
                    case TunnellingSocketConnectionStateResponseConnectionIdError:
                    {
                        NSLog(@"Connect state  Response  Connection Id Error");
                        heartBeatState = TunnellingSocketConnectionStateResponseConnectionIdError;
                        break;
                    }
                    case TunnellingSocketConnectionStateResponseDataConnectionError:
                    {
                        NSLog(@"Connect state  Response  Data Connection Error");
                        heartBeatState = TunnellingSocketConnectionStateResponseDataConnectionError;
                        break;
                    }
                    case TunnellingSocketConnectionStateResponseKnxConnectionError:
                    {
                        NSLog(@"Connect state  Response  Knx Connection Error");
                        heartBeatState = TunnellingSocketConnectionStateResponseKnxConnectionError;
                        break;
                    }
                    default:
                        break;
                }
            }
            
        }
    }

}

#pragma mark - event response
- (void) connectionStateResponseTimeoutFired
{
    LogInfo(@"connectionStateResponseTimeoutFired 10s....");
    [self connectionStateResponseTimeoutTimerStart:NO];
    connectionStateResponseTimeoutFlag = YES;
}

- (void)tunnellingHeartBeatTimerFired
{
    [self tunnellingHeartBeatTimerStart:NO];
    if (tunnellingConnectState != TunnellingSocketNoError)
    {
        return;
    }
    
    Byte sendByte[16] = {0x06,0x10,0x02,0x07,0x00,0x10,CID,0x00,0x08,0x01,0x00,0x00,0x00,0x00,0x00,0x00}; //state request
    
    NSData *data = [[NSData alloc] initWithBytes:sendByte length:sizeof(sendByte)];
    
    dispatch_async([Utils GlobalBackgroundQueue],
                   ^{
                        while(connectionStateRequestRepeatCounter--)
                       {
                           [tunnellingUdpSocket sendData:data toHost:serverAddr port:serverPort withTimeout:64 tag:tunnellingSocketTag++];
                           LogInfo(@"SENT (%i): Connection State Request Counter %lu", (int)tunnellingSocketTag, (unsigned long)connectionStateRequestRepeatCounter);
                           connectionStateResponseTimeoutFlag = NO;
                           heartBeatState = TunnellingSocketConnectionStateResponseWait;
                           [self connectionStateResponseTimeoutTimerStart:YES];
                           while ((connectionStateResponseTimeoutFlag == NO) && (heartBeatState == TunnellingSocketConnectionStateResponseWait))
                           {
                               [NSThread sleepForTimeInterval:0.01];
                           }
                           [self connectionStateResponseTimeoutTimerStart:NO];
                           if (connectionStateResponseTimeoutFlag == YES)
                           {
                               [NSThread sleepForTimeInterval:0.01];
                               continue;
                           }
                           
                           if (heartBeatState != TunnellingSocketConnectionStateResponseWait)
                           {
                               switch (heartBeatState)
                               {
                                   case TunnellingSocketNoError:
                                   {
                                       connectionStateRequestRepeatCounter = 3;
                                       [self tunnellingHeartBeatTimerStart:YES];
                                       break; //break switch
                                   }
                                   case TunnellingSocketConnectionStateResponseConnectionIdError:
                                   {
                                       [NSThread sleepForTimeInterval:0.01];
                                       continue;
                                   }
                                   case TunnellingSocketConnectionStateResponseDataConnectionError:
                                   {
                                       [NSThread sleepForTimeInterval:0.01];
                                       continue;
                                   }
                                   case TunnellingSocketConnectionStateResponseKnxConnectionError:
                                   {
                                       [NSThread sleepForTimeInterval:0.01];
                                       continue;
                                   }
                                   default:
                                       continue;
                               }
                               
                               if (heartBeatState == TunnellingSocketNoError)
                               {
                                   break; //break while
                               }
                               
                           }

                       }
    
                       if(connectionStateRequestRepeatCounter == 0) //heart beat no response or response error and try more than 3 times
                       {
                           LogInfo(@"heart beat error reset data ...");
                           [self disconnectServer];
                       }
                   });
    
}

- (void) tunnellingReconnectTimerFired
{
    [self tunnellingReconnectTimerStart:NO];
    dispatch_async([Utils GlobalBackgroundQueue],
                   ^{
                       [self connectToServer];
                   });
}

#pragma mark - private method
- (void) setTunnellingSocketWithClientBindToPort:(uint16_t)clientPort
                                 deviceIpAddress:(NSString *)serverIpAddr
                                    deviceIpPort:(uint16_t)serverIpPort
                                   delegateQueue:(dispatch_queue_t)dq
{
    clientBindPort = clientPort;
    serverAddr = serverIpAddr;
    serverPort = serverIpPort;
    //delegateQueue = dq;
    
    CID = 0;
    SC = 0;
    
    
    tunnellingConnectState = TunnellingSocketConnectResponseNoConnectionError;
    connectionStateResponseTimeoutFlag = YES;
    needReconnect = YES;
    connectionStateRequestRepeatCounter = 3; //3
    tunnellingRequestRepeatCounter = 2; //2
    
    connectionStateResponseTimeout = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(connectionStateResponseTimeoutFired) userInfo:nil repeats:YES];
    //NSLog(@"setFireDate ....");
    //[connectionStateResponseTimeout setFireDate:[NSDate dateWithTimeIntervalSinceNow:10.0]];//stop
    //[connectionStateResponseTimeout setFireDate:[NSDate distantFuture]];//stop
    [self connectionStateResponseTimeoutTimerStart:NO];
    
    tunnellingHeartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(tunnellingHeartBeatTimerFired) userInfo:nil repeats:YES];
    [self tunnellingHeartBeatTimerStart:NO];
    
    tunnellingReconnectTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tunnellingReconnectTimerFired) userInfo:nil repeats:YES];
    [self tunnellingReconnectTimerStart:NO];
    
    tunnellingUdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dq];
    NSError *error = nil;
    if (![tunnellingUdpSocket bindToPort:clientBindPort error:&error])
    {
        LogInfo(@"Error binding: %@", error);
        return;
    }
    else
    {
        //NSLog(@"didConnectToAddress %@", address);
        //[TransmitUdpSocket sendData:nil toHost:@"127.0.0.1" port:0 withTimeout:64 tag:0];
        //NSLog(@"didConnectToAddress sock.localAddress %@ sock.localHost %@ sock.localPort  %hu", TransmitUdpSocket.localAddress_IPv4, TransmitUdpSocket.localHost, TransmitUdpSocket.localPort);
    }
    if (![tunnellingUdpSocket beginReceiving:&error])
    {
        LogInfo(@"Error receiving: %@", error);
        return;
    }
    
}


- (void) tunnellingServeStart
{
    if (tunnellingUdpSocket == nil)
    {
        return;
    }
    
    dispatch_async([Utils GlobalBackgroundQueue],
                   ^{
                       needReconnect = YES;
                       [self connectToServer];
                   });
    
}

- (void) tunnellingServeStop
{
    needReconnect = NO;
    [self disconnectServer];
}

- (void) connectToServer
{
//    if (tunnellingConnectState != TunnellingSocketConnectResponseNoConnectionError)
//    {
//        [self tunnellingConnectStateChanged];
//        return;
//    }
    
    Byte sendByte[26] = {0x06,0x10,0x02,0x05,0x00,0x1a,0x08,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x08,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x04,0x04,0x02,0x00};
    NSData *data = [[NSData alloc] initWithBytes:sendByte length:sizeof(sendByte)];
    
    [tunnellingUdpSocket sendData:data toHost:serverAddr port:serverPort withTimeout:64 tag:tunnellingSocketTag++];
    LogInfo(@"SENT (%i): Connection State Request Counter", (int)tunnellingSocketTag);
    connectionStateResponseTimeoutFlag = NO;
    //[connectionStateResponseTimeout setFireDate:[NSDate date]];//start
    //[connectionStateResponseTimeout setFireDate:[NSDate dateWithTimeIntervalSinceNow:10.0]];//start 10 second later
    [self connectionStateResponseTimeoutTimerStart:YES];
    while ((tunnellingConnectState  == TunnellingSocketConnectResponseNoConnectionError) && (connectionStateResponseTimeoutFlag == NO))
    {
        [NSThread sleepForTimeInterval:0.01];
    }
    [self connectionStateResponseTimeoutTimerStart:NO];
    
    if (connectionStateResponseTimeoutFlag == YES) //connection timeout
    {
        LogInfo(@"connection timeout...");
        tunnellingConnectState = TunnellingSocketConnectRequestTimeoutError;
    }
    
    [self tunnellingConnectStateChanged];
    
    
    
}

- (void) disconnectServer
{
    Byte sendByte[16] = {0x06,0x10,0x02,0x09,0x00,0x10,CID,0x00,0x08,0x01,0x00,0x00,0x00,0x00,0x00,0x00};
    
    NSData *data = [[NSData alloc] initWithBytes:sendByte length:sizeof(sendByte)];
    
    
    connectionStateRequestRepeatCounter = 3;
    [self tunnellingHeartBeatTimerStart:NO]; //stop heart beat
    [self connectionStateResponseTimeoutTimerStart:NO];
    [self tunnellingReconnectTimerStart:NO];
    //send disconnect and reset data
    if (tunnellingConnectState != TunnellingSocketConnectResponseNoConnectionError)
    {
        [tunnellingUdpSocket sendData:data toHost:serverAddr port:serverPort withTimeout:64 tag:tunnellingSocketTag++];
        LogInfo(@"SENT (%i): Disconnect CID %u", (int)tunnellingSocketTag, CID);
    }
    tunnellingConnectState = TunnellingSocketConnectResponseNoConnectionError;
    heartBeatState = TunnellingSocketNoError;
    [self tunnellingConnectStateChanged];
}


- (void) tunnellingConnectStateChanged
{
    switch (tunnellingConnectState)
    {
        case TunnellingSocketNoError:
        {
            LogInfo(@"Connect Success...");
            [self tunnellingHeartBeatTimerStart:YES];
            break;
        }
        case TunnellingSocketConnectRequestTimeoutError:
        {
            LogInfo(@"connection timeout...");
            tunnellingConnectState = TunnellingSocketConnectResponseNoConnectionError;
            break;
        }
        case TunnellingSocketConnectResponseNoMoreConnectionsError:
        {
            tunnellingConnectState = TunnellingSocketConnectResponseNoConnectionError;
            LogInfo(@"Connect Response No More Connections...");
            break;
        }
        case TunnellingSocketConnectResponseNoMoreUniqueConnectionsError:
        {
            tunnellingConnectState = TunnellingSocketConnectResponseNoConnectionError;
            LogInfo(@"Connect Response No More Unique Connections...");
            break;
        }
        default:
        {
            tunnellingConnectState = TunnellingSocketConnectResponseNoConnectionError;
            LogInfo(@"Connect Response Other Error...");
            break;
        }
    }
    
    if (tunnellingConnectState == TunnellingSocketConnectResponseNoConnectionError)  //decide whether to start connect again
    {
        if (needReconnect == YES)
        {
            [self tunnellingReconnectTimerStart:YES];
        }
    }
}


- (void) tunnellingHeartBeatTimerStart:(BOOL)start
{
    if (tunnellingHeartBeatTimer == nil)
    {
        return;
    }
    
    if (start)
    {
        [tunnellingHeartBeatTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:30.0]];//start
    }
    else
    {
        [tunnellingHeartBeatTimer setFireDate:[NSDate distantFuture]];//stop
    }
}

- (void) connectionStateResponseTimeoutTimerStart:(BOOL)start
{
    if (connectionStateResponseTimeout == nil)
    {
        return;
    }
    
    if (start)
    {
        [connectionStateResponseTimeout setFireDate:[NSDate dateWithTimeIntervalSinceNow:10.0]];//start 10 second later
    }
    else
    {
        [connectionStateResponseTimeout setFireDate:[NSDate distantFuture]];//stop
    }
}


- (void) tunnellingReconnectTimerStart:(BOOL)start
{
    if (tunnellingReconnectTimer == nil)
    {
        return;
    }
    
    if (start)
    {
        [tunnellingReconnectTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];//start 10 second later
    }
    else
    {
        [tunnellingReconnectTimer setFireDate:[NSDate distantFuture]];//stop
    }
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - private class
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * The GCDAsyncUdpSendPacket encompasses the instructions for a single send/write.
 **/
@interface BLGCDKNXAsyncUdpSendPacket : NSObject
{
@public
    NSData *buffer;
    NSTimeInterval timeout;
    long tag;
    
    BOOL resolveInProgress;
    BOOL filterInProgress;
    
    NSArray *resolvedAddresses;
    NSError *resolveError;
    
    NSData *address;
    int addressFamily;
}

- (id)initWithData:(NSData *)d timeout:(NSTimeInterval)t tag:(long)i;

@end

@implementation BLGCDKNXAsyncUdpSendPacket

- (id)initWithData:(NSData *)d timeout:(NSTimeInterval)t tag:(long)i
{
    if ((self = [super init]))
    {
        buffer = d;
        timeout = t;
        tag = i;
        
        resolveInProgress = NO;
    }
    return self;
}
@end