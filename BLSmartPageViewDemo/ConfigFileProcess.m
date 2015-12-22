//
//  ConfigFileProcess.m
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/11/4.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "ConfigFileProcess.h"
#import "ZipArchive.h"

@interface ConfigFileProcess()
{
    
}
@end

@implementation ConfigFileProcess

- (id) init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(httpServerFileTransmitDone:) name:@"HTTPServerFileTransmitDone" object:nil];
    }
    
    return self;
}

- (void)httpServerFileTransmitDone:(NSNotification *)notification
{
    NSDictionary *infoDict = notification.userInfo;
    NSString *fileName = [infoDict objectForKey:@"FileName"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString* roomInfoDirPath = [path stringByAppendingPathComponent:@"RoomInfo"];
    
    NSLog(@"fileName = %@", fileName);
    if ([fileName isEqualToString:@"RoomInfo.zip"])
    {
        //NSString* configFilePath = [uploadDirPath stringByAppendingPathComponent:@"RoomInfo.zip"];

        BOOL isDir = YES;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL existed = [fileManager fileExistsAtPath:roomInfoDirPath isDirectory:&isDir];
        if ((isDir == YES && existed == YES))
        {
            [fileManager removeItemAtPath:roomInfoDirPath error:nil];
        }
        
        NSString* uploadDirPath = [path stringByAppendingPathComponent:@"upload"];
        NSString* configFilePath = [uploadDirPath stringByAppendingPathComponent:@"RoomInfo.zip"];
        
        ZipArchive *za = [[ZipArchive alloc] init];
        // 1
        if ([za UnzipOpenFile: configFilePath])
        {
            // 2
            BOOL ret = [za UnzipFileTo: path overWrite: YES];
            if (NO == ret)
            {
                
            }
            [za UnzipCloseFile];
            
            NSArray *pathArray = [self allFilesAtPath:roomInfoDirPath];
            for (NSString *fileName in pathArray)
            {
                NSLog(@"File Name = -----------%@", fileName);
            }
            // 3
//            NSString *RoomInfoDirPath = [path stringByAppendingPathComponent:@"RoomInfo"];
//            NSString *propertyConfigPath = [RoomInfoDirPath stringByAppendingPathComponent:@"总经理办公室.plist"];
//            //NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
//            NSString *textString = [NSString stringWithContentsOfFile:propertyConfigPath encoding:NSUTF8StringEncoding error:nil];
//            
//            NSLog(@"总经理办公室 = %@", textString);
        }
        
    }
}

- (NSMutableArray *)allFilesAtPath:(NSString *)direString
{
    NSMutableArray *pathArray = [NSMutableArray array];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *tempArray = [fileManager contentsOfDirectoryAtPath:direString error:nil];
    for (NSString *fileName in tempArray) {
        BOOL flag = YES;
        NSString *fullPath = [direString stringByAppendingPathComponent:fileName];
        if ([fileManager fileExistsAtPath:fullPath isDirectory:&flag]) {
            if (!flag) {
                // ignore .DS_Store
                if (![[fileName substringToIndex:1] isEqualToString:@"."]) {
                    [pathArray addObject:fullPath];
                }
            }
            else {
                [pathArray addObject:[self allFilesAtPath:fullPath]];
            }
        }
    }
    
    return pathArray;
}
@end
