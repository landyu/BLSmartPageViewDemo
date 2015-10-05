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
+ (instancetype)sharedInstance;
- (void) setTunnellingSocketWithClientBindToPort:(uint16_t)clientPort
                          deviceIpAddress:(NSString *)serverIpAddr
                             deviceIpPort:(uint16_t)serverIpPort
                            delegateQueue:(dispatch_queue_t)dq;
- (void) tunnellingServeStart;
- (void) tunnellingServeStop;
@end
