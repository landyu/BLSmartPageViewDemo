//
//  TimmingAddSendValueViewController.h
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/12/9.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimmingAddSendValueViewController : UIViewController
@property(nonatomic,assign)id delegate;
- (id)initWithSendValue:(NSString *)value;
@end

@protocol SendValueProtocol <NSObject>
@optional
-(void)setSendValue:(NSString *)value;

@end