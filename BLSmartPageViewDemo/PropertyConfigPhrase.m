//
//  PropertyConfigPhrase.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/8/10.
//  Copyright (c) 2015年 Landyu. All rights reserved.
//

#import "PropertyConfigPhrase.h"
#import "AppDelegate.h"

@implementation PropertyConfigPhrase

- (void)sceneListDictionary
{
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"PropertyConfig" ofType:@"plist"];
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [documentPaths objectAtIndex:0];
    NSString* roomInfoDirPath = [documentPath stringByAppendingPathComponent:@"RoomInfo"];
    NSString *propertyConfigPath = [roomInfoDirPath stringByAppendingPathComponent:@"PropertyConfig.plist"];;
    
    BOOL isDir = YES;
    BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:roomInfoDirPath isDirectory:&isDir];
    if ((isDir == YES && existed == YES))
    {
        isDir = NO;
        existed = [[NSFileManager defaultManager] fileExistsAtPath:propertyConfigPath isDirectory:&isDir];
        if (existed == NO)
        {
            return;
        }
    }
    else
    {
        return;
    }
    
    NSMutableDictionary *temDict = [[NSMutableDictionary alloc]initWithContentsOfFile:propertyConfigPath];
    
//    NSEnumerator *propConfigKeyEnum = [temDict keyEnumerator];
//    for (NSObject *obj in propConfigKeyEnum)
//    {
//        NSLog(@"key:%@", obj);
//    }
    self.sceneListMutDict = [[NSMutableDictionary alloc] initWithDictionary:[temDict objectForKey:@"RoomList"]];
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    appDelegate.sceneListDictionarySharedInstance = self.sceneListMutDict;
    
//    NSArray *propConfigArray = [[NSArray alloc] initWithArray:[temDict objectForKey:@"RoomList"]];
//    NSArray *targetKey = [[NSArray alloc] initWithObjects:@"RoomList", nil];
//    
//    sceneListMutDict = [[NSMutableDictionary alloc] initWithObjects:propConfigArray forKeys:targetKey];
//    //cell.textLabel.text = [secondTableInfo objectAtIndex:indexPath.row];
    //NSLog(@"%@",sceneListMutDict);
}

@end
