//
//  EmptyViewController.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/11/17.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmptyViewController : UIViewController
{
    
}
@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, nonatomic) id pageControllerDataSource;
@end
