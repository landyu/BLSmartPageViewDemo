//
//  TimmingViewController.m
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/12/8.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "TimmingViewController.h"
#import "TimmingAddViewController.h"
#import "TimmingItemTableViewCell.h"
#import "BLSettingData.h"
#import "Timming.h"
//#import "BLGCDKNXTunnellingAsyncUdpSocket.h"

@interface TimmingViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *timmingTableView;
    NSMutableArray *timmingItemsArray;
    BOOL timmingItemsChanged;
    
    Timming *timmingModeInstance;
    //BLGCDKNXTunnellingAsyncUdpSocket *tunnellingShareInstance;
}

@end

@implementation TimmingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //tunnellingShareInstance  = [BLGCDKNXTunnellingAsyncUdpSocket sharedInstance];
    
    //UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed:)];
    //self.navigationItem.leftBarButtonItem = leftButton;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd  target:self action:@selector(addButtonPressed:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    timmingItemsChanged = NO;
    //timmingItemsArray = [BLSettingData sharedSettingData].timmingItemsArray;
    if (timmingItemsArray == nil)
    {
        timmingItemsArray = [[NSMutableArray alloc] init];
    }
    
    timmingModeInstance = [[Timming alloc] init];
    timmingModeInstance.delegate = self;
    
    //timmingItemsArray = [[NSMutableArray alloc] init];
    
    
    timmingTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    
    timmingTableView.dataSource = self;
    timmingTableView.delegate = self;
    //timmingSettingTableView.allowsSelection = NO;
    
    UIGraphicsBeginImageContext([[UIScreen mainScreen] bounds].size);
    [[UIImage imageNamed:@"Background"] drawInRect:[[UIScreen mainScreen] bounds]];
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //timmingSettingTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    timmingTableView.backgroundColor = [UIColor clearColor];
    [timmingTableView setSeparatorColor:[UIColor blackColor]];
    [timmingTableView setLayoutMargins:UIEdgeInsetsZero];
    timmingTableView.autoresizingMask= UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    
    [self.view addSubview:timmingTableView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"定时";
    //[timmingTableView reloadData];TimmingItemsGetItemsTotalCount

    if ([timmingItemsArray count] != 0)
    {
        [timmingItemsArray removeAllObjects];
        [timmingTableView reloadData];
    }
    
    GetTimmingItemsCompleteBlock callback = ^(BOOL isNoError) {
        if (isNoError)
        {
            NSLog(@"Timming Items All Get Error");
        }
    };
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
    [timmingModeInstance getTimmingItemsWithCompletion:callback];
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    if (timmingItemsChanged == YES)
//    {
//        [[BLSettingData sharedSettingData] save];
//        timmingItemsChanged = NO;
//    }
    
}

- (void)editButtonPressed:(id)sender
{
    NSLog(@"editButtonPressed");
    [timmingTableView setEditing:!timmingTableView.editing animated:YES];
    
    if (timmingTableView.editing)
        [self.navigationItem.leftBarButtonItem setTitle:@"完成"];
    else
        [self.navigationItem.leftBarButtonItem setTitle:@"编辑"];
}

- (void)addButtonPressed:(id)sender
{
    NSLog(@"addButtonPressed");
    TimmingAddViewController *timmingAddViewController = [[TimmingAddViewController alloc] init];
    timmingAddViewController.delegate = self;
    [self.navigationController pushViewController:timmingAddViewController animated:YES];
    //timmingAddViewController.title = @"添加定时";
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
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [timmingItemsArray count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row];
    TimmingItemTableViewCell *cell =[timmingTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    //TimmingItemTableViewCell *timmingItemTableViewCell;
    if (cell == nil)
    {
        cell = [[TimmingItemTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    
    TimmingPacket *timmingItem = [timmingItemsArray objectAtIndex:indexPath.row];
    [cell setTimmingData:timmingItem];
    //cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    
    //cell = timmingItemTableViewCell;
    
    
    return cell;

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //add code here for when you hit delete
        [timmingItemsArray removeObjectAtIndex:indexPath.row];
        timmingItemsChanged = YES;
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - TimmingAddProtocol
-(void)timmingAddItem:(TimmingPacket *)timmingItem
{
    NSLog(@"################ Add ####################");
    NSLog(@"Timming Date  : %@", timmingItem->timmingDate);
    NSLog(@"Repeat Value  : %@", timmingItem->timmingRepeat);
    NSLog(@"setLabelName  : %@", timmingItem->timmingLabelName);
    NSLog(@"Write To Address  : %@", timmingItem->timmingWriteToAddress);
    NSLog(@"Value Type  : %@", timmingItem->timmingValueType);
    NSLog(@"Send Value  : %@", timmingItem->timmingSendValue);
    NSLog(@"Enable Flag  : %d", timmingItem->timmingEnable);
    
    [timmingItemsArray insertObject:timmingItem atIndex:[timmingItemsArray count]];
    timmingItemsChanged = YES;
    NSArray *insertIndexPaths = [NSArray arrayWithObjects:
                                 [NSIndexPath indexPathForRow:[timmingItemsArray count] - 1 inSection:0],
                                 nil];
    
    [timmingTableView beginUpdates];
    [timmingTableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationRight];
    [timmingTableView endUpdates];
}

#pragma mark - TimmingDelegate
- (void)timmingItemsAllGotWithItems:(NSArray *)items
{
    NSUInteger index = 0;
    
    if ([timmingItemsArray count] != 0)
    {
        [timmingItemsArray removeAllObjects];
    }
    for (TimmingPacket * timmingItem in items)
    {
        NSLog(@"################ %lu ####################", (unsigned long)index++);
        NSLog(@"----Timming Date  : %@", timmingItem->timmingDate);
        NSLog(@"----Repeat Value  : %@", timmingItem->timmingRepeat);
        NSLog(@"----setLabelName  : %@", timmingItem->timmingLabelName);
        NSLog(@"----Write To Address  : %@", timmingItem->timmingWriteToAddress);
        NSLog(@"----Value Type  : %@", timmingItem->timmingValueType);
        NSLog(@"----Send Value  : %@", timmingItem->timmingSendValue);
        NSLog(@"----Enable Flag  : %d", timmingItem->timmingEnable);
        
        [timmingItemsArray addObject:timmingItem];
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [timmingTableView reloadData];
    });
}


@end
