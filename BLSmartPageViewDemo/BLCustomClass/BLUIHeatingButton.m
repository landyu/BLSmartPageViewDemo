//
//  BLUIHeatingButton.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/22.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLUIHeatingButton.h"

@implementation BLUIHeatingButton
@synthesize heatingEnviromentTemperatureLabel;

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
    //self.heatingViewController = nil;
}

- (void)addEnviromentTemperatureLabelWithParentController:(APPChildViewController *)parentController
{
    CGPoint heatingButtonCGPoint = [self center];
    CGRect heatingEnviromentTemperatureLabelRect = CGRectMake ( heatingButtonCGPoint.x - 10, heatingButtonCGPoint.y - 38, 50, 20 );;
    
    heatingEnviromentTemperatureLabel = [[UILabel alloc] initWithFrame:heatingEnviromentTemperatureLabelRect];
    
    [heatingEnviromentTemperatureLabel setText:@"15"];
    
    [parentController.view addSubview:heatingEnviromentTemperatureLabel];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
