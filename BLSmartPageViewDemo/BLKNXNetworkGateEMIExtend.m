//
//  BLKNXNetworkGateEMIExtend.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/31.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLKNXNetworkGateEMIExtend.h"
#import "GlobalNotification.h"
@interface BLKNXNetworkGateEMIExtend()
{
    
}
@end

@implementation BLKNXNetworkGateEMIExtend

- (instancetype)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}
- (NSMutableData *)setTimmingItemWithChannelID:(unsigned char)CID squenceCount:(unsigned char)SC timmingItem:(NSDictionary *)timmingItem
{
    Byte standardTPData[11] = {0xbc,0xd0,0x00,0x00,0x18,0x00,0x01,0x00,0x00,0x00,0x00};
                       // 0    1   2    3    4     5    6   7   8   9   10    11  12   13   14    15   16  17    18   19   20  21    22
    Byte sendByte[23] = {0x06,0x10,0x04,0x20,0x00,0x15,0x04,CID,SC,0x00,0x11,0x00,0xbc,0xd0,0x00,0x00,0x18,0x00,0x01,0x00,0x00,0x00,0x00};
                                         // 0       1       2    3      4     5    6       7   8   9           10    11     12   13   14    15   16  17    18   19   20  21    22
    Byte sendByteWithAdditionalData[12] = {0x06,  0x10,   0x04,0x20,   0x00,0x15, 0x04,   CID,SC, 0x00,        0x11,0x00};
                                        // Header  ver    Tunnelling     Total    Struct          Rederved      MC   AddIL AddI
                                        // Length          Request       Length   Length
    unsigned char value = 0;
    unsigned char dataLength = 0;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    data = [NSMutableData dataWithBytes:sendByte length:21];
    
    NSMutableData *dataWithAdditionalData = [[NSMutableData alloc] init];
    dataWithAdditionalData = [NSMutableData dataWithBytes:sendByteWithAdditionalData length:12];
    
    //package length
    //value = 36;
    //[dataWithAdditionalData replaceBytesInRange:NSMakeRange(5, 1) withBytes:&value];
    

    //length = standard + additional package length Byte
    dataLength = 11 + 1;
    
    
    value = 0x86;//timming set flag     12
    [dataWithAdditionalData appendBytes:&value length:1];
    //additional data length  this value is nosense set this byte at the end of all the additional data setted   13
    value = 0x0D;
    [dataWithAdditionalData appendBytes:&value length:1];
    value = 0x01;//mode1 week repeat enable      14
    [dataWithAdditionalData appendBytes:&value length:1];
    
    
    
    value = [self enableSpecificRepeatRegionWithRegion:[timmingItem objectForKey:@"TimmingRepeat"] repeatMode:@"每周"];//mode2 certain week repeat enable      15
    [dataWithAdditionalData appendBytes:&value length:1];
    dataLength += 4;
    
    
    
    Byte dateByte[6];//set yy-mm-dd-hh-mm-ss      16-21
    NSDate *timmingDate = [timmingItem objectForKey:@"TimmingDate"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //[formatter setDateFormat:@"YYYY"];
    //NSString *timmingTimeString = [formatter stringFromDate:timmingDate];
    //dateByte[0] = [timmingTimeString integerValue] % 100;
    //fix the year byte for ui date picker do not have this option
    dateByte[0] = 15;
    //[dataWithAdditionalData appendBytes:dateByte length:6];
    [formatter setDateFormat:@"MM"];
    NSString *timmingTimeString = [formatter stringFromDate:timmingDate];
    dateByte[1] = [timmingTimeString integerValue];
    //[dataWithAdditionalData appendBytes:dateByte length:6];
    [formatter setDateFormat:@"dd"];
    timmingTimeString = [formatter stringFromDate:timmingDate];
    dateByte[2] = [timmingTimeString integerValue];
    //[dataWithAdditionalData appendBytes:dateByte length:6];
    [formatter setDateFormat:@"HH"];
    timmingTimeString = [formatter stringFromDate:timmingDate];
    dateByte[3] = [timmingTimeString integerValue];
    //[dataWithAdditionalData appendBytes:dateByte length:6];
    [formatter setDateFormat:@"mm"];
    timmingTimeString = [formatter stringFromDate:timmingDate];
    dateByte[4] = [timmingTimeString integerValue];
    //[formatter setDateFormat:@"ss"];
    //timmingTimeString = [formatter stringFromDate:timmingDate];
    //dateByte[5] = [timmingTimeString integerValue];
    //fix the second byte for ui date picker do not have this option
    dateByte[5] = 0x00;
    
    [dataWithAdditionalData appendBytes:dateByte length:6];
    
    //add
    dataLength += 6;
    
    //NSLog(@"dateByte[0] = %d, dateByte[0] = %d, dateByte[0] = %d, dateByte[0] = %d, dateByte[0] = %d, dateByte[0] = %d", dateByte[0], dateByte[1], dateByte[2], dateByte[3], dateByte[4], dateByte[5]);
    
    
    //Byte dateByte2[6] = {15, 12, 11, 9, 30, 10};//set yy-mm-dd-hh-mm-ss      16-21
    //[dataWithAdditionalData appendBytes:dateByte2 length:6];
    
    
    NSString *targetGroupAddress = [timmingItem objectForKey:@"TimmingWriteToAddress"];
    NSArray *groupAddressSplited = [targetGroupAddress componentsSeparatedByString:@"/"];
    //targetGroupAddress error
    if ([groupAddressSplited count] != 3)
    {
        Byte destAddress[2] = {0x00, 0x00};// set target address    22-23
        [dataWithAdditionalData appendBytes:destAddress length:2];
    }
    else //targetGroupAddress ok
    {
        unsigned char mainMidAdd = ([[groupAddressSplited objectAtIndex:0] integerValue] << 3 ) | ([[groupAddressSplited objectAtIndex:1] integerValue] & 0x07);
        unsigned char subAddress = [[groupAddressSplited objectAtIndex:2] integerValue];
        Byte destAddress[2] = {mainMidAdd, subAddress};// set target address    22-23
        [dataWithAdditionalData appendBytes:destAddress length:2];
    }
    //add
    dataLength += 2;
    
    NSString *valueType = [timmingItem objectForKey:@"TimmingValueType"];
    NSString *sendValue = [timmingItem objectForKey:@"TimmingSendValue"];
    unsigned char actionValueLength = 0;
    if ([valueType isEqualToString:@"1Bit"])
    {
        unsigned char dataByte = 0x80 | ([sendValue integerValue] & 0x01);
        Byte actionByte[3] = {0x01, 0x00, dataByte};
        //add action data length
        dataLength += 3;
        actionValueLength = 3;
        //set action      24-26
        [dataWithAdditionalData appendBytes:actionByte length:sizeof(actionByte)];
    }
    else if ([valueType isEqualToString:@"1Byte"])
    {
        unsigned char dataByte = [sendValue integerValue];
        Byte actionByte[4] = {0x02, 0x00, 0x80, dataByte};
        //add action data length
        dataLength += 4;
        actionValueLength = 4;
        //set action      24-27
        [dataWithAdditionalData appendBytes:actionByte length:sizeof(actionByte)];
    }
    else if ([valueType isEqualToString:@"2Byte"])
    {
        unsigned char dataByte1 = [sendValue integerValue];
        unsigned char dataByte2 = [sendValue integerValue];
        Byte actionByte[5] = {0x03, 0x00, 0x80, dataByte1, dataByte2};
        //add action data length
        dataLength += 5;
        actionValueLength = 5;
        //set action      24-28
        [dataWithAdditionalData appendBytes:actionByte length:sizeof(actionByte)];
    }
    else  //default as 1 bit
    {
        Byte actionByte[3] = {0x01, 0x00, 0x80};
        //add action data length
        dataLength += 3;
        actionValueLength = 3;
        //set action      24-26
        [dataWithAdditionalData appendBytes:actionByte length:sizeof(actionByte)];
    }
    //additional package the first command length
    value = 0x0A + actionValueLength;
    [dataWithAdditionalData replaceBytesInRange:NSMakeRange(13, 1) withBytes:&value];
    
    
    //plus standard data length
    dataLength += 9;
    [dataWithAdditionalData appendBytes:standardTPData length:9];
    
    //additional package length = fixed timming data + action value lenght + (timming setting flag + additional first command length byte)
    value = 0x0A + actionValueLength + 2;
    [dataWithAdditionalData replaceBytesInRange:NSMakeRange(11, 1) withBytes:&value];
    
    
    value = dataLength;//package length
    [dataWithAdditionalData replaceBytesInRange:NSMakeRange(5, 1) withBytes:&value];
    
    //                                       value = 0x00 | ([sendValue integerValue] & 0x01);
    //                                       [data replaceBytesInRange:NSMakeRange(20, 1) withBytes:&value];
    //dataLength = 36;
    data = [NSMutableData dataWithData:dataWithAdditionalData];
    
    
    Byte *testByte = (Byte *)[data bytes];
    for (NSUInteger index = 0; index < [data length]; index++)
    {
        NSLog(@"timmingSetCommand[%lu] = %x",(unsigned long)index, testByte[index]);
    }
    
    return [data copy];
}

- (unsigned char)enableSpecificRepeatRegionWithRegion:(id)region repeatMode:(NSString *)mode
{
    unsigned char enableRegion = 0x00;
    if ([mode isEqualToString:@"每周"])
    {
        NSDictionary *weekRepeatRegion = (NSDictionary *)region;
        NSArray *repeatDate = [[NSArray alloc] initWithObjects:@"每周日", @"每周一",  @"每周二", @"每周三", @"每周四", @"每周五", @"每周六",nil];
        
        for (NSUInteger index = 0; index < [repeatDate count]; index++)
        {
            NSString *repeatDateKey = [repeatDate objectAtIndex:index];
            NSString *repeatValue = [weekRepeatRegion objectForKey:repeatDateKey];
            
            if (repeatValue != nil)
            {
                if ([repeatDateKey  isEqualToString:@"每周日"])
                {
                    if ([repeatValue isEqualToString:@"1"])
                    {
                        enableRegion |= 0x01 << 7;
                    }
                }
                else if ([repeatDateKey  isEqualToString:@"每周一"])
                {
                    if ([repeatValue isEqualToString:@"1"])
                    {
                        enableRegion |= 0x01 << 1;
                    }
                }
                else if ([repeatDateKey  isEqualToString:@"每周二"])
                {
                    if ([repeatValue isEqualToString:@"1"])
                    {
                        enableRegion |= 0x01 << 2;
                    }
                }
                else if ([repeatDateKey  isEqualToString:@"每周三"])
                {
                    if ([repeatValue isEqualToString:@"1"])
                    {
                        enableRegion |= 0x01 << 3;
                    }
                }
                else if ([repeatDateKey  isEqualToString:@"每周四"])
                {
                    if ([repeatValue isEqualToString:@"1"])
                    {
                        enableRegion |= 0x01 << 4;
                    }
                }
                else if ([repeatDateKey  isEqualToString:@"每周五"])
                {
                    if ([repeatValue isEqualToString:@"1"])
                    {
                        enableRegion |= 0x01 << 5;
                    }
                }
                else if ([repeatDateKey  isEqualToString:@"每周六"])
                {
                    if ([repeatValue isEqualToString:@"1"])
                    {
                        enableRegion |= 0x01 << 6;
                    }
                }
            }
        }
    }
    
    return  enableRegion;
}

- (NSMutableData *)getAllTimmingItemsWithChannelID:(unsigned char)CID squenceCount:(unsigned char)SC
{
    Byte standardTPData[11] = {0xbc,0xd0,0x00,0x00,0x18,0x00,0x01,0x00,0x00,0x00,0x00};
                       // 0    1   2    3    4     5    6   7   8   9   10    11  12   13   14    15   16  17    18   19   20  21    22
    Byte sendByte[23] = {0x06,0x10,0x04,0x20,0x00,0x15,0x04,CID,SC,0x00,0x11,0x00,0xbc,0xd0,0x00,0x00,0x18,0x00,0x01,0x00,0x00,0x00,0x00};
                                          // 0       1       2    3      4     5    6       7   8   9           10    11     12   13   14    15   16  17    18   19   20  21    22
    Byte sendByteWithAdditionalData[12] = {0x06,  0x10,   0x04,0x20,   0x00,0x15, 0x04,   CID,SC, 0x00,        0x11,0x00};
                                        // Header  ver    Tunnelling     Total    Struct          Rederved      MC   AddIL AddI
                                        // Length          Request       Length   Length
    unsigned char value = 0;
    unsigned char dataLength = 0;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    data = [NSMutableData dataWithBytes:sendByte length:21];
    
    NSMutableData *dataWithAdditionalData = [[NSMutableData alloc] init];
    dataWithAdditionalData = [NSMutableData dataWithBytes:sendByteWithAdditionalData length:12];
    
    
    
    //additional package length
    value = 0x01;
    [dataWithAdditionalData replaceBytesInRange:NSMakeRange(11, 1) withBytes:&value];
    
    //length = standard + Additional information length + additional package length Byte
    dataLength = 12 + value + 1;
    
    //timming read all flag     12
    value = 0x83;
    [dataWithAdditionalData appendBytes:&value length:1];
    
    //plus standard data length
    dataLength += 9;
    [dataWithAdditionalData appendBytes:standardTPData length:9];
    
    value = dataLength;//package length
    [dataWithAdditionalData replaceBytesInRange:NSMakeRange(5, 1) withBytes:&value];
    
    
    data = [NSMutableData dataWithData:dataWithAdditionalData];
    
    return [data copy];
}

- (void)postTimmingItemsGetAllNotificationWithBytes:(NSData *)data
{
    //NSString *countString = [NSString stringWithFormat:@"%lu",(unsigned long)count];
    NSDictionary *timmingAllItemsDict = [NSDictionary dictionaryWithObjectsAndKeys:data, TimmingItemsAllGetResponseNotificationTimmingItemsAllKey,nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:TimmingItemsAllGetResponseNotification object:self userInfo:timmingAllItemsDict];
    
//    Byte *timmingItemsBytes = (Byte *)[data bytes];
//    
//    for (int index = 0; index < [data length]; index++)
//    {
//        NSLog(@"timmingItemsBytes[%d] = %x", index, timmingItemsBytes[index]);
//    }
}


- (NSMutableData *)getTimmingItemsTotalCountWithChannelID:(unsigned char)CID squenceCount:(unsigned char)SC
{
    Byte standardTPData[11] = {0xbc,0xd0,0x00,0x00,0x18,0x00,0x01,0x00,0x00,0x00,0x00};
    // 0    1   2    3    4     5    6   7   8   9   10    11  12   13   14    15   16  17    18   19   20  21    22
    Byte sendByte[23] = {0x06,0x10,0x04,0x20,0x00,0x15,0x04,CID,SC,0x00,0x11,0x00,0xbc,0xd0,0x00,0x00,0x18,0x00,0x01,0x00,0x00,0x00,0x00};
                                        // 0    1      2    3    4   5    6   7   8   9   10    11  12   13   14    15   16  17    18   19   20  21    22
    Byte sendByteWithAdditionalData[12] = {0x06,0x10,0x04,0x20,0x00,0x15,0x04,CID,SC,0x00,0x11,0x00};
    
    unsigned char value = 0;
    unsigned char dataLength = 0;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    data = [NSMutableData dataWithBytes:sendByte length:21];
    
    NSMutableData *dataWithAdditionalData = [[NSMutableData alloc] init];
    dataWithAdditionalData = [NSMutableData dataWithBytes:sendByteWithAdditionalData length:12];
    
    value = 0x01;//additional package length
    [dataWithAdditionalData replaceBytesInRange:NSMakeRange(11, 1) withBytes:&value];
    value = 0x88;//timming read all flag     12
    [dataWithAdditionalData appendBytes:&value length:1];
    [dataWithAdditionalData appendBytes:standardTPData length:9];
    dataLength = 22;
    value = dataLength;//package length
    [dataWithAdditionalData replaceBytesInRange:NSMakeRange(5, 1) withBytes:&value];
    data = [NSMutableData dataWithData:dataWithAdditionalData];
    
    return [data copy];
}

- (void)postTimmingItemsTotalCountNotificationWithCount:(NSUInteger)count
{
    NSString *countString = [NSString stringWithFormat:@"%lu",(unsigned long)count];
    NSDictionary *timmingCountDict = [NSDictionary dictionaryWithObjectsAndKeys:countString, TimmingItemsTotalCountResponseNotificationTimmingItemsTotalCountKey,nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:TimmingItemsTotalCountResponseNotification object:self userInfo:timmingCountDict];
}

- (NSMutableData *)deleteTimmingItemWithChannelID:(unsigned char)CID squenceCount:(unsigned char)SC timmingItem:(NSDictionary *)timmingItem
{
    NSMutableData *deletingItem = [self setTimmingItemWithChannelID:CID squenceCount:SC timmingItem:timmingItem];
    
    //set the deleting flag
    Byte deleteFlag = 0x87;
    [deletingItem replaceBytesInRange:NSMakeRange(12, 1) withBytes:&deleteFlag];
    
    return [deletingItem copy];
    
}


@end
