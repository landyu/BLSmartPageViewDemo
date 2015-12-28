//
//  BLCurtain2.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/28.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLCurtain2 : NSObject
- (void)updateItemsDict:(NSDictionary *)dict;

- (void)yarnCurtainPositionToChangeWithValue:(float)value;
- (void)yarnCurtainToOpen;
- (void)yarnCurtainToClose;
- (void)yarnCurtainToStop;

- (void)clothCurtainPositionToChangeWithValue:(float)value;
- (void)clothCurtainToOpen;
- (void)clothCurtainToClose;
- (void)clothCurtainToStop;

- (void)allCurtainToOpen;
- (void)allCurtainToClose;
- (void)allCurtainToStop;

+ (instancetype)sharedInstance;
- (void)setCurtain2PanelViewFromOldData;
- (void)readCurtain2PanelStatus;
@end
