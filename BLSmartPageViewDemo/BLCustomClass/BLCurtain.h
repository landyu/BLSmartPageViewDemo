//
//  BLCurtain.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/23.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLCurtain : NSObject
@property (strong, nonatomic) NSMutableDictionary *overallRecevedKnxDataDict;
- (void)updateItemsDict:(NSDictionary *)curtainPropertyDict;
- (void)curtainPositionChangedWithValue:(float)value;
- (void)curtainDidOpen;
- (void)curtainDidClose;
- (void)curtainDidStop;
+ (instancetype)sharedInstance;
@end
