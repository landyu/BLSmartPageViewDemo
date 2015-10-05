//
//  BLACViewController.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/9/2.
//  Copyright (c) 2015年 Landyu. All rights reserved.
//

#import "BLACViewController.h"
#import "AppDelegate.h"
#import "Utils.h"

@interface BLACViewController ()
{
    NSString *acButtonObjectName;
    
    NSMutableDictionary *EnviromentTemperatureDict;
    NSMutableDictionary *SettingTemperatureDict;
    NSMutableDictionary *WindSpeedDict;
    NSMutableDictionary *ModeDict;
    NSMutableDictionary *OnOffDict;
    
    AppDelegate *appDelegate;
    float senttingTemperatureFeedBackValue;
    //NSString *EnviromentTemperatureDictKey;
}
@end



@implementation BLACViewController
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //EnviromentTemperatureDictKey = @"EnviromentTemperature";
    
    appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    senttingTemperatureFeedBackValue = 15.0;

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
                       [self initReadACPanelWidgetStatus];
                   });
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
        
        [self blUIButtonTransmitActionWithDestGroupAddress:[ModeDict[@"WriteToGroupAddress"] objectForKey:@"0"] value:sendValue buttonName:acButtonObjectName valueLength:@"1Byte"];
    }
    else if([[sender titleForState:UIControlStateNormal] isEqualToString:@"制热"])
    {
        sendValue = [ModeDict[@"Heat"] integerValue];
        
        if (sendValue < 0)
        {
            return;
        }
        
        [self blUIButtonTransmitActionWithDestGroupAddress:[ModeDict[@"WriteToGroupAddress"] objectForKey:@"0"] value:sendValue buttonName:acButtonObjectName valueLength:@"1Byte"];
    }
    else if([[sender titleForState:UIControlStateNormal] isEqualToString:@"通风"])
    {
        sendValue = [ModeDict[@"Vent"] integerValue];
        
        if (sendValue < 0)
        {
            return;
        }
        
        [self blUIButtonTransmitActionWithDestGroupAddress:[ModeDict[@"WriteToGroupAddress"] objectForKey:@"0"] value:sendValue buttonName:acButtonObjectName valueLength:@"1Byte"];
    }
    else if([[sender titleForState:UIControlStateNormal] isEqualToString:@"除湿"])
    {
        sendValue = [ModeDict[@"Desiccation"] integerValue];
        
        if (sendValue < 0)
        {
            return;
        }
        
        [self blUIButtonTransmitActionWithDestGroupAddress:[ModeDict[@"WriteToGroupAddress"] objectForKey:@"0"] value:sendValue buttonName:acButtonObjectName valueLength:@"1Byte"];
    }

}

- (IBAction)acSettingTemperatureDownButton:(UIButton *)sender
{
    NSInteger sendSettingTemperature = senttingTemperatureFeedBackValue - 1;
    
    [self blUIButtonTransmitActionWithDestGroupAddress:[SettingTemperatureDict[@"WriteToGroupAddress"] objectForKey:@"0"] value:sendSettingTemperature buttonName:acButtonObjectName valueLength:@"2Byte"];
}

- (IBAction)acSettingTemperatureUpButton:(UIButton *)sender
{
    NSInteger sendSettingTemperature = senttingTemperatureFeedBackValue + 1;
    
    [self blUIButtonTransmitActionWithDestGroupAddress:[SettingTemperatureDict[@"WriteToGroupAddress"] objectForKey:@"0"] value:sendSettingTemperature buttonName:acButtonObjectName valueLength:@"2Byte"];
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
    
    [self blUIButtonTransmitActionWithDestGroupAddress:[OnOffDict[@"WriteToGroupAddress"] objectForKey:@"0"] value:sendValue buttonName:acButtonObjectName valueLength:@"1Bit"];
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
        
        [self blUIButtonTransmitActionWithDestGroupAddress:[WindSpeedDict[@"WriteToGroupAddress"] objectForKey:@"0"] value:sendValue buttonName:acButtonObjectName valueLength:@"1Byte"];
    }
    else if([[sender titleForState:UIControlStateNormal] isEqualToString:@"中"])
    {
        sendValue = [WindSpeedDict[@"Mid"] integerValue];
        
        if (sendValue < 0)
        {
            return;
        }
        
        [self blUIButtonTransmitActionWithDestGroupAddress:[WindSpeedDict[@"WriteToGroupAddress"] objectForKey:@"0"] value:sendValue buttonName:acButtonObjectName valueLength:@"1Byte"];
    }
    else if([[sender titleForState:UIControlStateNormal] isEqualToString:@"低"])
    {
        sendValue = [WindSpeedDict[@"Low"] integerValue];
        
        if (sendValue < 0)
        {
            return;
        }
        
        [self blUIButtonTransmitActionWithDestGroupAddress:[WindSpeedDict[@"WriteToGroupAddress"] objectForKey:@"0"] value:sendValue buttonName:acButtonObjectName valueLength:@"1Byte"];
    }
    else if([[sender titleForState:UIControlStateNormal] isEqualToString:@"自动"])
    {
        sendValue = [WindSpeedDict[@"Auto"] integerValue];
        
        if (sendValue < 0)
        {
            return;
        }
        
        [self blUIButtonTransmitActionWithDestGroupAddress:[WindSpeedDict[@"WriteToGroupAddress"] objectForKey:@"0"] value:sendValue buttonName:acButtonObjectName valueLength:@"1Byte"];
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
    NSLog(@"aEnviroment Temperature ");
}

- (void)acSettingTemperatureUpdateWithValue:(NSInteger)value
{
    NSLog(@"Setting Temperature = %ld", (long)value);
    senttingTemperatureFeedBackValue = value;
    [acSettingTemperature setText:[[NSString alloc] initWithFormat:@"%ld", (long)value]];
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
                  NSLog(@"AC OnOff readFromGroupAddressDict[%@] = %@", key, obj);
                  
                  NSDictionary *transmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:readFromGroupAddressDict[key], @"GroupAddress", @"1Bit", @"ValueLength", @"Read", @"CommandType", nil];
                  [appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:transmitDataDict];
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
                  NSLog(@"AC WindSpeed readFromGroupAddressDict[%@] = %@", key, obj);
                  
                  NSDictionary *transmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:readFromGroupAddressDict[key], @"GroupAddress", @"1Byte", @"ValueLength", @"Read", @"CommandType", nil];
                  [appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:transmitDataDict];
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
                  NSLog(@"AC Mode readFromGroupAddressDict[%@] = %@", key, obj);
                  
                  NSDictionary *transmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:readFromGroupAddressDict[key], @"GroupAddress", @"1Byte", @"ValueLength", @"Read", @"CommandType", nil];
                  [appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:transmitDataDict];
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
                  NSLog(@"Setting TemperatureDict readFromGroupAddressDict[%@] = %@", key, obj);
                  
                  NSDictionary *transmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:readFromGroupAddressDict[key], @"GroupAddress", @"2Byte", @"ValueLength", @"Read", @"CommandType", nil];
                  [appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:transmitDataDict];
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
                  NSLog(@"Setting TemperatureDict readFromGroupAddressDict[%@] = %@", key, obj);
                  
                  NSDictionary *transmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:readFromGroupAddressDict[key], @"GroupAddress", @"2Byte", @"ValueLength", @"Read", @"CommandType", nil];
                  [appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:transmitDataDict];
              }];
         }
     }];


}

#pragma mark Send Write Command
- (void) blUIButtonTransmitActionWithDestGroupAddress:(NSString *)destGroupAddress value:(NSInteger)value buttonName:(NSString *)name valueLength:(NSString *)valueLength
{
    
    NSDictionary *transmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:destGroupAddress, @"GroupAddress",  [NSString stringWithFormat: @"%ld", (long)value], @"Value", valueLength, @"ValueLength", @"Write", @"CommandType", nil];
    [appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:transmitDataDict];
}

@end

