//
//  TimmingAddRepeatViewController.h
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/12/9.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimmingAddRepeatViewController : UIViewController
@property(nonatomic,assign)id delegate;
- (id)initWithRepeatInfo:(NSDictionary *)info;
@end

@protocol RepeatProtocol <NSObject>
@optional
-(void)setRepeatDict:(NSDictionary *)data;

@end