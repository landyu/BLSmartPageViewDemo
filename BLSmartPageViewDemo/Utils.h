//
//  Utils.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/8/30.
//  Copyright (c) 2015年 Landyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject
+(dispatch_queue_t) GlobalMainQueue;
+(dispatch_queue_t) GlobalUserInteractiveQueue;
+(dispatch_queue_t) GlobalUserInitiatedQueue;
+(dispatch_queue_t) GlobalUtilityQueue;
+(dispatch_queue_t) GlobalBackgroundQueue;
@end
