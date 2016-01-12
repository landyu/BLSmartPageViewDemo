//
//  TimmingAddLabelViewController.h
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/12/9.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimmingAddLabelViewController : UIViewController
@property(nonatomic,assign)id delegate;

- (id)initWithLabelName:(NSString *)labelName;
@end


@protocol SenddataProtocol <NSObject>
@optional
-(void)setLabelName:(NSString *)labelName; //I am thinking my data is NSArray, you can use another object for store your information.

@end