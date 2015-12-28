//
//  BLCurtainViewController.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/23.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLCurtainViewController.h"
#import "BLCurtain.h"

@interface BLCurtainViewController ()
{
    BLCurtain *blCurtainSharedInstance;
}

@end

@implementation BLCurtainViewController
+ (instancetype)sharedInstance
{
    // 1
    static BLCurtainViewController *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[BLCurtainViewController alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        blCurtainSharedInstance = [BLCurtain sharedInstance];
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
    
    [blCurtainSharedInstance setCurtainPanelViewFromOldData];
    [blCurtainSharedInstance readCurtainPanelStatus];
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
- (IBAction)curtainOpenButtonPressed:(UIButton *)sender
{
    [blCurtainSharedInstance curtainToOpen];
}

- (IBAction)curtainCloseButtonPressed:(UIButton *)sender
{
    [blCurtainSharedInstance curtainToClose];
}

- (IBAction)curtainStopButtonPressed:(UIButton *)sender
{
    [blCurtainSharedInstance curtainToStop];
}

- (IBAction)curtainPositionChanged:(UISlider *)sender
{
    [blCurtainSharedInstance curtainPositionToChangeWithValue:sender.value];
}
@end
