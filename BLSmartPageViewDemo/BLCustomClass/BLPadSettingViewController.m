//
//  BLPadSettingViewController.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/9/24.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLPadSettingViewController.h"
#import "BLSettingData.h"

@interface BLPadSettingViewController ()
//@property (nonatomic, strong) UIImageView *backgroundImageView;
//@property (nonatomic, strong) UILabel *ipAddressLabel;
@end

@implementation BLPadSettingViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //[self.view addSubview:self.backgroundImageView];
    //[self.view addSubview:self.ipAddressLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"设置";
    NSString *ipAddress = [BLSettingData sharedSettingData].deviceIPAddress;
    self.deviceIpAddressText.text = ipAddress;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - enent response
- (IBAction)deviceIpAddressChanged:(UITextField *)sender
{
    NSLog(@"device ip = %@", sender.text);
}

- (IBAction)deviceIpAddressEditingDidEnd:(UITextField *)sender
{
    [BLSettingData sharedSettingData].deviceIPAddress = sender.text;
    [[BLSettingData sharedSettingData] save];
    NSLog(@"Editing Did End device ip = %@", sender.text);
}

#pragma mark - geters and setters

//- (UIImageView *)backgroundImageView
//{
//    if (!_backgroundImageView)
//    {
//        _backgroundImageView =
//        ({
//            UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BG_Blue.png"]];
//            imageView;
//        });
//    }
//    return _backgroundImageView;
//}
//
//- (UILabel *)ipAddressLabel
//{
//    if (!_ipAddressLabel)
//    {
//        _ipAddressLabel =
//        ({
//            UILabel *label = [[UILabel alloc] init];
//            label.frame = CGRectMake(100, 185, 30 * 6, 30);
//            label.text = @"网关 IP：";
//            label.textColor = [UIColor whiteColor];
//            label;
//        });
//    }
//    return _ipAddressLabel;
//}



@end
