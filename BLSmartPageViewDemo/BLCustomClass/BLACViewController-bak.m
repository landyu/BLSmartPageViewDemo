//
//  BLACViewController.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/9/2.
//  Copyright (c) 2015年 Landyu. All rights reserved.
//


#import "BLACViewController.h"
#import "GlobalMacro.h"
//#import "AppDelegate.h"
#import "Utils.h"

#import "BLACView.h"
#import "BLUISwitch.h"
#import "BLUILabel.h"
#import "BLUIImageView.h"

@interface BLACViewController ()
{
    
    NSString *acButtonObjectName;
    
    NSMutableDictionary *EnviromentTemperatureDict;
    NSMutableDictionary *SettingTemperatureDict;
    NSMutableDictionary *WindSpeedDict;
    NSMutableDictionary *ModeDict;
    NSMutableDictionary *OnOffDict;
    
    NSMutableDictionary *overallRecevedKnxDataDict;
    
    UIView *acView;
    
    //AppDelegate *appDelegate;
    float senttingTemperatureFeedBackValue;
    //NSString *EnviromentTemperatureDictKey;
}
@end



@implementation BLACViewController
@synthesize delegate;
@synthesize acOnOffButtonOutlet;
@synthesize acOnOffLabel;

@synthesize acWindSpeedHighButton;
@synthesize acWindSpeedMidButton;
@synthesize acWindSpeedLowButton;
@synthesize acWindSpeedAutoButton;
@synthesize acWindSpeedLabel;

@synthesize acModeCoolButton;
@synthesize acModHeatButton;
@synthesize acModeVentButton;
@synthesize acModDesiccationButton;
@synthesize acModeLabel;


@synthesize acSettingTemperature;
@synthesize overallRecevedKnxDataDict;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //EnviromentTemperatureDictKey = @"EnviromentTemperature";

    //appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    //senttingTemperatureFeedBackValue = 15.0;
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tunnellingConnectSuccess) name:TunnellingConnectSuccessNotification object:nil];

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

- (void) initACPropertyWithDictionary:(NSMutableDictionary *)acPropertyDict buttonName:(NSString *)acButtonName
{
    acButtonObjectName = acButtonName;
    senttingTemperatureFeedBackValue = 15.0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tunnellingConnectSuccess) name:TunnellingConnectSuccessNotification object:nil];
    
    [acPropertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"EnviromentTemperature"])
         {
             EnviromentTemperatureDict = [[NSMutableDictionary alloc] initWithDictionary:obj];
         }
         else if([key isEqualToString:@"SettingTemperature"])
         {
             SettingTemperatureDict = [[NSMutableDictionary alloc] initWithDictionary:obj];
         }
         else if([key isEqualToString:@"WindSpeed"])
         {
             WindSpeedDict = [[NSMutableDictionary alloc] initWithDictionary:obj];
         }
         else if([key isEqualToString:@"Mode"])
         {
             ModeDict = [[NSMutableDictionary alloc] initWithDictionary:obj];
         }
         else if([key isEqualToString:@"OnOff"])
         {
             OnOffDict = [[NSMutableDictionary alloc] initWithDictionary:obj];
         }
     }];
    
    dispatch_async([Utils GlobalUserInitiatedQueue],
                   ^{
                       //[self initReadACPanelWidgetStatus];
                       [self readACPanelTopDisplayStatus];
                   });
}

- (void) initACPanelView
{
    if (acView == nil)
    {
        CGRect rect = [self.view bounds];
        CGSize size = rect.size;
        CGFloat phywidth = size.width;
        CGFloat phyheight = size.height;
        acView = [[[NSBundle mainBundle] loadNibNamed:@"BLACPanelView" owner:self options:nil] firstObject];
        acView.frame = CGRectMake(phywidth/2.0 - 589.0/2.0, phyheight/2.0 - 298.0/2.0, 589, 298);
        self.view = acView;
        for (UIView *subView in self.view.subviews)
        {
            if ([subView isMemberOfClass:[BLUISwitch class]])
            {
                BLUISwitch *switchButton = (BLUISwitch *) subView;
                if ([switchButton.objName isEqualToString:@"开关"])
                {
                    [switchButton addTarget:self action:@selector(acOnOffButton:) forControlEvents:UIControlEventTouchUpInside];
                    acOnOffButtonOutlet = switchButton;
                }
                else if([switchButton.objName isEqualToString:@"高"])
                {
                    [switchButton addTarget:self action:@selector(acWindSpeedButton:) forControlEvents:UIControlEventTouchUpInside];
                    acWindSpeedHighButton = switchButton;
                }
                else if([switchButton.objName isEqualToString:@"中"])
                {
                    [switchButton addTarget:self action:@selector(acWindSpeedButton:) forControlEvents:UIControlEventTouchUpInside];
                    acWindSpeedMidButton = switchButton;
                }
                else if([switchButton.objName isEqualToString:@"低"])
                {
                    [switchButton addTarget:self action:@selector(acWindSpeedButton:) forControlEvents:UIControlEventTouchUpInside];
                    acWindSpeedLowButton = switchButton;
                }
                else if([switchButton.objName isEqualToString:@"自动"])
                {
                    [switchButton addTarget:self action:@selector(acWindSpeedButton:) forControlEvents:UIControlEventTouchUpInside];
                    acWindSpeedAutoButton = switchButton;
                }
                else if([switchButton.objName isEqualToString:@"制冷"])
                {
                    [switchButton addTarget:self action:@selector(acModeButton:) forControlEvents:UIControlEventTouchUpInside];
                    acModeCoolButton = switchButton;
                }
                else if([switchButton.objName isEqualToString:@"制热"])
                {
                    [switchButton addTarget:self action:@selector(acModeButton:) forControlEvents:UIControlEventTouchUpInside];
                    acModHeatButton = switchButton;
                }
                else if([switchButton.objName isEqualToString:@"通风"])
                {
                    [switchButton addTarget:self action:@selector(acModeButton:) forControlEvents:UIControlEventTouchUpInside];
                    acModeVentButton = switchButton;
                }
                else if([switchButton.objName isEqualToString:@"除湿"])
                {
                    [switchButton addTarget:self action:@selector(acModeButton:) forControlEvents:UIControlEventTouchUpInside];
                    acModDesiccationButton = switchButton;
                }
                else if([switchButton.objName isEqualToString:@"减"])
                {
                    [switchButton addTarget:self action:@selector(acSettingTemperatureDownButton:) forControlEvents:UIControlEventTouchUpInside];
                }
                else if([switchButton.objName isEqualToString:@"加"])
                {
                    [switchButton addTarget:self action:@selector(acSettingTemperatureUpButton:) forControlEvents:UIControlEventTouchUpInside];
                }
            }
            else if([subView isMemberOfClass:[BLUILabel class]])
            {
                BLUILabel *acLabel = (BLUILabel *) subView;
                if ([acLabel.objName isEqualToString:@"风速"])
                {
                    acWindSpeedLabel = acLabel;
                }
                else if([acLabel.objName isEqualToString:@"开关"])
                {
                    acOnOffLabel = acLabel;
                }
                else if([acLabel.objName isEqualToString:@"模式"])
                {
                    acModeLabel = acLabel;
                }
                else if([acLabel.objName isEqualToString:@"设定温度"])
                {
                    acSettingTemperature = acLabel;
                }
            }
        }
    }
    
    if (overallRecevedKnxDataDict != nil)
    {
        NSString *objectValue = [overallRecevedKnxDataDict objectForKey:[OnOffDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
        [self acOnOffButtonStatusUpdateWithValue:[objectValue integerValue]];
        objectValue = [overallRecevedKnxDataDict objectForKey:[WindSpeedDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
        [self acWindSpeedButtonStatusUpdateWithValue:[objectValue integerValue]];
        objectValue = [overallRecevedKnxDataDict objectForKey:[ModeDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
        [self acModeButtonStatusUpdateWithValue:[objectValue integerValue]];
        objectValue = [overallRecevedKnxDataDict objectForKey:[SettingTemperatureDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
        [self acSettingTemperatureUpdateWithValue:[objectValue integerValue]];
    }
    
}

- (IBAction)acModeButton:(UIButton *)sender
{
    NSInteger sendValue;
    
    if ([[sender titleForState:UIControlStateNormal] isEqualToString:@"制冷"])
    {
        sendValue = [ModeDict[@"Cool"] integerValue];
        
        if (sendValue < 0)
        {
            return;
        }
        
        [self blUIButtonTransmitWriteActionWithDestGroupAddress:[ModeDict[@"WriteToGroupAddress"] objectForKey:@"0"] value:sendValue buttonName:acButtonObjectName valueLength:@"1Byte"];
    }
    else if([[sender titleForState:UIControlStateNormal] isEqualToString:@"制热"])
    {
        sendValue = [ModeDict[@"Heat"] integerValue];
        
        if (sendValue < 0)
        {
            return;
        }
        
        [self blUIButtonTransmitWriteActionWithDestGroupAddress:[ModeDict[@"WriteToGroupAddress"] objectForKey:@"0"] value:sendValue buttonName:acButtonObjectName valueLength:@"1Byte"];
    }
    else if([[sender titleForState:UIControlStateNormal] isEqualToString:@"通风"])
    {
        sendValue = [ModeDict[@"Vent"] integerValue];
        
        if (sendValue < 0)
        {
            return;
        }
        
        [self blUIButtonTransmitWriteActionWithDestGroupAddress:[ModeDict[@"WriteToGroupAddress"] objectForKey:@"0"] value:sendValue buttonName:acButtonObjectName valueLength:@"1Byte"];
    }
    else if([[sender titleForState:UIControlStateNormal] isEqualToString:@"除湿"])
    {
        sendValue = [ModeDict[@"Desiccation"] integerValue];
        
        if (sendValue < 0)
        {
            return;
        }
        
        [self blUIButtonTransmitWriteActionWithDestGroupAddress:[ModeDict[@"WriteToGroupAddress"] objectForKey:@"0"] value:sendValue buttonName:acButtonObjectName valueLength:@"1Byte"];
    }
    
}

- (IBAction)acSettingTemperatureDownButton:(UIButton *)sender
{
    NSInteger sendSettingTemperature = senttingTemperatureFeedBackValue - 1;
    
    [self blUIButtonTransmitWriteActionWithDestGroupAddress:[SettingTemperatureDict[@"WriteToGroupAddress"] objectForKey:@"0"] value:sendSettingTemperature buttonName:acButtonObjectName valueLength:@"2Byte"];
}

- (IBAction)acSettingTemperatureUpButton:(UIButton *)sender
{
    NSInteger sendSettingTemperature = senttingTemperatureFeedBackValue + 1;
    
    [self blUIButtonTransmitWriteActionWithDestGroupAddress:[SettingTemperatureDict[@"WriteToGroupAddress"] objectForKey:@"0"] value:sendSettingTemperature buttonName:acButtonObjectName valueLength:@"2Byte"];
}

- (IBAction)acOnOffButton:(UIButton *)sender
{
    NSInteger sendValue;
    
    if ([sender isSelected])
    {
        sendValue = 0;
    }
    else
    {
        sendValue = 1;
    }
    
    [self blUIButtonTransmitWriteActionWithDestGroupAddress:[OnOffDict[@"WriteToGroupAddress"] objectForKey:@"0"] value:sendValue buttonName:acButtonObjectName valueLength:@"1Bit"];
}

- (IBAction)acWindSpeedButton:(UIButton *)sender
{
    NSInteger sendValue;
    
    if ([[sender titleForState:UIControlStateNormal] isEqualToString:@"高"])
    {
        sendValue = [WindSpeedDict[@"High"] integerValue];
        
        if (sendValue < 0)
        {
            return;
        }
        
        [self blUIButtonTransmitWriteActionWithDestGroupAddress:[WindSpeedDict[@"WriteToGroupAddress"] objectForKey:@"0"] value:sendValue buttonName:acButtonObjectName valueLength:@"1Byte"];
    }
    else if([[sender titleForState:UIControlStateNormal] isEqualToString:@"中"])
    {
        sendValue = [WindSpeedDict[@"Mid"] integerValue];
        
        if (sendValue < 0)
        {
            return;
        }
        
        [self blUIButtonTransmitWriteActionWithDestGroupAddress:[WindSpeedDict[@"WriteToGroupAddress"] objectForKey:@"0"] value:sendValue buttonName:acButtonObjectName valueLength:@"1Byte"];
    }
    else if([[sender titleForState:UIControlStateNormal] isEqualToString:@"低"])
    {
        sendValue = [WindSpeedDict[@"Low"] integerValue];
        
        if (sendValue < 0)
        {
            return;
        }
        
        [self blUIButtonTransmitWriteActionWithDestGroupAddress:[WindSpeedDict[@"WriteToGroupAddress"] objectForKey:@"0"] value:sendValue buttonName:acButtonObjectName valueLength:@"1Byte"];
    }
    else if([[sender titleForState:UIControlStateNormal] isEqualToString:@"自动"])
    {
        sendValue = [WindSpeedDict[@"Auto"] integerValue];
        
        if (sendValue < 0)
        {
            return;
        }
        
        [self blUIButtonTransmitWriteActionWithDestGroupAddress:[WindSpeedDict[@"WriteToGroupAddress"] objectForKey:@"0"] value:sendValue buttonName:acButtonObjectName valueLength:@"1Byte"];
    }
    
}

- (BOOL)acOnOffButtonStatusUpdateWithValue:(NSInteger)value
{
    BOOL ret = NO;
    
    if (value == 1)
    {
        [acOnOffButtonOutlet setSelected:YES];
        [acOnOffLabel setText:@"ON"];
        ret = YES;
    }
    else if(value == 0)
    {
        [acOnOffButtonOutlet setSelected:NO];
        [acOnOffLabel setText:@"OFF"];
        ret = NO;
    }
    
    return ret;
    
}

- (void)acWindSpeedButtonStatusUpdateWithValue:(NSInteger)value
{
    if (value == [WindSpeedDict[@"High"] integerValue])
    {
        [acWindSpeedHighButton setSelected:YES];
        [acWindSpeedMidButton setSelected:NO];
        [acWindSpeedLowButton setSelected:NO];
        [acWindSpeedAutoButton setSelected:NO];
        [acWindSpeedLabel setText:@"高"];
    }
    else if (value == [WindSpeedDict[@"Mid"] integerValue])
    {
        [acWindSpeedHighButton setSelected:NO];
        [acWindSpeedMidButton setSelected:YES];
        [acWindSpeedLowButton setSelected:NO];
        [acWindSpeedAutoButton setSelected:NO];
        [acWindSpeedLabel setText:@"中"];
    }
    else if (value == [WindSpeedDict[@"Low"] integerValue])
    {
        [acWindSpeedHighButton setSelected:NO];
        [acWindSpeedMidButton setSelected:NO];
        [acWindSpeedLowButton setSelected:YES];
        [acWindSpeedAutoButton setSelected:NO];
        [acWindSpeedLabel setText:@"低"];
    }
    else if (value == [WindSpeedDict[@"Auto"] integerValue])
    {
        [acWindSpeedHighButton setSelected:NO];
        [acWindSpeedMidButton setSelected:NO];
        [acWindSpeedLowButton setSelected:NO];
        [acWindSpeedAutoButton setSelected:YES];
        [acWindSpeedLabel setText:@"自动"];
    }
}

- (void)acModeButtonStatusUpdateWithValue:(NSInteger)value
{
    if (value == [ModeDict[@"Cool"] integerValue])
    {
        [acModeCoolButton setSelected:YES];
        [acModHeatButton setSelected:NO];
        [acModeVentButton setSelected:NO];
        [acModDesiccationButton setSelected:NO];
        [acModeLabel setText:@"制冷"];
    }
    else if (value == [ModeDict[@"Heat"] integerValue])
    {
        [acModeCoolButton setSelected:NO];
        [acModHeatButton setSelected:YES];
        [acModeVentButton setSelected:NO];
        [acModDesiccationButton setSelected:NO];
        [acModeLabel setText:@"制热"];
    }
    else if (value == [ModeDict[@"Vent"] integerValue])
    {
        [acModeCoolButton setSelected:NO];
        [acModHeatButton setSelected:NO];
        [acModeVentButton setSelected:YES];
        [acModDesiccationButton setSelected:NO];
        [acModeLabel setText:@"通风"];
    }
    else if (value == [ModeDict[@"Desiccation"] integerValue])
    {
        [acModeCoolButton setSelected:NO];
        [acModHeatButton setSelected:NO];
        [acModeVentButton setSelected:NO];
        [acModDesiccationButton setSelected:YES];
        [acModeLabel setText:@"除湿"];
    }
}

- (void)acEnviromentTemperatureUpdateWithValue:(NSInteger)value
{
    LogInfo(@"aEnviroment Temperature ");
}

- (void)acSettingTemperatureUpdateWithValue:(NSInteger)value
{
    LogInfo(@"Setting Temperature = %ld", (long)value);
    senttingTemperatureFeedBackValue = value;
    [acSettingTemperature setText:[[NSString alloc] initWithFormat:@"%ld", (long)value]];
}

- (void) tunnellingConnectSuccess
{
    if (self.view.superview == nil)
    {
        [self readACPanelTopDisplayStatus];
    }
    else
    {
        //[self readACPanelTopDisplayStatus];
        [self initReadACPanelWidgetStatus];
        
        [EnviromentTemperatureDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             if ([key isEqualToString:@"ReadFromGroupAddress"])
             {
                 NSDictionary *readFromGroupAddressDict = [[NSDictionary alloc] initWithDictionary:obj];
                 [readFromGroupAddressDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                  {
                      LogInfo(@"Enviroment TemperatureDict readFromGroupAddressDict[%@] = %@", key, obj);
                      
                      //                  NSDictionary *transmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:readFromGroupAddressDict[key], @"GroupAddress", @"2Byte", @"ValueLength", @"Read", @"CommandType", nil];
                      //                  [appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:transmitDataDict];
                      [self blUIButtonTransmitInitReadActionWithDestGroupAddress:readFromGroupAddressDict[key] valueLength:@"2Byte"];
                  }];
             }
         }];
    }
}

- (void)readACPanelTopDisplayStatus
{
    [OnOffDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"ReadFromGroupAddress"])
         {
             NSDictionary *readFromGroupAddressDict = [[NSDictionary alloc] initWithDictionary:obj];
             [readFromGroupAddressDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
              {
                  LogInfo(@"AC OnOff readFromGroupAddressDict[%@] = %@", key, obj);
                  
                  //NSDictionary *transmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:readFromGroupAddressDict[key], @"GroupAddress", @"1Bit", @"ValueLength", @"Read", @"CommandType", nil];
                  //[appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:transmitDataDict];
                  [self blUIButtonTransmitInitReadActionWithDestGroupAddress:readFromGroupAddressDict[key] valueLength:@"1Bit"];
              }];
         }
     }];
    
    [EnviromentTemperatureDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"ReadFromGroupAddress"])
         {
             NSDictionary *readFromGroupAddressDict = [[NSDictionary alloc] initWithDictionary:obj];
             [readFromGroupAddressDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
              {
                  LogInfo(@"Enviroment TemperatureDict readFromGroupAddressDict[%@] = %@", key, obj);
                  
                  //                  NSDictionary *transmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:readFromGroupAddressDict[key], @"GroupAddress", @"2Byte", @"ValueLength", @"Read", @"CommandType", nil];
                  //                  [appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:transmitDataDict];
                  [self blUIButtonTransmitInitReadActionWithDestGroupAddress:readFromGroupAddressDict[key] valueLength:@"2Byte"];
              }];
         }
     }];
}

- (void)initReadACPanelWidgetStatus
{
        [OnOffDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             if ([key isEqualToString:@"ReadFromGroupAddress"])
             {
                 NSDictionary *readFromGroupAddressDict = [[NSDictionary alloc] initWithDictionary:obj];
                 [readFromGroupAddressDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                  {
                      LogInfo(@"AC OnOff readFromGroupAddressDict[%@] = %@", key, obj);
    
                      //NSDictionary *transmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:readFromGroupAddressDict[key], @"GroupAddress", @"1Bit", @"ValueLength", @"Read", @"CommandType", nil];
                      //[appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:transmitDataDict];
                      [self blUIButtonTransmitInitReadActionWithDestGroupAddress:readFromGroupAddressDict[key] valueLength:@"1Bit"];
                  }];
             }
         }];
    
    [WindSpeedDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"ReadFromGroupAddress"])
         {
             NSDictionary *readFromGroupAddressDict = [[NSDictionary alloc] initWithDictionary:obj];
             [readFromGroupAddressDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
              {
                  LogInfo(@"AC WindSpeed readFromGroupAddressDict[%@] = %@", key, obj);
                  
                  //NSDictionary *transmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:readFromGroupAddressDict[key], @"GroupAddress", @"1Byte", @"ValueLength", @"Read", @"CommandType", nil];
                  //[appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:transmitDataDict];
                  [self blUIButtonTransmitInitReadActionWithDestGroupAddress:readFromGroupAddressDict[key] valueLength:@"1Byte"];
              }];
         }
     }];
    
    [ModeDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"ReadFromGroupAddress"])
         {
             NSDictionary *readFromGroupAddressDict = [[NSDictionary alloc] initWithDictionary:obj];
             [readFromGroupAddressDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
              {
                  LogInfo(@"AC Mode readFromGroupAddressDict[%@] = %@", key, obj);
                  
                  //NSDictionary *transmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:readFromGroupAddressDict[key], @"GroupAddress", @"1Byte", @"ValueLength", @"Read", @"CommandType", nil];
                  //[appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:transmitDataDict];
                  [self blUIButtonTransmitInitReadActionWithDestGroupAddress:readFromGroupAddressDict[key] valueLength:@"1Byte"];
              }];
         }
     }];
    
    [SettingTemperatureDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"ReadFromGroupAddress"])
         {
             NSDictionary *readFromGroupAddressDict = [[NSDictionary alloc] initWithDictionary:obj];
             [readFromGroupAddressDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
              {
                  LogInfo(@"Setting TemperatureDict readFromGroupAddressDict[%@] = %@", key, obj);
                  
                  //NSDictionary *transmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:readFromGroupAddressDict[key], @"GroupAddress", @"2Byte", @"ValueLength", @"Read", @"CommandType", nil];
                  //[appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:transmitDataDict];
                  [self blUIButtonTransmitInitReadActionWithDestGroupAddress:readFromGroupAddressDict[key] valueLength:@"2Byte"];
              }];
         }
     }];
    
    //    [EnviromentTemperatureDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    //     {
    //         if ([key isEqualToString:@"ReadFromGroupAddress"])
    //         {
    //             NSDictionary *readFromGroupAddressDict = [[NSDictionary alloc] initWithDictionary:obj];
    //             [readFromGroupAddressDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    //              {
    //                  LogInfo(@"Setting TemperatureDict readFromGroupAddressDict[%@] = %@", key, obj);
    //
    ////                  NSDictionary *transmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:readFromGroupAddressDict[key], @"GroupAddress", @"2Byte", @"ValueLength", @"Read", @"CommandType", nil];
    ////                  [appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:transmitDataDict];
    //                  [self blUIButtonTransmitInitReadActionWithDestGroupAddress:readFromGroupAddressDict[key] valueLength:@"2Byte"];
    //              }];
    //         }
    //     }];
    
    
}

#pragma mark Send Write Read Command
- (void) blUIButtonTransmitWriteActionWithDestGroupAddress:(NSString *)destGroupAddress value:(NSInteger)value buttonName:(NSString *)name valueLength:(NSString *)valueLength
{
    SEL selector = @selector(blACSendWithDestGroupAddress:value:buttonName:valueLength:commandType:);
    
    if ([delegate respondsToSelector:selector])
    {
        [delegate blACSendWithDestGroupAddress:destGroupAddress value:value buttonName:name valueLength:valueLength commandType:@"Write"];
    }
    //NSDictionary *transmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:destGroupAddress, @"GroupAddress",  [NSString stringWithFormat: @"%ld", (long)value], @"Value", valueLength, @"ValueLength", @"Write", @"CommandType", nil];
    //[appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:transmitDataDict];
}

- (void) blUIButtonTransmitReadActionWithDestGroupAddress:(NSString *)destGroupAddress  valueLength:(NSString *)valueLength
{
    SEL selector = @selector(blACSendWithDestGroupAddress:value:buttonName:valueLength:commandType:);
    
    if ([delegate respondsToSelector:selector])
    {
        [delegate blACSendWithDestGroupAddress:destGroupAddress value:0 buttonName:nil valueLength:valueLength commandType:@"Read"];
    }
    //NSDictionary *transmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:destGroupAddress, @"GroupAddress", valueLength, @"ValueLength", @"Read", @"CommandType", nil];
    //[appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:transmitDataDict];
}

- (void) blUIButtonTransmitInitReadActionWithDestGroupAddress:(NSString *)destGroupAddress  valueLength:(NSString *)valueLength
{
    SEL selector = @selector(blACInitReadWithDestGroupAddress:value:buttonName:valueLength:);
    
    if ([delegate respondsToSelector:selector])
    {
        [delegate blACInitReadWithDestGroupAddress:destGroupAddress value:0 buttonName:nil valueLength:valueLength];
    }
    //NSDictionary *transmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:destGroupAddress, @"GroupAddress", valueLength, @"ValueLength", @"Read", @"CommandType", nil];
    //[appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:transmitDataDict];
}

@end


