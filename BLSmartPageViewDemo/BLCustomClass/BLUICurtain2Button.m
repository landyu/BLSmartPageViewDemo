//
//  BLUICurtainButton.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/9/6.
//  Copyright (c) 2015年 Landyu. All rights reserved.
//

#import "BLUICurtain2Button.h"

@implementation BLUICurtain2Button

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
    self.curtainViewController = nil;
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
