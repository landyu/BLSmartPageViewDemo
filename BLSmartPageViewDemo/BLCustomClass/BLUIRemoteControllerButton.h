//
//  BLUIRemoteControllerButton.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/28.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLUIRemoteControllerButton : UIButton
@property (nonatomic, copy)NSString *objName;
@property (nonatomic, retain)NSMutableDictionary *remoteControllerPropertyDict;
@end
