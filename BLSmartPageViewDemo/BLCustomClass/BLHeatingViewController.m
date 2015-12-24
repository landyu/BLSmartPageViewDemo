//
//  BLHeatingViewController.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/22.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLHeatingViewController.h"
#import "BLHeating.h"

@interface BLHeatingViewController ()
{
    BLHeating *blHeatingSharedInstance;
}

- (IBAction)heatingOnOffButtonPressed:(UIButton *)sender;
- (IBAction)heatingSettingTemperatureUpButtonPressed:(UIButton *)sender;
- (IBAction)heatingSettingTemperatureDownButtonPressed:(UIButton *)sender;

@end

@implementation BLHeatingViewController

+ (instancetype)sharedInstance
{
    // 1
    static BLHeatingViewController *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[BLHeatingViewController alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        blHeatingSharedInstance = [BLHeating sharedInstance];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat phywidth = size.width;
    CGFloat phyheight = size.height;
    self.view.frame = CGRectMake(phywidth/2.0 - 589.0/2.0, phyheight/2.0 - 298.0/2.0, 589, 298);
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



- (IBAction)heatingOnOffButtonPressed:(UIButton *)sender
{
    [blHeatingSharedInstance heatingOnOffToChangeWithState:![sender isSelected]];
}

- (IBAction)heatingSettingTemperatureUpButtonPressed:(UIButton *)sender
{
    NSInteger sendSettingTemperature = blHeatingSharedInstance.settingEnvironmentTemperature + 1;
    if (sendSettingTemperature > 35)
    {
        return;
    }
    [blHeatingSharedInstance heatingSettingEnvironmentTemperatureToChangeWithValue:sendSettingTemperature];
}
- (IBAction)heatingSettingTemperatureDownButtonPressed:(UIButton *)sender
{
    NSInteger sendSettingTemperature = blHeatingSharedInstance.settingEnvironmentTemperature - 1;
    if (sendSettingTemperature < 15)
    {
        return;
    }
    [blHeatingSharedInstance heatingSettingEnvironmentTemperatureToChangeWithValue:sendSettingTemperature];

}





@end
