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
    NSString *path = [[NSBundle mainBundle] pathForResource:@"PropertyConfig" ofType:@"plist"];
    NSMutableDictionary *temDict = [[NSMutableDictionary alloc]initWithContentsOfFile:path];
    
//    NSEnumerator *propConfigKeyEnum = [temDict keyEnumerator];
//    for (NSObject *obj in propConfigKeyEnum)
//    {
//        NSLog(@"key:%@", obj);
//    }
    self.sceneListMutDict = [[NSMutableDictionary alloc] initWithDictionary:[temDict objectForKey:@"SceneList"]];
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    appDelegate.sceneListDictionarySharedInstance = self.sceneListMutDict;
    
//    NSArray *propConfigArray = [[NSArray alloc] initWithArray:[temDict objectForKey:@"SceneList"]];
//    NSArray *targetKey = [[NSArray alloc] initWithObjects:@"SceneList", nil];
//    
//    sceneListMutDict = [[NSMutableDictionary alloc] initWithObjects:propConfigArray forKeys:targetKey];
//    //cell.textLabel.text = [secondTableInfo objectAtIndex:indexPath.row];
    //NSLog(@"%@",sceneListMutDict);
}

@end
