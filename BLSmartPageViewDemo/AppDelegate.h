//
//  AppDelegate.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/8/7.
//  Copyright (c) 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSMutableArray+QueueStack.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UINavigationItem *viewControllerNavigationItemSharedInstance;
    NSMutableDictionary *sceneListDictionarySharedInstance;
    dispatch_queue_t concurrentWriteToBusDataProcessQueue;
    dispatch_queue_t serialUdpWriteToBusQueue;
    NSMutableArray *transmitDataFIFO;
    /// Notification when Data updates (i.e. Download finishes)
    NSString *TransmitQueueDataUpdateNotification;
}

@property(strong, nonatomic) UINavigationItem *viewControllerNavigationItemSharedInstance;
@property(strong, nonatomic) NSMutableDictionary *sceneListDictionarySharedInstance;
//@property(strong, nonatomic) dispatch_queue_t transmitQueue;
@property(strong, atomic) NSMutableArray *transmitDataFIFO;
@property(strong, nonatomic) UIWindow *window;

-(void)pushDataToFIFOThreadSaveAndSendNotificationAsync:(id)value;
-(id)popDataFromFIFOThreadSave;


@end

