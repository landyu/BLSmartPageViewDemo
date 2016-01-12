//
//  TimmingAddLabelViewController.m
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/12/9.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "TimmingAddLabelViewController.h"

@interface TimmingAddLabelViewController ()
{
    UITextField *labelTextField;
    NSString *timmingLabelName;
}

@end

@implementation TimmingAddLabelViewController
@synthesize delegate;
- (id)initWithLabelName:(NSString *)labelName
{
    self = [super init];
    if (self)
    {
        timmingLabelName = labelName;
    }
    
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"设置标签";
    
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
    
    labelTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.size.height / 4.0, self.view.bounds.size.width, 45)];
    labelTextField.borderStyle = UITextBorderStyleRoundedRect;
    labelTextField.backgroundColor = [UIColor whiteColor];
    labelTextField.text = timmingLabelName;
    
    
    UIGraphicsBeginImageContext([[UIScreen mainScreen] bounds].size);
    [[UIImage imageNamed:@"Background"] drawInRect:[[UIScreen mainScreen] bounds]];
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    
    [self.view addSubview:labelTextField];
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
    SEL selector = @selector(setLabelName:);
    
    if ([delegate respondsToSelector:selector])
    {
        [delegate setLabelName:labelTextField.text];
    }
    
}




@end
