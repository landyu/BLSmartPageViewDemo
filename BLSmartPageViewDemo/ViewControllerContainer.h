//
//  ViewControllerContainer.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/22.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLACViewController.h"
#import "BLHeatingViewController.h"
#import "BLDimmingViewController.h"
#import "BLCurtainViewController.h"
#import "BLCurtain2ViewController.h"

@interface ViewControllerContainer : NSObject
+ (instancetype)sharedInstance;
- (BLACViewController *)acViewController;
- (BLHeatingViewController *) heatingViewController;
- (BLDimmingViewController *) dimmingViewController;
- (BLCurtainViewController *) curtainViewController;
- (BLCurtain2ViewController *) curtain2ViewController;
@end
