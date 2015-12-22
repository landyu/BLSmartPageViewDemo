//
//  BLGCDKNXAsyncUdpSocket.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/9/28.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#include <ifaddrs.h>
#include <arpa/inet.h>
#import "BLGCDKNXTunnellingAsyncUdpSocket.h"
#import "GlobalMacro.h"
#import "GCDAsyncUdpSocket.h"
#import "Utils.h"
#import "NSMutableArray+QueueStack.h"

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

enum TunnellingSocketConfig
{
    kReconnectTaskRun        = 1 <<  0,
    kHeartBeatTaskRun        = 1 <<  1,
};

enum TunnellingServeState
{
    TunnellingServeReadyToRun = 0,
    TunnellingServeRunning,
    TunnellingServeReadyToStop,
    TunnellingServeStop,
};
typedef enum TunnellingServeState TunnellingServeState;


@interface BLGCDKNXTunnellingAsyncUdpSocket()
{
    uint16_t config;
    
    
    uint16_t clientBindPort;
    NSString *serverAddr;
    NSString *serverAddrPre;
    uint16_t serverPort;
    dispatch_queue_t tunnellingAsyncUdpdelegateQueue;
    dispatch_queue_t tunnellingSendQueueOperateQueue;
    
    
    
    long tunnellingSocketTag;
    unsigned int CID;
    unsigned char SC;
    
    TunnellingSocketError tunnellingConnectState;
    TunnellingSocketError heartBeatState;
    TunnellingServeState tunnellingServeState;
    TunnellingSocketError tunnellingRequestAckResponseState;
    
    
    
    BOOL connectionStateResponseTimeoutFlag;
    BOOL heartBeatTimeoutFlag;
    BOOL tunnellingRequestAckResponseTimeoutFlag;
    //BOOL needReconnect;
    
    NSTimer *connectionStateResponseTimeout; //10s
    NSTimer *tunnellingHeartBeatTimer;
    NSTimer *tunnellingRequestAckResponsetTimer; //1s
    
    NSUInteger connectionStateRequestRepeatCounter; //3
    NSUInteger tunnellingRequestRepeatCounter; //2
    
    GCDAsyncUdpSocket *tunnellingUdpSocket;
    
    NSOperationQueue *connectAndHeartBeatQueue;
    NSInvocationOperation *connectOperation;
    NSInvocationOperation *heartBeatOperation;
    
    //NSMutableDictionary *overallReceivedKnxDataDict;
    
    //NSString *connectAndHeartBeatQueueFinishNotification;
    
}
@property (nonatomic, strong) NSMutableArray *tunnellingSendQueue;

@end

@class BLGCDKNXAsyncUdpSendPacket;

@implementation BLGCDKNXTunnellingAsyncUdpSocket
@synthesize tunnellingSendQueue;
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

- (id) init
{
    self = [super init];
    
    if (self)
    {
        CID = 0;
        SC = 0;
        
        //connectAndHeartBeatQueueFinishNotification = @"BL.BLSmartPageViewDemo.connectAndHeartBeatQueueFinish";
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectAndHeartBeatQueueFinish) name:connectAndHeartBeatQueueFinishNotification object:nil];
        tunnellingServeState = TunnellingServeStop;
        
        tunnellingConnectState = TunnellingSocketConnectResponseNoConnectionError;
        connectionStateResponseTimeoutFlag = YES;
        heartBeatTimeoutFlag = YES;
        //needReconnect = YES;
        connectionStateRequestRepeatCounter = 3; //3
        tunnellingRequestRepeatCounter = 2; //2
        
        connectionStateResponseTimeout = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(connectionStateResponseTimeoutFired) userInfo:nil repeats:YES];
        //NSLog(@"setFireDate ....");
        //[connectionStateResponseTimeout setFireDate:[NSDate dateWithTimeIntervalSinceNow:10.0]];//stop
        //[connectionStateResponseTimeout setFireDate:[NSDate distantFuture]];//stop
        [self connectionStateResponseTimeoutTimerStart:NO];
        
        tunnellingHeartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(tunnellingHeartBeatTimerFired) userInfo:nil repeats:YES];
        [self tunnellingHeartBeatTimerStart:NO];
        
        tunnellingRequestAckResponsetTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tunnellingRequestAckResponseTimerFired) userInfo:nil repeats:YES];
        [self tunnellingRequestAckResponseTimerStart:NO];
        
        //tunnellingReconnectTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tunnellingReconnectTimerFired) userInfo:nil repeats:YES];
        //[self tunnellingReconnectTimerStart:NO];
        connectAndHeartBeatQueue = [[NSOperationQueue alloc]init];
        [connectAndHeartBeatQueue setMaxConcurrentOperationCount:1];
        
        tunnellingSendQueueOperateQueue = dispatch_queue_create(TunnellingSendQueueOperateQueue, NULL);
        
        tunnellingSendQueue = [[NSMutableArray alloc] init];
        [self addObserver:self forKeyPath:TunnellingSendQueueKeyPath options:0 context:nil];
    }
    
    return self;
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
    
//    NSString *hexStr=@"";
//    for(int i=0;i<[data length];i++)
//    {
//        NSString *newHexStr = [NSString stringWithFormat:@"%x",testByte[i]&0xff];///16进制数
//        if([newHexStr length]==1)
//            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
//        else
//            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
//    }
    
    if ([data length])
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
            if (tunnellingConnectState != TunnellingSocketNoError)
            {
                return;
            }
            if (testByte[6] == CID)
            {
                LogInfo(@"Disconnect  CID : %u", CID);  //CID
                [self tunnellingServeRestart];
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
                        LogInfo(@"Connect state  Response No Error");
                        heartBeatState = TunnellingSocketNoError;
                        break;
                    }
                    case TunnellingSocketConnectionStateResponseConnectionIdError:
                    {
                        LogInfo(@"Connect state  Response  Connection Id Error");
                        heartBeatState = TunnellingSocketConnectionStateResponseConnectionIdError;
                        break;
                    }
                    case TunnellingSocketConnectionStateResponseDataConnectionError:
                    {
                        LogInfo(@"Connect state  Response  Data Connection Error");
                        heartBeatState = TunnellingSocketConnectionStateResponseDataConnectionError;
                        break;
                    }
                    case TunnellingSocketConnectionStateResponseKnxConnectionError:
                    {
                        LogInfo(@"Connect state  Response  Knx Connection Error");
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
            
            Byte ackByte[10] = {0x06,0x10,0x04,0x21,0x00,0x0a,0x04,CID,testByte[8],0x00};  //ack
            
            NSMutableData *ackData = [[NSMutableData alloc] init];
            
            ackData = [NSMutableData dataWithBytes:ackByte length:sizeof(ackByte)];
            
            [self tunnellingUdpSocketSend:ackData];
            LogInfo(@"SENT (%i): Request ACK CID %u  SC %u", (int)tunnellingSocketTag, CID, testByte[8]);
            
            if (testByte[10] == 0x29)  //L_Data.ind
            {
                [self resortDataAndPostReceiveNotification:data];
            }
            
        }
        else if((testByte[0] == 0x06) && (testByte[1] == 0x10) && (testByte[2] == 0x04) && (testByte[3] == 0x21))//ack
        {
            if ((testByte[7] == CID)  && (tunnellingRequestAckResponseTimeoutFlag == NO) && (tunnellingRequestAckResponseState == TunnellingRequestAckResponseStateWait))  //
            {
                LogInfo(@"SEND SC %u   RECV (%i): ACK CID %u  SC %u  Status %u", SC, (int)tunnellingSocketTag, testByte[7], testByte[8], testByte[9]);
                if (testByte[8] == SC)
                {
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

}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    //sock = nil;
    LogInfo(@"udpSocketDidClose ....");
}

#pragma mark - GCDAsyncUdpSocketDelegate private method
- (void) resortDataAndPostReceiveNotification:(NSData *)data
{
    Byte *receivedBytes = (Byte *)[data bytes];
    
    if ([data length] < 21)
    {
        return;
    }
    
    if ((receivedBytes[19] == 0x00) && (receivedBytes[20]  == 0x00))  //group value read
    {
        return;
    }
    
    NSString *groupAddress = [[NSString alloc] initWithFormat:@"%d/%d/%d",(receivedBytes[16] >> 3), receivedBytes[16] & 0x07,receivedBytes[17]];
    NSString *value = nil;
    
    
    if (receivedBytes[18] == 1) //1Bit
    {
        value = [[NSString alloc] initWithFormat:@"%d",receivedBytes[20] & 0x01];
    }
    else if(receivedBytes[18] == 2) //1Byte
    {
        value = [[NSString alloc] initWithFormat:@"%d",receivedBytes[21]];
    }
    else if(receivedBytes[18] == 3) //2Byte
    {
        float floatValueM = (receivedBytes[21] & 0x07) << 8 | receivedBytes[22];
        float floatValueE = (receivedBytes[21] >> 3) & 0x0F;
        float tempValue = pow(2.0, floatValueE) * (floatValueM * 0.01);
        float tempValueInt = tempValue;
        value = [[NSString alloc] initWithFormat:@"%f",tempValueInt];
    }
    
    LogInfo(@"Receive Address : %@  Value : %@", groupAddress, value);
    dispatch_async([Utils GlobalBackgroundQueue],
                   ^{
                       [self.overallReceivedKnxDataDict setValue:value forKey:groupAddress];
                   });
    NSDictionary *eibBusDataDict = [NSDictionary dictionaryWithObjectsAndKeys:groupAddress, @"Address", value, @"Value",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BL.BLSmartPageViewDemo.RecvFromBus" object:self userInfo:eibBusDataDict];
    
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
    heartBeatTimeoutFlag = YES;
}

- (void)tunnellingRequestAckResponseTimerFired
{
    [self tunnellingRequestAckResponseTimerStart:NO];
    tunnellingRequestAckResponseTimeoutFlag = YES;
}

- (void) observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    //                           0           1           2           3           4           5           6           7           8           9
    unsigned char eibIntValue[72] = {0x00, 0x00, 0x00, 0x64, 0x08, 0x64, 0x01, 0x2C, 0x10, 0x64, 0x01, 0xF4, 0x02, 0x58, 0x02, 0xBC, 0x18, 0x64, 0x03, 0x84,\
        0x03, 0xE8, 0x04, 0x4C, 0x04, 0xB0, 0x05, 0x14, 0x05, 0x78, 0x05, 0xDC, 0x06, 0x40, 0x06, 0xA4, 0x07, 0x08, 0x07, 0x6C,\
        0x07, 0xD0, 0x0C, 0x1A, 0x0C, 0x4C, 0x0C, 0x7E, 0x0C, 0xB0, 0x0C, 0xE2, 0x0D, 0x14, 0x0D, 0x46, 0x0D, 0x78, 0x0D, 0xAA,\
        0x0D, 0xDC, 0x0E, 0x0E, 0x0E, 0x40, 0x0E, 0x72, 0x0E, 0xA4, 0x0E, 0xD6};
    NSData *eibIntValueData = [[NSData alloc]init];
    eibIntValueData = [NSData dataWithBytes:eibIntValue length:sizeof(eibIntValue)];
    
    
    if ([keyPath isEqual:TunnellingSendQueueKeyPath])
    {
        dispatch_async(tunnellingSendQueueOperateQueue,
                       ^{
                           while ([tunnellingSendQueue count])
                           {
                               Byte sendByte[23] = {0x06,0x10,0x04,0x20,0x00,0x15,0x04,CID,SC,0x00,0x11,0x00,0xbc,0xd0,0x00,0x00,0x18,0x00,0x01,0x00,0x00,0x00,0x00};
                               NSMutableData *data = [[NSMutableData alloc] init];
                               data = [NSMutableData dataWithBytes:sendByte length:21];

                               NSDictionary *sendData = [tunnellingSendQueue queuePop];
                               [NSThread sleepForTimeInterval:0.05];
                               //NSLog(@"PageView课程被改变了  count = %lu", (unsigned long)[tunnellingSendQueue count]);@"GroupAddress", valueLength, @"ValueLength", commangType, @"CommandType", value, @"Value"
                               LogInfo(@"GroupAddress = %@  Length = %@   CommandType = %@  Value = %@", [sendData objectForKey:@"GroupAddress"], [sendData objectForKey:@"ValueLength"],[sendData objectForKey:@"CommandType"],[sendData objectForKey:@"Value"]);
                               
                               if (tunnellingConnectState != TunnellingSocketNoError)
                               {
                                   continue;
                               }
                               
                               NSArray *groupAddressSplit = [[sendData objectForKey:@"GroupAddress"] componentsSeparatedByString:@"/"];
                               unsigned char mainMidAdd = ([[groupAddressSplit objectAtIndex:0] integerValue] << 3 ) | ([[groupAddressSplit objectAtIndex:1] integerValue] & 0x07);
                               [data replaceBytesInRange:NSMakeRange(16, 1) withBytes:&mainMidAdd];
                               unsigned char subAddress = [[groupAddressSplit objectAtIndex:2] integerValue];
                               [data replaceBytesInRange:NSMakeRange(17, 1) withBytes:&subAddress];
                               
                               
                               NSString *commandType = [sendData objectForKey:@"CommandType"];
                               NSString *valueLength = [sendData objectForKey:@"ValueLength"];
                               NSString *sendValue = [sendData objectForKey:@"Value"];
                               unsigned char value = 0;
                               unsigned char dataLength = 0;
                               if ([commandType isEqualToString:@"Write"])
                               {
                                   if ([valueLength isEqualToString:@"1Bit"])
                                   {
                                       value = 0x15;//package length
                                       [data replaceBytesInRange:NSMakeRange(5, 1) withBytes:&value];
                                       value = 1;//value length
                                       [data replaceBytesInRange:NSMakeRange(18, 1) withBytes:&value];
                                       value = 0x80 | ([sendValue integerValue] & 0x01);
                                       [data replaceBytesInRange:NSMakeRange(20, 1) withBytes:&value];
                                       dataLength = 21;
                                   }
                                   else if ([valueLength isEqualToString:@"1Byte"])
                                   {
                                       value = 0x16;//package length
                                       [data replaceBytesInRange:NSMakeRange(5, 1) withBytes:&value];
                                       value = 2;//value length
                                       [data replaceBytesInRange:NSMakeRange(18, 1) withBytes:&value];
                                       value = 0x80;
                                       [data replaceBytesInRange:NSMakeRange(20, 1) withBytes:&value];
                                       value = [sendValue integerValue];
                                       [data appendBytes:&value length:1];//21
                                       //[data replaceBytesInRange:NSMakeRange(21, 1) withBytes:&value];
                                       dataLength = 22;
                                   }
                                   else if ([valueLength isEqualToString:@"2Byte"])
                                   {
                                       if ([sendValue integerValue] < 0 || [sendValue integerValue] > 36)
                                       {
                                           return;
                                       }
                                       
                                       value = 0x17;//package length
                                       [data replaceBytesInRange:NSMakeRange(5, 1) withBytes:&value];
                                       value = 3;//value length
                                       [data replaceBytesInRange:NSMakeRange(18, 1) withBytes:&value];
                                       value = 0x80;
                                       [data replaceBytesInRange:NSMakeRange(20, 1) withBytes:&value];
                                       [eibIntValueData getBytes:&value range:NSMakeRange([sendValue integerValue] * 2, 1)];
                                       [data appendBytes:&value length:1];//21
                                       //[data replaceBytesInRange:NSMakeRange(21, 1) withBytes:&value];
                                       [eibIntValueData getBytes:&value range:NSMakeRange([sendValue integerValue] * 2 + 1, 1)];
                                       [data appendBytes:&value length:1];//22
                                       //[data replaceBytesInRange:NSMakeRange(22, 1) withBytes:&value];
                                       dataLength = 23;
                                   }
                                   
                               }
                               else if ([commandType isEqualToString:@"Read"])
                               {
                                   //if ([valueLength isEqualToString:@"1Bit"])
                                   {
                                       value = 0x15;//package length
                                       [data replaceBytesInRange:NSMakeRange(5, 1) withBytes:&value];
                                       value = 1;//value length
                                       [data replaceBytesInRange:NSMakeRange(18, 1) withBytes:&value];
//                                       value = 0x00 | ([sendValue integerValue] & 0x01);
//                                       [data replaceBytesInRange:NSMakeRange(20, 1) withBytes:&value];
                                       dataLength = 21;
                                   }
                               }
                               if (dataLength == 0)
                               {
                                   continue;
                               }
                               
                               tunnellingRequestRepeatCounter = 2;
                               while (tunnellingRequestRepeatCounter)
                               {
                                   tunnellingRequestRepeatCounter--;
                                   [self tunnellingUdpSocketSend:data];
                                   //LogInfo(@"SENT (%i): Request Repeat Counter %lu SC  %u", (int)tag, (unsigned long)tunnellingRequestRepeatCounter, SC);
                                   
                                   tunnellingRequestAckResponseTimeoutFlag = NO;
                                   tunnellingRequestAckResponseState = TunnellingRequestAckResponseStateWait;
                                   //[connectionStateResponseTimeout setFireDate:[NSDate distantPast]];//start
                                   [self tunnellingRequestAckResponseTimerStart:YES];//start 1.1 second later
                                   while ((tunnellingRequestAckResponseTimeoutFlag == NO) && (tunnellingRequestAckResponseState == TunnellingRequestAckResponseStateWait))
                                   {
                                       [NSThread sleepForTimeInterval:0.01];
                                   }
                                   [self tunnellingRequestAckResponseTimerStart:NO];//stop timer
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
                                       break;  //break while (tunnellingRequestRepeatCounter)
                                   }
                                   
                                   if (tunnellingRequestAckResponseTimeoutFlag == YES) //timeout
                                   {
                                       continue;
                                   }
                               }

                           }
                       });
    }
}

//- (void) connectAndHeartBeatQueueFinish
//{
//    //__typeof (self) __weak weakSelf = self;
//    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
//                   //^{
//                       [connectAndHeartBeatQueue waitUntilAllOperationsAreFinished];
//                       //connectAndHeartBeatQueue = nil;
//                       //connectAndHeartBeatQueue = [[NSOperationQueue alloc]init];
//                       //[connectAndHeartBeatQueue setMaxConcurrentOperationCount:1];
//                       if ((config & kReconnectTaskRun) && (config & kHeartBeatTaskRun))
//                       {
//                           LogInfo(@"startConnectAndHeatBeatTask Restart----");
//                           [self  startConnectAndHeatBeatTask];
//                           //[self performSelectorOnMainThread: @selector(startConnectAndHeatBeatTask) withObject:nil waitUntilDone: NO];
//                           //[weakSelf  startConnectAndHeatBeatTask];
//                       }
//                    //});
//}

//- (void) tunnellingReconnectTimerFired
//{
//    [self tunnellingReconnectTimerStart:NO];
//    dispatch_async([Utils GlobalBackgroundQueue],
//                   ^{
//                       [self connectToServer];
//                   });
//}

#pragma mark - private method
- (void) setTunnellingSocketWithClientBindToPort:(uint16_t)clientPort
                                 deviceIpAddress:(NSString *)serverIpAddr
                                    deviceIpPort:(uint16_t)serverIpPort
                                   delegateQueue:(dispatch_queue_t)dq
{
    clientBindPort = clientPort;
    if (serverAddr == nil)
    {
        serverAddrPre = serverIpAddr;
    }
    else
    {
        serverAddrPre = serverAddr;
    }
    serverAddr = serverIpAddr;
    serverPort = serverIpPort;
    tunnellingAsyncUdpdelegateQueue = dq;
}


- (void) startConnectAndHeatBeatTask
{
    connectOperation = nil;
    connectOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(connectToServer) object:nil];
    connectOperation.completionBlock = ^()
    {
        LogInfo(@"connectOperation finish----");
        if (tunnellingConnectState == TunnellingSocketNoError)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:TunnellingConnectSuccessNotification object:nil];
        }
    };
    heartBeatOperation = nil;
    heartBeatOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(heartBeatTask) object:nil];
    __typeof (self) __weak weakSelf = self;
    __typeof (connectAndHeartBeatQueue) __weak weakconnectAndHeartBeatQueue = connectAndHeartBeatQueue;
    heartBeatOperation.completionBlock = ^()
    {
        LogInfo(@"heartBeatOperation finish----");
        //[weakSelf performSelectorOnMainThread: @selector(doPostConnectAndHeartBeatQueueFinishNotificatin) withObject:nil waitUntilDone: NO];
        //__typeof (self) __weak weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
        ^{
        [weakconnectAndHeartBeatQueue waitUntilAllOperationsAreFinished];
        //connectAndHeartBeatQueue = nil;
        //connectAndHeartBeatQueue = [[NSOperationQueue alloc]init];
        //[connectAndHeartBeatQueue setMaxConcurrentOperationCount:1];
        if ((config & kReconnectTaskRun) && (config & kHeartBeatTaskRun))
        {
            LogInfo(@"startConnectAndHeatBeatTask Restart----");
            [weakSelf  startConnectAndHeatBeatTask];
            //[self performSelectorOnMainThread: @selector(startConnectAndHeatBeatTask) withObject:nil waitUntilDone: NO];
            //[weakSelf  startConnectAndHeatBeatTask];
        }
        });
    };

    [connectAndHeartBeatQueue addOperation:connectOperation];
    [connectAndHeartBeatQueue addOperation:heartBeatOperation];
}

- (BOOL) tunnellingServeStart
{
    if (tunnellingServeState != TunnellingServeStop)
    {
        LogInfo(@"#####Tunnelling Serve Start Error the Serve already run.....");
        return NO;
    }
    
    tunnellingServeState = TunnellingServeReadyToRun;
    if (tunnellingUdpSocket)
    {
        [tunnellingUdpSocket closeAfterSending];
        while (![tunnellingUdpSocket isClosed])
        {
            [NSThread sleepForTimeInterval:0.01];
        }
        tunnellingUdpSocket = nil;
    }
    
    
    
    tunnellingUdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:tunnellingAsyncUdpdelegateQueue];
    NSError *error = nil;
    if (![tunnellingUdpSocket bindToPort:clientBindPort error:&error])
    {
        LogInfo(@"#####Error binding: %@", error);
        tunnellingServeState = TunnellingServeStop;
        return NO;
    }
    
    LogInfo(@"#####Sucess binding port : %hu  %hu %hu", [tunnellingUdpSocket localPort], [tunnellingUdpSocket localPort_IPv4], [tunnellingUdpSocket localPort_IPv6]);
    clientBindPort = [tunnellingUdpSocket localPort];
    if (![tunnellingUdpSocket beginReceiving:&error])
    {
        LogInfo(@"####Error receiving: %@", error);
        tunnellingServeState = TunnellingServeStop;
        return NO;
    }
    
    config |= (kReconnectTaskRun | kHeartBeatTaskRun);
    
    [self  startConnectAndHeatBeatTask];
    
    tunnellingServeState = TunnellingServeRunning;
    
    return YES;
}

- (void) tunnellingServeStop
{
    if (tunnellingServeState == TunnellingServeStop)
    {
        return;
    }
    tunnellingServeState = TunnellingServeReadyToStop;
    [self disconnectServer];
    config &= ~(kReconnectTaskRun | kHeartBeatTaskRun);
    if (tunnellingUdpSocket)
    {
        [tunnellingUdpSocket closeAfterSending];
        while (![tunnellingUdpSocket isClosed])
        {
            [NSThread sleepForTimeInterval:0.01];
        }
        tunnellingUdpSocket = nil;
    }
    
    [connectAndHeartBeatQueue waitUntilAllOperationsAreFinished];
    tunnellingServeState = TunnellingServeStop;
}

- (void) tunnellingServeRestart
{
    if (tunnellingServeState == TunnellingServeReadyToStop)
    {
        while (true)
        {
            if (tunnellingServeState == TunnellingServeStop)
            {
                break;
            }
            [NSThread sleepForTimeInterval:0.01];
        }
    }
    else if(tunnellingServeState == TunnellingServeReadyToRun)
    {
        while (true)
        {
            if (tunnellingServeState == TunnellingServeRunning)
            {
                break;
            }
            [NSThread sleepForTimeInterval:0.01];
        }

    }
    
    
    if (tunnellingServeState == TunnellingServeRunning)
    {
        [self tunnellingServeStop];
        while (true)
        {
            if (tunnellingServeState == TunnellingServeStop)
            {
                break;
            }
            [NSThread sleepForTimeInterval:0.01];
        }
        [self tunnellingServeStart];
    }
    else if(tunnellingServeState == TunnellingServeStop)
    {
        [self tunnellingServeStart];
    }
    
}


- (void) connectToServer
{
    LogInfo(@"connectToServer----");
    Byte sendByte[26] = {0x06,0x10,0x02,0x05,0x00,0x1a,0x08,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x08,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x04,0x04,0x02,0x00};
    NSData *data = [[NSData alloc] initWithBytes:sendByte length:sizeof(sendByte)];
    
    
    while (config & kReconnectTaskRun)
    {
        if (!(config & kReconnectTaskRun))
        {
            return;
        }
        
        [tunnellingUdpSocket sendData:data toHost:serverAddr port:serverPort withTimeout:64 tag:tunnellingSocketTag++];
        LogInfo(@"SENT (%i): Connection State Request Counter", (int)tunnellingSocketTag);
        connectionStateResponseTimeoutFlag = NO;
        //[connectionStateResponseTimeout setFireDate:[NSDate date]];//start
        //[connectionStateResponseTimeout setFireDate:[NSDate dateWithTimeIntervalSinceNow:10.0]];//start 10 second later
        [self connectionStateResponseTimeoutTimerStart:YES];
        while ((tunnellingConnectState  == TunnellingSocketConnectResponseNoConnectionError) && (connectionStateResponseTimeoutFlag == NO))
        {
            if(config & kReconnectTaskRun)
            {
                [NSThread sleepForTimeInterval:0.01];
            }
            else
            {
                return;
            }
        }
        [self connectionStateResponseTimeoutTimerStart:NO];
        
        if (connectionStateResponseTimeoutFlag == YES) //connection timeout
        {
            LogInfo(@"connection timeout...");
            if (clientBindPort != [tunnellingUdpSocket localPort])
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                               ^{
                                   [self tunnellingServeRestart];
                               });
            }
            tunnellingConnectState = TunnellingSocketConnectRequestTimeoutError;
        }
        
        [self tunnellingConnectStateChanged];
        
        if (tunnellingConnectState == TunnellingSocketNoError)
        {
            return;
        }
        else
        {
            NSUInteger sleepCount = 250;
            while (sleepCount--)
            {
                if(config & kReconnectTaskRun)
                {
                    [NSThread sleepForTimeInterval:0.01];
                }
                else
                {
                    return;
                }
            }
        }
    }
}

- (void) heartBeatTask
{
    LogInfo(@"heartBeatTask----");
    
    Byte sendByte[16] = {0x06,0x10,0x02,0x07,0x00,0x10,CID,0x00,0x08,0x01,0x00,0x00,0x00,0x00,0x00,0x00}; //state request
    
    NSData *data = [[NSData alloc] initWithBytes:sendByte length:sizeof(sendByte)];
    
    while(connectionStateRequestRepeatCounter)
    {
        connectionStateRequestRepeatCounter--;
        if (!(config & kHeartBeatTaskRun))
        {
            return;
        }
        
        [tunnellingUdpSocket sendData:data toHost:serverAddr port:serverPort withTimeout:64 tag:tunnellingSocketTag++];
        LogInfo(@"SENT (%i): Connection State Request Counter %lu", (int)tunnellingSocketTag, (unsigned long)connectionStateRequestRepeatCounter);
        connectionStateResponseTimeoutFlag = NO;
        heartBeatState = TunnellingSocketConnectionStateResponseWait;
        [self connectionStateResponseTimeoutTimerStart:YES];
        while ((connectionStateResponseTimeoutFlag == NO) && (heartBeatState == TunnellingSocketConnectionStateResponseWait))
        {
            if (!(config & kHeartBeatTaskRun))
            {
                return;
            }
            [NSThread sleepForTimeInterval:0.01];
        }
        [self connectionStateResponseTimeoutTimerStart:NO];
        if (connectionStateResponseTimeoutFlag == YES)
        {
            [NSThread sleepForTimeInterval:0.01];
            continue;
        }
        
        //if (heartBeatState != TunnellingSocketConnectionStateResponseWait)
        //{
            switch (heartBeatState)
            {
                case TunnellingSocketNoError:
                {
                    connectionStateRequestRepeatCounter = 3;
                    heartBeatTimeoutFlag = NO;
                    [self tunnellingHeartBeatTimerStart:YES];
                    
                    while (heartBeatTimeoutFlag == NO)
                    {
                        if (!(config & kHeartBeatTaskRun))
                        {
                            return;
                        }
                        [NSThread sleepForTimeInterval:0.01];
                    }
                    continue;
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
            
//            if (heartBeatState == TunnellingSocketNoError)
//            {
//                break; //break while
//            }
            
        //}
        
    }
    
    if(connectionStateRequestRepeatCounter == 0) //heart beat no response or response error and try more than 3 times
    {
        LogInfo(@"heart beat error reset data ...");
        [self disconnectServer];
    }
}


- (void) disconnectServer
{
    Byte sendByte[16] = {0x06,0x10,0x02,0x09,0x00,0x10,CID,0x00,0x08,0x01,0x00,0x00,0x00,0x00,0x00,0x00};
    
    NSData *data = [[NSData alloc] initWithBytes:sendByte length:sizeof(sendByte)];
    
    
    connectionStateRequestRepeatCounter = 3;
    [self tunnellingHeartBeatTimerStart:NO]; //stop heart beat
    [self connectionStateResponseTimeoutTimerStart:NO];
    //[self tunnellingReconnectTimerStart:NO];
    //send disconnect and reset data
    if (tunnellingConnectState != TunnellingSocketConnectResponseNoConnectionError)
    {
        [tunnellingUdpSocket sendData:data toHost:serverAddrPre port:serverPort withTimeout:64 tag:tunnellingSocketTag++];
        LogInfo(@"SENT (%i): Disconnect CID %u", (int)tunnellingSocketTag, CID);
    }
    tunnellingConnectState = TunnellingSocketConnectResponseNoConnectionError;
    heartBeatState = TunnellingSocketNoError;
    //[self tunnellingConnectStateChanged];
}


- (void) tunnellingConnectStateChanged
{
    switch (tunnellingConnectState)
    {
        case TunnellingSocketNoError:
        {
            LogInfo(@"Connect Success...");
            //[self tunnellingHeartBeatTimerStart:YES];
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
            [self disconnectServer];
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
    
//    if (tunnellingConnectState == TunnellingSocketConnectResponseNoConnectionError)  //decide whether to start connect again
//    {
//        if (needReconnect == YES)
//        {
//            [self tunnellingReconnectTimerStart:YES];
//        }
//    }
}

- (void) tunnellingUdpSocketSend:(NSData *)data
{

    [tunnellingUdpSocket sendData:data toHost:serverAddrPre port:serverPort withTimeout:64 tag:tunnellingSocketTag++];
    //LogInfo(@"send sc %ld", [data, ])
}

- (void) tunnellingSendWithDestGroupAddress:(NSString *)destGroupAddress value:(NSInteger)value buttonName:(NSString *)name valueLength:(NSString *)valueLength commandType:(NSString *)commangType;
{
    //NSDictionary *transmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:destGroupAddress, @"GroupAddress", valueLength, @"ValueLength", commangType, @"CommandType", value, @"Value", nil];
    NSDictionary *transmitDataDict = [[NSDictionary alloc]initWithObjectsAndKeys:destGroupAddress, @"GroupAddress", valueLength, @"ValueLength", commangType, @"CommandType", [NSString stringWithFormat:@"%ld",(long)value], @"Value", nil];
    dispatch_async(tunnellingSendQueueOperateQueue,
                   ^{
                       //[tunnellingSendQueue queuePush:data];
                       [[self mutableArrayValueForKey:TunnellingSendQueueKeyPath] queuePush:transmitDataDict];
                   });
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

- (void) tunnellingRequestAckResponseTimerStart:(BOOL)start
{
    if (tunnellingRequestAckResponsetTimer == nil)
    {
        return;
    }
    
    if (start)
    {
        [tunnellingRequestAckResponsetTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];//start 10 second later
    }
    else
    {
        [tunnellingRequestAckResponsetTimer setFireDate:[NSDate distantFuture]];//stop
    }
}

- (NSString *) serverIpAddress
{
    return serverAddr;
}


- (NSString *)getIPAddress
{
    
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en1"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    LogInfo(@"local ip address = %@", address);
                    break;
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}

- (int)getPort
{
    NSString *address = nil;
    int port;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en1"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    port = ((struct sockaddr_in *)temp_addr->ifa_addr)->sin_port;
                    LogInfo(@"local ip address = %@", address);
                    LogInfo(@"local avaible port = %d", port);
                    break;
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return port;
}


#pragma mark - getters and setters
- (NSMutableDictionary *) overallReceivedKnxDataDict
{
    if (!_overallReceivedKnxDataDict)
    {
        _overallReceivedKnxDataDict =
        ({
            NSMutableDictionary * mutableDictionary = [[NSMutableDictionary alloc] init];
            mutableDictionary;
        });
    }
    return _overallReceivedKnxDataDict;
}
//- (void) tunnellingReconnectTimerStart:(BOOL)start
//{
//    if (tunnellingReconnectTimer == nil)
//    {
//        return;
//    }
//    
//    if (start)
//    {
//        [tunnellingReconnectTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];//start 10 second later
//    }
//    else
//    {
//        [tunnellingReconnectTimer setFireDate:[NSDate distantFuture]];//stop
//    }
//}

//- (void) doPostConnectAndHeartBeatQueueFinishNotificatin
//{
// [[NSNotificationCenter defaultCenter] postNotificationName:connectAndHeartBeatQueueFinishNotification object:nil];
//}

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