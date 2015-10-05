//
//  TransmitUdp.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/8/25.
//  Copyright (c) 2015年 Landyu. All rights reserved.
//

#import "TransmitUdp.h"
#import "GCDAsyncUdpSocket.h"
#import "Utils.h"

NSTimer *udpHeartBeat;
unsigned int CID = 0;
unsigned char SC = 0;
unsigned int connectStatus = 0;
//NSString *ipRouterHost = @"192.168.10.222";
NSString *ipRouterHost = @"192.168.10.193";
NSInteger ipRouterHostPort = 3671;

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


@interface TransmitUdp()
{
    long tag;
    GCDAsyncUdpSocket *TransmitUdpSocket;
    
    dispatch_queue_t serialHeartBeatWaitResponseQueue;
    dispatch_queue_t serialKnxUdpReconnectQueue;
    
    NSTimer *connectionStateResponseTimeout; //10s
    NSTimer *tunnellingRequestAckResponseTimeout; //1s
    
    NSUInteger connectionStateRequestRepeatCounter; //3
    NSUInteger tunnellingRequestRepeatCounter; //2
    
    TunnellingSocketError tunnellingConnectState;
    TunnellingSocketError heartBeatState;
    
    BOOL connectionStateResponseTimeoutFlag;
    BOOL connectDeviceTaskSuspendFlag;
    
    TunnellingSocketError tunnellingRequestAckResponseState;
    BOOL tunnellingRequestAckResponseTimeoutFlag;
    //BOOL timeoutFlag;
}
@end

@implementation TransmitUdp

+ (TransmitUdp *)sharedInstance
{
    // 1
    static TransmitUdp *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[TransmitUdp alloc] init];
    });
    return _sharedInstance;
}

- (void)setupSocket
{
    //TransmitUdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    TransmitUdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:[Utils GlobalMainQueue]];

    
    NSError *error = nil;
    serialHeartBeatWaitResponseQueue = dispatch_queue_create("BL.BLSmartPageViewDemo.HeartBeatWaitResponseQueue", DISPATCH_QUEUE_SERIAL);
    serialKnxUdpReconnectQueue = dispatch_queue_create("BL.BLSmartPageViewDemo.KnxUdpReconnectQueue", DISPATCH_QUEUE_SERIAL);
    
    tunnellingConnectState = TunnellingSocketConnectResponseNoConnectionError;
    heartBeatState = TunnellingSocketNoError;
    
    tunnellingRequestAckResponseState = TunnellingRequestAckResponseStateWait;
    
    if (![TransmitUdpSocket bindToPort:57032 error:&error])
    {
        NSLog(@"Error binding: %@", error);
        return;
    }
    else
    {
        //NSLog(@"didConnectToAddress %@", address);
        //[TransmitUdpSocket sendData:nil toHost:@"127.0.0.1" port:0 withTimeout:64 tag:0];
        //NSLog(@"didConnectToAddress sock.localAddress %@ sock.localHost %@ sock.localPort  %hu", TransmitUdpSocket.localAddress_IPv4, TransmitUdpSocket.localHost, TransmitUdpSocket.localPort);
    }
    if (![TransmitUdpSocket beginReceiving:&error])
    {
        NSLog(@"Error receiving: %@", error);
        return;
    }
    
    udpHeartBeat = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(udpHeartBeatTimerFired) userInfo:nil repeats:YES];
    [udpHeartBeat setFireDate:[NSDate distantFuture]];//stop heart beat
    
    
    connectionStateResponseTimeout = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(connectionStateResponseTimeoutFired) userInfo:nil repeats:YES];
    //NSLog(@"setFireDate ....");
    //[connectionStateResponseTimeout setFireDate:[NSDate dateWithTimeIntervalSinceNow:10.0]];//stop
    [connectionStateResponseTimeout setFireDate:[NSDate distantFuture]];//stop
    connectionStateRequestRepeatCounter = 3;
    
    tunnellingRequestAckResponseTimeout = [NSTimer scheduledTimerWithTimeInterval:1.1 target:self selector:@selector(tunnellingRequestAckResponseTimeoutFired) userInfo:nil repeats:YES];
    [tunnellingRequestAckResponseTimeout setFireDate:[NSDate distantFuture]];//stop
    tunnellingRequestRepeatCounter = 2;
    
    //timeoutFlag = 0;
    connectionStateResponseTimeoutFlag = YES;
    connectDeviceTaskSuspendFlag = NO;
    
    tunnellingRequestAckResponseTimeoutFlag = YES;
    
}

- (void)closeSocket
{
    if (TransmitUdpSocket)
    {
        [TransmitUdpSocket close];
    }
}

- (BOOL) udpSocketIsConnected
{
    if (TransmitUdpSocket == nil)
    {
        return NO;
    }
    
    return [TransmitUdpSocket isConnected];
}


- (BOOL) udpSocketisClosed
{
    if (TransmitUdpSocket == nil)
    {
        return YES;
    }
    
    return [TransmitUdpSocket isClosed];
}


- (void)udpHeartBeatTimerFired
{
//    if (connectStatus == 0)
//    {
//        return;
//    }
    
    if (tunnellingConnectState != TunnellingSocketNoError)
    {
        return;
    }
    
    Byte sendByte[] = {0x06,0x10,0x02,0x07,0x00,0x10,CID,0x00,0x08,0x01,0x00,0x00,0x00,0x00,0x00,0x00};
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    data = [NSMutableData dataWithBytes:sendByte length:16];
    
    
    
    dispatch_async(serialHeartBeatWaitResponseQueue,
                   ^{
                       while (connectionStateRequestRepeatCounter)
                       {
                           connectionStateRequestRepeatCounter--;
                           [TransmitUdpSocket sendData:data toHost:ipRouterHost port:ipRouterHostPort withTimeout:64 tag:tag++];
                           NSLog(@"SENT (%i): Connection State Request Counter %lu", (int)tag, (unsigned long)connectionStateRequestRepeatCounter);
                           
                           connectionStateResponseTimeoutFlag = NO;
                           heartBeatState = TunnellingSocketConnectionStateResponseWait;
                           //[connectionStateResponseTimeout setFireDate:[NSDate distantPast]];//start
                           [connectionStateResponseTimeout setFireDate:[NSDate dateWithTimeIntervalSinceNow:10.0]];//start 10 second later
                           while ((tunnellingConnectState  == TunnellingSocketNoError) && (connectionStateResponseTimeoutFlag == NO) && (heartBeatState == TunnellingSocketConnectionStateResponseWait))
                           {
                               [NSThread sleepForTimeInterval:0.01];
                           }
                           
                           if (heartBeatState != TunnellingSocketConnectionStateResponseWait)
                           {
                               switch (heartBeatState)
                               {
                                   case TunnellingSocketNoError:
                                   {
                                       connectionStateRequestRepeatCounter = 3;
                                       break;
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
                           }
                           
                           if (heartBeatState == TunnellingSocketNoError)
                           {
                               break;
                           }
                           
                           if (connectionStateResponseTimeoutFlag == YES)
                           {
                               [NSThread sleepForTimeInterval:0.01];
                               continue;
                           }
                       }
                       
                       if (connectionStateRequestRepeatCounter == 0) //heart beat no response or response error and try more than 3 times
                       {
                           NSLog(@"heart beat error reset data ...");
                           connectionStateRequestRepeatCounter = 3;
                           [udpHeartBeat setFireDate:[NSDate distantFuture]]; //stop heart beat
                           [connectionStateResponseTimeout setFireDate:[NSDate distantFuture]];//stop
                           //send disconnect and reset data
                           [self disconnectDevice];
                           tunnellingConnectState = TunnellingSocketConnectResponseNoConnectionError;
                           heartBeatState = TunnellingSocketNoError;
                       }
                   });
    
    
    
}

- (void) connectionStateResponseTimeoutFired
{
    NSLog(@"connectionStateResponseTimeoutFired 10s....");
    connectionStateResponseTimeoutFlag = YES;
}

- (void) tunnellingRequestAckResponseTimeoutFired
{
    NSLog(@"tunnellingRequestTimeoutFired 1s....");
    tunnellingRequestAckResponseTimeoutFlag = YES;
}

-(void) connectDeviceTaskSuspend
{
    if(serialKnxUdpReconnectQueue == nil)
    {
        return;
    }
    
    //dispatch_suspend(serialKnxUdpReconnectQueue);
    connectDeviceTaskSuspendFlag = YES;
    //[udpHeartBeat setFireDate:[NSDate distantFuture]]; //stop heart beat
}

-(void) connectDeviceTaskResume
{
    if(serialKnxUdpReconnectQueue == nil)
    {
        return;
    }
    
    //dispatch_resume(serialKnxUdpReconnectQueue);
    connectDeviceTaskSuspendFlag = NO;
}

- (void) seTtunnellingConnectStateAsTunnellingSocketConnectResponseNoConnectionError
{
    tunnellingConnectState = TunnellingSocketConnectResponseNoConnectionError;
}

- (BOOL) isDeviceConnected
{
    if (tunnellingConnectState == TunnellingSocketNoError)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)connectDevice
{
    __block Byte sendByte[] = {0x06,0x10,0x02,0x05,0x00,0x1a,0x08,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x08,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x04,0x04,0x02,0x00};
    
    __block int connectTimes = 0;
    NSMutableData *data = [[NSMutableData alloc] init];
    
    data = [NSMutableData dataWithBytes:sendByte length:26];
    
//        [TransmitUdpSocket sendData:data toHost:ipRouterHost port:ipRouterHostPort withTimeout:64 tag:tag];
//        NSLog(@"SENT (%i): Connect Times = %d", (int)tag, connectTimes++);
//    tag++;
    
    
    dispatch_async(serialKnxUdpReconnectQueue, ^{
        // 耗时的操作
        
        while (true)
        {
            while(connectDeviceTaskSuspendFlag == YES)
            {
                [NSThread sleepForTimeInterval:0.01];
            }
            
            if (tunnellingConnectState  == TunnellingSocketConnectResponseNoConnectionError)
            {
                [TransmitUdpSocket sendData:data toHost:ipRouterHost port:ipRouterHostPort withTimeout:64 tag:tag++];
                connectionStateResponseTimeoutFlag = NO;
                //[connectionStateResponseTimeout setFireDate:[NSDate date]];//start
                [connectionStateResponseTimeout setFireDate:[NSDate dateWithTimeIntervalSinceNow:10.0]];//start 10 second later
                NSLog(@"SENT (%i): Connect Times = %d", (int)tag, connectTimes++);
                while ((tunnellingConnectState  == TunnellingSocketConnectResponseNoConnectionError) && (connectionStateResponseTimeoutFlag == NO))
                {
                    [NSThread sleepForTimeInterval:0.01];
                }
                if (connectionStateResponseTimeoutFlag == YES) //connection timeout
                {
                  NSLog(@"connection timeout...");
                  [connectionStateResponseTimeout setFireDate:[NSDate distantFuture]];//stop
                    continue;
                }
                else
                {
                    //[connectionStateResponseTimeout setFireDate:[NSDate distantFuture]];//stop
                    switch (tunnellingConnectState)
                    {
                        case TunnellingSocketNoError:
                            NSLog(@"Connect Success...");
                            break;
                        case TunnellingSocketConnectResponseNoMoreConnectionsError:
                        {
                            tunnellingConnectState = TunnellingSocketConnectResponseNoConnectionError;
                            NSLog(@"Connect Response No More Connections...");
                            connectionStateResponseTimeoutFlag = NO;
                            [connectionStateResponseTimeout setFireDate:[NSDate dateWithTimeIntervalSinceNow:10.0]];//start 10 second later
                            while (connectionStateResponseTimeoutFlag == NO)
                            {
                                [NSThread sleepForTimeInterval:0.01];
                            }
                            break;
                        }
                        case TunnellingSocketConnectResponseNoMoreUniqueConnectionsError:
                        {
                            tunnellingConnectState = TunnellingSocketConnectResponseNoConnectionError;
                            NSLog(@"Connect Response No More Unique Connections...");
                            connectionStateResponseTimeoutFlag = NO;
                            [connectionStateResponseTimeout setFireDate:[NSDate dateWithTimeIntervalSinceNow:10.0]];//start 10 second later
                            while (connectionStateResponseTimeoutFlag == NO)
                            {
                                [NSThread sleepForTimeInterval:0.01];
                            }
                            break;
                        }
                        default:
                        {
                            tunnellingConnectState = TunnellingSocketConnectResponseNoConnectionError;
                            NSLog(@"Connect Response Other Error...");
                            connectionStateResponseTimeoutFlag = NO;
                            [connectionStateResponseTimeout setFireDate:[NSDate dateWithTimeIntervalSinceNow:10.0]];//start 10 second later
                            while (connectionStateResponseTimeoutFlag == NO)
                            {
                                [NSThread sleepForTimeInterval:0.01];
                            }
                            break;
                        }
                    }
                }
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
        }
    });

    
  
   
}

- (void)disconnectDevice
{
    Byte sendByte[] = {0x06,0x10,0x02,0x09,0x00,0x10,CID,0x00,0x08,0x01,0x00,0x00,0x00,0x00,0x00,0x00};
    
//    if (connectStatus == 0)
//    {
//        return;
//    }
    
//    if(tunnellingConnectState != TunnellingSocketNoError)
//    {
//        return;
//    }
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    data = [NSMutableData dataWithBytes:sendByte length:16];
    
    [TransmitUdpSocket sendData:data toHost:ipRouterHost port:ipRouterHostPort withTimeout:64 tag:tag];
    NSLog(@"SENT (%i): Disconnect CID %u", (int)tag, CID);
    tag++;
    
    tunnellingConnectState  = TunnellingSocketConnectResponseNoConnectionError;
    [udpHeartBeat setFireDate:[NSDate distantFuture]];  //stop heart beat
    
}



- (BOOL)sendKnxDataWithGroupAddress:(NSString *)groupAddress objectValue:(NSString *)value valueLength:(NSString *)valueLength commandType:(NSString *)commandType
{
    
    //                           0           1           2           3           4           5           6           7           8           9
    unsigned char eibIntValue[72] = {0x00, 0x00, 0x00, 0x64, 0x08, 0x64, 0x01, 0x2C, 0x10, 0x64, 0x01, 0xF4, 0x02, 0x58, 0x02, 0xBC, 0x18, 0x64, 0x03, 0x84,\
        0x03, 0xE8, 0x04, 0x4C, 0x04, 0xB0, 0x05, 0x14, 0x05, 0x78, 0x05, 0xDC, 0x06, 0x40, 0x06, 0xA4, 0x07, 0x08, 0x07, 0x6C,\
        0x07, 0xD0, 0x0C, 0x1A, 0x0C, 0x4C, 0x0C, 0x7E, 0x0C, 0xB0, 0x0C, 0xE2, 0x0D, 0x14, 0x0D, 0x46, 0x0D, 0x78, 0x0D, 0xAA,\
        0x0D, 0xDC, 0x0E, 0x0E, 0x0E, 0x40, 0x0E, 0x72, 0x0E, 0xA4, 0x0E, 0xD6};
    
    NSInteger dataLength = 0;
    
//    if (connectStatus == 0)
//    {
//        return;
//    }
    
    //NSInteger outputValue = [value integerValue];
    NSArray *groupAddressSplit = [groupAddress componentsSeparatedByString:@"/"];
    
    Byte sendByte[] = {0x06,0x10,0x04,0x20,0x00,0x15,0x04,CID,SC,0x00,0x11,0x00,0xbc,0xd0,0x00,0x00,0x18,0x00,0x01,0x00,0x81,0x00,0x00};
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    
    sendByte[16] = ([[groupAddressSplit objectAtIndex:0] integerValue] << 3 ) | ([[groupAddressSplit objectAtIndex:1] integerValue] & 0x07);
    sendByte[17] = [[groupAddressSplit objectAtIndex:2] integerValue];
    
    if ([commandType isEqualToString:@"Write"])
    {
        if ([valueLength isEqualToString:@"1Bit"])
        {
            sendByte[5] = 0x15;//package length
            sendByte[18] = 1;//value length
            sendByte[20] = 0x80 | ([value integerValue] & 0x01);
            dataLength = 21;
            //SC++;
        }
        else if ([valueLength isEqualToString:@"1Byte"])
        {
            sendByte[5] = 0x16;//package length
            sendByte[18] = 2;//value length
            sendByte[20] = 0x80;
            sendByte[21] = [value integerValue];
            dataLength = 22;
            //SC++;
        }
        else if ([valueLength isEqualToString:@"2Byte"])
        {
            if ([value integerValue] < 0 || [value integerValue] > 36)
            {
                return NO;
            }
            
            sendByte[5] = 0x17;//package length
            sendByte[18] = 3;//value length
            sendByte[20] = 0x80; //apci
            sendByte[21] = eibIntValue[[value integerValue] * 2]; //value
            sendByte[22] = eibIntValue[[value integerValue] * 2 + 1]; //value
            dataLength = 23;
            //SC++;
        }
        
    }
    else if ([commandType isEqualToString:@"Read"])
    {
        //if ([valueLength isEqualToString:@"1Bit"])
        {
            sendByte[5] = 0x15;//package length
            sendByte[18] = 1;//value length
            sendByte[20] = 0x00 | ([value integerValue] & 0x01);
            dataLength = 21;
            //SC++;
        }
    }
    
    
    
    data = [NSMutableData dataWithBytes:sendByte length:dataLength];
    
    tunnellingRequestRepeatCounter = 2;
    while (tunnellingRequestRepeatCounter)
    {
        tunnellingRequestRepeatCounter--;
        [TransmitUdpSocket sendData:data toHost:ipRouterHost port:ipRouterHostPort withTimeout:64 tag:tag];
        NSLog(@"SENT (%i): Request Repeat Counter %lu SC  %u", (int)tag, (unsigned long)tunnellingRequestRepeatCounter, SC);
        
        tunnellingRequestAckResponseTimeoutFlag = NO;
        tunnellingRequestAckResponseState = TunnellingRequestAckResponseStateWait;
        //[connectionStateResponseTimeout setFireDate:[NSDate distantPast]];//start
        [tunnellingRequestAckResponseTimeout setFireDate:[NSDate dateWithTimeIntervalSinceNow:1.1]];//start 1.1 second later
        while ((tunnellingRequestAckResponseTimeoutFlag == NO) && (tunnellingRequestAckResponseState == TunnellingRequestAckResponseStateWait))
        {
            [NSThread sleepForTimeInterval:0.01];
        }
        
        if (tunnellingRequestAckResponseState != TunnellingRequestAckResponseStateWait)
        {
            switch (tunnellingRequestAckResponseState)
            {
                case TunnellingSocketNoError:
                {
                    SC++;
                    break;
                }
                default:
                    continue;
            }

        }
        
        if (tunnellingRequestAckResponseState == TunnellingSocketNoError)
        {
            break;
        }
        
        if (tunnellingRequestAckResponseTimeoutFlag == YES) //timeout
        {
            continue;
        }
    }
    
    if (tunnellingRequestRepeatCounter == 0)  //
    {
        NSLog(@"Send request failed...");
        [tunnellingRequestAckResponseTimeout setFireDate:[NSDate distantFuture]];//stop
        return NO;
    }
    else
    {
        return YES;
    }
}

#pragma mark - GCDAsyncUdpSocketDelegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    // You could add checks here
    //NSLog(@"didConnectToAddress sock.localAddress %@ sock.localHost %@ sock.localPort  %hu", sock.localAddress_IPv4, sock.localHost, sock.localPort);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    // You could add checks here
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    //NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    Byte *testByte = (Byte *)[data bytes];
    //atos();
    //NSString *msg = [[NSString alloc] initWithBytes:testByte length:[data length] encoding:NSUnicodeStringEncoding];
    
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
        //[self logMessage:FORMAT(@"RECV: %@", hexStr)];  //CID
        
        if ((testByte[0] == 0x06) && (testByte[1] == 0x10) && (testByte[2] == 0x02) && (testByte[3] == 0x06))
        {
            if((tunnellingConnectState  != TunnellingSocketConnectResponseNoConnectionError) || (connectionStateResponseTimeoutFlag == YES))
            {
                return;
            }
            
            [connectionStateResponseTimeout setFireDate:[NSDate distantFuture]];//stop
            
            switch (testByte[7])
            {
                case TunnellingSocketNoError:
                {
                    CID = testByte[6];
                    tunnellingConnectState = TunnellingSocketNoError; //Connect Sucess
                    [udpHeartBeat setFireDate:[NSDate dateWithTimeIntervalSinceNow:30.0]];//start 30 second later
                    //[udpHeartBeat setFireDate:[NSDate distantPast]];  //start heart beat
                    NSLog(@"Connect Sucess code %d CID : %u", testByte[7] , CID);  //CID
                    break;
                }
                case TunnellingSocketConnectResponseNoMoreConnectionsError:
                {
                    NSLog(@"Connect Failed  E_NO_MORE_CONNECTIONS code %d", testByte[7]);
                    tunnellingConnectState = TunnellingSocketConnectResponseNoMoreConnectionsError;
                    break;
                }
                case TunnellingSocketConnectResponseNoMoreUniqueConnectionsError:
                {
                    NSLog(@"Connect Failed  E_NO_MORE_UNIQUE_CONNECTIONS code %d", testByte[7]);
                    tunnellingConnectState = TunnellingSocketConnectResponseNoMoreUniqueConnectionsError;
                    break;
                }
                case TunnellingSocketConnectResponseConnectionOptionError:
                {
                    NSLog(@"Connect Failed  E_CONNECTION_OPTION code %d", testByte[7]);
                    tunnellingConnectState = TunnellingSocketConnectResponseConnectionOptionError;
                    break;
                }
                case TunnellingSocketConnectResponseConnectionTypeError:
                {
                    NSLog(@"Connect Failed  E_CONNECTION_TYPE code %d", testByte[7]);
                    tunnellingConnectState = TunnellingSocketConnectResponseConnectionTypeError;
                    break;
                }
                default:
                    NSLog(@"Connect Failed  Other Error code %d", testByte[7]);
                    tunnellingConnectState = TunnellingSocketConnectResponseOtherError;
                    break;
            }
        }
//        else if((testByte[0] == 0x06) && (testByte[1] == 0x10) && (testByte[2] == 0x02) && (testByte[3] == 0x06) && (testByte[7] == 0x24))
//        {
//            NSLog(@"Connect Failed  E_NO_MORE_CONNECTIONS");  //CID
//            if((tunnellingConnectState  != TunnellingSocketConnectResponseNoConnectionError) || (connectionStateResponseTimeoutFlag == timeoutFlag))
//            {
//                return;
//            }
//            tunnellingConnectState = TunnellingSocketConnectResponseNoMoreConnectionsError;
//            
//        }
//        else if((testByte[0] == 0x06) && (testByte[1] == 0x10) && (testByte[2] == 0x02) && (testByte[3] == 0x06) && (testByte[7] == 0x23))
//        {
//            NSLog(@"Connect Failed  E_CONNECTION_OPTION");  //CID
//            if((tunnellingConnectState  != TunnellingSocketConnectResponseNoConnectionError) || (connectionStateResponseTimeoutFlag == timeoutFlag))
//            {
//                return;
//            }
//            tunnellingConnectState = TunnellingSocketConnectResponseConnectionOptionError;
//            
//        }
//        else if((testByte[0] == 0x06) && (testByte[1] == 0x10) && (testByte[2] == 0x02) && (testByte[3] == 0x06) && (testByte[7] == 0x22))
//        {
//            NSLog(@"Connect Failed  E_CONNECTION_TYPE");  //CID
//            if((tunnellingConnectState  != TunnellingSocketConnectResponseNoConnectionError) || (connectionStateResponseTimeoutFlag == timeoutFlag))
//            {
//                return;
//            }
//            tunnellingConnectState = TunnellingSocketConnectResponseConnectionTypeError;
//            
//        }
        else if((testByte[0] == 0x06) && (testByte[1] == 0x10) && (testByte[2] == 0x02) && (testByte[3] == 0x0A))
        {
            if (testByte[6] == CID)
            {
                connectStatus = 0;
                SC = 0;
                [udpHeartBeat setFireDate:[NSDate distantFuture]]; //stop heart beat
                [self connectDeviceTaskSuspend];
                NSLog(@"Disconnect  CID : %u", CID);  //CID
            }
        }
        else if((testByte[0] == 0x06) && (testByte[1] == 0x10) && (testByte[2] == 0x02) && (testByte[3] == 0x08))
        {
            if (testByte[6] == CID)
            {
//                if (testByte[7] == 0x00)
//                {
//                    //[self logMessage:FORMAT(@"Connection State Response OK  CID : %u", CID)];  //CID
//                    NSLog(@"Connection State Response OK  CID : %u", CID);  //CID
//                    return;
//                }
//                else
//                {
//                    connectStatus = 0;
//                    [udpHeartBeat setFireDate:[NSDate distantFuture]];  //stop heart beat
//                    NSLog(@"Connection State Error  CID : %u", CID);  //CID
//                }
                [connectionStateResponseTimeout setFireDate:[NSDate distantFuture]];//stop
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
        else if ((testByte[0] == 0x06) && (testByte[1] == 0x10) && (testByte[2] == 0x04) && (testByte[3] == 0x20)) //request
        {
            //SC = testByte[8] + 1;
            
            Byte sendByte[] = {0x06,0x10,0x04,0x21,0x00,0x0a,0x04,CID,testByte[8],0x00};  //ack
            
            NSMutableData *data = [[NSMutableData alloc] init];
            
            data = [NSMutableData dataWithBytes:sendByte length:10];
            
            [TransmitUdpSocket sendData:data toHost:ipRouterHost port:ipRouterHostPort withTimeout:64 tag:tag];
            NSLog(@"SENT (%i): Request ACK CID %u  SC %u", (int)tag, CID, testByte[8]);
            tag++;
            
            if ((testByte[19] == 0x00) && (testByte[20]  == 0x00))  //group value read
            {
                return;
            }
            
            NSString *groupAddress = [[NSString alloc] initWithFormat:@"%d/%d/%d",(testByte[16] >> 3), testByte[16] & 0x07,testByte[17]];
            NSString *value = nil;
            
            
            if (testByte[18] == 1) //1Bit
            {
                value = [[NSString alloc] initWithFormat:@"%d",testByte[20] & 0x01];
            }
            else if(testByte[18] == 2) //1Byte
            {
                value = [[NSString alloc] initWithFormat:@"%d",testByte[21]];
            }
            else if(testByte[18] == 3) //2Byte
            {
                float floatValueM = (testByte[21] & 0x07) << 8 | testByte[22];
                float floatValueE = (testByte[21] >> 3) & 0x0F;
                float tempValue = pow(2.0, floatValueE) * (floatValueM * 0.01);
                float tempValueInt = tempValue;
                value = [[NSString alloc] initWithFormat:@"%f",tempValueInt];
            }
            
            NSDictionary *eibBusDataDict = [NSDictionary dictionaryWithObjectsAndKeys:groupAddress, @"Address", value, @"Value",nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BL.BLSmartPageViewDemo.RecvFromBus" object:self userInfo:eibBusDataDict];
            
//            //if ((testByte[16] == 0x18) && (testByte[17] == 0x0c))  //Light A State Response
//            {
////                if ((testByte[20] & 0x01))  //ON
////                {
////                    [uibLightA setHighlighted:YES];
////                    [uibLightA setSelected:YES];
////                }
////                else  //OFF
////                {
////                    [uibLightA setHighlighted:NO];
////                    [uibLightA setSelected:NO];
////                }
////                
////                [self logMessage:FORMAT(@"setHighlighted %u", (testByte[20] & 0x01))];
//                ß
//                
//            }
            
            
        }
        else if((testByte[0] == 0x06) && (testByte[1] == 0x10) && (testByte[2] == 0x04) && (testByte[3] == 0x21))//ack
        {
            NSLog(@"SEND SC %u   RECV (%i): Request ACK CID %u  SC %u  Status %u", SC, (int)tag, testByte[7], testByte[8], testByte[9]);
            if ((testByte[7] == CID)  && (tunnellingRequestAckResponseTimeoutFlag == NO) && (tunnellingRequestAckResponseState == TunnellingRequestAckResponseStateWait))  //
            {
                if (testByte[8] == SC)
                {
                    [tunnellingRequestAckResponseTimeout setFireDate:[NSDate distantFuture]];//stop
                    switch (testByte[9])
                    {
                        case TunnellingSocketNoError:
                        {
                            tunnellingRequestAckResponseState = TunnellingSocketNoError;
                            break;
                        }
                        default:
                        {
                            tunnellingRequestAckResponseState = TunnellingRequestAckResponseStateOtherError;
                            break;
                        }
                    }
                }
            }
            
        }
        
    }
    else
    {
        NSString *host = nil;
        uint16_t port = 0;
        [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
        
        NSLog(@"RECV: Unknown message from: %@:%hu", host, port);
    }
}


@end
