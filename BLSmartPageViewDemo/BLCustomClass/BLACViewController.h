//
//  BLACViewController.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/9/2.
//  Copyright (c) 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLACViewController : UIViewController
{
    
}


- (void) initACPropertyWithDictionary:(NSMutableDictionary *)acPropertyDict buttonName:(NSString *)acButtonName;
- (void)initReadACPanelWidgetStatus;
- (BOOL)acOnOffButtonStatusUpdateWithValue:(NSInteger)value;
- (void)acWindSpeedButtonStatusUpdateWithValue:(NSInteger)value;
- (void)acModeButtonStatusUpdateWithValue:(NSInteger)value;
- (void)acEnviromentTemperatureUpdateWithValue:(NSInteger)value;
- (void)acSettingTemperatureUpdateWithValue:(NSInteger)value;


@property (weak) id delegate;
@property (strong, nonatomic) NSMutableDictionary *overallRecevedKnxDataDict;

//@property (strong, nonatomic) IBOutlet UILabel *acOnOffLabel;
//@property (strong, nonatomic) IBOutlet UIButton *acOnOffButtonOutlet;
//
//@property (strong, nonatomic) IBOutlet UIButton *acWindSpeedHighButton;
//@property (strong, nonatomic) IBOutlet UIButton *acWindSpeedMidButton;
//@property (strong, nonatomic) IBOutlet UIButton *acWindSpeedLowButton;
//@property (strong, nonatomic) IBOutlet UIButton *acWindSpeedAutoButton;
//@property (strong, nonatomic) IBOutlet UILabel *acWindSpeedLabel;
//
//@property (strong, nonatomic) IBOutlet UIButton *acSettingTemperatureUpButton;
//@property (strong, nonatomic) IBOutlet UIButton *acSettingTemperatureDownButton;
//@property (strong, nonatomic) IBOutlet UILabel *acSettingTemperature;
//
//@property (strong, nonatomic) IBOutlet UIButton *acModeCoolButton;
//@property (strong, nonatomic) IBOutlet UIButton *acModHeatButton;
//@property (strong, nonatomic) IBOutlet UIButton *acModeVentButton;
//@property (strong, nonatomic) IBOutlet UIButton *acModDesiccationButton;
//@property (strong, nonatomic) IBOutlet UILabel *acModeLabel;


@property (strong, nonatomic)  UILabel *acOnOffLabel;
@property (strong, nonatomic)  UIButton *acOnOffButtonOutlet;

@property (strong, nonatomic)  UIButton *acWindSpeedHighButton;
@property (strong, nonatomic)  UIButton *acWindSpeedMidButton;
@property (strong, nonatomic)  UIButton *acWindSpeedLowButton;
@property (strong, nonatomic)  UIButton *acWindSpeedAutoButton;
@property (strong, nonatomic)  UILabel *acWindSpeedLabel;

@property (strong, nonatomic)  UIButton *acSettingTemperatureUpButton;
@property (strong, nonatomic)  UIButton *acSettingTemperatureDownButton;
@property (strong, nonatomic)  UILabel *acSettingTemperature;

@property (strong, nonatomic)  UIButton *acModeCoolButton;
@property (strong, nonatomic)  UIButton *acModHeatButton;
@property (strong, nonatomic)  UIButton *acModeVentButton;
@property (strong, nonatomic)  UIButton *acModDesiccationButton;
@property (strong, nonatomic)  UILabel *acModeLabel;




- (IBAction)acOnOffButton:(UIButton *)sender;
- (IBAction)acWindSpeedButton:(UIButton *)sender;
- (IBAction)acModeButton:(UIButton *)sender;
- (IBAction)acSettingTemperatureDownButton:(UIButton *)sender;
- (IBAction)acSettingTemperatureUpButton:(UIButton *)sender;

- (void) initACPanelView;


@end

@protocol ACProcessDataDelegate
@optional
- (void) blACSendWithDestGroupAddress:(NSString *)destGroupAddress value:(NSInteger)value buttonName:(NSString *)name valueLength:(NSString *)valueLength commandType:(NSString *)commangType;
- (void) blACInitReadWithDestGroupAddress:(NSString *)destGroupAddress value:(NSInteger)value buttonName:(NSString *)name valueLength:(NSString *)valueLength;
@end