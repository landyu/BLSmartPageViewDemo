//
//  BLGCDKNXAsyncUdpSocket.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/9/28.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLGCDKNXTunnellingAsyncUdpSocket : NSObject
@property (nonatomic, weak) id delegate;
@property (strong, nonatomic) NSMutableDictionary *overallReceivedKnxDataDict;
+ (instancetype)sharedInstance;
- (void) setTunnellingSocketWithClientBindToPort:(uint16_t)clientPort
                          deviceIpAddress:(NSString *)serverIpAddr
                             deviceIpPort:(uint16_t)serverIpPort
                            delegateQueue:(dispatch_queue_t)dq;
- (BOOL) tunnellingServeStart;
- (void) tunnellingServeStop;
- (void) tunnellingServeRestart;
- (NSString *) serverIpAddress;
- (void) tunnellingSendWithDestGroupAddress:(NSString *)destGroupAddress value:(NSInteger)value buttonName:(NSString *)name valueLength:(NSString *)valueLength commandType:(NSString *)commangType;
//- (NSMutableDictionary *)getOverallReceivedKnxDataDict;
@end
