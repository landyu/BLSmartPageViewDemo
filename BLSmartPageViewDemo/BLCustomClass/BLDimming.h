//
//  BLDimming.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/23.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLDimming : NSObject
@property (strong, nonatomic) NSMutableDictionary *overallRecevedKnxDataDict;
- (void)updateItemsDict:(NSDictionary *)dimmingPropertyDict;
- (void)dimmingValueChangedWithValue:(float)value;
- (void)dimmingOnOffChangedWithState:(BOOL)isSelected;
+ (instancetype)sharedInstance;
@end


@protocol DimmingProcessDataDelegate
@optional
- (void) blDimmingSendWithDestGroupAddress:(NSString *)destGroupAddress value:(NSInteger)value buttonName:(NSString *)name valueLength:(NSString *)valueLength commandType:(NSString *)commangType;
- (void) blDimmingInitReadWithDestGroupAddress:(NSString *)destGroupAddress value:(NSInteger)value buttonName:(NSString *)name valueLength:(NSString *)valueLength;
@end