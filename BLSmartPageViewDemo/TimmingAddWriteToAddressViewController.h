//
//  TimmingAddWriteToAddressViewController.h
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/12/9.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimmingAddWriteToAddressViewController : UIViewController
@property(nonatomic,assign)id delegate;
- (id)initWithWriteToAddress:(NSString *)address;
@end

@protocol WriteToAddressProtocol <NSObject>
@optional
-(void)setWriteToAddress:(NSString *)address;

@end