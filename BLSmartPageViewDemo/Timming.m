//
//  Timming.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 16/1/7.
//  Copyright © 2016年 Landyu. All rights reserved.
//

#import "Timming.h"
#import "KNXCommandType.h"
#import "GlobalNotification.h"
#import "BLGCDKNXTunnellingAsyncUdpSocket.h"

typedef NS_ENUM(NSInteger, KNXTimmingError)
{
    //以下是枚举成员
    KNXTimmingGotTotalCountNoAction = 0,
    KNXTimmingGotTotalCountNoError,
    KNXTimmingGotTotalCountError,
    KNXTimmingGotTotalCountTimeoutError,
    
    KNXTimmingGotTotalItemsNoAction,
    KNXTimmingGotTotalItemsNoError,
    KNXTimmingGotTotalItemsError,
    KNXTimmingGotTotalItemsTimeoutError
};

@implementation TimmingPacket
#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)encode
{
    [encode encodeObject:self->timmingDate    forKey:@"ktTimmingDate"];
    [encode encodeObject:self->timmingRepeat    forKey:@"ktTimmingRepeat"];
    [encode encodeObject:self->timmingLabelName    forKey:@"kTimmingLabelName"];
    [encode encodeObject:self->timmingWriteToAddress    forKey:@"kTimmingWriteToAddress"];
    [encode encodeObject:self->timmingValueType    forKey:@"kTimmingValueType"];
    [encode encodeObject:self->timmingSendValue    forKey:@"kTimmingSendValue"];
    [encode encodeBool:self->timmingEnable    forKey:@"kTimmingEnable"];
    
}
- (nullable instancetype)initWithCoder:(NSCoder *)decoder // NS_DESIGNATED_INITIALIZER
{
    self->timmingDate     = [decoder decodeObjectForKey:@"ktTimmingDate"];
    self->timmingRepeat     = [decoder decodeObjectForKey:@"ktTimmingRepeat"];
    self->timmingLabelName  = [decoder decodeObjectForKey:@"kTimmingLabelName"];
    self->timmingWriteToAddress      = [decoder decodeObjectForKey:@"kTimmingWriteToAddress"];
    self->timmingValueType    = [decoder decodeObjectForKey:@"kTimmingValueType"];
    self->timmingSendValue    = [decoder decodeObjectForKey:@"kTimmingSendValue"];
    self->timmingEnable    = [decoder decodeBoolForKey:@"kTimmingEnable"];
    return self;
}

- (instancetype) initWithTimmingDate:(NSDate *)dade
                       timmingRepeat:(NSDictionary *)repeat
                    timmingLabelName:(NSString *)labelName
                    timmingWriteToAddress:(NSString *)writeToAddress
                    timmingValueType:(NSString *)valueType
                    timmingSendValue:(NSString *)sendValue
                       timmingEnable:(BOOL)flag
{
    self = [super init];
    if (self)
    {
        timmingDate = dade;
        timmingRepeat = repeat;
        timmingLabelName = labelName;
        timmingWriteToAddress = writeToAddress;
        timmingValueType = valueType;
        timmingSendValue = sendValue;
        timmingEnable = flag;
    }
    return self;
}
@end


@interface Timming()
{
    BLGCDKNXTunnellingAsyncUdpSocket *tunnellingShareInstance;
    NSTimer *getTimmingItemsTotalCountTimer;
    NSTimer *getTimmingTotalItemsTimer;
    KNXTimmingError timmingGotTotalCountError;
    KNXTimmingError timmingGotTotalItemsError;
    BOOL didGetTimmingItemsCount;
    NSArray *timmingItems;
}
@end



@implementation Timming

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        tunnellingShareInstance  = [BLGCDKNXTunnellingAsyncUdpSocket sharedInstance];
        getTimmingItemsTotalCountTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(getTimmingItemsTotalCountTimeout) userInfo:nil repeats:YES];
        getTimmingTotalItemsTimer =  [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(getTimmingTotalItemsTimeout) userInfo:nil repeats:YES];
        timmingGotTotalCountError = KNXTimmingGotTotalCountNoAction;
        timmingGotTotalItemsError = KNXTimmingGotTotalItemsNoAction;
        didGetTimmingItemsCount = NO;
        //stop getTimmingItemsTimerStart
        [self getTimmingItemsTotalCountTimerStart:NO];
        [self getTimmingTotalItemsTimerStart:NO];
        
        timmingItems = [[NSArray alloc] init];
        
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timmingItemsTotalCountGot:) name:TimmingItemsTotalCountResponseNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timmingItemsAllGot:) name:TimmingItemsAllGetResponseNotification object:nil];
    }
    return self;
}

#pragma mark - Set Timming Item


#pragma mark - Get Timming Items

- (void)getTimmingItemsWithCompletion:(GetTimmingItemsCompleteBlock)completion
{
    //didGetTimmingItemsCount = NO;
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:@"0/0/0" value:0 buttonName:nil valueLength:@"1Bit" commandType:KNXCommandTimmingItemsItemsGetAll];// TimmingItemsGetItemsTotalCount TimmingItemsGetAll
    //timmingGotTotalCountError = KNXTimmingGotTotalCountNoAction;
    timmingGotTotalItemsError = KNXTimmingGotTotalItemsNoAction;
    //[self getTimmingItemsTotalCountTimerStart:YES];
    [self getTimmingTotalItemsTimerStart:YES];
    while (timmingGotTotalItemsError == KNXTimmingGotTotalItemsNoAction)
    {
        [NSThread sleepForTimeInterval:0.01];
    }
    
    if (completion)
    {
        BOOL isNoError = NO;
        if (KNXTimmingGotTotalItemsNoAction == KNXTimmingGotTotalItemsNoError)
        {
            isNoError = YES;
        }
        else
        {
            isNoError = NO;
        }
        completion(isNoError);
    }
}

- (void)getTimmingItemsTotalCountTimeout
{
    //stop getTimmingItemsTimer
    [self getTimmingItemsTotalCountTimerStart:NO];
    timmingGotTotalItemsError = KNXTimmingGotTotalCountTimeoutError;//
    
    //NSLog(@"Timming Items Count Timeout");
    
}

- (void)getTimmingTotalItemsTimeout
{
    [self getTimmingTotalItemsTimerStart:NO];
    timmingGotTotalItemsError = KNXTimmingGotTotalItemsTimeoutError;
}

- (void) getTimmingItemsTotalCountTimerStart:(BOOL)start
{
    if (getTimmingItemsTotalCountTimer == nil)
    {
        return;
    }
    
    if (start)
    {
        //start 10 second later
        [getTimmingItemsTotalCountTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:3.0]];
    }
    else
    {
        //stop
        [getTimmingItemsTotalCountTimer setFireDate:[NSDate distantFuture]];
    }
}


- (void) getTimmingTotalItemsTimerStart:(BOOL)start
{
    if (getTimmingTotalItemsTimer == nil)
    {
        return;
    }
    
    if (start)
    {
        //start 10 second later
        [getTimmingTotalItemsTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:3.0]];
    }
    else
    {
        //stop
        [getTimmingTotalItemsTimer setFireDate:[NSDate distantFuture]];
    }
}

- (void)timmingItemsTotalCountGot:(NSNotification*)notification
{
//    [self getTimmingItemsTotalCountTimerStart:NO];
//    NSDictionary *dict = [notification userInfo];
//    
//    NSUInteger itemsCount = [dict[TimmingItemsTotalCountResponseNotificationTimmingItemsTotalCountKey] integerValue];
//    
//    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:@"0/0/0" value:0 buttonName:nil valueLength:@"1Bit" commandType:KNXCommandTimmingItemsItemsGetAll];// TimmingItemsGetItemsTotalCount TimmingItemsGetAll
//    
//    //reset timmingGotTotalItemsError avoid receiving this notification sent by other device
//    timmingGotTotalItemsError = KNXTimmingGotTotalItemsNoAction;
//    [self getTimmingTotalItemsTimerStart:YES];
//    
//    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
//        while (timmingGotTotalItemsError == KNXTimmingGotTotalItemsNoAction)
//        {
//            [NSThread sleepForTimeInterval:0.01];
//        }
//
//    });
    
    //didGetTimmingItemsCount = YES;
    //NSLog(@"Timming Items Count = %lu", (unsigned long)itemsCount);
}

- (void)timmingItemsAllGot:(NSNotification*)notification
{
    NSDictionary *dict = [notification userInfo];
    
    NSData *timmingTotalItemsData = dict[TimmingItemsAllGetResponseNotificationTimmingItemsAllKey];
    
    if (timmingTotalItemsData == nil)
    {
        return;
    }
    
    Byte *timmingItemsBytes = (Byte *)[timmingTotalItemsData bytes];
    
    for (int index = 0; index < [timmingTotalItemsData length]; index++)
    {
        NSLog(@"timmingItemsBytes[%d] = %x", index, timmingItemsBytes[index]);
    }
    
    //dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        //NSLog(@"timmingItemsBytes[0] = %d", timmingItemsBytes[0]);
        //NSLog(@"read all timming setting data response $$$$$$$$$$$$");
        int additionalDataLength = timmingItemsBytes[0] - 1;
        int itemCount = 0;
        int offset = 0;
        Byte *itemByte;
        NSMutableArray *itemsArray = [[NSMutableArray alloc] init];
        if (additionalDataLength > 0)
        {
            int timmingItemLength = timmingItemsBytes[2];
            itemByte = timmingItemsBytes + 1;
            do
            {
                
                
                if (additionalDataLength <= 0)
                {
                    break;
                }
                
                itemCount++;
                //NSLog(@"timming item index = %d  item length = %d", index, timmingItemLength);
                NSLog(@"pointer = %lu", itemByte);
                NSString *stringDate = [NSString stringWithFormat:@"20%d-%d-%d %d:%d:%d", itemByte[4], itemByte[5], itemByte[6], itemByte[7], itemByte[8], itemByte[9]];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                [dateFormatter setDateFormat:@"yyy-MM-dd HH:mm:ss"];
                NSDate *itemDate = [dateFormatter dateFromString:stringDate];
                NSLog(@"############string = %@,  itemDate = %@", stringDate, itemDate);
                
//                NSDate *timmingDate = [[NSDate alloc] init];
                
                TimmingPacket *timmingItem = [[TimmingPacket alloc] initWithTimmingDate:itemDate
                                                                          timmingRepeat:nil
                                                                       timmingLabelName:@"测试"
                                                                  timmingWriteToAddress:[NSString stringWithFormat:@"0/%d/%d", itemByte[10], itemByte[11]]
                                                                       timmingValueType:[NSString stringWithFormat:@"%dByte", itemByte[12]]
                                                                       timmingSendValue:[NSString stringWithFormat:@"Value%d", itemByte[14]]
                                                                          timmingEnable:itemByte[2] & 0x80];
                [itemsArray addObject:timmingItem];
                
                additionalDataLength = additionalDataLength - timmingItemLength - 1 - 1;
                
                offset += 1 + 1 + timmingItemLength;
                timmingItemLength = timmingItemsBytes[1 + offset + 1];
                
                itemByte = timmingItemsBytes + 1 + offset;


            }while (1);
            
            

        }
        else
        {
            //NSLog(@"timming item count = 0, additionalDataLength = %d", additionalDataLength);
        }
    
        timmingItems = [itemsArray copy];
    
        SEL selector = @selector(timmingItemsAllGotWithItems:);
        if ([_delegate respondsToSelector:selector])
        {
            [_delegate timmingItemsAllGotWithItems:itemsArray];
        }
    
        timmingGotTotalItemsError = KNXTimmingGotTotalItemsNoError;

    //});
    
}

- (TimmingPacket *)getTimmingItemWithIndex:(NSUInteger)index
{
    NSUInteger itemsCount = [timmingItems count];
    if ((index + 1) > itemsCount)
    {
        return nil;
    }
    
    return [timmingItems objectAtIndex:index];
    
    
}

+ (NSDictionary *) assembleToDictionaryWithTimmingPacket:(TimmingPacket *)data
{
    
    NSDictionary *timmingItemDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     data->timmingDate, @"TimmingDate",
                                     data->timmingRepeat, @"TimmingRepeat",
                                     data->timmingWriteToAddress, @"TimmingWriteToAddress",
                                     data->timmingValueType, @"TimmingValueType",
                                     data->timmingSendValue, @"TimmingSendValue",nil];
    return timmingItemDict;
    
}


@end
