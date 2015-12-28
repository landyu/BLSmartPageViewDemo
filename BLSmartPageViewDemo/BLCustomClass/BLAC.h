//
//  BLAC.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/25.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLAC : NSObject
@property (readwrite) float settingEnvironmentTemperature;

- (void) setACPanelViewFromOldData;
- (void) readACPanelStatus;
- (void) acOnOffToChangeWithState:(BOOL)isOn;
- (void) acWindSpeedToChangeWithButtonName:(NSString *)name;
- (void) acModeToChangeWithButtonName:(NSString *)name;
- (void) acSettingEnvironmentTemperatureToChangeWithValue:(float)value;
- (void)updateItemsDict:(NSDictionary *)dimmingPropertyDict;
+ (instancetype)sharedInstance;
@end
