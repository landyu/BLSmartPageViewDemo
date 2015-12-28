//
//  BLDimmingViewController.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/23.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLDimmingViewController.h"
#import "BLDimming.h"

@interface BLDimmingViewController ()
{
    BLDimming *blDimmingSharedInstance;
}

@end

@implementation BLDimmingViewController

+ (instancetype)sharedInstance
{
    // 1
    static BLDimmingViewController *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[BLDimmingViewController alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        blDimmingSharedInstance = [BLDimming sharedInstance];
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
    
    [blDimmingSharedInstance setDimmingPanelViewFromOldData];
    [blDimmingSharedInstance readDimmingPanelStatus];
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
- (IBAction)dimmingSliderValueChanged:(UISlider *)sender
{
//    SEL selector = @selector(dimmingValueChangedWithValue:);
//    
//    if ([_dimmingModeDelegate respondsToSelector:selector])
//    {
//        [_dimmingModeDelegate dimmingValueChangedWithValue:sender.value];
//    }
    
    [blDimmingSharedInstance dimmingValueChangedWithValue:sender.value];

}

- (IBAction)dimmingOnOffButtonPressed:(UIButton *)sender
{
//    SEL selector = @selector(dimmingOnOffChangedWithState:);
//    
//    if ([_dimmingModeDelegate respondsToSelector:selector])
//    {
//        [_dimmingModeDelegate dimmingOnOffChangedWithState:[sender isSelected]];
//    }
    [blDimmingSharedInstance dimmingOnOffChangedWithState:[sender isSelected]];
}


@end
