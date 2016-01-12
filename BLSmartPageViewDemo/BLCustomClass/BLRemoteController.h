//
//  BLRemoteController.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/28.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BLRemoteController : NSObject
+ (instancetype)sharedInstance;
- (void)updateItemsDict:(NSDictionary *)dict;
//- (void)addRemoteControllerButtonToScrollView:(UIScrollView *)scrollView;
@property (strong, nonatomic)NSDictionary *remoteControllerPropertyDict;
@end
