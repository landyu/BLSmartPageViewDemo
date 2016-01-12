//
//  TimmingAddRepeatViewController.m
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/12/9.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "TimmingAddRepeatViewController.h"

@interface TimmingAddRepeatViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *repeatTableView;
    NSArray *repeatDate;
    NSMutableDictionary *repeatInfo;
}

@end

@implementation TimmingAddRepeatViewController
@synthesize delegate;

- (id)initWithRepeatInfo:(NSDictionary *)info
{
    self = [super init];
    if (self)
    {
        repeatInfo = [info mutableCopy];
        if (repeatInfo == nil)
        {
            repeatInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"0", @"每周日", @"0", @"每周一",@"0", @"每周二",@"0", @"每周三",@"0", @"每周四",@"0", @"每周五",@"0", @"每周六",nil];
        }
    }
    
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"重复";
    
    repeatDate = [[NSArray alloc] initWithObjects:@"每周日", @"每周一",  @"每周二", @"每周三", @"每周四", @"每周五", @"每周六",nil];
    
    repeatTableView=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    repeatTableView.delegate = self;
    repeatTableView.dataSource = self;
    
    UIGraphicsBeginImageContext([[UIScreen mainScreen] bounds].size);
    [[UIImage imageNamed:@"Background"] drawInRect:[[UIScreen mainScreen] bounds]];
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //repeatTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    repeatTableView.backgroundColor = [UIColor clearColor];
    [repeatTableView setSeparatorColor:[UIColor blackColor]];
    [repeatTableView setLayoutMargins:UIEdgeInsetsZero];
    repeatTableView.autoresizingMask= UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    
    
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    
    [self.view addSubview:repeatTableView];
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
    SEL selector = @selector(setRepeatDict:);
    
    if ([delegate respondsToSelector:selector])
    {
        [delegate setRepeatDict:[repeatInfo copy]];
    }
    
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *repeatKey = [repeatDate objectAtIndex:indexPath.row];
    //NSString *repeatEnable;
    if ([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryCheckmark)
    {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
        //repeatEnable = [repeatInfo objectForKey:repeatKey];
        [repeatInfo setObject:@"0" forKey:repeatKey];
    }
    else
    {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        //repeatEnable = [repeatInfo objectForKey:repeatKey];
        [repeatInfo setObject:@"1" forKey:repeatKey];
    }
    
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row];
    UITableViewCell *cell =[repeatTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell != nil)
    {
        NSString *repeatValue = [repeatInfo objectForKey:[repeatDate objectAtIndex:indexPath.row]];
        if ([repeatValue isEqualToString:@"1"])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        return cell;
    }
    
    cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    
    UIGraphicsBeginImageContext(cell.bounds.size);
    //UIGraphicsBeginImageContext(CGSizeMake(cell.bounds.size.width, cell.bounds.size.height - 3));
    [[UIImage imageNamed:@"CellBackground"] drawInRect:cell.bounds];
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    cell.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = [repeatDate objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.tintColor = [UIColor whiteColor];
    //cell.contentView.backgroundColor = [UIColor clearColor];
    
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.3];
    cell.selectedBackgroundView = bgView;
    
    NSString *repeatValue = [repeatInfo objectForKey:[repeatDate objectAtIndex:indexPath.row]];
    if ([repeatValue isEqualToString:@"1"])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}



@end
