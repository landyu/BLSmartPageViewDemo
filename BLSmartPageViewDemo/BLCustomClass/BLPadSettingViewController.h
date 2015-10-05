//
//  BLPadSettingViewController.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/9/24.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLPadSettingViewController : UIViewController
- (IBAction)deviceIpAddressChanged:(UITextField *)sender;
- (IBAction)deviceIpAddressEditingDidEnd:(UITextField *)sender;
@property (strong, nonatomic) IBOutlet UITextField *deviceIpAddressText;
@end
