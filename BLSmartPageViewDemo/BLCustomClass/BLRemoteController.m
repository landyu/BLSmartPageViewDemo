//
//  BLRemoteController.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/28.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLRemoteController.h"
@interface BLRemoteController()
{
}
@end

@implementation BLRemoteController
+ (instancetype)sharedInstance
{
    // 1
    static BLRemoteController *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[BLRemoteController alloc] init];
    });
    return _sharedInstance;
}

- (void)updateItemsDict:(NSDictionary *)dict
{
    _remoteControllerPropertyDict = dict;
}

//- (void)addRemoteControllerButtonToScrollView:(UIScrollView *)scrollView
//{
//    
//}
@end
