//
//  ViewController.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/8/7.
//  Copyright (c) 2015年 Landyu. All rights reserved.
//

#import "ViewController.h"
#import "APPChildViewController.h"
#import "AppDelegate.h"
#import "PropertyConfigPhrase.h"
#import "BLRootNavigationController.h"
#import "GlobalMacro.h"
#import "BLPadSettingViewController.h"
//#import <objc/runtime.h>
//@import CoreData;

@interface ViewController ()
{
    NSUInteger pageIndicatorIndex;
}
@property (strong, readwrite, nonatomic) REMenu *menu;
@property (strong, readwrite, nonatomic) UIBarButtonItem * settingButton;
@property (strong, readwrite, nonatomic) UIBarButtonItem * roomSelectButton;
@property (strong, readwrite, nonatomic) UIBarButtonItem * barButtonSpacer;
@property (strong, nonatomic) BLPadSettingViewController *settingViewController;
@end

@implementation ViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.rightBarButtonItems =[NSArray arrayWithObjects:self.barButtonSpacer, self.settingButton, self.barButtonSpacer, self.barButtonSpacer, self.roomSelectButton, nil];
    
    //add navigator room select button
    [self initRoomSelectButton];

    //add page controller
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    //self.pageController
    
    self.pageController.dataSource = self;
    self.pageController.delegate = self;
    //[[self.pageController view] setFrame:[[self view] bounds]];
    //[[self.pageController view] setFrame:CGRectMake(0, 44, 2048, 1492)];
    [[self.pageController view] setFrame:CGRectMake(0, 65, 1024, 703)];
    
    
    
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    //appDelegate.viewControllerNavigationItemSharedInstance = self.viewControllerNavigationItem;
    
    //self.viewControllerNavigationItem.title = [NSString stringWithFormat:@"Screen #0"];
    
    
    PropertyConfigPhrase *sceneConfig = [[PropertyConfigPhrase alloc] init];
    [sceneConfig sceneListDictionary];
    
    self.sceneListDict = appDelegate.sceneListDictionarySharedInstance;
    sceneListCount = [self.sceneListDict count];
    
    //self.viewControllerNavigationItem.title = [self.sceneListDict objectForKey:@"0"];
    self.title = [self.sceneListDict objectForKey:@"0"];
    
    pageIndicatorIndex = 0;
    APPChildViewController *initialViewController = [self viewControllerAtIndex:pageIndicatorIndex];
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished)
     {
         NSLog(@"set View Controllers Done...");
     }];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    

}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageJump:) name:PageJumpNotification object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) {
        NSInteger currentIndex = ((UIViewController *)[pageViewController.viewControllers objectAtIndex:0]).view.tag;
        
        
        //self.viewControllerNavigationItem.title = [self.sceneListDict objectForKey:[NSString stringWithFormat:@"%d", currentIndex]];
        self.title = [self.sceneListDict objectForKey:[NSString stringWithFormat:@"%ld", (long)currentIndex]];
    }
}

#pragma mark - UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(APPChildViewController *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(APPChildViewController *)viewController index];
    
    
    index++;
    //NSLog(@"scene list count = %d", sceneListCount);
    if (index == sceneListCount) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
    
}


//- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
//    // The number of items reflected in the page indicator.
//    return sceneListCount;
//}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    NSLog(@"presentation Index For Page View Controller Done...");
    return pageIndicatorIndex;
}

#pragma mark - event response
- (void)roomSelect:(UIButton *)sender
{
    CGRect buttonRect = sender.frame;
    NSLog(@"roomSelect @%f @%f", buttonRect.origin.x, buttonRect.origin.y);
    if (self.menu.isOpen)
        return [self.menu close];
    
    [self.menu showFromNavigationController:self.navigationController withPressedButtonRect:buttonRect];
    //[self.menu showFromRect:buttonRect inView:self.view];
}

- (void)setBarTintColor:(id)sender
{
    NSLog(@"setBarTintColor");
}

- (void)pageJump:(NSNotification*) notification
{
    NSDictionary *pageNameDict = [notification userInfo];
    NSString *roomName = [pageNameDict objectForKey:@"PageName"];
    
    if (roomName == nil)
    {
        return;
    }
    
    __typeof (self) __weak weakSelf = self;
    if (self.sceneListDict == nil)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"PropertyConfig" ofType:@"plist"];
        NSDictionary *temDict = [[NSDictionary alloc]initWithContentsOfFile:path];
        
        self.sceneListDict = [[NSDictionary alloc] initWithDictionary:[temDict objectForKey:@"SceneList"]];
    }
    
    
    [self.sceneListDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         NSString *nibName = (NSString *)obj;
         if ([nibName isEqualToString:roomName])
         {
             pageIndicatorIndex = [key integerValue];
             [self.pageController setViewControllers:[NSArray arrayWithObject:[self viewControllerAtIndex:pageIndicatorIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished)
              {
                  NSLog(@"back to %@...", nibName);
                  weakSelf.title = nibName;
                  //NSDictionary *pageJumpDict = [NSDictionary dictionaryWithObjectsAndKeys:roomName, @"PageName",nil];
                  //[[NSNotificationCenter defaultCenter] postNotificationName:PageJumpNotification object:nil userInfo:pageJumpDict];
                  //self.title = roomName;
                  //[self setNavigatorTitle:roomName];
              }];
             *stop = YES;
         }
     }];
}
- (void)setttingButtonPressed:(UIButton *)sender
{
    NSLog(@"setttingButtonPressed");
    [self.navigationController pushViewController:self.settingViewController animated:YES];
    //[self.navigationController addChildViewController:self.settingPageNavigationController];
    //[self.settingPageNavigationController.view show];
}

//- (IBAction)recvFromBusBtn:(id)sender
//{
//    
//    NSDictionary *eibBusDataDict = [NSDictionary dictionaryWithObjectsAndKeys:groupAddressField.text, @"Address", valueField.text, @"Value",nil];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"BL.BLSmartPageViewDemo.RecvFromBus" object:self userInfo:eibBusDataDict];
//}

//- (void)viewWillLayoutSubviews
//{
//    [super viewWillLayoutSubviews];
//    BLRootNavigationController *navigationController = (BLRootNavigationController *)self.navigationController;
//    [navigationController.menu setNeedsLayout];
//}

#pragma mark - private methods
- (APPChildViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    //APPChildViewController *childViewController = [[APPChildViewController alloc] initWithNibName:@"APPChildViewController" bundle:nil];
    
    //AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    //NSLog(@"%@", self.sceneListDict);
    //NSLog(@"%@", appDelegate.sceneListDictionarySharedInstance);
    
    NSLog(@"nib name = %@", [self.sceneListDict valueForKey:[NSString stringWithFormat: @"%lu", (unsigned long)index]]);
    //NSLog(@"key = %@", [NSString stringWithFormat: @"%d", index]);
    //NSString *nibName = [self.sceneListDict valueForKey:[NSString stringWithFormat: @"%d", index]];
    
    APPChildViewController *childViewController = [[APPChildViewController alloc] initWithNibName:[self.sceneListDict valueForKey:[NSString stringWithFormat: @"%lu", (unsigned long)index]] bundle:nil];
    
    //self.viewControllerNavigationItem.title = [NSString stringWithFormat:@"Screen #%ld", (long)index];
    childViewController.index = index;
    childViewController.nibName = [self.sceneListDict valueForKey:[NSString stringWithFormat: @"%lu", (unsigned long)index]];
    childViewController.pageController = self.pageController;
    childViewController.pageControllerDataSource = self;
    //[childViewController addChildViewController:self.pageController];
    
    return childViewController;
    
}

- (void)initRoomSelectButton
{
//    UIButton * customRoomSelectButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    customRoomSelectButton.frame = CGRectMake(0, 0, 30, 30);
//    [customRoomSelectButton setImage:[UIImage imageNamed:@"Icon_Home.png"] forState:UIControlStateNormal];
//    [customRoomSelectButton addTarget:self action:@selector(roomSelect:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *roomSelectButton = [[UIBarButtonItem alloc] initWithCustomView:customRoomSelectButton];
//    
//    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self.navigationController action:nil];
//    negativeSpacer.width = 40;
//    self.navigationItem.rightBarButtonItems =[NSArray arrayWithObjects:negativeSpacer, negativeSpacer, negativeSpacer, negativeSpacer, roomSelectButton, nil];
    
    
    if (REUIKitIsFlatMode())
    {
        [self.navigationController.navigationBar performSelector:@selector(setBarTintColor:) withObject:[UIColor colorWithRed:0/255.0 green:213/255.0 blue:161/255.0 alpha:1]];
        self.navigationController.navigationBar.tintColor = [UIColor greenColor];
    } else
    {
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0 green:179/255.0 blue:134/255.0 alpha:1];
    }
    
    [self initNavigatorButtonItems];
    
    
    
}


- (void) initNavigatorButtonItems
{

    
    self.menu = [[REMenu alloc] initWithItems:[self roomSelectButtonItemsInit]];
    
    if (!REUIKitIsFlatMode())
    {
        self.menu.cornerRadius = 4;
        self.menu.shadowRadius = 4;
        self.menu.shadowColor = [UIColor blackColor];
        self.menu.shadowOffset = CGSizeMake(0, 1);
        self.menu.shadowOpacity = 1;
    }
    
    self.menu.imageOffset = CGSizeMake(5, -1);
    self.menu.waitUntilAnimationIsComplete = NO;
    self.menu.badgeLabelConfigurationBlock = ^(UILabel *badgeLabel, REMenuItem *item) {
        badgeLabel.backgroundColor = [UIColor colorWithRed:0 green:179/255.0 blue:134/255.0 alpha:1];
        badgeLabel.layer.borderColor = [UIColor colorWithRed:0.000 green:0.648 blue:0.507 alpha:1.000].CGColor;
    };
    
    
    [self.menu setClosePreparationBlock:^{
        NSLog(@"Menu will close");
    }];
    
    [self.menu setCloseCompletionHandler:^{
        NSLog(@"Menu did close");
    }];
}


- (NSArray *)roomSelectButtonItemsInit
{
    NSUInteger menuTag = 0;
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"PropertyConfig" ofType:@"plist"];
    NSDictionary *temDict = [[NSDictionary alloc]initWithContentsOfFile:path];
    
    NSDictionary * sceneListDic = [[NSDictionary alloc] initWithDictionary:[temDict objectForKey:@"SceneList"]];
    NSDictionary * roomSelectButtonListDict = [[NSDictionary alloc] initWithDictionary:[temDict objectForKey:@"RoomSelectButtonList"]];
    NSDictionary * ButtonListLevel1Dict = [[NSDictionary alloc] initWithDictionary:[roomSelectButtonListDict objectForKey:@"ButtonListLevel1"]];
    NSDictionary * ButtonListDetailDict = [[NSDictionary alloc] initWithDictionary:[roomSelectButtonListDict objectForKey:@"ButtonListDetail"]];
    __typeof (self) __weak weakSelf = self;
    
    for (NSUInteger buttonLevel1Index = 0; buttonLevel1Index < [ButtonListDetailDict count]; buttonLevel1Index++)
    {
        NSString * level1Key = [NSString stringWithFormat:@"%lu", (unsigned long)buttonLevel1Index];
        
        NSDictionary *level1Dict = [ButtonListDetailDict objectForKey:level1Key];
        if (level1Dict == nil)
        {
            continue;
        }
        
        REMenuItem *menuLevel1Item = [[REMenuItem alloc] initWithTitle:[ButtonListLevel1Dict objectForKey:level1Key]
                                                        subtitle:nil
                                                           image:[UIImage imageNamed:@"Icon_Home"]
                                                highlightedImage:nil
                                                                action:^(REMenuItem *item)
                                                                {
                                                                    [sceneListDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                                                                                                                         {
                                                                                                                             NSString *nibName = (NSString *)obj;
                                                                                                                             if ([nibName isEqualToString:[ButtonListLevel1Dict objectForKey:level1Key]])
                                                                                                                             {
                                                                                                                                 pageIndicatorIndex = [key integerValue];
                                                                                                                                 [self.pageController setViewControllers:[NSArray arrayWithObject:[self viewControllerAtIndex:pageIndicatorIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished)
                                                                                                                                  {
                                                                                                                                      NSLog(@"back to %@...", nibName);
                                                                                                                                      weakSelf.title = nibName;
                                                                                                                                  }];
                                                                                                                                 *stop = YES;
                                                                                                                             }
                                                                                                                         }];
                                                                }];
        menuLevel1Item.tag = menuTag++;
        [items addObject:menuLevel1Item];
        
        for (NSUInteger buttonLevel2Index = 0; buttonLevel2Index < [level1Dict count]; buttonLevel2Index++)
        {
            NSString * level2Key = [NSString stringWithFormat:@"%lu", (unsigned long)buttonLevel2Index];
            
            NSString *level2RoomName = [level1Dict objectForKey:level2Key];
            REMenuItem *menuLevel2Item = [[REMenuItem alloc] initWithTitle:level2RoomName
                                                                  subtitle:nil
                                                                     image:nil
                                                          highlightedImage:nil
                                                                    action:^(REMenuItem *item)
                                                                        {
                                                                            [sceneListDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                                                                            {
                                                                                NSString *nibName = (NSString *)obj;
                                                                                if ([nibName isEqualToString:level2RoomName])
                                                                                {
                                                                                    pageIndicatorIndex = [key integerValue];
                                                                                    [self.pageController setViewControllers:[NSArray arrayWithObject:[self viewControllerAtIndex:pageIndicatorIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished)
                                                                                     {
                                                                                         NSLog(@"back to %@...", nibName);
                                                                                         weakSelf.title = nibName;
                                                                                     }];
                                                                                    *stop = YES;
                                                                                }
                                                                            }];
                                                                        }];

            menuLevel2Item.tag = menuTag++;
            [items addObject:menuLevel2Item];


        }
    }

    
    return items;
}


#pragma mark - getters and setters
- (UIBarButtonItem *) roomSelectButton
{
    if (!_roomSelectButton)
    {
        _roomSelectButton =
        ({
            UIButton * CustomButton = [UIButton buttonWithType:UIButtonTypeCustom];
            CustomButton.frame = CGRectMake(0, 0, 30, 30);
            [CustomButton setImage:[UIImage imageNamed:@"Icon_Home.png"] forState:UIControlStateNormal];
            [CustomButton addTarget:self action:@selector(roomSelect:) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:CustomButton];
            button;
        });
    }
    return _roomSelectButton;
}


- (UIBarButtonItem *) settingButton
{
    if (!_settingButton)
    {
        _settingButton =
        ({
            UIButton * CustomButton = [UIButton buttonWithType:UIButtonTypeCustom];
            CustomButton.frame = CGRectMake(0, 0, 30, 30);
            [CustomButton setImage:[UIImage imageNamed:@"Icon_Activity.png"] forState:UIControlStateNormal];
            [CustomButton addTarget:self action:@selector(setttingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:CustomButton];
            button;
        });
    }
    return _settingButton;
}

- (UIBarButtonItem *) barButtonSpacer
{
    if (!_barButtonSpacer)
    {
        _barButtonSpacer =
        ({
            UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            button.width = 40;
            button;
        });
    }
    return _barButtonSpacer;
}

- (BLPadSettingViewController *) settingViewController
{
    if (!_settingViewController)
    {
        _settingViewController =
        ({
            BLPadSettingViewController *viewController = [[BLPadSettingViewController alloc] initWithNibName:@"BLPadSettingViewController" bundle:nil];
            //BLPadSettingViewController *viewController = [[BLPadSettingViewController alloc] init];
            //[[viewController view] setFrame:CGRectMake(0, 65, 1024, 703)];
            viewController;
        });
    }
    return _settingViewController;
}

@end
