//
//  BLCurtain2ViewController.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/28.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLCurtain2ViewController : UIViewController
+ (instancetype)sharedInstance;
@property (strong, nonatomic) IBOutlet UISlider *yarnCurtainSliderOutlet;
@property (strong, nonatomic) IBOutlet UISlider *clothCurtainSliderOutlet;
@end
