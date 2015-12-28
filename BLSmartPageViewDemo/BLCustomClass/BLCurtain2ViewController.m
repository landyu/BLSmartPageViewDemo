//
//  BLCurtain2ViewController.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/28.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLCurtain2ViewController.h"
#import "BLCurtain2.h"

@interface BLCurtain2ViewController ()
{
    BLCurtain2 *blCurtain2SharedInstance;
}

@end

@implementation BLCurtain2ViewController
+ (instancetype)sharedInstance
{
    // 1
    static BLCurtain2ViewController *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[BLCurtain2ViewController alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        blCurtain2SharedInstance = [BLCurtain2 sharedInstance];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat phywidth = size.width;
    CGFloat phyheight = size.height;
    self.view.frame = CGRectMake(phywidth/2.0 - 589.0/2.0, phyheight/2.0 - 298.0/2.0, 589, 298);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [blCurtain2SharedInstance setCurtain2PanelViewFromOldData];
    [blCurtain2SharedInstance readCurtain2PanelStatus];
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

//yarn
- (IBAction)yarnCurtainOpenButtonPressed:(UIButton *)sender
{
    [blCurtain2SharedInstance yarnCurtainToOpen];
}

- (IBAction)yarnCurtainCloseButtonPressed:(UIButton *)sender
{
    [blCurtain2SharedInstance yarnCurtainToClose];
}

- (IBAction)yarnCurtainStopButton:(UIButton *)sender
{
    [blCurtain2SharedInstance yarnCurtainToStop];
}
- (IBAction)yarnCurtainSliderValueChanged:(UISlider *)sender
{
    [blCurtain2SharedInstance yarnCurtainPositionToChangeWithValue:sender.value];
}
//cloth
- (IBAction)clothCurtainOpenButtonPressed:(UIButton *)sender
{
    [blCurtain2SharedInstance clothCurtainToOpen];
}

- (IBAction)clothCurtainCloseButtonPressed:(UIButton *)sender
{
    [blCurtain2SharedInstance clothCurtainToClose];
}

- (IBAction)clothCurtainStopButton:(UIButton *)sender
{
    [blCurtain2SharedInstance clothCurtainToStop];
}
- (IBAction)clothCurtainSliderValueChanged:(UISlider *)sender
{
    [blCurtain2SharedInstance clothCurtainPositionToChangeWithValue:sender.value];
}

//all
- (IBAction)allCurtainOpenButtonPressed:(UIButton *)sender
{
    [blCurtain2SharedInstance allCurtainToOpen];
}
- (IBAction)allCurtainCloseButtonPressed:(UIButton *)sender
{
    [blCurtain2SharedInstance allCurtainToClose];
}
- (IBAction)allCurtainStopButtonPressed:(UIButton *)sender
{
    [blCurtain2SharedInstance allCurtainToStop];
}
@end
