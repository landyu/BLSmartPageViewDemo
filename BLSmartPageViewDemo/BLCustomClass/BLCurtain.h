//
//  BLCurtain.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/23.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLCurtain : NSObject
- (void)updateItemsDict:(NSDictionary *)curtainPropertyDict;
- (void)curtainPositionToChangeWithValue:(float)value;
- (void)curtainToOpen;
- (void)curtainToClose;
- (void)curtainToStop;
+ (instancetype)sharedInstance;
- (void)setCurtainPanelViewFromOldData;
- (void)readCurtainPanelStatus;
@end
