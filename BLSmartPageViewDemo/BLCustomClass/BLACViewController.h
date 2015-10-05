//
//  BLACViewController.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/9/2.
//  Copyright (c) 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLACViewController : UIViewController

- (void) initACPropertyWithDictionary:(NSMutableDictionary *)acPropertyDict buttonName:(NSString *)acButtonName;
- (BOOL)acOnOffButtonStatusUpdateWithValue:(NSInteger)value;
- (void)acWindSpeedButtonStatusUpdateWithValue:(NSInteger)value;
- (void)acModeButtonStatusUpdateWithValue:(NSInteger)value;
- (void)acEnviromentTemperatureUpdateWithValue:(NSInteger)value;
- (void)acSettingTemperatureUpdateWithValue:(NSInteger)value;

@property (strong, nonatomic) IBOutlet UILabel *acOnOffLabel;
@property (strong, nonatomic) IBOutlet UIButton *acOnOffButtonOutlet;

@property (strong, nonatomic) IBOutlet UIButton *acWindSpeedHighButton;
@property (strong, nonatomic) IBOutlet UIButton *acWindSpeedMidButton;
@property (strong, nonatomic) IBOutlet UIButton *acWindSpeedLowButton;
@property (strong, nonatomic) IBOutlet UIButton *acWindSpeedAutoButton;
@property (strong, nonatomic) IBOutlet UILabel *acWindSpeedLabel;

@property (strong, nonatomic) IBOutlet UIButton *acSettingTemperatureUpButton;
@property (strong, nonatomic) IBOutlet UIButton *acSettingTemperatureDownButton;
@property (strong, nonatomic) IBOutlet UILabel *acSettingTemperature;

@property (strong, nonatomic) IBOutlet UIButton *acModeCoolButton;
@property (strong, nonatomic) IBOutlet UIButton *acModHeatButton;
@property (strong, nonatomic) IBOutlet UIButton *acModeVentButton;
@property (strong, nonatomic) IBOutlet UIButton *acModDesiccationButton;
@property (strong, nonatomic) IBOutlet UILabel *acModeLabel;




- (IBAction)acOnOffButton:(UIButton *)sender;
- (IBAction)acWindSpeedButton:(UIButton *)sender;
- (IBAction)acModeButton:(UIButton *)sender;
- (IBAction)acSettingTemperatureDownButton:(UIButton *)sender;
- (IBAction)acSettingTemperatureUpButton:(UIButton *)sender;



@end
