//
//  BLKNXNetworkGateEMIExtend.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/31.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLKNXNetworkGateEMIExtend : NSObject
- (NSMutableData *)setTimmingItemWithChannelID:(unsigned char)CID squenceCount:(unsigned char)SC timmingItem:(NSDictionary *)timmingItem;
- (NSMutableData *)getAllTimmingItemsWithChannelID:(unsigned char)CID squenceCount:(unsigned char)SC;
- (NSMutableData *)getTimmingItemsTotalCountWithChannelID:(unsigned char)CID squenceCount:(unsigned char)SC;
- (NSMutableData *)deleteTimmingItemWithChannelID:(unsigned char)CID squenceCount:(unsigned char)SC timmingItem:(NSDictionary *)timmingItem;
- (void)postTimmingItemsGetAllNotificationWithBytes:(NSData *)data;
- (void)postTimmingItemsTotalCountNotificationWithCount:(NSUInteger)count;
@end
