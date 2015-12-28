//
//  BLDimming.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/23.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLDimming.h"
#import "BLDimmingViewController.h"
#import "BLGCDKNXTunnellingAsyncUdpSocket.h"
#import "GlobalMacro.h"
#define dimmingViewControllerSharedInstance  [BLDimmingViewController sharedInstance]

enum DimmingReadFromGroupAddressObject
{
    kOnOff = 0,
    kValue,
};

@interface BLDimming()
{
    NSMutableDictionary *ValueDict;
    NSMutableDictionary *OnOffDict;
    
    NSDictionary *dimmingPropertyDict;
    
    NSMutableArray *ReadFromGroupAddressArray;
    NSMutableArray *WriteToGroupAddressArray;
    
    BLGCDKNXTunnellingAsyncUdpSocket *tunnellingShareInstance;
    NSMutableDictionary *overallRecevedKnxDataDict;
}
@end

@implementation BLDimming
/*
 entire app has only one BLDimming Class, s every diffent dimming buttons pressed
 with the same BLDimming Class, so diffent buttons should use - (void)updateItemsDict:(NSDictionary *)dict to
 up date the dimming item imformation.
 */



+ (instancetype)sharedInstance
{
    // 1
    static BLDimming *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[BLDimming alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
        tunnellingShareInstance  = [BLGCDKNXTunnellingAsyncUdpSocket sharedInstance];
        overallRecevedKnxDataDict = tunnellingShareInstance.overallReceivedKnxDataDict;
        
        ReadFromGroupAddressArray = [[NSMutableArray alloc] initWithCapacity:2];
        for (NSInteger i = 0; i < 2; ++i)
        {
            [ReadFromGroupAddressArray addObject:[NSNull null]];
        }
        WriteToGroupAddressArray = [[NSMutableArray alloc] initWithCapacity:2];
        for (NSInteger i = 0; i < 2; ++i)
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
    dimmingPropertyDict = dict;
    [dimmingPropertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if([key isEqualToString:@"Value"])
         {
             ValueDict = [[NSMutableDictionary alloc] initWithDictionary:obj];
             [ReadFromGroupAddressArray replaceObjectAtIndex:kValue withObject:[ValueDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
             [WriteToGroupAddressArray replaceObjectAtIndex:kValue withObject:[ValueDict[@"WriteToGroupAddress"] objectForKey:@"0"]];
         }
         else if([key isEqualToString:@"OnOff"])
         {
             OnOffDict = [[NSMutableDictionary alloc] initWithDictionary:obj];
             [ReadFromGroupAddressArray replaceObjectAtIndex:kOnOff withObject:[OnOffDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
             [WriteToGroupAddressArray replaceObjectAtIndex:kOnOff withObject:[OnOffDict[@"WriteToGroupAddress"] objectForKey:@"0"]];
         }
     }];
}

- (void)dimmingValueChangedWithValue:(float)value
{
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:WriteToGroupAddressArray[kValue] value:value buttonName:nil valueLength:@"1Byte" commandType:@"Write"];
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:ReadFromGroupAddressArray[kValue] value:0  buttonName:nil valueLength:@"1Byte" commandType:@"Read"];
}

- (void)dimmingOnOffChangedWithState:(BOOL)isOn
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


#pragma mark Receive From Bus
- (void)recvFromBus:(NSNotification*) notification
{
    
    if (dimmingViewControllerSharedInstance.view.superview == nil)
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
                [self dimmingOnOffStatusUpdateWithValue:value];
            }
            else if (index == kValue)
            {
                [self dimmingValueUpdateWithValue:value];
            }
            //            else if (index == kEnviromentTemperature)
            //            {
            //                [self heatingEnvironmentTemperatureStatusUpdateWithValue:value];
            //            }
        }
    }
}

- (void)tunnellingConnectSuccess
{
    if (dimmingViewControllerSharedInstance.view.superview == nil)
    {
        return;
    }
    [self setDimmingPanelViewFromOldData];
    [self readDimmingPanelStatus];
}

- (void)setDimmingPanelViewFromOldData
{
    
    if (overallRecevedKnxDataDict != nil)
    {
        NSString *objectValue = [overallRecevedKnxDataDict objectForKey:[OnOffDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
        [self dimmingOnOffStatusUpdateWithValue:[objectValue integerValue]];
        objectValue = [overallRecevedKnxDataDict objectForKey:[ValueDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
        [self dimmingValueUpdateWithValue:[objectValue integerValue]];
    }
}

- (void)readDimmingPanelStatus
{
    if ((ReadFromGroupAddressArray[kValue] == [NSNull null]) || (ReadFromGroupAddressArray[kOnOff] == [NSNull null]))
    {
        return;
    }
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:ReadFromGroupAddressArray[kOnOff] value:0 buttonName:nil valueLength:@"1Bit" commandType:@"Read"];
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:ReadFromGroupAddressArray[kValue] value:0 buttonName:nil valueLength:@"1Byte" commandType:@"Read"];
    
    
}

- (void)dimmingOnOffStatusUpdateWithValue:(NSInteger)value
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       if (value == 1)
                       {
                           [dimmingViewControllerSharedInstance.dimmingOnOffButtonOutlet setSelected:YES];
                       }
                       else if(value == 0)
                       {
                           [dimmingViewControllerSharedInstance.dimmingOnOffButtonOutlet setSelected:NO];
                       }
                   });

}

- (void)dimmingValueUpdateWithValue:(NSInteger)value
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       [dimmingViewControllerSharedInstance.dimmingSliderOutlet setValue:value animated:YES];
                   });
}
@end
