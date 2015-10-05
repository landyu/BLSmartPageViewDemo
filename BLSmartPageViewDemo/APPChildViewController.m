//
//  APPChildViewController.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/8/7.
//  Copyright (c) 2015年 Landyu. All rights reserved.
//

#import "APPChildViewController.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "BLUISwitch.h"
#import "BLUISceneButton.h"
#import "BLUIACButton.h"
#import "BLACViewController.h"
#import "BLUICurtainButton.h"
#import "BLCurtainViewController.h"
#import "BLUIPageJumpButton.h"
#import "GlobalMacro.h"



@interface APPChildViewController ()
{
    //dispatch_queue_t transmitActionQueue;
    //NSMutableArray * childTransmitDataFIFO;
    AppDelegate *appDelegate;
    //NSString *widgetPlistPath;
    NSMutableDictionary *viewNibPlistDict;
    UIViewController  *activeVC;
    CGFloat phywidth;
    CGFloat phyheight;
}

@end

@implementation APPChildViewController
@synthesize nibName;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    activeVC = nil;
    viewNibPlistDict = nil;

    self.view.tag = self.index;
    
    NSLog(@"view count = %lu", (unsigned long)self.view.subviews.count);
    
    CGRect rect = [self.view bounds];
    CGSize size = rect.size;
    phywidth = size.width;
    phyheight = size.height;
    
    appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    //transmitActionQueue = appDelegate.transmitQueue;
    //childTransmitDataFIFO = appDelegate.transmitDataFIFO;
    
    NSString *widgetPlistPath = [[NSBundle mainBundle] pathForResource:self.nibName ofType:@"plist"];
    viewNibPlistDict = [[NSMutableDictionary alloc]initWithContentsOfFile:widgetPlistPath];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvFromBus:) name:@"BL.BLSmartPageViewDemo.RecvFromBus" object:nil];
    
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, 150ull * NSEC_PER_MSEC);
    
    dispatch_after(delayTime, [Utils GlobalMainQueue],
    //dispatch_async([Utils GlobalMainQueue],
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
                           else if([subView isMemberOfClass:[BLUICurtainButton class]])
                           {
                               //dispatch_async([Utils GlobalBackgroundQueue], ^(void)
                                              //{
                                                  BLUICurtainButton *curtainButton = (BLUICurtainButton *) subView;
                                                  [self initCurtainButtonWithCurtainButtonObject:curtainButton nibPlistDict:viewNibPlistDict];
                                                  [curtainButton addTarget:self action:@selector(curtainButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
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
    
    NSLog(@"SwitchButtonPressd #%ld, objName = %@", (long)self.index, sender.objName);
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
    [viewNibPlistDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
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
    
    NSLog(@"SceneButtonPressd #%ld, objName = %@", (long)self.index, sender.objName);
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

    [nibPlistDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
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

#pragma mark AC Button
- (void) acButtonPressed:(BLUIACButton *)sender
{
    [self playClickSound];
    //[self playClickSound];
    if (sender.acViewController == nil)
    {
//        acVC = [[BLACViewController alloc] init];
//        acVC.view.frame = CGRectMake(phywidth/2.0 - 298.0/2.0, phyheight/2.0 - 589.0/2.0, 589, 298);
//        //acVC.view.backgroundColor = [UIColor clearColor];
//        [self.view addSubview:acVC.view];
    }
    else
    {
        if (activeVC != nil)
        {
            [activeVC.view removeFromSuperview];
            activeVC = nil;
            if (self.pageController.dataSource == nil)
            {
                self.pageController.dataSource = self.pageControllerDataSource;
            }
        }
        activeVC = sender.acViewController;
        [self.view addSubview:sender.acViewController.view];
    }

}

- (void) initACButtonWithACButtonObject:(BLUIACButton *)acButton nibPlistDict:(NSMutableDictionary *)nibPlistDict
{
    
    
    //dispatch_async([Utils GlobalUserInteractiveQueue],
                   //^{
                       acButton.acViewController = [[BLACViewController alloc] init];
                       acButton.acViewController.view.frame = CGRectMake(phywidth/2.0 - 298.0/2.0, phyheight/2.0 - 589.0/2.0, 589, 298);
                       
                       if (!nibPlistDict) {
                           return;
                       }
                       
                       [nibPlistDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                        {
                            
                            if ([key isEqualToString:acButton.objName])
                            {
                                [acButton.acViewController initACPropertyWithDictionary:obj buttonName:acButton.objName];
                                *stop = YES;
                            }
                        }];

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

#pragma mark Curtain Button
- (void) initCurtainButtonWithCurtainButtonObject:(BLUICurtainButton *)curtainButton nibPlistDict:(NSMutableDictionary *)nibPlistDict
{
    //dispatch_sync([Utils GlobalUserInteractiveQueue],
                   //^{
                       curtainButton.curtainViewController = [[BLCurtainViewController alloc] init];
                       curtainButton.curtainViewController.view.frame = CGRectMake(phywidth/2.0 - 298.0/2.0, phyheight/2.0 - 589.0/2.0, 589, 298);
                       
                       if (!nibPlistDict) {
                           return;
                       }
                       
                       [nibPlistDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                        {
                            
                            if ([key isEqualToString:curtainButton.objName])
                            {
                                [curtainButton.curtainViewController initCurtainPropertyWithDictionary:obj buttonName:curtainButton.objName];
                                *stop = YES;
                            }
                        }];
                       
                       
                   //});

}

- (void) curtainButtonPressed:(BLUICurtainButton *)sender
{
    [self playClickSound];
    //[self playClickSound];
    if (sender.curtainViewController == nil)
    {
        //        acVC = [[BLACViewController alloc] init];
        //        acVC.view.frame = CGRectMake(phywidth/2.0 - 298.0/2.0, phyheight/2.0 - 589.0/2.0, 589, 298);
        //        //acVC.view.backgroundColor = [UIColor clearColor];
        //        [self.view addSubview:acVC.view];
    }
    else
    {
        if (activeVC != nil)
        {
            [activeVC.view removeFromSuperview];
            activeVC = nil;
        }
        activeVC = sender.curtainViewController;
        [self.view addSubview:sender.curtainViewController.view];
        //self.parentViewController
        self.pageController.dataSource = nil;
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

    NSDictionary *transmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:destGroupAddress, @"GroupAddress",  [NSString stringWithFormat: @"%ld", (long)value], @"Value", valueLength, @"ValueLength", @"Write", @"CommandType", nil];
    [appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:transmitDataDict];
}

#pragma mark Receive From Bus
- (void) recvFromBus: (NSNotification*) notification
{
    NSDictionary *dict = [notification userInfo];
    NSLog(@"receive data from bus at NibName = %@ Scene %ld dict = %@", self.nibName,(long)self.index, dict);
    [self actionWithGroupAddress:dict[@"Address"] withObjectValue:[dict[@"Value"] intValue]];
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
    [viewNibPlistDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
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
                                  NSLog(@"readFromGroupAddressDict[%@] = %@", key, obj);
                                  if ([readFromGroupAddressDict[key] isEqualToString:groupAddress])
                                  {
                                      
                                      [self blUISwitchUpdateActionWithButtonObject:switchButton buttonValue:objectValue buttonName:objectName valueLength:valueLength];
                                      
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
                                           NSLog(@"readFromGroupAddressDict[%@] = %@", key, obj);
                                           if ([readFromGroupAddressDict[key] isEqualToString:groupAddress])
                                           {
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
                                           }
                                       }];
                                  }
                              }];
                         }
                     }];
                    
                    break;
                }
            }

        }
        

    }];
    
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
    //NSMutableDictionary *nibPlistDict = [[NSMutableDictionary alloc]initWithContentsOfFile:widgetPlistPath];
    
    
    //__block NSMutableDictionary *readFromGroupAddressDict = [[NSMutableDictionary alloc] initWithDictionary:temDict[key]];
    [viewNibPlistDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
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
                       NSLog(@"readFromGroupAddressDict[%@] = %@", key, readFromGroupAddressDict[key]);

                       NSDictionary *transmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:readFromGroupAddressDict[key], @"GroupAddress", valueLength, @"ValueLength", @"Read", @"CommandType", nil];
                       [appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:transmitDataDict];
                   }];
              }
          }];
     }];
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
