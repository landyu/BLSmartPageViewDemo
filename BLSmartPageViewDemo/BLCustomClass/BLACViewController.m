//
//  BLACViewController.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/25.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLACViewController.h"
#import "BLAC.h"

@interface BLACViewController ()
{
    BLAC *blACSharedInstance;
}
@end

@implementation BLACViewController

+ (instancetype)sharedInstance
{
    // 1
    static BLACViewController *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[BLACViewController alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        blACSharedInstance = [BLAC sharedInstance];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat phywidth = size.width;
    CGFloat phyheight = size.height;
    self.view.frame = CGRectMake(phywidth/2.0 - 589.0/2.0, phyheight/2.0 - 298.0/2.0, 589, 298);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [blACSharedInstance setACPanelViewFromOldData];
    [blACSharedInstance readACPanelStatus];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)acOnOffButton:(UIButton *)sender
{
    [blACSharedInstance acOnOffToChangeWithState:![sender isSelected]];
}
- (IBAction)acWindSpeedButton:(UIButton *)sender
{
    [blACSharedInstance acWindSpeedToChangeWithButtonName:[sender titleForState:UIControlStateNormal]];
}
- (IBAction)acModeButton:(UIButton *)sender
{
    [blACSharedInstance acModeToChangeWithButtonName:[sender titleForState:UIControlStateNormal]];
}
- (IBAction)acSettingTemperatureDownButton:(UIButton *)sender
{
    NSInteger sendSettingTemperature = blACSharedInstance.settingEnvironmentTemperature - 1;
    if (sendSettingTemperature < 15)
    {
        return;
    }
    [blACSharedInstance acSettingEnvironmentTemperatureToChangeWithValue:sendSettingTemperature];
}
- (IBAction)acSettingTemperatureUpButton:(UIButton *)sender
{
    NSInteger sendSettingTemperature = blACSharedInstance.settingEnvironmentTemperature + 1;
    if (sendSettingTemperature > 35)
    {
        return;
    }
    [blACSharedInstance acSettingEnvironmentTemperatureToChangeWithValue:sendSettingTemperature];
}

@end
