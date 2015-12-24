//
//  APPChildViewController.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/8/7.
//  Copyright (c) 2015年 Landyu. All rights reserved.
//

#import "APPChildViewController.h"
#import <AVFoundation/AVFoundation.h>
//#import "ViewController.h"
//#import "AppDelegate.h"
#import "BLGCDKNXTunnellingAsyncUdpSocket.h"
#import "Utils.h"
#import "BLUISwitch.h"
#import "BLUISceneButton.h"
#import "BLUIACButton.h"
#import "BLUIHeatingButton.h"
#import "BLHeating.h"
#import "BLACViewController.h"
#import "BLUICurtain2Button.h"
#import "BLCurtain2ViewController.h"
#import "BLDimmingButton.h"
#import "BLDimming.h"
#import "BLUICurtainButton.h"
#import "BLCurtain.h"
#import "BLUIPageJumpButton.h"
#import "GlobalMacro.h"
#import "ViewControllerContainer.h"



@interface APPChildViewController ()
{
    //dispatch_queue_t transmitActionQueue;
    //NSMutableArray * childTransmitDataFIFO;
    //AppDelegate *appDelegate;
    BLGCDKNXTunnellingAsyncUdpSocket *tunnellingAsyncUdpSocketSharedInstance;
    //NSString *widgetPlistPath;
    NSMutableDictionary *viewNibPlistDict;
    UIViewController  *activeVC;
    CGFloat phywidth;
    CGFloat phyheight;
    NSString *nibName;
}

@end

@implementation APPChildViewController
@synthesize nibName;

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
//    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentPath = [documentPaths objectAtIndex:0];
//    NSString* roomInfoDirPath = [documentPath stringByAppendingPathComponent:@"RoomInfo"];
//    NSString *nibFilePath = [roomInfoDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%s.xib.bin", nibNameOrNil]];
//    NSBundle *bundle = [NSBundle bundleWithPath:nibFilePath];
    
    
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [documentPaths objectAtIndex:0];
    NSString* roomInfoDirPath = [documentPath stringByAppendingPathComponent:@"RoomInfo"];
    NSString *nibFilePath = [roomInfoDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.xib.bin", nibNameOrNil]];
    //NSBundle *bundle = [NSBundle bundleWithPath:nibFilePath];
    [NSBundle bundleWithPath:roomInfoDirPath];
    NSData *data = [NSData dataWithContentsOfFile:nibFilePath];
    if (data == nil)
    {
        return nil;
    }
    
    nibName = [NSString stringWithFormat:@"%@", nibNameOrNil];
    
    return [super initWithNibName:nil  bundle:nil];
    
}

- (void)loadView
{
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [documentPaths objectAtIndex:0];
    NSString* roomInfoDirPath = [documentPath stringByAppendingPathComponent:@"RoomInfo"];
    NSString *nibFilePath = [roomInfoDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.xib.bin", nibName]];
    NSBundle *bundle = [NSBundle bundleWithPath:nibFilePath];
    //[bundle load];
    
    [NSBundle bundleWithPath:roomInfoDirPath];
    NSData *data = [NSData dataWithContentsOfFile:nibFilePath];
    
    UINib *nib = [UINib nibWithData:data bundle:bundle];
    [nib instantiateWithOwner:self options:nil];
    //[super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    activeVC = nil;
    viewNibPlistDict = nil;

    self.view.tag = self.index;
    
    LogInfo(@"view count = %lu", (unsigned long)self.view.subviews.count);
    
    CGRect rect = [self.view bounds];
    CGSize size = rect.size;
    phywidth = size.width;
    phyheight = size.height;
    
    //appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    tunnellingAsyncUdpSocketSharedInstance = [BLGCDKNXTunnellingAsyncUdpSocket sharedInstance];
    //transmitActionQueue = appDelegate.transmitQueue;
    //childTransmitDataFIFO = appDelegate.transmitDataFIFO;
    
    //NSString *widgetPlistPath = [[NSBundle mainBundle] pathForResource:self.nibName ofType:@"plist"];
    //viewNibPlistDict = [[NSMutableDictionary alloc]initWithContentsOfFile:widgetPlistPath];
    
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [documentPaths objectAtIndex:0];
    NSString* roomInfoDirPath = [documentPath stringByAppendingPathComponent:@"RoomInfo"];
    NSString *propertyConfigPath = [roomInfoDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", self.nibName]];
    
    BOOL isDir = YES;
    BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:roomInfoDirPath isDirectory:&isDir];
    if ((isDir == YES && existed == YES))
    {
        isDir = NO;
        existed = [[NSFileManager defaultManager] fileExistsAtPath:propertyConfigPath isDirectory:&isDir];
        if (existed == NO)
        {
            return;
        }
    }
    else
    {
        return;
    }
    
    
    viewNibPlistDict = [[NSMutableDictionary alloc]initWithContentsOfFile:propertyConfigPath];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvFromBus:) name:@"BL.BLSmartPageViewDemo.RecvFromBus" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tunnellingConnectSuccess) name:TunnellingConnectSuccessNotification object:nil];
    
    //dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, 150ull * NSEC_PER_MSEC);
    
    //dispatch_after(delayTime, [Utils GlobalMainQueue],
    dispatch_async([Utils GlobalMainQueue],
                   ^{
                       for (UIView *subView in self.view.subviews)
                       {
                           if ([subView isMemberOfClass:[BLUISwitch class]])
                           {
                               BLUISwitch *switchButton = (BLUISwitch *) subView;
                               
                               [switchButton addTarget:self action:@selector(switchButtonPressd:) forControlEvents:UIControlEventTouchUpInside];
                               
                           }
                           else if ([subView isMemberOfClass:[BLUISceneButton class]])
                           {
                               BLUISceneButton *sceneButton = (BLUISceneButton *) subView;
                               
                               [self parseSceneButtonWithNibPlistDict:viewNibPlistDict object:sceneButton];
                               [sceneButton addTarget:self action:@selector(sceneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                           }
                           else if([subView isMemberOfClass:[BLUIACButton class]])
                           {
                               BLUIACButton *acButton = (BLUIACButton *) subView;
                               
                               //dispatch_async([Utils GlobalBackgroundQueue], ^(void)
                                              //{
                                                  [acButton addEnviromentTemperatureLabelWithParentController:self];
                                                  [self initACButtonWithACButtonObject:acButton nibPlistDict:viewNibPlistDict];
                                                  [acButton addTarget:self action:@selector(acButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                                              //});
                               
                           }
                           else if([subView isMemberOfClass:[BLUIHeatingButton class]])
                           {
                               BLUIHeatingButton *heatingButton = (BLUIHeatingButton *) subView;
                               
                               //dispatch_async([Utils GlobalBackgroundQueue], ^(void)
                               //{
                               [heatingButton addEnviromentTemperatureLabelWithParentController:self];
                               [self initHeatingButtonWithHeatingButtonObject:heatingButton nibPlistDict:viewNibPlistDict];
                               [heatingButton addTarget:self action:@selector(heatingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                               //});
                               
                           }
                           else if([subView isMemberOfClass:[BLUICurtain2Button class]])
                           {
                               //dispatch_async([Utils GlobalBackgroundQueue], ^(void)
                                              //{
                                                  BLUICurtain2Button *curtain2Button = (BLUICurtain2Button *) subView;
                                                  [self initCurtain2ButtonWithCurtainButtonObject:curtain2Button nibPlistDict:viewNibPlistDict];
                                                  [curtain2Button addTarget:self action:@selector(curtain2ButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                                              //});
                           }
                           else if([subView isMemberOfClass:[BLUICurtainButton class]])
                           {
                               //dispatch_async([Utils GlobalBackgroundQueue], ^(void)
                               //{
                               BLUICurtainButton *curtainButton = (BLUICurtainButton *) subView;
                               [self initCurtainButtonWithCurtainButtonObject:curtainButton nibPlistDict:viewNibPlistDict];
                               [curtainButton addTarget:self action:@selector(curtainButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                               //});
                           }
                           else if([subView isMemberOfClass:[BLDimmingButton class]])
                           {
                               //dispatch_async([Utils GlobalBackgroundQueue], ^(void)
                               //{
                               BLDimmingButton *dimmingButton = (BLDimmingButton *) subView;
                               [self initDimmingButtonWithHeatingButtonObject:dimmingButton nibPlistDict:viewNibPlistDict];
                               [dimmingButton addTarget:self action:@selector(dimmingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                               //});
                           }
                           else if([subView isMemberOfClass:[BLUIPageJumpButton class]])
                           {
                               BLUIPageJumpButton *pageJumpButton = (BLUIPageJumpButton *) subView;
                               [pageJumpButton addTarget:self action:@selector(pageJumpButtonPressd:) forControlEvents:UIControlEventTouchUpInside];
                           }
                           
                       }
                       
                       [self getAllWidgetsStatus];
                   });
    
    
    //appDelegate.viewControllerNavigationItemSharedInstance = self.viewControllerNavigationItem;
    
    
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark Switch Button

- (void)switchButtonPressd:(BLUISwitch *)sender {
    
    //__block NSInteger transmitValue;
    
    LogInfo(@"SwitchButtonPressd #%ld, objName = %@", (long)self.index, sender.objName);
    [self playClickSound];
    
    if (activeVC != nil)
    {
        [activeVC.view removeFromSuperview];
        activeVC = nil;
        if (self.pageController.dataSource == nil)
        {
            self.pageController.dataSource = self.pageControllerDataSource;
        }
    }

    
    //NSString *path = [[NSBundle mainBundle] pathForResource:self.nibName ofType:@"plist"];
    
    if (!viewNibPlistDict) {
        return;
    }
    //NSMutableDictionary *nibPlistDict = [[NSMutableDictionary alloc]initWithContentsOfFile:widgetPlistPath];
    
    
    //__block NSMutableDictionary *readFromGroupAddressDict = [[NSMutableDictionary alloc] initWithDictionary:temDict[key]];
    for (NSUInteger itemIndex = 0; itemIndex < [viewNibPlistDict count]; itemIndex++)
    {
        NSDictionary *itemDict = [viewNibPlistDict objectForKey:[NSString stringWithFormat:@"%ld", (long)itemIndex]];
        [itemDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             
             //NSLog(@"dict[%@] = %@", key, temDict[key]);
             //NSString *objectName = (NSString *)key;
             if ([key isEqualToString:sender.objName])
             {
                 NSMutableDictionary *objectPropertyDict = [[NSMutableDictionary alloc] initWithDictionary:viewNibPlistDict[key]];
                 [objectPropertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                  {
                      if ([key isEqualToString:@"WriteToGroupAddress"])
                      {
                          NSString *valueLength = [[NSString alloc]initWithString:objectPropertyDict[@"ValueLength"]];
                          NSMutableDictionary *writeToGroupAddressDict = [[NSMutableDictionary alloc] initWithDictionary:objectPropertyDict[key]];
                          [writeToGroupAddressDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                           {
                               [self parseDataForPreTransmitWithObject:sender destGroupAddress:writeToGroupAddressDict[key] buttonName:sender.objName valueLength:valueLength objectPropertyDictionay:objectPropertyDict];
                           }];
                      }
                  }];
             }
         }];
    }
}

- (void) parseDataForPreTransmitWithObject:(BLUISwitch *)obj destGroupAddress:(NSString *)destGroupAddress buttonName:(NSString *)buttonName valueLength:(NSString *)valueLength objectPropertyDictionay:(NSMutableDictionary *)objectPropertyDict
{
    //NSLog(@"writeToGroupAddressDict[%@] = %@", key, writeToGroupAddressDict[key]);
    __block NSInteger transmitValue;
    
    if ([valueLength isEqualToString:@"1Bit"])
    {
        if ([obj isSelected])
        {
            transmitValue = 0;
        }
        else
        {
            transmitValue = 1;
        }
        
    }
    else if([valueLength isEqualToString:@"1Byte"])
    {
        [objectPropertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             if ([key isEqualToString:@"WriteToValue"])
             {
                 transmitValue = [(NSString *)obj integerValue];
             }
         }];
    }
    else
    {
        return;
    }
    
    [self blUIButtonTransmitActionWithDestGroupAddress:destGroupAddress value:transmitValue buttonName:buttonName valueLength:valueLength];
}

#pragma mark Scene Button
- (void) sceneButtonPressed:(BLUISceneButton *)sender
{
    //__block NSInteger transmitValue;
    
    LogInfo(@"SceneButtonPressd #%ld, objName = %@", (long)self.index, sender.objName);
    [self playClickSound];
    
    if (activeVC != nil)
    {
        [activeVC.view removeFromSuperview];
        activeVC = nil;
        if (self.pageController.dataSource == nil)
        {
            self.pageController.dataSource = self.pageControllerDataSource;
        }
    }

    
    //NSString *path = [[NSBundle mainBundle] pathForResource:self.nibName ofType:@"plist"];
    dispatch_async([Utils GlobalBackgroundQueue],
    ^{
        [sender.sceneSequenceMutableDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             NSDictionary *sceneDict = (NSDictionary *)obj;
             [self blUIButtonTransmitActionWithDestGroupAddress:sceneDict[@"WriteToGroupAddress"] value:[sceneDict[@"Value"] integerValue] buttonName:sender.objName valueLength:sceneDict[@"ValueLength"]];
             [NSThread sleepForTimeInterval:[sender.sceneDelayDuration doubleValue]];
         }];
    });
    
}

- (void) parseSceneButtonWithNibPlistDict:(NSMutableDictionary *)nibPlistDict object:(BLUISceneButton *)sceneButton
{
    if (!nibPlistDict) {
        return;
    }

    for (NSUInteger itemIndex = 0; itemIndex < [viewNibPlistDict count]; itemIndex++)
    {
        NSDictionary *itemDict = [viewNibPlistDict objectForKey:[NSString stringWithFormat:@"%ld", (long)itemIndex]];
        [itemDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             
             if ([key isEqualToString:sceneButton.objName])
             {
                 NSMutableDictionary *objectPropertyDict = [[NSMutableDictionary alloc] initWithDictionary:obj];
                 sceneButton.sceneDelayDuration = [NSNumber numberWithFloat:[objectPropertyDict[@"SceneDelayDuration"] floatValue]];
                 sceneButton.sceneSequenceMutableDict = [[NSMutableDictionary alloc] initWithDictionary:objectPropertyDict[@"Scene"]];
                 //sceneButton.sceneCount = [sceneButton.sceneSequenceMutableDict count];
             }
         }];
    }

}

#pragma mark AC Button
- (void) acButtonPressed:(BLUIACButton *)sender
{
    [self playClickSound];
    //[self playClickSound];
//    if (sender.acViewController == nil)
//    {
////        acVC = [[BLACViewController alloc] init];
////        acVC.view.frame = CGRectMake(phywidth/2.0 - 298.0/2.0, phyheight/2.0 - 589.0/2.0, 589, 298);
////        //acVC.view.backgroundColor = [UIColor clearColor];
////        [self.view addSubview:acVC.view];
//    }
//    else
    {
        if (activeVC != nil)
        {
            [activeVC.view removeFromSuperview];
            activeVC = nil;
            //sender.acViewController.view = nil;
            if (self.pageController.dataSource == nil)
            {
                self.pageController.dataSource = self.pageControllerDataSource;
            }
        }
        //UIView *acView = [[[NSBundle mainBundle] loadNibNamed:@"BLACView" owner:sender.acViewController options:nil] firstObject];
        //acView.frame = CGRectMake(phywidth/2.0 - 589.0/2.0, phyheight/2.0 - 298.0/2.0, 589, 298);
        //sender.acViewController.view = acView;
        [sender.acViewController initACPanelView];
        //dispatch_async([Utils GlobalUserInitiatedQueue],
                       //^{
                         [sender.acViewController initReadACPanelWidgetStatus];
                       //});
        
        activeVC = sender.acViewController;
        [self.view addSubview:activeVC.view];
    }

}

- (void) initACButtonWithACButtonObject:(BLUIACButton *)acButton nibPlistDict:(NSMutableDictionary *)nibPlistDict
{
    
    
    //dispatch_async([Utils GlobalUserInteractiveQueue],
                   //^{
                       acButton.acViewController = [[BLACViewController alloc] init];
                       acButton.acViewController.delegate = self;
                       acButton.acViewController.overallRecevedKnxDataDict = tunnellingAsyncUdpSocketSharedInstance.overallReceivedKnxDataDict;
                       //acButton.acViewController.view = nil;
                        LogInfo(@"acButton.acViewController.view = %@", acButton.acViewController.view);
                       //acButton.acViewController.view.frame = CGRectMake(phywidth/2.0 - 298.0/2.0, phyheight/2.0 - 589.0/2.0, 589, 298);
                       //acButton.acViewController.view =
                       if (!nibPlistDict) {
                           return;
                       }
    
    for (NSUInteger itemIndex = 0; itemIndex < [nibPlistDict count]; itemIndex++)
    {
        NSDictionary *itemDitc = [nibPlistDict objectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)itemIndex]];
        
        [itemDitc enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             
             if ([key isEqualToString:acButton.objName])
             {
                 [acButton.acViewController initACPropertyWithDictionary:obj buttonName:acButton.objName];
                 *stop = YES;
             }
         }];
    }
    

                   //});
    
    
}


#pragma mark Heating Button
- (void) heatingButtonPressed:(BLUIHeatingButton *)sender
{
    [self playClickSound];
    if (activeVC != nil)
    {
        [activeVC.view removeFromSuperview];
        activeVC = nil;
        //sender.acViewController.view = nil;
        if (self.pageController.dataSource == nil)
        {
            self.pageController.dataSource = self.pageControllerDataSource;
        }
    }
    ViewControllerContainer *viewControllerCotainerSharedInstance = [ViewControllerContainer sharedInstance];
    if (viewControllerCotainerSharedInstance.heatingViewController == nil)
    {
        NSLog(@"ERROR heatingViewController == NILL");
        return;
    }
    BLHeating *heatingSharedInstance = [BLHeating sharedInstance];
    [heatingSharedInstance updateItemsDict:sender.heatingPropertyDict];
    
    [heatingSharedInstance setHeatingPanelViewFromOldData];
    [heatingSharedInstance readHeatingPanelStatus];
    
    //[sender.acViewController initACPanelView];
    activeVC = viewControllerCotainerSharedInstance.heatingViewController;
    [self.view addSubview:activeVC.view];
}


- (void) initHeatingButtonWithHeatingButtonObject:(BLUIHeatingButton *)heatingButton nibPlistDict:(NSMutableDictionary *)nibPlistDict
{
    
    //acButton.acViewController.delegate = self;
    //acButton.acViewController.overallRecevedKnxDataDict = tunnellingAsyncUdpSocketSharedInstance.overallReceivedKnxDataDict;
    //LogInfo(@"acButton.acViewController.view = %@", acButton.acViewController.view);
    //acButton.acViewController.view.frame = CGRectMake(phywidth/2.0 - 298.0/2.0, phyheight/2.0 - 589.0/2.0, 589, 298);
    //acButton.acViewController.view =
    if (!nibPlistDict) {
        return;
    }
    
    for (NSUInteger itemIndex = 0; itemIndex < [nibPlistDict count]; itemIndex++)
    {
        NSDictionary *itemDitc = [nibPlistDict objectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)itemIndex]];
        
        [itemDitc enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             
             if ([key isEqualToString:heatingButton.objName])
             {
                 heatingButton.heatingPropertyDict = obj;
                 *stop = YES;
             }
         }];
    }
    
    
    //});
    
    
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    //CGPoint touchPoint = [touch locationInView:[touch view]];//获取坐标相对于当前视图
    CGPoint touchPoint = [touch locationInView:self.view];//获取视图坐标相对于父视图与子视图无关
    //touchPoint.x ，touchPoint.y 就是触点的坐标。
    //   NSLog(@"x = %f  y = %f",touchPoint.x, touchPoint.y);
    CGRect acVCRect = activeVC.view.frame;
    //    NSLog(@"curRect.origin.x = %f  curRect.origin.y = %f curRect.size.height = %f curRect.size.width = %f",curRect.origin.x, curRect.origin.y, curRect.size.height, curRect.size.width);
    //  curRect.origin.x
    if ([self isInThisRectWithRectOrigX:acVCRect.origin.x rectOrigY:acVCRect.origin.y rectSizeH:acVCRect.size.height rectSizeW:acVCRect.size.width pointX:touchPoint.x pointY:touchPoint.y])
    {
        //NSLog(@"This point is within area!!");
    }
    else
    {
        if (activeVC != nil) {
            [self playClickSound];
            //[self.view rem];
            [activeVC.view removeFromSuperview];
            self.pageController.dataSource = self.pageControllerDataSource;
            activeVC = nil;
            //acVC.view = nil;
            //removeFromSuperview
        }
        //NSLog(@"This point is not within area!!");
    }
    
    //NSLog(@"touchesBegan");
    
}

- (void) blACSendWithDestGroupAddress:(NSString *)destGroupAddress value:(NSInteger)value buttonName:(NSString *)name valueLength:(NSString *)valueLength commandType:(NSString *)commangType
{
    [tunnellingAsyncUdpSocketSharedInstance tunnellingSendWithDestGroupAddress:destGroupAddress value:value buttonName:name valueLength:valueLength commandType:commangType];
}
- (void) blACInitReadWithDestGroupAddress:(NSString *)destGroupAddress value:(NSInteger)value buttonName:(NSString *)name valueLength:(NSString *)valueLength
{
    [tunnellingAsyncUdpSocketSharedInstance tunnellingSendWithDestGroupAddress:destGroupAddress value:value buttonName:name valueLength:valueLength commandType:@"Read"];
}

#pragma mark Curtain2 Button
- (void) initCurtain2ButtonWithCurtainButtonObject:(BLUICurtain2Button *)curtainButton nibPlistDict:(NSMutableDictionary *)nibPlistDict
{
    //dispatch_sync([Utils GlobalUserInteractiveQueue],
                   //^{
                       curtainButton.curtainViewController = [[BLCurtain2ViewController alloc] init];
                       curtainButton.curtainViewController.delegate = self;
                       curtainButton.curtainViewController.overallRecevedKnxDataDict = tunnellingAsyncUdpSocketSharedInstance.overallReceivedKnxDataDict;
                       
                       if (!nibPlistDict)
                       {
                           return;
                       }
    
    for (NSUInteger itemIndex = 0; itemIndex < [nibPlistDict count]; itemIndex++)
    {
        NSDictionary *itemDitc = [nibPlistDict objectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)itemIndex]];
        
        [itemDitc enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             
             if ([key isEqualToString:curtainButton.objName])
             {
                 [curtainButton.curtainViewController initCurtainPropertyWithDictionary:obj buttonName:curtainButton.objName];
                 *stop = YES;
             }
         }];
    }
    
    
                   //});

}

- (void) curtain2ButtonPressed:(BLUICurtain2Button *)sender
{
    [self playClickSound];
    //[self playClickSound];
//    if (sender.curtainViewController == nil)
//    {
//        //        acVC = [[BLACViewController alloc] init];
//        //        acVC.view.frame = CGRectMake(phywidth/2.0 - 298.0/2.0, phyheight/2.0 - 589.0/2.0, 589, 298);
//        //        //acVC.view.backgroundColor = [UIColor clearColor];
//        //        [self.view addSubview:acVC.view];
//    }
//    else
    {
        if (activeVC != nil)
        {
            [activeVC.view removeFromSuperview];
            activeVC = nil;
        }
        [sender.curtainViewController initPanelView];
        //dispatch_async([Utils GlobalUserInitiatedQueue],
        //^{
        [sender.curtainViewController initReadCurtainPanelWidgetStatus];
        //});
        activeVC = sender.curtainViewController;
        [self.view addSubview:sender.curtainViewController.view];
        //self.parentViewController
        self.pageController.dataSource = nil;
    }
}




- (void) blCurtainSendWithDestGroupAddress:(NSString *)destGroupAddress value:(NSInteger)value buttonName:(NSString *)name valueLength:(NSString *)valueLength commandType:(NSString *)commangType
{
    [tunnellingAsyncUdpSocketSharedInstance tunnellingSendWithDestGroupAddress:destGroupAddress value:value buttonName:name valueLength:valueLength commandType:commangType];
}

#pragma mark Curtain Button
- (void) initCurtainButtonWithCurtainButtonObject:(BLUICurtainButton *)curtainButton nibPlistDict:(NSMutableDictionary *)nibPlistDict
{
    if (!nibPlistDict) {
        return;
    }
    
    for (NSUInteger itemIndex = 0; itemIndex < [nibPlistDict count]; itemIndex++)
    {
        NSDictionary *itemDitc = [nibPlistDict objectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)itemIndex]];
        
        [itemDitc enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             
             if ([key isEqualToString:curtainButton.objName])
             {
                 curtainButton.curtainPropertyDict = obj;
                 *stop = YES;
             }
         }];
    }
}
- (void) curtainButtonPressed:(BLUICurtainButton *)sender
{
    [self playClickSound];
    
    if (activeVC != nil)
    {
        [activeVC.view removeFromSuperview];
        activeVC = nil;
    }
    
    ViewControllerContainer *viewControllerCotainerSharedInstance = [ViewControllerContainer sharedInstance];
    if (viewControllerCotainerSharedInstance.curtainViewController == nil)
    {
        NSLog(@"ERROR curtainViewController == NILL");
        return;
    }
    BLCurtain *curtainSharedInstance = [BLCurtain sharedInstance];
    [curtainSharedInstance updateItemsDict:sender.curtainPropertyDict];
    
    //[sender.acViewController initACPanelView];
    activeVC = viewControllerCotainerSharedInstance.curtainViewController;
    [self.view addSubview:activeVC.view];
    self.pageController.dataSource = nil; //avoid move the slider to change the page view
}

#pragma mark Dimming Button
- (void)dimmingButtonPressed:(BLDimmingButton *)sender
{
    [self playClickSound];
    
    if (activeVC != nil)
    {
        [activeVC.view removeFromSuperview];
        activeVC = nil;
    }
    
    ViewControllerContainer *viewControllerCotainerSharedInstance = [ViewControllerContainer sharedInstance];
    if (viewControllerCotainerSharedInstance.dimmingViewController == nil)
    {
        NSLog(@"ERROR dimmingViewController == NILL");
        return;
    }
    BLDimming *dimmingSharedInstance = [BLDimming sharedInstance];
    [dimmingSharedInstance updateItemsDict:sender.dimmingPropertyDict];
    
    //[sender.acViewController initACPanelView];
    activeVC = viewControllerCotainerSharedInstance.dimmingViewController;
    [self.view addSubview:activeVC.view];
    self.pageController.dataSource = nil; //avoid move the slider to change the page view
}

- (void) initDimmingButtonWithHeatingButtonObject:(BLDimmingButton *)dimmingButton nibPlistDict:(NSMutableDictionary *)nibPlistDict
{
    if (!nibPlistDict) {
        return;
    }
    
    for (NSUInteger itemIndex = 0; itemIndex < [nibPlistDict count]; itemIndex++)
    {
        NSDictionary *itemDitc = [nibPlistDict objectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)itemIndex]];
        
        [itemDitc enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             
             if ([key isEqualToString:dimmingButton.objName])
             {
                 dimmingButton.dimmingPropertyDict = obj;
                 *stop = YES;
             }
         }];
    }
    
    
}

#pragma mark Page Jump Button
- (void)pageJumpButtonPressd:(BLUIPageJumpButton *)sender
{
    [self playClickSound];
    NSDictionary *pageJumpDict = [NSDictionary dictionaryWithObjectsAndKeys:sender.objName, @"PageName",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:PageJumpNotification object:self userInfo:pageJumpDict];
}

#pragma mark Send Write Command
- (void) blUIButtonTransmitActionWithDestGroupAddress:(NSString *)destGroupAddress value:(NSInteger)value buttonName:(NSString *)name valueLength:(NSString *)valueLength
{

    //NSDictionary *transmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:destGroupAddress, @"GroupAddress",  [NSString stringWithFormat: @"%ld", (long)value], @"Value", valueLength, @"ValueLength", @"Write", @"CommandType", nil];
    //[appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:transmitDataDict];
    [tunnellingAsyncUdpSocketSharedInstance tunnellingSendWithDestGroupAddress:destGroupAddress value:value buttonName:name valueLength:valueLength commandType:@"Write"];
}

#pragma mark Receive From Bus
- (void) recvFromBus: (NSNotification*) notification
{
    NSDictionary *dict = [notification userInfo];
    //NSLog(@"receive data from bus at NibName = %@ Scene %ld dict = %@", self.nibName,(long)self.index, dict);
    [self actionWithGroupAddress:dict[@"Address"] withObjectValue:[dict[@"Value"] intValue]];
}

- (void) tunnellingConnectSuccess
{
    [self getAllWidgetsStatus];
}

//-(void)dealloc
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}


- (void)actionWithGroupAddress:(NSString *)groupAddress withObjectValue:(NSInteger)objectValue
{
    //NSString *path = [[NSBundle mainBundle] pathForResource:self.nibName ofType:@"plist"];
    
    if (!viewNibPlistDict) {
        return;
    }
    //NSMutableDictionary *nibPlistDict = [[NSMutableDictionary alloc]initWithContentsOfFile:widgetPlistPath];
    
    
    //__block NSMutableDictionary *readFromGroupAddressDict = [[NSMutableDictionary alloc] initWithDictionary:temDict[key]];
    for (NSUInteger itemIndex = 0; itemIndex < [viewNibPlistDict count]; itemIndex++)
    {
        NSDictionary *itemDitc = [viewNibPlistDict objectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)itemIndex]];
        
        [itemDitc enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             
             //NSLog(@"dict[%@] = %@", key, temDict[key]);
             NSString *objectName = (NSString *)key;
             
             NSMutableDictionary *objectPropertyDict = [[NSMutableDictionary alloc] initWithDictionary:obj];
             
             for (UIView *subView in self.view.subviews)
             {
                 if ([subView isMemberOfClass:[BLUISwitch class]])
                 {
                     BLUISwitch *switchButton = (BLUISwitch *) subView;
                     
                     if ([switchButton.objName isEqualToString:objectName])
                     {
                         [objectPropertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                          {
                              if ([key isEqualToString:@"ReadFromGroupAddress"])
                              {
                                  NSString *valueLength = [[NSString alloc]initWithString:objectPropertyDict[@"ValueLength"]];
                                  NSMutableDictionary *readFromGroupAddressDict = [[NSMutableDictionary alloc] initWithDictionary:obj];
                                  [readFromGroupAddressDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                                   {
                                       //NSLog(@"readFromGroupAddressDict[%@] = %@", key, obj);
                                       if ([readFromGroupAddressDict[key] isEqualToString:groupAddress])
                                       {
                                           dispatch_async(dispatch_get_main_queue(),
                                                          ^{
                                                              [self blUISwitchUpdateActionWithButtonObject:switchButton buttonValue:objectValue buttonName:objectName valueLength:valueLength];
                                                          });
                                       }
                                   }];
                              }
                          }];
                         
                         break;
                     }
                 }
                 else if([subView isMemberOfClass:[BLUIACButton class]])
                 {
                     BLUIACButton *acButton = (BLUIACButton *) subView;
                     
                     if ([acButton.objName isEqualToString:objectName])
                     {
                         [objectPropertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                          {
                              NSString *acObjectKey = key;
                              
                              //if ([key isEqualToString:@"OnOff"])
                              {
                                  //NSString *valueLength = [[NSString alloc]initWithString:objectPropertyDict[@"ValueLength"]];
                                  NSDictionary *acObjectDict = [[NSMutableDictionary alloc] initWithDictionary:obj];
                                  [acObjectDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                                   {
                                       if ([key isEqualToString:@"ReadFromGroupAddress"])
                                       {
                                           NSMutableDictionary *readFromGroupAddressDict = [[NSMutableDictionary alloc] initWithDictionary:obj];
                                           [readFromGroupAddressDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                                            {
                                                //NSLog(@"readFromGroupAddressDict[%@] = %@", key, obj);
                                                if ([readFromGroupAddressDict[key] isEqualToString:groupAddress])
                                                {
                                                    dispatch_async(dispatch_get_main_queue(),
                                                                   ^{
                                                                       if ([acObjectKey isEqualToString:@"OnOff"])
                                                                       {
                                                                           BOOL ret = [acButton.acViewController acOnOffButtonStatusUpdateWithValue:objectValue];
                                                                           
                                                                           if (ret == YES)
                                                                           {
                                                                               [acButton setSelected:YES];
                                                                           }
                                                                           else
                                                                           {
                                                                               [acButton setSelected:NO];
                                                                           }
                                                                       }
                                                                       else if([acObjectKey isEqualToString:@"WindSpeed"])
                                                                       {
                                                                           [acButton.acViewController acWindSpeedButtonStatusUpdateWithValue:objectValue];
                                                                       }
                                                                       else if([acObjectKey isEqualToString:@"Mode"])
                                                                       {
                                                                           [acButton.acViewController acModeButtonStatusUpdateWithValue:objectValue];
                                                                           
                                                                       }
                                                                       else if([acObjectKey isEqualToString:@"EnviromentTemperature"])
                                                                       {
                                                                           NSString *enviromentTemperatureValue = [[NSString alloc] initWithFormat:@"%ld", (long)objectValue];
                                                                           [acButton.acEnviromentTemperatureLabel setText:enviromentTemperatureValue];
                                                                       }
                                                                       else if([acObjectKey isEqualToString:@"SettingTemperature"])
                                                                       {
                                                                           [acButton.acViewController acSettingTemperatureUpdateWithValue:objectValue];
                                                                       }
                                                                   });
                                                }
                                            }];
                                       }
                                   }];
                              }
                          }];
                         
                         break;
                     }
                 }
                 else if([subView isMemberOfClass:[BLUIHeatingButton class]])
                 {
                     BLUIHeatingButton *heatingButton = (BLUIHeatingButton *) subView;
                     
                     if ([heatingButton.objName isEqualToString:objectName])
                     {
                         [objectPropertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                          {
                              NSString *acObjectKey = key;
                              
                              //if ([key isEqualToString:@"OnOff"])
                              {
                                  //NSString *valueLength = [[NSString alloc]initWithString:objectPropertyDict[@"ValueLength"]];
                                  NSDictionary *heatingObjectDict = [[NSMutableDictionary alloc] initWithDictionary:obj];
                                  [heatingObjectDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                                   {
                                       if ([key isEqualToString:@"ReadFromGroupAddress"])
                                       {
                                           NSMutableDictionary *readFromGroupAddressDict = [[NSMutableDictionary alloc] initWithDictionary:obj];
                                           [readFromGroupAddressDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                                            {
                                                //NSLog(@"readFromGroupAddressDict[%@] = %@", key, obj);
                                                if ([readFromGroupAddressDict[key] isEqualToString:groupAddress])
                                                {
                                                    dispatch_async(dispatch_get_main_queue(),
                                                                   ^{
                                                                       if ([acObjectKey isEqualToString:@"OnOff"])
                                                                       {
                                                                           //BOOL ret = [[BLHeating sharedInstance] heatingOnOffStatusUpdateWithValue:objectValue];
                                                                           
                                                                           if(objectValue)
                                                                           {
                                                                               [heatingButton setSelected:YES];
                                                                           }
                                                                           else
                                                                           {
                                                                               [heatingButton setSelected:NO];
                                                                           }
                                                                       }
                                                                       else if([acObjectKey isEqualToString:@"EnviromentTemperature"])
                                                                       {
                                                                           NSString *enviromentTemperatureValue = [[NSString alloc] initWithFormat:@"%ld", (long)objectValue];
                                                                           [heatingButton.heatingEnviromentTemperatureLabel setText:enviromentTemperatureValue];
                                                                       }
                                                                   });
                                                }
                                            }];
                                       }
                                   }];
                              }
                          }];
                         
                         break;
                     }
                 }
                 else if([subView isMemberOfClass:[BLUICurtain2Button class]])
                 {
                     BLUICurtain2Button *curtainButton = (BLUICurtain2Button *) subView;
                     if ([curtainButton.objName isEqualToString:objectName])
                     {
                         [objectPropertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                          {
                              NSString *curtainTypetKey = key;
                              if ([curtainTypetKey isEqualToString:@"YarnCurtain"])
                              {
                                  NSDictionary *curtainObjectDict = [[NSMutableDictionary alloc] initWithDictionary:obj];
                                  [curtainObjectDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                                   {
                                       NSString *curtainObjectKey = key;
                                       if ([curtainObjectKey isEqualToString:@"StatusHeight"])
                                       {
                                           if ([groupAddress isEqualToString:obj])
                                           {
                                               dispatch_async(dispatch_get_main_queue(),
                                                              ^{
                                                                  [curtainButton.curtainViewController yarnCurtainPositionChangedWithValue:objectValue];
                                                              });
                                           }
                                       }
                                   }];
                                  
                              }
                              else if([curtainTypetKey isEqualToString:@"ClothCurtain"])
                              {
                                  NSDictionary *curtainObjectDict = [[NSMutableDictionary alloc] initWithDictionary:obj];
                                  [curtainObjectDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                                   {
                                       NSString *curtainObjectKey = key;
                                       if ([curtainObjectKey isEqualToString:@"StatusHeight"])
                                       {
                                           if ([groupAddress isEqualToString:obj])
                                           {
                                               dispatch_async(dispatch_get_main_queue(),
                                                              ^{
                                                                  [curtainButton.curtainViewController clothCurtainPositionChangedWithValue:objectValue];
                                                              });
                                           }
                                       }
                                   }];
                                  
                              }
                          }];
                     }
                 }
                 
             }
             
             
         }];
    }
    
}

//- (void)checkSubViewClassMemberAndActionWithGroupAddress:(NSString *)groupAddress withObjectValue:(NSInteger)objectValue withObjectName:(NSString *)objectName withValueLength:(NSString *)valueLength
//{
//    for (UIView *subView in self.view.subviews)
//    {
//        if ([subView isMemberOfClass:[BLUISwitch class]])
//        {
//            BLUISwitch *button = (BLUISwitch *) subView;
//            [self blUIButtonUpdateActionWithButtonObject:button buttonValue:objectValue buttonName:objectName valueLength:valueLength];
//        }
//        
//    }
//}

- (void) blUISwitchUpdateActionWithButtonObject:(BLUISwitch *)button buttonValue:(NSInteger)value buttonName:(NSString *)name valueLength:(NSString *)valueLength
{
    //if ([button.objName isEqualToString:name])
    {
        if ([valueLength isEqualToString:@"1Bit"])
        {
            if (value == 1)
            {
                [button setSelected:YES];
            }
            else if(value == 0)
            {
                [button setSelected:NO];
            }
        }
    }

}


#pragma mark Init Widgets Status

-(void) getAllWidgetsStatus
{
    //NSString *path = [[NSBundle mainBundle] pathForResource:self.nibName ofType:@"plist"];
    
    if (!viewNibPlistDict) {
        return;
    }
    NSMutableDictionary *groupAddressDict = [[NSMutableDictionary alloc]init];
    
    
    //__block NSMutableDictionary *readFromGroupAddressDict = [[NSMutableDictionary alloc] initWithDictionary:temDict[key]];
    for (NSUInteger itemIndex = 0; itemIndex < [viewNibPlistDict count]; itemIndex++)
    {
        NSDictionary *itemDitc = [viewNibPlistDict objectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)itemIndex]];
        [itemDitc enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             
             NSMutableDictionary *objectPropertyDict = [[NSMutableDictionary alloc] initWithDictionary:viewNibPlistDict[key]];
             [objectPropertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
              {
                  if ([key isEqualToString:@"ReadFromGroupAddress"])
                  {
                      NSString *valueLength = [[NSString alloc]initWithString:objectPropertyDict[@"ValueLength"]];
                      NSMutableDictionary *readFromGroupAddressDict = [[NSMutableDictionary alloc] initWithDictionary:objectPropertyDict[key]];
                      [readFromGroupAddressDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                       {
                           if ([groupAddressDict objectForKey:readFromGroupAddressDict[key]] == nil)
                           {
                               [groupAddressDict setValue:@"ReadFromAddress" forKey:readFromGroupAddressDict[key]];
                               [tunnellingAsyncUdpSocketSharedInstance tunnellingSendWithDestGroupAddress:readFromGroupAddressDict[key] value:0 buttonName:nil valueLength:valueLength commandType:@"Read"];
                           }
                       }];
                  }
              }];
         }];
    }
}

#pragma mark Private Method
- (BOOL) isInThisRectWithRectOrigX:(float)origX rectOrigY:(float)origY rectSizeH:(float)sizeH rectSizeW:(float)sizeW pointX:(float)ptX pointY:(float)ptY
{
    if ((ptX > origX) && (ptX < (origX + sizeW)) && (ptY > origY) && (ptY < (origY + sizeH))) {
        
        return YES;
    }
    
    return NO;
}

- (void) playClickSound
{
    CFBundleRef mainbundle=CFBundleGetMainBundle();
    SystemSoundID soundFileObject;
    //获得声音文件URL
    CFURLRef soundfileurl=CFBundleCopyResourceURL(mainbundle,CFSTR("click1"),CFSTR("mp3"),NULL);
    //创建system sound 对象
    AudioServicesCreateSystemSoundID(soundfileurl, &soundFileObject);
    //播放
    AudioServicesPlaySystemSound(soundFileObject);
}

@end
