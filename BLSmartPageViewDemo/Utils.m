//
//  Utils.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/8/30.
//  Copyright (c) 2015年 Landyu. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+(dispatch_queue_t) GlobalMainQueue
{
    return dispatch_get_main_queue();
}

+(dispatch_queue_t) GlobalUserInteractiveQueue
{
    return dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0);
}

+(dispatch_queue_t) GlobalUserInitiatedQueue
{
    return dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0);  //DISPATCH_QUEUE_PRIORITY_HIGH    DISPATCH_QUEUE_PRIORITY_DEFAULT
}

+(dispatch_queue_t) GlobalUtilityQueue
{
    return dispatch_get_global_queue(QOS_CLASS_UTILITY, 0);  //DISPATCH_QUEUE_PRIORITY_LOW
}

+(dispatch_queue_t) GlobalBackgroundQueue
{
    return dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0); //DISPATCH_QUEUE_PRIORITY_BACKGROUND
}

@end
