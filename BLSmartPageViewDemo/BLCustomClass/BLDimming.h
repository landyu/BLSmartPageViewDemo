//
//  BLDimming.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/23.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLDimming : NSObject

+ (instancetype)sharedInstance;
- (void)updateItemsDict:(NSDictionary *)dimmingPropertyDict;
- (void)dimmingValueChangedWithValue:(float)value;
- (void)dimmingOnOffChangedWithState:(BOOL)isOn;

- (void)setDimmingPanelViewFromOldData;
- (void)readDimmingPanelStatus;
@end
