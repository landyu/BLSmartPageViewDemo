//
//  TimmingAddViewController.m
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/12/8.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "TimmingAddViewController.h"
#import "TimmingAddRepeatViewController.h"
#import "TimmingAddLabelViewController.h"
#import "TimmingAddWriteToAddressViewController.h"
#import "TimmingAddValueTypeViewController.h"
#import "TimmingAddSendValueViewController.h"
#import "BLGCDKNXTunnellingAsyncUdpSocket.h"

@interface TimmingAddViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *timmingSettingTableView;
    NSDate *timmingDate;
    NSDictionary *repeatInfo;
    NSString *timmingLabelName;
    NSString *timmingWriteToAddress;
    NSString *timmingValueType;
    NSString *timmingSendValue;
    
    NSIndexPath *timmingRepeatCellIndexPath;
    NSIndexPath *timmingLabelCellIndexPath;
    NSIndexPath *timmingWriteToAddressCellIndexPath;
    NSIndexPath *timmingValueTypeCellIndexPath;
    NSIndexPath *timmingSendValueCellIndexPath;
    
    NSArray *repeatDate;
    UIDatePicker *timePick;
    
    //TimmingAdd *timmingAddModeInstance;
    
    TimmingPacket *timmingPacket;
    BLGCDKNXTunnellingAsyncUdpSocket *tunnellingShareInstance;
}

@end

@implementation TimmingAddViewController
@synthesize delegate;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"添加定时";
    
    tunnellingShareInstance  = [BLGCDKNXTunnellingAsyncUdpSocket sharedInstance];
    //timmingAddModeInstance = [[TimmingAdd alloc] init];
    
    timmingPacket = [[TimmingPacket alloc]init];
    
    if (timmingLabelName == nil)
    {
        timmingLabelName = [NSString stringWithFormat:@"标签"];
    }
    
    if (timmingWriteToAddress == nil)
    {
        timmingWriteToAddress = [NSString stringWithFormat:@"0/0/1"];
    }
    
    if (timmingValueType == nil)
    {
        timmingValueType = [NSString stringWithFormat:@"1Bit"];
    }
    
    if (timmingSendValue == nil)
    {
        timmingSendValue = [NSString stringWithFormat:@"0"];
    }
    
    if (repeatInfo == nil)
    {
        repeatInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"0", @"每周日", @"0", @"每周一",@"0", @"每周二",@"0", @"每周三",@"0", @"每周四",@"0", @"每周五",@"0", @"每周六",nil];
    }
    
    if (repeatDate == nil)
    {
        repeatDate = [[NSArray alloc] initWithObjects:@"每周日", @"每周一",  @"每周二", @"每周三", @"每周四", @"每周五", @"每周六",nil];
    }
    
    NSArray *viewControllerArr = [self.navigationController viewControllers];
    long previousViewControllerIndex = [viewControllerArr indexOfObject:self] - 1;
    UIViewController *previous;
    previous = [viewControllerArr objectAtIndex:previousViewControllerIndex];
    if (previousViewControllerIndex >= 0)
    {
        previous.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                 initWithTitle:@"取消"
                                                 style:UIBarButtonItemStylePlain
                                                 target:self
                                                 action:nil];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                         initWithTitle:@"存储"
                                                         style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(saveButtonPressed:)];
    
    //self.navigationItem.leftBarButtonItem.
    
    timePick = [[UIDatePicker alloc]initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y + 50, self.view.bounds.size.width, self.view.bounds.size.height / 3.0)];
    timePick.datePickerMode =UIDatePickerModeTime;
    [timePick setValue:[UIColor whiteColor] forKey:@"textColor"];
    [timePick addTarget:self action:@selector(datePickerChange:) forControlEvents:UIControlEventValueChanged];
    
    
    timmingSettingTableView=[[UITableView alloc]initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y + self.view.bounds.size.height / 3.0 + 50, self.view.bounds.size.width, self.view.bounds.size.height * 2.0 / 3.0) style:UITableViewStyleGrouped];
    //itemsTableView=[[UITableView alloc]initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y + sceneCellHight, self.view.bounds.size.width, self.view.bounds.size.height - sceneCellHight) style:UITableViewStyleGrouped];
    
    //设置数据源，注意必须实现对应的UITableViewDataSource协议
    timmingSettingTableView.dataSource = self;
    timmingSettingTableView.delegate = self;
    //timmingSettingTableView.allowsSelection = NO;
    
    UIGraphicsBeginImageContext([[UIScreen mainScreen] bounds].size);
    [[UIImage imageNamed:@"Background"] drawInRect:[[UIScreen mainScreen] bounds]];
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //timmingSettingTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    timmingSettingTableView.backgroundColor = [UIColor clearColor];
    [timmingSettingTableView setSeparatorColor:[UIColor blackColor]];
    [timmingSettingTableView setLayoutMargins:UIEdgeInsetsZero];
    //[timmingSettingTableView.separator]
    
    
    
//    if ([timmingSettingTableView respondsToSelector:@selector(setSeparatorInset:)]) {
//        [timmingSettingTableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
//    }
//    
//    if ([timmingSettingTableView respondsToSelector:@selector(setLayoutMargins:)]) {
//        [timmingSettingTableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
//    }
    timmingSettingTableView.autoresizingMask= UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    //UIColor *color = [UIColor clearColor];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    //self.view.backgroundColor = color;
    
    [self.view addSubview:timePick];
    [self.view addSubview:timmingSettingTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)datePickerChange:(UIDatePicker *)paramPicker
{
    NSLog(@"Selected date = %@", paramPicker.date);
    timmingDate = paramPicker.date;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        TimmingAddRepeatViewController *timmingAddRepeatViewController = [[TimmingAddRepeatViewController alloc] initWithRepeatInfo:repeatInfo];
        timmingAddRepeatViewController.delegate = self;
        [self.navigationController pushViewController:timmingAddRepeatViewController animated:YES];
        //UILabel *cellLabel = [[tableView cellForRowAtIndexPath:indexPath] textLabel];
        //timmingAddRepeatViewController.title = cellLabel.text;
    }
    else if (indexPath.row == 1)
    {
        TimmingAddLabelViewController *timmingAddLabelViewController = [[TimmingAddLabelViewController alloc] initWithLabelName:timmingLabelName];
        timmingAddLabelViewController.delegate = self;
        [self.navigationController pushViewController:timmingAddLabelViewController animated:YES];
        //UILabel *cellLabel = [[tableView cellForRowAtIndexPath:indexPath] textLabel];
        //timmingAddRepeatViewController.title = cellLabel.text;
    }
    else if(indexPath.row == 2)
    {
        TimmingAddWriteToAddressViewController *timmingAddLabelViewController = [[TimmingAddWriteToAddressViewController alloc] initWithWriteToAddress:timmingWriteToAddress];
        timmingAddLabelViewController.delegate = self;
        [self.navigationController pushViewController:timmingAddLabelViewController animated:YES];
    }
    else if(indexPath.row == 3)
    {
        TimmingAddValueTypeViewController *timmingAddValueTypeViewController = [[TimmingAddValueTypeViewController alloc] initWithValueType:timmingValueType];
        timmingAddValueTypeViewController.delegate = self;
        [self.navigationController pushViewController:timmingAddValueTypeViewController animated:YES];
    }
    else if(indexPath.row == 4)
    {
        TimmingAddSendValueViewController *timmingAddSendValueViewController = [[TimmingAddSendValueViewController alloc] initWithSendValue:timmingSendValue];
        timmingAddSendValueViewController.delegate = self;
        [self.navigationController pushViewController:timmingAddSendValueViewController animated:YES];
    }
    
    
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row];
    UITableViewCell *cell =[timmingSettingTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell != nil)
    {
        return cell;
    }
    
    if (indexPath.row == 0)
    {
        cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.textLabel.text = @"重复";
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.text = @"永不";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIGraphicsBeginImageContext(cell.bounds.size);
        //UIGraphicsBeginImageContext(CGSizeMake(cell.bounds.size.width, cell.bounds.size.height - 3));
        [[UIImage imageNamed:@"CellBackground"] drawInRect:cell.bounds];
        UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        cell.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        cell.backgroundColor = [UIColor clearColor];
        //cell.contentView.backgroundColor = [UIColor clearColor];
        
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.3];
        cell.selectedBackgroundView = bgView;
        
        timmingRepeatCellIndexPath = indexPath;
    }
    else if(indexPath.row == 1)
    {
        cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.textLabel.text = @"标签";
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.text = timmingLabelName;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //[cell.separatorInset.bottom];
        
        UIGraphicsBeginImageContext(cell.bounds.size);
        [[UIImage imageNamed:@"CellBackground"] drawInRect:cell.bounds];
        UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        cell.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        cell.backgroundColor = [UIColor clearColor];
        
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.3];
        cell.selectedBackgroundView = bgView;
        
        timmingLabelCellIndexPath = indexPath;
    }
    else if(indexPath.row == 2)
    {
        cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.textLabel.text = @"目标地址";
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.text = timmingWriteToAddress;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //[cell.separatorInset.bottom];
        
        UIGraphicsBeginImageContext(cell.bounds.size);
        [[UIImage imageNamed:@"CellBackground"] drawInRect:cell.bounds];
        UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        cell.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        cell.backgroundColor = [UIColor clearColor];
        
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.3];
        cell.selectedBackgroundView = bgView;
        
        timmingWriteToAddressCellIndexPath = indexPath;
    }
    else if(indexPath.row == 3)
    {
        cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.textLabel.text = @"数据类型";
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.text = timmingValueType;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //[cell.separatorInset.bottom];
        
        UIGraphicsBeginImageContext(cell.bounds.size);
        [[UIImage imageNamed:@"CellBackground"] drawInRect:cell.bounds];
        UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        cell.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        cell.backgroundColor = [UIColor clearColor];
        
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.3];
        cell.selectedBackgroundView = bgView;
        
        timmingValueTypeCellIndexPath = indexPath;
    }
    else if(indexPath.row == 4)
    {
        cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.textLabel.text = @"发送值";
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.text = timmingSendValue;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //[cell.separatorInset.bottom];
        
        UIGraphicsBeginImageContext(cell.bounds.size);
        [[UIImage imageNamed:@"CellBackground"] drawInRect:cell.bounds];
        UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        cell.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        cell.backgroundColor = [UIColor clearColor];
        
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.3];
        cell.selectedBackgroundView = bgView;
        
        timmingSendValueCellIndexPath = indexPath;
    }
    return cell;
}

- (void)saveButtonPressed:(UIBarButtonItem *)sender
{
    if (timmingDate == nil)
    {
        timmingDate = timePick.date;
    }
    NSLog(@"saveButtonPressed");
    NSLog(@"Timming Date : %@", timmingDate);
    NSLog(@"setLabelName  : %@", timmingLabelName);
    NSLog(@"Write To Address  : %@", timmingWriteToAddress);
    NSLog(@"Value Type  : %@", timmingValueType);
    NSLog(@"Send Value  : %@", timmingSendValue);
    timmingPacket->timmingDate = timmingDate;
    timmingPacket->timmingRepeat = repeatInfo;
    timmingPacket->timmingLabelName = timmingLabelName;
    timmingPacket->timmingWriteToAddress = timmingWriteToAddress;
    timmingPacket->timmingValueType = timmingValueType;
    timmingPacket->timmingSendValue = timmingSendValue;
    
    SEL selector = @selector(timmingAddItem:);
    
    if ([delegate respondsToSelector:selector])
    {
        [delegate timmingAddItem:timmingPacket];
    }
    //[tunnellingShareInstance tunnellingSendWithDestGroupAddress:@"0/0/1" value:0 buttonName:nil valueLength:@"1Bit" commandType:@"TimmingItemSet"];
    NSDictionary *timmingItemDict = [Timming assembleToDictionaryWithTimmingPacket:timmingPacket];
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:@"0/0/1" value:0 buttonName:nil valueLength:@"1Bit" commandType:@"TimmingItemSet" additionInfo:timmingItemDict];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setLabelName:(NSString *)labelName
{
    NSLog(@"setLabelName  : %@", labelName);
    timmingLabelName = labelName;
    UITableViewCell *timmingLabelCell = [timmingSettingTableView cellForRowAtIndexPath:timmingLabelCellIndexPath];
    timmingLabelCell.detailTextLabel.text = timmingLabelName;
    
}

-(void)setWriteToAddress:(NSString *)address
{
    NSLog(@"Write To Address  : %@", address);
    timmingWriteToAddress = address;
    UITableViewCell *timmingWriteToAddressCell = [timmingSettingTableView cellForRowAtIndexPath:timmingWriteToAddressCellIndexPath];
    timmingWriteToAddressCell.detailTextLabel.text = timmingWriteToAddress;
}

-(void)setValueType:(NSString *)type
{
    NSLog(@"Value Type  : %@", type);
    timmingValueType = type;
    UITableViewCell *timmingValueTypeCell = [timmingSettingTableView cellForRowAtIndexPath:timmingValueTypeCellIndexPath];
    timmingValueTypeCell.detailTextLabel.text = timmingValueType;
}

-(void)setSendValue:(NSString *)value
{
    NSLog(@"Send Value  : %@", value);
    timmingSendValue = value;
    UITableViewCell *timmingSendValueCell = [timmingSettingTableView cellForRowAtIndexPath:timmingSendValueCellIndexPath];
    timmingSendValueCell.detailTextLabel.text = timmingSendValue;
}

-(void)setRepeatDict:(NSDictionary *)data
{
    NSLog(@"Repeat Info  : %@", data);
    repeatInfo = data;
    UITableViewCell *timmingRepeatCell = [timmingSettingTableView cellForRowAtIndexPath:timmingRepeatCellIndexPath];
    BOOL repeatWeekend = YES;
    BOOL repeatWeekday = YES;
    BOOL everyday = YES;
    NSMutableArray *availableRepeatDate = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < [repeatDate count]; index++)
    {
        NSString *repeatDateKey = [repeatDate objectAtIndex:index];
        NSString *repeatValue = [repeatInfo objectForKey:repeatDateKey];
        
        if (repeatValue != nil)
        {
            if ([repeatDateKey  isEqualToString:@"每周日"])
            {
                if ([repeatValue isEqualToString:@"0"])
                {
                    everyday = everyday & NO;
                    repeatWeekend = repeatWeekend & NO;
                }
                else
                {
                    [availableRepeatDate addObject:repeatDateKey];
                }
            }
            else if ([repeatDateKey  isEqualToString:@"每周一"])
            {
                if ([repeatValue isEqualToString:@"0"])
                {
                    everyday = everyday & NO;
                    repeatWeekday = repeatWeekday & NO;
                }
                else
                {
                    [availableRepeatDate addObject:repeatDateKey];
                }
            }
            else if ([repeatDateKey  isEqualToString:@"每周二"])
            {
                if ([repeatValue isEqualToString:@"0"])
                {
                    everyday = everyday & NO;
                    repeatWeekday = repeatWeekday & NO;
                }
                else
                {
                    [availableRepeatDate addObject:repeatDateKey];
                }
            }
            else if ([repeatDateKey  isEqualToString:@"每周三"])
            {
                if ([repeatValue isEqualToString:@"0"])
                {
                    everyday = everyday & NO;
                    repeatWeekday = repeatWeekday & NO;
                }
                else
                {
                    [availableRepeatDate addObject:repeatDateKey];
                }
            }
            else if ([repeatDateKey  isEqualToString:@"每周四"])
            {
                if ([repeatValue isEqualToString:@"0"])
                {
                    everyday = everyday & NO;
                    repeatWeekday = repeatWeekday & NO;
                }
                else
                {
                    [availableRepeatDate addObject:repeatDateKey];
                }
            }
            else if ([repeatDateKey  isEqualToString:@"每周五"])
            {
                if ([repeatValue isEqualToString:@"0"])
                {
                    everyday = everyday & NO;
                    repeatWeekday = repeatWeekday & NO;
                }
                else
                {
                    [availableRepeatDate addObject:repeatDateKey];
                }
            }
            else if ([repeatDateKey  isEqualToString:@"每周六"])
            {
                if ([repeatValue isEqualToString:@"0"])
                {
                    everyday = everyday & NO;
                    repeatWeekend = repeatWeekend & NO;
                }
                else
                {
                    [availableRepeatDate addObject:repeatDateKey];
                }
            }
        }
    }
    
    if (everyday)
    {
        timmingRepeatCell.detailTextLabel.text = @"每天";
    }
    else if(repeatWeekday && ([availableRepeatDate count] <= 5))
    {
        timmingRepeatCell.detailTextLabel.text = @"工作日";
    }
    else if(repeatWeekend && ([availableRepeatDate count] <= 2))
    {
        timmingRepeatCell.detailTextLabel.text = @"每周末";
    }
    else
    {
        timmingRepeatCell.detailTextLabel.text = [[availableRepeatDate valueForKey:@"description"] componentsJoinedByString:@","];
    }
}



@end
