//
//  BLACView.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/10/15.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLACView.h"

@implementation BLACView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

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
    
    //[self blUIButtonTransmitWriteActionWithDestGroupAddress:[OnOffDict[@"WriteToGroupAddress"] objectForKey:@"0"] value:sendValue buttonName:acButtonObjectName valueLength:@"1Bit"];
    NSLog(@"acOnOffButton-----");
}

@end
