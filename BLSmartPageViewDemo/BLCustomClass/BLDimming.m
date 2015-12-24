//
//  BLDimming.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/23.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLDimming.h"
#import "BLDimmingViewController.h"
#define dimmingViewControllerSharedInstance  [BLDimmingViewController sharedInstance]
@interface BLDimming()
{
    NSDictionary *dimmingPropertyDict;
    //BLDimmingViewController *dimmingViewControllerSharedInstance;
}
@end

@implementation BLDimming
/*
 entire app has only one BLDimming Class, s every diffent dimming buttons pressed
 with the same BLDimming Class, so diffent buttons should use - (void)updateItemsDict:(NSDictionary *)dict to
 up date the dimming item imformation.
 */



+ (instancetype)sharedInstance
{
    // 1
    static BLDimming *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[BLDimming alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (void)updateItemsDict:(NSDictionary *)dict
{
    dimmingPropertyDict = dict;
}

- (void)dimmingValueChangedWithValue:(float)value
{
    
}

- (void)dimmingOnOffChangedWithState:(BOOL)isSelected
{
    
}
@end
