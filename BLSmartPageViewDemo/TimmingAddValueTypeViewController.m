//
//  TimmingAddValueTypeViewController.m
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/12/9.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "TimmingAddValueTypeViewController.h"

@interface TimmingAddValueTypeViewController ()
{
    UITextField *valueTypeTextField;
    NSString *valueType;
}

@end

@implementation TimmingAddValueTypeViewController
@synthesize delegate;
- (id)initWithValueType:(NSString *)type
{
    self = [super init];
    if (self)
    {
        valueType = type;
    }
    
    return  self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"设置数据类型";
    
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
    
    valueTypeTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.size.height / 4.0, self.view.bounds.size.width, 45)];
    valueTypeTextField.borderStyle = UITextBorderStyleRoundedRect;
    valueTypeTextField.backgroundColor = [UIColor whiteColor];
    valueTypeTextField.text = valueType;
    
    
    UIGraphicsBeginImageContext([[UIScreen mainScreen] bounds].size);
    [[UIImage imageNamed:@"Background"] drawInRect:[[UIScreen mainScreen] bounds]];
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    
    [self.view addSubview:valueTypeTextField];
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
    SEL selector = @selector(setValueType:);
    
    if ([delegate respondsToSelector:selector])
    {
        [delegate setValueType:valueTypeTextField.text];
    }
    
}

@end
