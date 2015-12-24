//
//  ViewControllerContainer.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/22.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "ViewControllerContainer.h"

@interface ViewControllerContainer()
{
    
}
//@property (strong, nonatomic) BLHeatingViewController *heatingViewController123;
@end


@implementation ViewControllerContainer
static BLHeatingViewController *_heatingViewController =  nil;
static BLDimmingViewController *_dimmingViewController =  nil;
static BLCurtainViewController *_curtainViewController =  nil;

+ (instancetype)sharedInstance
{
    // 1
    static ViewControllerContainer *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[ViewControllerContainer alloc] init];
    });
    return _sharedInstance;
}

- (instancetype) init
{
    self = [super init];
    if (self)
    {
        //BLHeatingViewController *hVC = self.heatingViewController;
        self.heatingViewController.view;
        self.dimmingViewController.view;
        self.curtainViewController.view;
    }
    return self;
}

//- (BLHeatingViewController *)heatingViewController
//{
//    if (_heatingViewController123 == nil)
//    {
//        _heatingViewController123 = [[BLHeatingViewController alloc] init];
//    }
//    return _heatingViewController123;
//}
//+ (void) setHeatingViewController:(int)val
//{ @synchronized(self) { value = val; } }
- (BLHeatingViewController *) heatingViewController
{
    if (!_heatingViewController)
    {
        _heatingViewController =
        ({
            BLHeatingViewController *viewController = [BLHeatingViewController sharedInstance];
            viewController;
        });
    }
    return _heatingViewController;
}

- (BLDimmingViewController *) dimmingViewController
{
    if (!_dimmingViewController)
    {
        _dimmingViewController =
        ({
            BLDimmingViewController *viewController = [BLDimmingViewController sharedInstance];
            viewController;
        });
    }
    return _dimmingViewController;
}

- (BLCurtainViewController *) curtainViewController
{
    if (!_curtainViewController)
    {
        _curtainViewController =
        ({
            BLCurtainViewController *viewController = [BLCurtainViewController sharedInstance];
            viewController;
        });
    }
    return _curtainViewController;
}

@end
