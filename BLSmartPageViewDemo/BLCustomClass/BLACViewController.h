//
//  BLACViewController.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/25.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLACViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *acOnOffButtonOutlet;

@property (strong, nonatomic) IBOutlet UIButton *acWindSpeedHighButtonOutlet;
@property (strong, nonatomic) IBOutlet UIButton *acWindSpeedMidButtonOutlet;
@property (strong, nonatomic) IBOutlet UIButton *acWindSpeedLowButtonOutlet;
@property (strong, nonatomic) IBOutlet UIButton *acWindSpeedAutoButtonOutlet;

@property (strong, nonatomic) IBOutlet UIButton *acModeCoolingButtonOutlet;
@property (strong, nonatomic) IBOutlet UIButton *acModeHeatingButtonOutlet;
@property (strong, nonatomic) IBOutlet UIButton *acModeDehumidificationButtonOutlet;
@property (strong, nonatomic) IBOutlet UIButton *acModeVentingButtonOutlet;

@property (strong, nonatomic) IBOutlet UILabel *acOnOffLabel;
@property (strong, nonatomic) IBOutlet UILabel *acWindSpeedLabel;
@property (strong, nonatomic) IBOutlet UILabel *acWindSpeedIconLabel;
@property (strong, nonatomic) IBOutlet UILabel *acModeLabel;
@property (strong, nonatomic) IBOutlet UILabel *acModeIconLabel;
@property (strong, nonatomic) IBOutlet UILabel *acSettingTempratureLabel;

+ (instancetype)sharedInstance;
@end
