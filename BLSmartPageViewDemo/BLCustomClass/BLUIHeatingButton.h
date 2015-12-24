//
//  BLUIHeatingButton.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/22.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APPChildViewController.h"

@interface BLUIHeatingButton : UIButton

@property (nonatomic, copy)NSString *objName;
@property (nonatomic, retain)NSDictionary *heatingPropertyDict;
//@property (nonatomic, retain)BLHeatingViewController *heatingViewController;
@property (strong, nonatomic)UILabel *heatingEnviromentTemperatureLabel;

- (void)addEnviromentTemperatureLabelWithParentController:(APPChildViewController *)parentController;

@end
