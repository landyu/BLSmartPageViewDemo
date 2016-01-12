//
//  BLRemoteControllerViewController.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/28.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLRemoteControllerViewController.h"
#import "BLRemoteController.h"
#import "GlobalMacro.h"
#import "BLGCDKNXTunnellingAsyncUdpSocket.h"

@interface BLRemoteControllerViewController ()
{
    UIScrollView *scrollView;
    BLRemoteController *blRemoteControllerSharedInstance;
    BLGCDKNXTunnellingAsyncUdpSocket *tunnellingShareInstance;
    NSDictionary *previousRemoteControllerPropertyDict;
}

@end

@implementation BLRemoteControllerViewController

+ (instancetype)sharedInstance
{
    // 1
    static BLRemoteControllerViewController *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[BLRemoteControllerViewController alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        blRemoteControllerSharedInstance = [BLRemoteController sharedInstance];
        previousRemoteControllerPropertyDict = nil;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    tunnellingShareInstance  = [BLGCDKNXTunnellingAsyncUdpSocket sharedInstance];
    CGRect rect = [[UIScreen mainScreen] bounds];
    self.view.center = CGPointMake(rect.origin.x + rect.size.width / 2.0, rect.origin.y + rect.size.height / 2.0);
    
    scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview: scrollView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (blRemoteControllerSharedInstance.remoteControllerPropertyDict == nil || scrollView == nil)
    {
        return;
    }
    
    if (previousRemoteControllerPropertyDict == blRemoteControllerSharedInstance.remoteControllerPropertyDict)
    {
        return;
    }
    //avoid add the same button once again
    previousRemoteControllerPropertyDict = blRemoteControllerSharedInstance.remoteControllerPropertyDict;
    NSUInteger itemCount = [blRemoteControllerSharedInstance.remoteControllerPropertyDict count] - 1;
    NSUInteger itemRowNum = 0;
    if (itemCount > 3)
    {
        itemRowNum = itemCount / 3;
    }
    
    CGSize contentSize = CGSizeMake(self.view.bounds.size.width, itemRowNum * 80 + 80 + 150);
    scrollView.contentSize = contentSize;
    
   
    
    float rcButtonHeight = 60.0;
    float rcButtonWidth = 98.0;
    
    for (NSUInteger index = 0; index < [blRemoteControllerSharedInstance.remoteControllerPropertyDict count] -1; index++)
    {
        NSDictionary *itemDict = [blRemoteControllerSharedInstance.remoteControllerPropertyDict objectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)index]];
        
        if (itemDict == nil)
        {
            NSLog(@"remote item dict error......");
            continue;
            //return;
        }
        else
        {
            NSInteger currentRCItemIndex = index;
            NSInteger currentRCItemColumnIndex = (currentRCItemIndex % 3);
            NSInteger currentSceneItemRowIndex = 0;
            if (currentRCItemIndex >= 3)
            {
                currentSceneItemRowIndex = (currentRCItemIndex / 3);
            }
            
            
            UIButton *rcButoon = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            if (currentSceneItemRowIndex == 0)
            {
                if (currentRCItemColumnIndex == 0)
                {
                    rcButoon.frame = CGRectMake((currentRCItemColumnIndex) * rcButtonWidth + 150, 15, rcButtonWidth, rcButtonHeight);
                }
                else
                {
                    rcButoon.frame = CGRectMake((currentRCItemColumnIndex) * (rcButtonWidth  + 15) + 150, 15, rcButtonWidth, rcButtonHeight);
                }
                
            }
            else
            {
                if (currentRCItemColumnIndex == 0)
                {
                    rcButoon.frame = CGRectMake((currentRCItemColumnIndex) * rcButtonWidth + 150, (currentSceneItemRowIndex) * (rcButtonHeight + 10) + 15, rcButtonWidth, rcButtonHeight);
                }
                else
                {
                    rcButoon.frame = CGRectMake((currentRCItemColumnIndex) * (rcButtonWidth  + 15) + 150, (currentSceneItemRowIndex) * (rcButtonHeight + 10) + 15, rcButtonWidth, rcButtonHeight);
                }
                
            }
            
            NSString *buttonTitle = [itemDict objectForKey:@"Name"];
            if ([buttonTitle isEqualToString:@""])
            {
                continue;
            }
            else
            {
                
                UIImage *image = [UIImage imageNamed: @"CustomButton"];
                [rcButoon setBackgroundImage:image forState:UIControlStateNormal];
                image = [UIImage imageNamed: @"CustomButtonSelected"];
                [rcButoon setBackgroundImage:image forState:UIControlStateSelected];
                [rcButoon setTitle:buttonTitle forState:UIControlStateNormal];
                rcButoon.translatesAutoresizingMaskIntoConstraints = NO;
                [rcButoon setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [rcButoon addTarget:self action:@selector(rcButoonPressed:) forControlEvents:UIControlEventTouchUpInside];
                
                [scrollView addSubview:rcButoon];
            }
            //sceneItem->button = rcButoon;
            
            //[sceneArray addObject:sceneItem];
        }
        
        
        
        
    }
    
}

-(void)rcButoonPressed:(UIButton *)sender
{
    NSString *buttonTitle = [sender titleForState:UIControlStateNormal];
    
    for (NSUInteger index = 0; index < [blRemoteControllerSharedInstance.remoteControllerPropertyDict count] -1; index++)
    {
        NSDictionary *itemDict = [blRemoteControllerSharedInstance.remoteControllerPropertyDict objectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)index]];
        
        if (itemDict == nil)
        {
            NSLog(@"remote item dict error......2");
            continue;
            //return;
        }
        
        NSString *itemName = [itemDict objectForKey:@"Name"];
        
        if (itemName == nil)
        {
            continue;
        }
        
        if ([buttonTitle isEqualToString:itemName])
        {
            NSLog(@"RC Group Address = %@", [itemDict objectForKey:@"WriteToGroupAddress"]);
            NSString *writeToGroupAddress = [itemDict objectForKey:@"WriteToGroupAddress"];
            NSString *value = [itemDict objectForKey:@"Value"];
            NSString *valueLength = [itemDict objectForKey:@"ValueLength"];
            
            [tunnellingShareInstance tunnellingSendWithDestGroupAddress:writeToGroupAddress value:[value integerValue] buttonName:nil valueLength:valueLength commandType:@"Write"];
            break;
        }
    }
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

@end
