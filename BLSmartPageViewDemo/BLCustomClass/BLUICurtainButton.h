//
//  BLUICurtainButton.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/9/6.
//  Copyright (c) 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLCurtainViewController.h"

@interface BLUICurtainButton : UIButton

@property (nonatomic, copy)NSString *objName;
@property  (nonatomic, retain)BLCurtainViewController * curtainViewController;

@end
