//
//  BLCurtainViewController.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/9/6.
//  Copyright (c) 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLCurtainViewController : UIViewController

- (void) initCurtainPropertyWithDictionary:(NSMutableDictionary *)curtainPropertyDict buttonName:(NSString *)curtainButtonName;


@property (strong, nonatomic) IBOutlet UIButton *yarnCurtainOpenButton;
@property (strong, nonatomic) IBOutlet UIButton *yarnCurtainCloseButton;
@property (strong, nonatomic) IBOutlet UISlider *yarnCurtainSlider;
- (IBAction)yarnCurtainOpenButtonPressed:(UIButton *)sender;
- (IBAction)yarnCurtainCloseButtonPressed:(UIButton *)sender;
- (IBAction)yarnCurtainSliderValueChanged:(UISlider *)sender;
- (IBAction)yarnCurtainStopButton:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UIButton *clothCurtainOpenButton;
@property (strong, nonatomic) IBOutlet UIButton *clothCurtainCloseButton;
@property (strong, nonatomic) IBOutlet UISlider *clothCurtainSlider;
- (IBAction)clothCurtainOpenButtonPressed:(UIButton *)sender;
- (IBAction)clothCurtainCloseButtonPressed:(UIButton *)sender;
- (IBAction)clothCurtainSliderValueChanged:(UISlider *)sender;
- (IBAction)clothCurtainStopButton:(UIButton *)sender;


@end
