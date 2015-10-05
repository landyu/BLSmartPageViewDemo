//
//  APPChildViewController.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/8/7.
//  Copyright (c) 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface APPChildViewController : UIViewController<AVAudioPlayerDelegate>
{

}

//- (void)addChildViewController:(UIViewController *)childController;

@property (assign, nonatomic) NSInteger index;
@property (copy, nonatomic) NSString* nibName;
@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, nonatomic) id pageControllerDataSource;
//- (void)switchButtonPressd:(BLUISwitch *)sender;


@end
