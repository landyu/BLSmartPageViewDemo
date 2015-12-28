//
//  BLHeating.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/24.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLHeating.h"
#import "BLHeatingViewController.h"
#import "BLGCDKNXTunnellingAsyncUdpSocket.h"
#import "GlobalMacro.h"
#define heatingViewControllerSharedInstance [BLHeatingViewController sharedInstance]

enum HeatingReadFromGroupAddressObject
{
    kOnOff = 0,
    kSettingTemperature,
    kEnviromentTemperature,
};


@interface BLHeating()
{
    
    NSDictionary *EnviromentTemperatureDict;
    NSDictionary *SettingTemperatureDict;
    NSDictionary *OnOffDict;
    
    NSDictionary *heatingPropertyDict;
    //BLHeatingViewController *heatingViewControllerSharedInstance;
    
    NSMutableArray *ReadFromGroupAddressArray;
    NSMutableArray *WriteToGroupAddressArray;
    
    BLGCDKNXTunnellingAsyncUdpSocket *tunnellingShareInstance;
    NSMutableDictionary *overallRecevedKnxDataDict;
}
@end

@implementation BLHeating
+ (instancetype)sharedInstance
{
    // 1
    static BLHeating *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[BLHeating alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _settingEnvironmentTemperature = 15.0;
        
        tunnellingShareInstance  = [BLGCDKNXTunnellingAsyncUdpSocket sharedInstance];
        overallRecevedKnxDataDict = tunnellingShareInstance.overallReceivedKnxDataDict;
        
        
        ReadFromGroupAddressArray = [[NSMutableArray alloc] initWithCapacity:3];
        for (NSInteger i = 0; i < 3; ++i)
        {
            [ReadFromGroupAddressArray addObject:[NSNull null]];
        }
        WriteToGroupAddressArray = [[NSMutableArray alloc] initWithCapacity:3];
        for (NSInteger i = 0; i < 3; ++i)
        {
            [WriteToGroupAddressArray addObject:[NSNull null]];
        }
        
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvFromBus:) name:@"BL.BLSmartPageViewDemo.RecvFromBus" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tunnellingConnectSuccess) name:TunnellingConnectSuccessNotification object:nil];
    }
    return self;
}

- (void)updateItemsDict:(NSDictionary *)dict
{
    
    heatingPropertyDict = dict;
    [heatingPropertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"EnviromentTemperature"])
         {
             EnviromentTemperatureDict = [[NSDictionary alloc] initWithDictionary:obj];
             [ReadFromGroupAddressArray replaceObjectAtIndex:kEnviromentTemperature withObject:[EnviromentTemperatureDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
             //[WriteToGroupAddressArray replaceObjectAtIndex:kEnviromentTemperature withObject:[EnviromentTemperatureDict[@"WriteToGroupAddress"] objectForKey:@"0"]];
             //ReadFromGroupAddressArray[kEnviromentTemperature] = [EnviromentTemperatureDict[@"ReadFromGroupAddress"] objectForKey:@"0"];
             //WriteToGroupAddressArray[kEnviromentTemperature] = [EnviromentTemperatureDict[@"WriteToGroupAddress"] objectForKey:@"0"];
         }
         else if([key isEqualToString:@"SettingTemperature"])
         {
             SettingTemperatureDict = [[NSDictionary alloc] initWithDictionary:obj];
             [ReadFromGroupAddressArray replaceObjectAtIndex:kSettingTemperature withObject:[SettingTemperatureDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
             [WriteToGroupAddressArray replaceObjectAtIndex:kSettingTemperature withObject:[SettingTemperatureDict[@"WriteToGroupAddress"] objectForKey:@"0"]];
             //ReadFromGroupAddressArray[kSettingTemperature] = [SettingTemperatureDict[@"ReadFromGroupAddress"] objectForKey:@"0"];
             //WriteToGroupAddressArray[kSettingTemperature] = [SettingTemperatureDict[@"WriteToGroupAddress"] objectForKey:@"0"];
         }
         else if([key isEqualToString:@"OnOff"])
         {
             OnOffDict = [[NSDictionary alloc] initWithDictionary:obj];
             [ReadFromGroupAddressArray replaceObjectAtIndex:kOnOff withObject:[OnOffDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
             [WriteToGroupAddressArray replaceObjectAtIndex:kOnOff withObject:[OnOffDict[@"WriteToGroupAddress"] objectForKey:@"0"]];
             //ReadFromGroupAddressArray[kOnOff] = [OnOffDict[@"ReadFromGroupAddress"] objectForKey:@"0"];
             //WriteToGroupAddressArray[kOnOff] = [OnOffDict[@"WriteToGroupAddress"] objectForKey:@"0"];
         }
     }];
    
}

- (void)heatingOnOffToChangeWithState:(BOOL)isOn
{
    NSInteger value = 0;
    
    if (isOn)
    {
        value = 1;
    }
    else
    {
        value = 0;
    }
    
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:WriteToGroupAddressArray[kOnOff] value:value buttonName:nil valueLength:@"1Bit" commandType:@"Write"];
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:ReadFromGroupAddressArray[kOnOff] value:0 buttonName:nil valueLength:@"1Bit" commandType:@"Read"];
}
- (void)heatingSettingEnvironmentTemperatureToChangeWithValue:(float)value
{
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:WriteToGroupAddressArray[kSettingTemperature] value:value buttonName:nil valueLength:@"2Byte" commandType:@"Write"];
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:ReadFromGroupAddressArray[kSettingTemperature] value:0 buttonName:nil valueLength:@"2Byte" commandType:@"Read"];
}

//- (NSString *)getReadFromGroupAddressWithKey:(NSString *)targetKey
//{
//    if (heatingPropertyDict ==  nil)
//    {
//        return nil;
//    }
//    
//    __block NSString *readFromGroupAddress;
//    [heatingPropertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
//     {
//         if ([key isEqualToString:targetKey])
//         {
//             NSDictionary *subDict = [[NSMutableDictionary alloc] initWithDictionary:obj];
//             readFromGroupAddress = [subDict[@"ReadFromGroupAddress"] objectForKey:@"0"];
//             *stop = YES;
//         }
//     }];
//    return readFromGroupAddress;
//}
//
//- (NSString *)getWriteToGroupAddressWithKey:(NSString *)targetKey
//{
//    if (heatingPropertyDict ==  nil)
//    {
//        return nil;
//    }
//    
//    __block NSString *writeToGroupAddress;
//    [heatingPropertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
//     {
//         if ([key isEqualToString:targetKey])
//         {
//             NSDictionary *subDict = [[NSMutableDictionary alloc] initWithDictionary:obj];
//             writeToGroupAddress = [subDict[@"WriteToGroupAddress"] objectForKey:@"0"];
//             *stop = YES;
//         }
//     }];
//    return writeToGroupAddress;
//}

#pragma mark Receive From Bus
- (void)recvFromBus:(NSNotification*) notification
{
    
    if (heatingViewControllerSharedInstance.view.superview == nil)
    {
        return;
    }
    
    NSDictionary *dict = [notification userInfo];
    
    for (NSUInteger index = 0; index < [ReadFromGroupAddressArray count]; index++)
    {
        if (ReadFromGroupAddressArray[index] == [NSNull null])
        {
            continue;
        }
        
        if ([dict[@"Address"] isEqualToString:ReadFromGroupAddressArray[index]])
        {
            NSUInteger value = [dict[@"Value"] intValue];
            
            if (index == kOnOff)
            {
                [self heatingOnOffStatusUpdateWithValue:value];
            }
            else if (index == kSettingTemperature)
            {
                [self heatingSettingTemperatureUpdateWithValue:value];
            }
        }
    }
}

//read item status
- (void)setHeatingPanelViewFromOldData
{
    
    if (overallRecevedKnxDataDict != nil)
    {
        NSString *objectValue = [overallRecevedKnxDataDict objectForKey:[OnOffDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
        [self heatingOnOffStatusUpdateWithValue:[objectValue integerValue]];
        objectValue = [overallRecevedKnxDataDict objectForKey:[SettingTemperatureDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
        [self heatingSettingTemperatureUpdateWithValue:[objectValue integerValue]];
    }
}


- (void) tunnellingConnectSuccess
{
    if (heatingViewControllerSharedInstance.view.superview == nil)
    {
        return;
    }
    [self setHeatingPanelViewFromOldData];
    [self readHeatingPanelStatus];
}

- (void)readHeatingPanelStatus
{
    if ((ReadFromGroupAddressArray[kOnOff] == [NSNull null]) || (ReadFromGroupAddressArray[kSettingTemperature] == [NSNull null]))
    {
        return;
    }
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:ReadFromGroupAddressArray[kOnOff] value:0 buttonName:nil valueLength:@"1Bit" commandType:@"Read"];
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:ReadFromGroupAddressArray[kSettingTemperature] value:0 buttonName:nil valueLength:@"2Byte" commandType:@"Read"];
    
    
}
//
//
//
//#pragma mark Send Write Read Command
//- (void) blUIButtonTransmitWriteActionWithDestGroupAddress:(NSString *)destGroupAddress value:(NSInteger)value buttonName:(NSString *)name valueLength:(NSString *)valueLength
//{
//    SEL selector = @selector(blHeatingSendWithDestGroupAddress:value:buttonName:valueLength:commandType:);
//    
//    if ([_delegate respondsToSelector:selector])
//    {
//        [_delegate blHeatingSendWithDestGroupAddress:destGroupAddress value:value buttonName:name valueLength:valueLength commandType:@"Write"];
//    }
//    //NSDictionary *transmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:destGroupAddress, @"GroupAddress",  [NSString stringWithFormat: @"%ld", (long)value], @"Value", valueLength, @"ValueLength", @"Write", @"CommandType", nil];
//    //[appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:transmitDataDict];
//}
//
//- (void) blUIButtonTransmitReadActionWithDestGroupAddress:(NSString *)destGroupAddress  valueLength:(NSString *)valueLength
//{
//    SEL selector = @selector(blHeatingSendWithDestGroupAddress:value:buttonName:valueLength:commandType:);
//    
//    if ([_delegate respondsToSelector:selector])
//    {
//        [_delegate blHeatingSendWithDestGroupAddress:destGroupAddress value:0 buttonName:nil valueLength:valueLength commandType:@"Read"];
//    }
//    //NSDictionary *transmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:destGroupAddress, @"GroupAddress", valueLength, @"ValueLength", @"Read", @"CommandType", nil];
//    //[appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:transmitDataDict];
//}
//
//- (void) blUIButtonTransmitInitReadActionWithDestGroupAddress:(NSString *)destGroupAddress  valueLength:(NSString *)valueLength
//{
//    SEL selector = @selector(blHeatingInitReadWithDestGroupAddress:value:buttonName:valueLength:);
//    
//    if ([_delegate respondsToSelector:selector])
//    {
//        [_delegate blHeatingInitReadWithDestGroupAddress:destGroupAddress value:0 buttonName:nil valueLength:valueLength];
//    }
//    //NSDictionary *transmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:destGroupAddress, @"GroupAddress", valueLength, @"ValueLength", @"Read", @"CommandType", nil];
//    //[appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:transmitDataDict];
//}


- (BOOL)heatingOnOffStatusUpdateWithValue:(NSInteger)value
{
    __block BOOL ret = NO;
    dispatch_async(dispatch_get_main_queue(),
       ^{
           if (value == 1)
           {
               [heatingViewControllerSharedInstance.heatingOnOffButtonOutlet setSelected:YES];
               [heatingViewControllerSharedInstance.heatingOnOffLabel setText:@"ON"];
               ret = YES;
           }
           else if(value == 0)
           {
               [heatingViewControllerSharedInstance.heatingOnOffButtonOutlet setSelected:NO];
               [heatingViewControllerSharedInstance.heatingOnOffLabel setText:@"OFF"];
               ret = NO;
           }
       });
    
    return ret;
    
}

- (void)heatingSettingTemperatureUpdateWithValue:(NSInteger)value
{
    //LogInfo(@"Setting Temperature = %ld", (long)value);
    _settingEnvironmentTemperature = value;
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                        [heatingViewControllerSharedInstance.heatingSettingTemperatureLabel setText:[[NSString alloc] initWithFormat:@"%ld", (long)value]];
                    });
   
}

//- (void)updateItemsDict:(NSDictionary *)heatingPropertyDict
//{
//    senttingTemperatureFeedBackValue = 15.0;
//    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tunnellingConnectSuccess) name:TunnellingConnectSuccessNotification object:nil];
//    
//    [heatingPropertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
//     {
//         if ([key isEqualToString:@"EnviromentTemperature"])
//         {
//             EnviromentTemperatureDict = [[NSMutableDictionary alloc] initWithDictionary:obj];
//         }
//         else if([key isEqualToString:@"SettingTemperature"])
//         {
//             SettingTemperatureDict = [[NSMutableDictionary alloc] initWithDictionary:obj];
//         }
//         else if([key isEqualToString:@"OnOff"])
//         {
//             OnOffDict = [[NSMutableDictionary alloc] initWithDictionary:obj];
//         }
//     }];
//    
//    //    dispatch_async([Utils GlobalUserInitiatedQueue],
//    //                   ^{
//    //                       //[self initReadACPanelWidgetStatus];
//    //                       [self readACPanelTopDisplayStatus];
//    //                   });
//}

@end
