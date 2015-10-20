//
//  BLCurtainViewController.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/9/6.
//  Copyright (c) 2015年 Landyu. All rights reserved.
//

#import "BLCurtainViewController.h"
//#import "AppDelegate.h"
#import "BLUISwitch.h"
#import "BLUISlider.h"
#import "Utils.h"
#import "GlobalMacro.h"

@class Curtain;

@interface Curtain : NSObject {
@public
    NSString *openCloseWriteToGroupAddress;
    NSString *stopWriteToGroupAddress;
    NSString *moveToPositionWriteToGroupAddress;
    NSString *positionStatusReadFromGroupAddress;
    NSUInteger curtainPosition;
}

@end

@implementation Curtain

@end


@interface BLCurtainViewController ()
{
    NSString *curtainButtonObjectName;
    Curtain *yarnCurtain;
    Curtain *clothCurtain;
    NSTimer *yarnCurtainPositionChangeTimer;
    NSTimer *clothCurtainPositionChangeTimer;
    
    UIView *curtainView;
    //AppDelegate *appDelegate;
}
- (IBAction)yarnCurtainTouchUpInside:(UISlider *)sender;
- (IBAction)clothCurtainTouchUpInside:(UISlider *)sender;

@end

@implementation BLCurtainViewController
@synthesize delegate;
@synthesize overallRecevedKnxDataDict;
@synthesize yarnCurtainOpenButton;
@synthesize yarnCurtainCloseButton;
@synthesize yarnCurtainSlider;
@synthesize clothCurtainOpenButton;
@synthesize clothCurtainCloseButton;
@synthesize clothCurtainSlider;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

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

- (void) initPanelView
{
    if (curtainView == nil)
    {
        CGRect rect = [self.view bounds];
        CGSize size = rect.size;
        CGFloat phywidth = size.width;
        CGFloat phyheight = size.height;
        curtainView = [[[NSBundle mainBundle] loadNibNamed:@"BLCurtainPanelView" owner:self options:nil] firstObject];
        curtainView.frame = CGRectMake(phywidth/2.0 - 589.0/2.0, phyheight/2.0 - 298.0/2.0, 589, 298);
        self.view = curtainView;
        
        for (UIView *subView in self.view.subviews)
        {
            if ([subView isMemberOfClass:[BLUISwitch class]])
            {
                BLUISwitch *switchButton = (BLUISwitch *) subView;
                if ([switchButton.objName isEqualToString:@"纱帘开"])
                {
                    [switchButton addTarget:self action:@selector(yarnCurtainOpenButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                    yarnCurtainOpenButton = switchButton;
                }
                else if ([switchButton.objName isEqualToString:@"纱帘闭"])
                {
                    [switchButton addTarget:self action:@selector(yarnCurtainCloseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                    yarnCurtainCloseButton = switchButton;
                }
                else if ([switchButton.objName isEqualToString:@"纱帘停"])
                {
                    [switchButton addTarget:self action:@selector(yarnCurtainStopButton:) forControlEvents:UIControlEventTouchUpInside];
                    //yarnCurtainCloseButton = switchButton;
                }
                else if ([switchButton.objName isEqualToString:@"布帘开"])
                {
                    [switchButton addTarget:self action:@selector(clothCurtainOpenButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                    clothCurtainOpenButton = switchButton;
                }
                else if ([switchButton.objName isEqualToString:@"布帘闭"])
                {
                    [switchButton addTarget:self action:@selector(clothCurtainCloseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                    clothCurtainCloseButton = switchButton;
                }
                else if ([switchButton.objName isEqualToString:@"布帘停"])
                {
                    [switchButton addTarget:self action:@selector(clothCurtainStopButton:) forControlEvents:UIControlEventTouchUpInside];
                    //yarnCurtainCloseButton = switchButton;
                }
                else if ([switchButton.objName isEqualToString:@"全开"])
                {

                }
                else if ([switchButton.objName isEqualToString:@"全闭"])
                {

                }
                else if ([switchButton.objName isEqualToString:@"全停"])
                {
                    
                }
            }
            else if([subView isMemberOfClass:[BLUISlider class]])
            {
                BLUISlider *slider = (BLUISlider *) subView;
                if ([slider.objName isEqualToString:@"纱帘"])
                {
                    [slider addTarget:self action:@selector(yarnCurtainTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
                    yarnCurtainSlider = slider;
                }
                else if ([slider.objName isEqualToString:@"布帘"])
                {
                    [slider addTarget:self action:@selector(clothCurtainTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
                    clothCurtainSlider = slider;
                }
            }

        }
    }
    
    if (overallRecevedKnxDataDict != nil)
    {
        NSString *objectValue = [overallRecevedKnxDataDict objectForKey:yarnCurtain->positionStatusReadFromGroupAddress];
        yarnCurtain->curtainPosition = [objectValue integerValue];
        [yarnCurtainSlider setValue:yarnCurtain->curtainPosition animated:YES];
        
        objectValue = [overallRecevedKnxDataDict objectForKey:clothCurtain->positionStatusReadFromGroupAddress];
        clothCurtain->curtainPosition = [objectValue integerValue];
        [clothCurtainSlider setValue:clothCurtain->curtainPosition animated:YES];
    }
}

- (void) initCurtainPropertyWithDictionary:(NSMutableDictionary *)curtainPropertyDict buttonName:(NSString *)curtainButtonName
{
    curtainButtonObjectName = curtainButtonName;
    yarnCurtain = [Curtain alloc];
    clothCurtain = [Curtain alloc];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tunnellingConnectSuccess) name:TunnellingConnectSuccessNotification object:nil];
    
    yarnCurtainPositionChangeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(yarnCurtainPositionChangeTimerFired) userInfo:nil repeats:YES];
    [self yarnCurtainPositionChangeTimerStart:NO];
    
    clothCurtainPositionChangeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(clothCurtainPositionChangeTimerFired) userInfo:nil repeats:YES];
    [self clothCurtainPositionChangeTimerStart:NO];
    
    [curtainPropertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"YarnCurtain"])
         {
             NSDictionary *yarnCurtainDict = (NSDictionary *)obj;
             [yarnCurtainDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
              {
                  if ([key isEqualToString:@"OpenClose"])
                  {
                      yarnCurtain->openCloseWriteToGroupAddress = (NSString *)obj;
                  }
                  else if ([key isEqualToString:@"Stop"])
                  {
                      yarnCurtain->stopWriteToGroupAddress = (NSString *)obj;
                  }
                  else if ([key isEqualToString:@"MoveToPosition"])
                  {
                      yarnCurtain->moveToPositionWriteToGroupAddress = (NSString *)obj;
                  }
                  else if ([key isEqualToString:@"StatusHeight"])
                  {
                      yarnCurtain->positionStatusReadFromGroupAddress = (NSString *)obj;
                  }
              }];
         }
         else if([key isEqualToString:@"ClothCurtain"])
         {
             NSDictionary *clothCurtainDict = (NSDictionary *)obj;
             [clothCurtainDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
              {
                  if ([key isEqualToString:@"OpenClose"])
                  {
                      clothCurtain->openCloseWriteToGroupAddress = (NSString *)obj;
                  }
                  else if ([key isEqualToString:@"Stop"])
                  {
                      clothCurtain->stopWriteToGroupAddress = (NSString *)obj;
                  }
                  else if ([key isEqualToString:@"MoveToPosition"])
                  {
                      clothCurtain->moveToPositionWriteToGroupAddress = (NSString *)obj;
                  }
                  else if ([key isEqualToString:@"StatusHeight"])
                  {
                      clothCurtain->positionStatusReadFromGroupAddress = (NSString *)obj;
                  }
              }];

         }
    }];
    
    dispatch_async([Utils GlobalUserInitiatedQueue],
                   ^{
                       [self initReadCurtainPanelWidgetStatus];
                   });
}

- (void) tunnellingConnectSuccess
{
    [self initReadCurtainPanelWidgetStatus];
}

- (void) initReadCurtainPanelWidgetStatus
{

  //LogInfo(@"Yarn Curtain  read position status from %@", yarnCurtain->positionStatusReadFromGroupAddress);
  
  //NSDictionary *yarnCurtainTransmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:yarnCurtain->positionStatusReadFromGroupAddress, @"GroupAddress", @"1Byte", @"ValueLength", @"Read", @"CommandType", nil];
  //[appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:yarnCurtainTransmitDataDict];
    [self blUIButtonTransmitReadActionWithDestGroupAddress:yarnCurtain->positionStatusReadFromGroupAddress value:0 buttonName:nil valueLength:@"1Byte"];
    
    //LogInfo(@"Cloth Curtain  read position status from %@", yarnCurtain->positionStatusReadFromGroupAddress);
    
    //NSDictionary *clothCurtainTransmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:yarnCurtain->positionStatusReadFromGroupAddress, @"GroupAddress", @"1Byte", @"ValueLength", @"Read", @"CommandType", nil];
    //[appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:clothCurtainTransmitDataDict];
    [self blUIButtonTransmitReadActionWithDestGroupAddress:clothCurtain->positionStatusReadFromGroupAddress value:0 buttonName:nil valueLength:@"1Byte"];

}
#pragma mark - event response

- (IBAction)yarnCurtainOpenButtonPressed:(UIButton *)sender
{
    [self blUIButtonTransmitWriteActionWithDestGroupAddress:yarnCurtain->openCloseWriteToGroupAddress value:1 buttonName:curtainButtonObjectName valueLength:@"1Bit"];
}
- (IBAction)yarnCurtainCloseButtonPressed:(UIButton *)sender
{
    [self blUIButtonTransmitWriteActionWithDestGroupAddress:yarnCurtain->openCloseWriteToGroupAddress value:0 buttonName:curtainButtonObjectName valueLength:@"1Bit"];
}
- (IBAction)yarnCurtainSliderValueChanged:(UISlider *)sender
{
    NSInteger sendValue = (NSInteger)sender.value;
    
    [self blUIButtonTransmitWriteActionWithDestGroupAddress:yarnCurtain->moveToPositionWriteToGroupAddress value:sendValue buttonName:curtainButtonObjectName valueLength:@"1Byte"];
}

- (IBAction)yarnCurtainStopButton:(UIButton *)sender
{
    [self blUIButtonTransmitWriteActionWithDestGroupAddress:yarnCurtain->stopWriteToGroupAddress value:1 buttonName:curtainButtonObjectName valueLength:@"1Bit"];

}

- (IBAction)yarnCurtainTouchUpInside:(UISlider *)sender
{
    NSInteger sendValue = (NSInteger)sender.value;
    
    [self blUIButtonTransmitWriteActionWithDestGroupAddress:yarnCurtain->moveToPositionWriteToGroupAddress value:sendValue buttonName:curtainButtonObjectName valueLength:@"1Byte"];
}


- (IBAction)clothCurtainOpenButtonPressed:(UIButton *)sender
{
    [self blUIButtonTransmitWriteActionWithDestGroupAddress:clothCurtain->openCloseWriteToGroupAddress value:1 buttonName:curtainButtonObjectName valueLength:@"1Bit"];
}
- (IBAction)clothCurtainCloseButtonPressed:(UIButton *)sender
{
    [self blUIButtonTransmitWriteActionWithDestGroupAddress:clothCurtain->openCloseWriteToGroupAddress value:0 buttonName:curtainButtonObjectName valueLength:@"1Bit"];
}
- (IBAction)clothCurtainSliderValueChanged:(UISlider *)sender
{
    NSInteger sendValue = (NSInteger)sender.value;
    
    [self blUIButtonTransmitWriteActionWithDestGroupAddress:clothCurtain->moveToPositionWriteToGroupAddress value:sendValue buttonName:curtainButtonObjectName valueLength:@"1Byte"];
}

- (IBAction)clothCurtainStopButton:(UIButton *)sender
{
    [self blUIButtonTransmitWriteActionWithDestGroupAddress:clothCurtain->stopWriteToGroupAddress value:1 buttonName:curtainButtonObjectName valueLength:@"1Bit"];
}

- (void) yarnCurtainPositionChangeTimerFired
{
    [self yarnCurtainPositionChangeTimerStart:NO];
    [yarnCurtainSlider setValue:yarnCurtain->curtainPosition animated:YES];
}

- (void) clothCurtainPositionChangeTimerFired
{
    [self clothCurtainPositionChangeTimerStart:NO];
    [clothCurtainSlider setValue:clothCurtain->curtainPosition animated:YES];
}


- (IBAction)clothCurtainTouchUpInside:(UISlider *)sender
{
    NSInteger sendValue = (NSInteger)sender.value;
    
    [self blUIButtonTransmitWriteActionWithDestGroupAddress:clothCurtain->moveToPositionWriteToGroupAddress value:sendValue buttonName:curtainButtonObjectName valueLength:@"1Byte"];
}

#pragma mark - private method
- (void)yarnCurtainPositionChangedWithValue:(NSUInteger)position
{
    [self yarnCurtainPositionChangeTimerStart:YES]; //reset fire time
    yarnCurtain->curtainPosition = position;
}
- (void)clothCurtainPositionChangedWithValue:(NSUInteger)position
{
    [self clothCurtainPositionChangeTimerStart:YES]; //reset fire time
    clothCurtain->curtainPosition = position;
}

- (void) yarnCurtainPositionChangeTimerStart:(BOOL)start
{
    if (yarnCurtainPositionChangeTimer == nil)
    {
        return;
    }
    
    if (start)
    {
        [yarnCurtainPositionChangeTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];//start 10 second later
    }
    else
    {
        [yarnCurtainPositionChangeTimer setFireDate:[NSDate distantFuture]];//stop
    }
}

- (void) clothCurtainPositionChangeTimerStart:(BOOL)start
{
    if (clothCurtainPositionChangeTimer == nil)
    {
        return;
    }
    
    if (start)
    {
        [clothCurtainPositionChangeTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];//start 10 second later
    }
    else
    {
        [clothCurtainPositionChangeTimer setFireDate:[NSDate distantFuture]];//stop
    }
}


#pragma mark Send Write Command
- (void) blUIButtonTransmitWriteActionWithDestGroupAddress:(NSString *)destGroupAddress value:(NSInteger)value buttonName:(NSString *)name valueLength:(NSString *)valueLength
{
    
    SEL selector = @selector(blCurtainSendWithDestGroupAddress:value:buttonName:valueLength:commandType:);
    
    if ([delegate respondsToSelector:selector])
    {
        [delegate blCurtainSendWithDestGroupAddress:destGroupAddress value:value buttonName:name valueLength:valueLength commandType:@"Write"];
    }
}

- (void) blUIButtonTransmitReadActionWithDestGroupAddress:(NSString *)destGroupAddress value:(NSInteger)value buttonName:(NSString *)name valueLength:(NSString *)valueLength
{
    
    SEL selector = @selector(blCurtainSendWithDestGroupAddress:value:buttonName:valueLength:commandType:);
    
    if ([delegate respondsToSelector:selector])
    {
        [delegate blCurtainSendWithDestGroupAddress:destGroupAddress value:value buttonName:name valueLength:valueLength commandType:@"Read"];
    }
}

@end
