//
//  BLAC.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/25.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLAC.h"
#import "BLACViewController.h"
#import "BLGCDKNXTunnellingAsyncUdpSocket.h"
#import "GlobalMacro.h"

#define acViewControllerSharedInstance [BLACViewController sharedInstance]

enum HeatingReadFromGroupAddressObject
{
    kOnOff = 0,
    kSettingTemperature,
    kEnviromentTemperature,
    kMode,
    kWindSpeed,
};


@interface BLAC()
{
    NSDictionary *EnviromentTemperatureDict;
    NSDictionary *SettingTemperatureDict;
    NSDictionary *OnOffDict;
    NSDictionary *ModeDict;
    NSDictionary *WindSpeedDict;
    
    NSDictionary *acPropertyDict;
    
    NSMutableArray *ReadFromGroupAddressArray;
    NSMutableArray *WriteToGroupAddressArray;
    
    BLGCDKNXTunnellingAsyncUdpSocket *tunnellingShareInstance;
    NSMutableDictionary *overallRecevedKnxDataDict;
}
@end

@implementation BLAC
+ (instancetype)sharedInstance
{
    // 1
    static BLAC *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[BLAC alloc] init];
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
        
        
        ReadFromGroupAddressArray = [[NSMutableArray alloc] initWithCapacity:5];
        for (NSInteger i = 0; i < 5; ++i)
        {
            [ReadFromGroupAddressArray addObject:[NSNull null]];
        }
        WriteToGroupAddressArray = [[NSMutableArray alloc] initWithCapacity:5];
        for (NSInteger i = 0; i < 5; ++i)
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
    
    acPropertyDict = dict;
    [acPropertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"EnviromentTemperature"])
         {
             EnviromentTemperatureDict = [[NSDictionary alloc] initWithDictionary:obj];
             [ReadFromGroupAddressArray replaceObjectAtIndex:kEnviromentTemperature withObject:[EnviromentTemperatureDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
         }
         else if([key isEqualToString:@"SettingTemperature"])
         {
             SettingTemperatureDict = [[NSDictionary alloc] initWithDictionary:obj];
             [ReadFromGroupAddressArray replaceObjectAtIndex:kSettingTemperature withObject:[SettingTemperatureDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
             [WriteToGroupAddressArray replaceObjectAtIndex:kSettingTemperature withObject:[SettingTemperatureDict[@"WriteToGroupAddress"] objectForKey:@"0"]];
         }
         else if([key isEqualToString:@"OnOff"])
         {
             OnOffDict = [[NSDictionary alloc] initWithDictionary:obj];
             [ReadFromGroupAddressArray replaceObjectAtIndex:kOnOff withObject:[OnOffDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
             [WriteToGroupAddressArray replaceObjectAtIndex:kOnOff withObject:[OnOffDict[@"WriteToGroupAddress"] objectForKey:@"0"]];
         }
         else if([key isEqualToString:@"Mode"])
         {
             ModeDict = [[NSDictionary alloc] initWithDictionary:obj];
             [ReadFromGroupAddressArray replaceObjectAtIndex:kMode withObject:[ModeDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
             [WriteToGroupAddressArray replaceObjectAtIndex:kMode withObject:[ModeDict[@"WriteToGroupAddress"] objectForKey:@"0"]];
         }
         else if([key isEqualToString:@"WindSpeed"])
         {
             WindSpeedDict = [[NSDictionary alloc] initWithDictionary:obj];
             [ReadFromGroupAddressArray replaceObjectAtIndex:kWindSpeed withObject:[WindSpeedDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
             [WriteToGroupAddressArray replaceObjectAtIndex:kWindSpeed withObject:[WindSpeedDict[@"WriteToGroupAddress"] objectForKey:@"0"]];
         }
     }];
    
}

#pragma mark Receive From Bus
- (void)recvFromBus:(NSNotification*) notification
{
    if (acViewControllerSharedInstance.view.superview == nil)
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
                [self acOnOffUpdateWithValue:value];
            }
            else if (index == kSettingTemperature)
            {
                [self acSettingTemperatureUpdateWithValue:value];
            }
            else if (index == kMode)
            {
                [self acModeUpdateWithValue:value];
            }
            else if (index == kWindSpeed)
            {
                [self acWindSpeedUpdateWithValue:value];
            }
        }
    }
}

- (void) tunnellingConnectSuccess
{
    if (acViewControllerSharedInstance.view.superview == nil)
    {
        return;
    }
    [self setACPanelViewFromOldData];
    [self readACPanelStatus];
}

- (void) setACPanelViewFromOldData
{
    if (overallRecevedKnxDataDict != nil)
    {
        NSString *objectValue = [overallRecevedKnxDataDict objectForKey:[OnOffDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
        [self acOnOffUpdateWithValue:[objectValue integerValue]];
        objectValue = [overallRecevedKnxDataDict objectForKey:[SettingTemperatureDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
        [self acSettingTemperatureUpdateWithValue:[objectValue integerValue]];
        objectValue = [overallRecevedKnxDataDict objectForKey:[ModeDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
        [self acModeUpdateWithValue:[objectValue integerValue]];
        objectValue = [overallRecevedKnxDataDict objectForKey:[WindSpeedDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
        [self acWindSpeedUpdateWithValue:[objectValue integerValue]];
    }
}
- (void) readACPanelStatus
{
    if ((ReadFromGroupAddressArray[kOnOff] == [NSNull null]) || (ReadFromGroupAddressArray[kSettingTemperature] == [NSNull null]) || (ReadFromGroupAddressArray[kMode] == [NSNull null]) || (ReadFromGroupAddressArray[kWindSpeed] == [NSNull null]))
    {
        return;
    }
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:ReadFromGroupAddressArray[kOnOff] value:0 buttonName:nil valueLength:@"1Bit" commandType:@"Read"];
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:ReadFromGroupAddressArray[kSettingTemperature] value:0 buttonName:nil valueLength:@"2Byte" commandType:@"Read"];
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:ReadFromGroupAddressArray[kMode] value:0 buttonName:nil valueLength:@"1Byte" commandType:@"Read"];
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:ReadFromGroupAddressArray[kWindSpeed] value:0 buttonName:nil valueLength:@"1Byte" commandType:@"Read"];
}
- (void) acOnOffToChangeWithState:(BOOL)isOn
{
    NSInteger sendValue = 0;
    
    if (isOn)
    {
        sendValue = 1;
    }
    else
    {
        sendValue = 0;
    }
    
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:[OnOffDict[@"WriteToGroupAddress"] objectForKey:@"0"] value:sendValue buttonName:nil valueLength:@"1Bit" commandType:@"Write"];
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:[OnOffDict[@"ReadFromGroupAddress"] objectForKey:@"0"] value:sendValue buttonName:nil valueLength:@"1Bit" commandType:@"Read"];
}
- (void) acWindSpeedToChangeWithButtonName:(NSString *)name
{
    NSInteger sendValue = -1;
    
    if ([name isEqualToString:@"高"])
    {
        sendValue = [WindSpeedDict[@"High"] integerValue];
    }
    else if([name isEqualToString:@"中"])
    {
        sendValue = [WindSpeedDict[@"Mid"] integerValue];
    }
    else if([name isEqualToString:@"低"])
    {
        sendValue = [WindSpeedDict[@"Low"] integerValue];
    }
    else if([name isEqualToString:@"自动"])
    {
        sendValue = [WindSpeedDict[@"Auto"] integerValue];
    }
    
    if (sendValue < 0)
    {
        return;
    }
    
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:[WindSpeedDict[@"WriteToGroupAddress"] objectForKey:@"0"] value:sendValue buttonName:nil valueLength:@"1Byte" commandType:@"Write"];
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:[WindSpeedDict[@"ReadFromGroupAddress"] objectForKey:@"0"] value:sendValue buttonName:nil valueLength:@"1Byte" commandType:@"Read"];

}
- (void) acModeToChangeWithButtonName:(NSString *)name
{
    NSInteger sendValue = -1;
    
    if ([name isEqualToString:@"制冷"])
    {
        sendValue = [ModeDict[@"Cool"] integerValue];
    }
    else if([name isEqualToString:@"制热"])
    {
        sendValue = [ModeDict[@"Heat"] integerValue];
    }
    else if([name isEqualToString:@"通风"])
    {
        sendValue = [ModeDict[@"Vent"] integerValue];
    }
    else if([name isEqualToString:@"除湿"])
    {
        sendValue = [ModeDict[@"Dehumidification"] integerValue];
    }
    
    if (sendValue < 0)
    {
        return;
    }
    
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:[ModeDict[@"WriteToGroupAddress"] objectForKey:@"0"] value:sendValue buttonName:nil valueLength:@"1Byte" commandType:@"Write"];
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:[ModeDict[@"ReadFromGroupAddress"] objectForKey:@"0"] value:sendValue buttonName:nil valueLength:@"1Byte" commandType:@"Read"];
}
- (void) acSettingEnvironmentTemperatureToChangeWithValue:(float)value
{
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:[SettingTemperatureDict[@"WriteToGroupAddress"] objectForKey:@"0"] value:value buttonName:nil valueLength:@"2Byte" commandType:@"Write"];
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:[SettingTemperatureDict[@"ReadFromGroupAddress"] objectForKey:@"0"] value:value buttonName:nil valueLength:@"2Byte" commandType:@"Read"];
}




- (void) acOnOffUpdateWithValue:(NSInteger)value
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       if (value == 1)
                       {
                           [acViewControllerSharedInstance.acOnOffButtonOutlet setSelected:YES];
                           [acViewControllerSharedInstance.acOnOffLabel setText:@"ON"];
                       }
                       else if(value == 0)
                       {
                           [acViewControllerSharedInstance.acOnOffButtonOutlet setSelected:NO];
                           [acViewControllerSharedInstance.acOnOffLabel setText:@"OFF"];
                       }
                   });
}

- (void) acSettingTemperatureUpdateWithValue:(NSInteger)value
{
    _settingEnvironmentTemperature = value;
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       [acViewControllerSharedInstance.acSettingTempratureLabel setText:[[NSString alloc] initWithFormat:@"%ld", (long)value]];
                   });
}

- (void) acModeUpdateWithValue:(NSInteger)value
{
    if (ModeDict == nil)
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       if (value == [ModeDict[@"Cool"] integerValue])
                       {
                           [acViewControllerSharedInstance.acModeCoolingButtonOutlet setSelected:YES];
                           [acViewControllerSharedInstance.acModeHeatingButtonOutlet setSelected:NO];
                           [acViewControllerSharedInstance.acModeVentingButtonOutlet setSelected:NO];
                           [acViewControllerSharedInstance.acModeDehumidificationButtonOutlet setSelected:NO];
                           [acViewControllerSharedInstance.acModeLabel setText:@"制冷"];
                       }
                       else if (value == [ModeDict[@"Heat"] integerValue])
                       {
                           [acViewControllerSharedInstance.acModeCoolingButtonOutlet setSelected:NO];
                           [acViewControllerSharedInstance.acModeHeatingButtonOutlet setSelected:YES];
                           [acViewControllerSharedInstance.acModeVentingButtonOutlet setSelected:NO];
                           [acViewControllerSharedInstance.acModeDehumidificationButtonOutlet setSelected:NO];
                           [acViewControllerSharedInstance.acModeLabel setText:@"制热"];
                       }
                       else if (value == [ModeDict[@"Vent"] integerValue])
                       {
                           [acViewControllerSharedInstance.acModeCoolingButtonOutlet setSelected:NO];
                           [acViewControllerSharedInstance.acModeHeatingButtonOutlet setSelected:NO];
                           [acViewControllerSharedInstance.acModeVentingButtonOutlet setSelected:YES];
                           [acViewControllerSharedInstance.acModeDehumidificationButtonOutlet setSelected:NO];
                           [acViewControllerSharedInstance.acModeLabel setText:@"通风"];
                       }
                       else if (value == [ModeDict[@"Dehumidification"] integerValue])
                       {
                           [acViewControllerSharedInstance.acModeCoolingButtonOutlet setSelected:NO];
                           [acViewControllerSharedInstance.acModeHeatingButtonOutlet setSelected:NO];
                           [acViewControllerSharedInstance.acModeVentingButtonOutlet setSelected:NO];
                           [acViewControllerSharedInstance.acModeDehumidificationButtonOutlet setSelected:YES];
                           [acViewControllerSharedInstance.acModeLabel setText:@"除湿"];
                       }
                    });
}

- (void) acWindSpeedUpdateWithValue:(NSInteger)value
{
    if (WindSpeedDict == nil)
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       if (value == [WindSpeedDict[@"High"] integerValue])
                       {
                           [acViewControllerSharedInstance.acWindSpeedHighButtonOutlet setSelected:YES];
                           [acViewControllerSharedInstance.acWindSpeedMidButtonOutlet setSelected:NO];
                           [acViewControllerSharedInstance.acWindSpeedLowButtonOutlet setSelected:NO];
                           [acViewControllerSharedInstance.acWindSpeedAutoButtonOutlet setSelected:NO];
                           [acViewControllerSharedInstance.acModeLabel setText:@"高"];
                       }
                       else if (value == [WindSpeedDict[@"Mid"] integerValue])
                       {
                           [acViewControllerSharedInstance.acWindSpeedHighButtonOutlet setSelected:NO];
                           [acViewControllerSharedInstance.acWindSpeedMidButtonOutlet setSelected:YES];
                           [acViewControllerSharedInstance.acWindSpeedLowButtonOutlet setSelected:NO];
                           [acViewControllerSharedInstance.acWindSpeedAutoButtonOutlet setSelected:NO];
                           [acViewControllerSharedInstance.acModeLabel setText:@"中"];
                       }
                       else if (value == [WindSpeedDict[@"Low"] integerValue])
                       {
                           [acViewControllerSharedInstance.acWindSpeedHighButtonOutlet setSelected:NO];
                           [acViewControllerSharedInstance.acWindSpeedMidButtonOutlet setSelected:NO];
                           [acViewControllerSharedInstance.acWindSpeedLowButtonOutlet setSelected:YES];
                           [acViewControllerSharedInstance.acWindSpeedAutoButtonOutlet setSelected:NO];
                           [acViewControllerSharedInstance.acModeLabel setText:@"低"];
                       }
                       else if (value == [WindSpeedDict[@"Auto"] integerValue])
                       {
                           [acViewControllerSharedInstance.acWindSpeedHighButtonOutlet setSelected:NO];
                           [acViewControllerSharedInstance.acWindSpeedMidButtonOutlet setSelected:NO];
                           [acViewControllerSharedInstance.acWindSpeedLowButtonOutlet setSelected:NO];
                           [acViewControllerSharedInstance.acWindSpeedAutoButtonOutlet setSelected:YES];
                           [acViewControllerSharedInstance.acModeLabel setText:@"自动"];
                       }
                    });
}

@end
