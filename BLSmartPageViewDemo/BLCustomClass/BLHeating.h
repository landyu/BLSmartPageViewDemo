//
//  BLHeating.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/24.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLHeating : NSObject
@property (readwrite) float settingEnvironmentTemperature;

+ (instancetype)sharedInstance;
- (void)updateItemsDict:(NSDictionary *)dimmingPropertyDict;
- (void)heatingOnOffToChangeWithState:(BOOL)isOn;
- (void)heatingSettingEnvironmentTemperatureToChangeWithValue:(float)value;
- (BOOL)heatingOnOffStatusUpdateWithValue:(NSInteger)value;
- (void)setHeatingPanelViewFromOldData;
- (void)readHeatingPanelStatus;
@end
