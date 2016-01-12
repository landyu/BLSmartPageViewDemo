//
//  TimmingAddValueTypeViewController.h
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/12/9.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimmingAddValueTypeViewController : UIViewController
@property(nonatomic,assign)id delegate;
- (id)initWithValueType:(NSString *)type;
@end


@protocol ValueTypeProtocol <NSObject>
@optional
-(void)setValueType:(NSString *)type;

@end