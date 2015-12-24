//
//  BLDimmingViewController.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/23.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLDimmingViewController : UIViewController
//@property (weak) id dimmingModeDelegate;
+ (instancetype)sharedInstance;

@property (strong, nonatomic) IBOutlet UIButton *dimmingOnOffButtonOutlet;
@property (strong, nonatomic) IBOutlet UISlider *dimmingSliderOutlet;
@end


//@protocol HeatingViewDelegate
//@optional
//- (void)dimmingValueChangedWithValue:(float)value;
//- (void)dimmingOnOffChangedWithState:(BOOL)isSelected;
//@end