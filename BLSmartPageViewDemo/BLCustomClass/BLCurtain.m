//
//  BLCurtain.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/23.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLCurtain.h"
#import "BLCurtainViewController.h"
#define dimmingViewControllerSharedInstance [BLDimmingViewController sharedInstance]
@interface BLCurtain()
{
    NSDictionary *dimmingPropertyDict;
    //BLDimmingViewController *dimmingViewControllerSharedInstance;
}
@end

@implementation BLCurtain
+ (instancetype)sharedInstance
{
    // 1
    static BLCurtain *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[BLCurtain alloc] init];
    });
    return _sharedInstance;
}

- (void)updateItemsDict:(NSDictionary *)dict
{
    dimmingPropertyDict = dict;
}

- (void)curtainPositionChangedWithValue:(float)value
{
    
}

- (void)curtainDidOpen
{
    
}

- (void)curtainDidClose
{
    
}

- (void)curtainDidStop
{
    
}
@end
