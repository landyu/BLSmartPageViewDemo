//
//  BLCurtainViewController.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/23.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLCurtainViewController : UIViewController

+ (instancetype)sharedInstance;

@property (strong, nonatomic) IBOutlet UISlider *curtainSliderOutlet;
@end
