//
//  BLUIACButton.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/9/2.
//  Copyright (c) 2015年 Landyu. All rights reserved.
//

#import "BLUIACButton.h"

@implementation BLUIACButton
@synthesize acEnviromentTemperatureLabel;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.acViewController = nil;
}

- (void)addEnviromentTemperatureLabelWithParentController:(APPChildViewController *)parentController
{
    CGPoint acButtonCGPoint = [self center];
    CGRect acEnviromentTemperatureLabelRect = CGRectMake ( acButtonCGPoint.x - 10, acButtonCGPoint.y - 38, 50, 20 );;
    
    acEnviromentTemperatureLabel = [[UILabel alloc] initWithFrame:acEnviromentTemperatureLabelRect];
    
    [acEnviromentTemperatureLabel setText:@"15"];
    
    [parentController.view addSubview:acEnviromentTemperatureLabel];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
