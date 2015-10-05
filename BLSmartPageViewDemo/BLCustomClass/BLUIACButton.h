//
//  BLUIACButton.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/9/2.
//  Copyright (c) 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLACViewController.h"
#import "APPChildViewController.h"

@interface BLUIACButton : UIButton

@property (nonatomic, copy)NSString *objName;
@property (nonatomic, retain)NSMutableDictionary *acPropertyMutableDict;
@property (nonatomic, retain)BLACViewController *acViewController;
@property (strong, nonatomic)UILabel *acEnviromentTemperatureLabel;


- (void)addEnviromentTemperatureLabelWithParentController:(APPChildViewController *)parentController;

@end
