//
//  TimmingAddViewController.h
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/12/8.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Timming.h"


@interface TimmingAddViewController : UIViewController
@property(nonatomic,assign)id delegate;
@end




@protocol TimmingAddProtocol <NSObject>
@optional
-(void)timmingAddItem:(TimmingPacket *)timmingItem;

@end