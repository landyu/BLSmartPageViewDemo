//
//  Timming.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 16/1/7.
//  Copyright © 2016年 Landyu. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface TimmingPacket : NSObject<NSCoding>
{
@public
    NSDate *timmingDate;
    NSDictionary *timmingRepeat;
    NSString *timmingLabelName;
    NSString *timmingWriteToAddress;
    NSString *timmingValueType;
    NSString *timmingSendValue;
    BOOL timmingEnable;
}
@end


typedef void (^GetTimmingItemsCompleteBlock) (BOOL isNoError);

@interface Timming : NSObject
@property (weak) id delegate;
- (void)getTimmingItemsWithCompletion:(GetTimmingItemsCompleteBlock)completion;
- (TimmingPacket *)getTimmingItemWithIndex:(NSUInteger)index;
+ (NSDictionary *) assembleToDictionaryWithTimmingPacket:(TimmingPacket *)data;

@end

@protocol TimmingDelegate <NSObject>

- (void)timmingItemsAllGotWithItems:(NSArray *)items;

@end
