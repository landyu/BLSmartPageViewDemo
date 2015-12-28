//
//  BLCurtain.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/23.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLCurtain.h"
#import "BLCurtainViewController.h"
#import "Curtain.h"
#import "BLGCDKNXTunnellingAsyncUdpSocket.h"
#import "GlobalMacro.h"
#define curtainViewControllerSharedInstance [BLCurtainViewController sharedInstance]


@interface BLCurtain()
{
    NSDictionary *curtainPropertyDict;
    Curtain *singleCurtain;
    
    BLGCDKNXTunnellingAsyncUdpSocket *tunnellingShareInstance;
    NSMutableDictionary *overallRecevedKnxDataDict;
}
@end

@implementation BLCurtain
+ (instancetype)sharedInstance
{
    // 1
    static BLCurtain *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[BLCurtain alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        singleCurtain = [[Curtain alloc] init];
        
        tunnellingShareInstance  = [BLGCDKNXTunnellingAsyncUdpSocket sharedInstance];
        overallRecevedKnxDataDict = tunnellingShareInstance.overallReceivedKnxDataDict;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvFromBus:) name:@"BL.BLSmartPageViewDemo.RecvFromBus" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tunnellingConnectSuccess) name:TunnellingConnectSuccessNotification object:nil];
    }
    return self;
}

- (void)updateItemsDict:(NSDictionary *)dict
{
    curtainPropertyDict = dict;
    [curtainPropertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"Curtain"])
         {
             singleCurtain.openCloseWriteToGroupAddress = [obj objectForKey:@"OpenClose"];
             singleCurtain.stopWriteToGroupAddress = [obj objectForKey:@"Stop"];
             singleCurtain.moveToPositionWriteToGroupAddress = [obj objectForKey:@"MoveToPosition"];
             singleCurtain.positionStatusReadFromGroupAddress = [obj objectForKey:@"StatusHeight"];
         }
     }];
}

- (void)curtainPositionToChangeWithValue:(float)value
{
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:singleCurtain.moveToPositionWriteToGroupAddress value:value buttonName:nil valueLength:@"1Byte" commandType:@"Write"];
}

- (void)curtainToOpen
{
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:singleCurtain.openCloseWriteToGroupAddress value:0 buttonName:nil valueLength:@"1Bit" commandType:@"Write"];
}

- (void)curtainToClose
{
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:singleCurtain.openCloseWriteToGroupAddress value:1 buttonName:nil valueLength:@"1Bit" commandType:@"Write"];
}

- (void)curtainToStop
{
        [tunnellingShareInstance tunnellingSendWithDestGroupAddress:singleCurtain.stopWriteToGroupAddress value:1 buttonName:nil valueLength:@"1Bit" commandType:@"Write"];
}


#pragma mark Receive From Bus
- (void) recvFromBus: (NSNotification*) notification
{
    if (curtainViewControllerSharedInstance.view.superview == nil)
    {
        return;
    }
    
    NSDictionary *dict = [notification userInfo];
    if ([dict[@"Address"] isEqualToString:singleCurtain.positionStatusReadFromGroupAddress])
    {
        NSInteger value = [dict[@"Value"] intValue];
        [self curtainPositionUpdateWithValue:value];
    }
}

- (void) tunnellingConnectSuccess
{
    if (curtainViewControllerSharedInstance.view.superview == nil)
    {
        return;
    }
    [self setCurtainPanelViewFromOldData];
    [self readCurtainPanelStatus];
}

- (void)setCurtainPanelViewFromOldData
{
    
    if (overallRecevedKnxDataDict != nil)
    {
        NSString *objectValue = [overallRecevedKnxDataDict objectForKey:singleCurtain.positionStatusReadFromGroupAddress];
        [self curtainPositionUpdateWithValue:[objectValue integerValue]];
    }
}

- (void)readCurtainPanelStatus
{
    if (singleCurtain.positionStatusReadFromGroupAddress == nil)
    {
        return;
    }
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:singleCurtain.positionStatusReadFromGroupAddress value:0 buttonName:nil valueLength:@"1Byte" commandType:@"Read"];
    
    
}


- (void)curtainPositionUpdateWithValue:(NSInteger)value
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       [curtainViewControllerSharedInstance.curtainSliderOutlet setValue:value animated:YES];
                   });
}
@end
