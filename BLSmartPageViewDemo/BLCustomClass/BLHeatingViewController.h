//
//  BLHeatingViewController.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/22.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLHeatingViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *heatingOnOffLabel;
@property (strong, nonatomic)  IBOutlet UIButton *heatingOnOffButtonOutlet;
@property (strong, nonatomic)  IBOutlet UILabel *heatingSettingTemperatureLabel;
+ (instancetype)sharedInstance;
@end