//
//  ViewControllerContainer.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/22.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLHeatingViewController.h"
#import "BLDimmingViewController.h"
#import "BLCurtainViewController.h"

@interface ViewControllerContainer : NSObject
+ (instancetype)sharedInstance;
//- (BLHeatingViewController *)heatingViewController;
- (BLHeatingViewController *) heatingViewController;
- (BLDimmingViewController *) dimmingViewController;
- (BLCurtainViewController *) curtainViewController;
@end
