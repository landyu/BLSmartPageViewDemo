//
//  BLCurtain2.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/28.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLCurtain2.h"
#import "BLCurtain2ViewController.h"
#import "Curtain.h"
#import "BLGCDKNXTunnellingAsyncUdpSocket.h"
#import "GlobalMacro.h"
#define curtain2ViewControllerSharedInstance [BLCurtain2ViewController sharedInstance]

@interface BLCurtain2()
{
    NSDictionary *curtain2PropertyDict;
    Curtain *yarnCurtain;
    Curtain *clothCurtain;
    
    BLGCDKNXTunnellingAsyncUdpSocket *tunnellingShareInstance;
    NSMutableDictionary *overallRecevedKnxDataDict;
}
@end

@implementation BLCurtain2
+ (instancetype)sharedInstance
{
    // 1
    static BLCurtain2 *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[BLCurtain2 alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        yarnCurtain = [[Curtain alloc] init];
        clothCurtain = [[Curtain alloc] init];
        
        tunnellingShareInstance  = [BLGCDKNXTunnellingAsyncUdpSocket sharedInstance];
        overallRecevedKnxDataDict = tunnellingShareInstance.overallReceivedKnxDataDict;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvFromBus:) name:@"BL.BLSmartPageViewDemo.RecvFromBus" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tunnellingConnectSuccess) name:TunnellingConnectSuccessNotification object:nil];
    }
    return self;
}

- (void)updateItemsDict:(NSDictionary *)dict
{
    curtain2PropertyDict = dict;
    [curtain2PropertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"YarnCurtain"])
         {
             yarnCurtain.openCloseWriteToGroupAddress = [obj objectForKey:@"OpenClose"];
             yarnCurtain.stopWriteToGroupAddress = [obj objectForKey:@"Stop"];
             yarnCurtain.moveToPositionWriteToGroupAddress = [obj objectForKey:@"MoveToPosition"];
             yarnCurtain.positionStatusReadFromGroupAddress = [obj objectForKey:@"StatusHeight"];
         }
         else if ([key isEqualToString:@"ClothCurtain"])
         {
             clothCurtain.openCloseWriteToGroupAddress = [obj objectForKey:@"OpenClose"];
             clothCurtain.stopWriteToGroupAddress = [obj objectForKey:@"Stop"];
             clothCurtain.moveToPositionWriteToGroupAddress = [obj objectForKey:@"MoveToPosition"];
             clothCurtain.positionStatusReadFromGroupAddress = [obj objectForKey:@"StatusHeight"];
         }
     }];
}

- (void)yarnCurtainPositionToChangeWithValue:(float)value
{
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:yarnCurtain.moveToPositionWriteToGroupAddress value:value buttonName:nil valueLength:@"1Byte" commandType:@"Write"];
}

- (void)yarnCurtainToOpen
{
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:yarnCurtain.openCloseWriteToGroupAddress value:0 buttonName:nil valueLength:@"1Bit" commandType:@"Write"];
}

- (void)yarnCurtainToClose
{
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:yarnCurtain.openCloseWriteToGroupAddress value:1 buttonName:nil valueLength:@"1Bit" commandType:@"Write"];
}

- (void)yarnCurtainToStop
{
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:yarnCurtain.stopWriteToGroupAddress value:1 buttonName:nil valueLength:@"1Bit" commandType:@"Write"];
}
//////
- (void)clothCurtainPositionToChangeWithValue:(float)value
{
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:clothCurtain.moveToPositionWriteToGroupAddress value:value buttonName:nil valueLength:@"1Byte" commandType:@"Write"];
}

- (void)clothCurtainToOpen
{
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:clothCurtain.openCloseWriteToGroupAddress value:0 buttonName:nil valueLength:@"1Bit" commandType:@"Write"];
}

- (void)clothCurtainToClose
{
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:clothCurtain.openCloseWriteToGroupAddress value:1 buttonName:nil valueLength:@"1Bit" commandType:@"Write"];
}

- (void)clothCurtainToStop
{
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:clothCurtain.stopWriteToGroupAddress value:1 buttonName:nil valueLength:@"1Bit" commandType:@"Write"];
}

/////
- (void)allCurtainToOpen
{
    //[tunnellingShareInstance tunnellingSendWithDestGroupAddress:clothCurtain.openCloseWriteToGroupAddress value:0 buttonName:nil valueLength:@"1Bit" commandType:@"Write"];
}

- (void)allCurtainToClose
{
    //[tunnellingShareInstance tunnellingSendWithDestGroupAddress:clothCurtain.openCloseWriteToGroupAddress value:1 buttonName:nil valueLength:@"1Bit" commandType:@"Write"];
}

- (void)allCurtainToStop
{
    //[tunnellingShareInstance tunnellingSendWithDestGroupAddress:clothCurtain.stopWriteToGroupAddress value:1 buttonName:nil valueLength:@"1Bit" commandType:@"Write"];
}





#pragma mark Receive From Bus
- (void) recvFromBus: (NSNotification*) notification
{
    if (curtain2ViewControllerSharedInstance.view.superview == nil)
    {
        return;
    }
    
    NSDictionary *dict = [notification userInfo];
    if ([dict[@"Address"] isEqualToString:yarnCurtain.positionStatusReadFromGroupAddress])
    {
        NSInteger value = [dict[@"Value"] intValue];
        [self yarnCurtainPositionUpdateWithValue:value];
    }
    else if ([dict[@"Address"] isEqualToString:clothCurtain.positionStatusReadFromGroupAddress])
    {
        NSInteger value = [dict[@"Value"] intValue];
        [self clothCurtainPositionUpdateWithValue:value];
    }
}

- (void) tunnellingConnectSuccess
{
    if (curtain2ViewControllerSharedInstance.view.superview == nil)
    {
        return;
    }
    [self setCurtain2PanelViewFromOldData];
    [self readCurtain2PanelStatus];
}

- (void)setCurtain2PanelViewFromOldData
{
    
    if (overallRecevedKnxDataDict != nil)
    {
        NSString *objectValue = [overallRecevedKnxDataDict objectForKey:yarnCurtain.positionStatusReadFromGroupAddress];
        [self yarnCurtainPositionUpdateWithValue:[objectValue integerValue]];
        objectValue = [overallRecevedKnxDataDict objectForKey:clothCurtain.positionStatusReadFromGroupAddress];
        [self clothCurtainPositionUpdateWithValue:[objectValue integerValue]];
    }
}

- (void)readCurtain2PanelStatus
{
    if (yarnCurtain.positionStatusReadFromGroupAddress == nil)
    {
        return;
    }
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:yarnCurtain.positionStatusReadFromGroupAddress value:0 buttonName:nil valueLength:@"1Byte" commandType:@"Read"];
    if (clothCurtain.positionStatusReadFromGroupAddress == nil)
    {
        return;
    }
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:clothCurtain.positionStatusReadFromGroupAddress value:0 buttonName:nil valueLength:@"1Byte" commandType:@"Read"];
    
    
}

- (void)yarnCurtainPositionUpdateWithValue:(NSInteger)value
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       [curtain2ViewControllerSharedInstance.yarnCurtainSliderOutlet setValue:value animated:YES];
                   });
}

- (void)clothCurtainPositionUpdateWithValue:(NSInteger)value
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       [curtain2ViewControllerSharedInstance.clothCurtainSliderOutlet setValue:value animated:YES];
                   });
}

@end
