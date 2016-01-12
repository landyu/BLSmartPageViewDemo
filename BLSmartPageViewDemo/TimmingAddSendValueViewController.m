//
//  TimmingAddSendValueViewController.m
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/12/9.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "TimmingAddSendValueViewController.h"

@interface TimmingAddSendValueViewController ()
{
    UITextField *sendValueTextField;
    NSString *sendValue;
}
@end

@implementation TimmingAddSendValueViewController
@synthesize delegate;
- (id)initWithSendValue:(NSString *)value
{
    self = [super init];
    if (self)
    {
        sendValue = value;
    }
    
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"设置发送值";
    
    NSArray *viewControllerArr = [self.navigationController viewControllers];
    long previousViewControllerIndex = [viewControllerArr indexOfObject:self] - 1;
    UIViewController *previous;
    previous = [viewControllerArr objectAtIndex:previousViewControllerIndex];
    if (previousViewControllerIndex >= 0)
    {
        previous.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                     initWithTitle:@"返回"
                                                     style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:nil];
    }
    
    sendValueTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.size.height / 4.0, self.view.bounds.size.width, 45)];
    sendValueTextField.borderStyle = UITextBorderStyleRoundedRect;
    sendValueTextField.backgroundColor = [UIColor whiteColor];
    sendValueTextField.text = sendValue;
    
    
    UIGraphicsBeginImageContext([[UIScreen mainScreen] bounds].size);
    [[UIImage imageNamed:@"Background"] drawInRect:[[UIScreen mainScreen] bounds]];
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    
    [self.view addSubview:sendValueTextField];
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

-(void)viewWillDisappear:(BOOL)animated
{
    //[delegate sendDataToA:yourdata];
    SEL selector = @selector(setSendValue:);
    
    if ([delegate respondsToSelector:selector])
    {
        [delegate setSendValue:sendValueTextField.text];
    }
    
}

@end
