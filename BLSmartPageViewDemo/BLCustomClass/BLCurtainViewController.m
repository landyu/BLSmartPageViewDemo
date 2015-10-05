//
//  BLCurtainViewController.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/9/6.
//  Copyright (c) 2015年 Landyu. All rights reserved.
//

#import "BLCurtainViewController.h"
#import "AppDelegate.h"
#import "Utils.h"

@class Curtain;

@interface Curtain : NSObject {
@public
    NSString *openCloseWriteToGroupAddress;
    NSString *stopWriteToGroupAddress;
    NSString *moveToPositionWriteToGroupAddress;
    NSString *positionStatusReadFromGroupAddress;
}

@end

@implementation Curtain

@end


@interface BLCurtainViewController ()
{
    NSString *curtainButtonObjectName;
    Curtain *yarnCurtain;
    Curtain *clothCurtain;
    AppDelegate *appDelegate;
}

@end

@implementation BLCurtainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    yarnCurtain = [Curtain alloc];
    clothCurtain = [Curtain alloc];
    
    appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
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

- (void) initCurtainPropertyWithDictionary:(NSMutableDictionary *)curtainPropertyDict buttonName:(NSString *)curtainButtonName
{
    curtainButtonObjectName = curtainButtonName;
    
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
                  else if ([key isEqualToString:@"PositionStatus"])
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
                  else if ([key isEqualToString:@"PositionStatus"])
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


- (void) initReadCurtainPanelWidgetStatus
{

  NSLog(@"Yarn Curtain  read position status from %@", yarnCurtain->positionStatusReadFromGroupAddress);
  
  NSDictionary *yarnCurtainTransmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:yarnCurtain->positionStatusReadFromGroupAddress, @"GroupAddress", @"1Byte", @"ValueLength", @"Read", @"CommandType", nil];
  [appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:yarnCurtainTransmitDataDict];
    
    NSLog(@"Cloth Curtain  read position status from %@", yarnCurtain->positionStatusReadFromGroupAddress);
    
    NSDictionary *clothCurtainTransmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:yarnCurtain->positionStatusReadFromGroupAddress, @"GroupAddress", @"1Byte", @"ValueLength", @"Read", @"CommandType", nil];
    [appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:clothCurtainTransmitDataDict];

}


- (IBAction)yarnCurtainOpenButtonPressed:(UIButton *)sender
{
    [self blUIButtonTransmitActionWithDestGroupAddress:yarnCurtain->openCloseWriteToGroupAddress value:1 buttonName:curtainButtonObjectName valueLength:@"1Bit"];
}
- (IBAction)yarnCurtainCloseButtonPressed:(UIButton *)sender
{
    [self blUIButtonTransmitActionWithDestGroupAddress:yarnCurtain->openCloseWriteToGroupAddress value:0 buttonName:curtainButtonObjectName valueLength:@"1Bit"];
}
- (IBAction)yarnCurtainSliderValueChanged:(UISlider *)sender
{
    NSInteger sendValue = (NSInteger)sender.value;
    
    [self blUIButtonTransmitActionWithDestGroupAddress:yarnCurtain->moveToPositionWriteToGroupAddress value:sendValue buttonName:curtainButtonObjectName valueLength:@"1Byte"];
}

- (IBAction)yarnCurtainStopButton:(UIButton *)sender
{
    [self blUIButtonTransmitActionWithDestGroupAddress:yarnCurtain->stopWriteToGroupAddress value:1 buttonName:curtainButtonObjectName valueLength:@"1Bit"];

}


- (IBAction)clothCurtainOpenButtonPressed:(UIButton *)sender
{
    [self blUIButtonTransmitActionWithDestGroupAddress:clothCurtain->openCloseWriteToGroupAddress value:0 buttonName:curtainButtonObjectName valueLength:@"1Bit"];
}
- (IBAction)clothCurtainCloseButtonPressed:(UIButton *)sender
{
    [self blUIButtonTransmitActionWithDestGroupAddress:clothCurtain->openCloseWriteToGroupAddress value:1 buttonName:curtainButtonObjectName valueLength:@"1Bit"];
}
- (IBAction)clothCurtainSliderValueChanged:(UISlider *)sender
{
    NSInteger sendValue = (NSInteger)sender.value;
    
    [self blUIButtonTransmitActionWithDestGroupAddress:clothCurtain->moveToPositionWriteToGroupAddress value:sendValue buttonName:curtainButtonObjectName valueLength:@"1Byte"];
}

- (IBAction)clothCurtainStopButton:(UIButton *)sender
{
    [self blUIButtonTransmitActionWithDestGroupAddress:clothCurtain->stopWriteToGroupAddress value:1 buttonName:curtainButtonObjectName valueLength:@"1Bit"];
}


#pragma mark Send Write Command
- (void) blUIButtonTransmitActionWithDestGroupAddress:(NSString *)destGroupAddress value:(NSInteger)value buttonName:(NSString *)name valueLength:(NSString *)valueLength
{
    
    NSDictionary *transmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:destGroupAddress, @"GroupAddress",  [NSString stringWithFormat: @"%ld", (long)value], @"Value", valueLength, @"ValueLength", @"Write", @"CommandType", nil];
    [appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:transmitDataDict];
}


@end
