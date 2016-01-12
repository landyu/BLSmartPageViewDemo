//
//  BLPadSettingData.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/9/25.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLSettingData.h"


@implementation BLSettingData

static NSString* const BLSettingDataDeviceIPAddressKey = @"deviceIPAddress";
static NSString* const BLTimmingItemsArrayKey = @"timmingItemsArray";

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.deviceIPAddress forKey: BLSettingDataDeviceIPAddressKey];
    [encoder encodeObject:self.timmingItemsArray forKey: BLTimmingItemsArrayKey];
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self)
    {
        _deviceIPAddress = [decoder decodeObjectForKey: BLSettingDataDeviceIPAddressKey];
        _timmingItemsArray = [[decoder decodeObjectForKey: BLTimmingItemsArrayKey] mutableCopy];
    }
    return self;
}


- (instancetype)init
{
    if (self = [super init]) {
        if (_timmingItemsArray == nil)
        {
            _timmingItemsArray = [[NSMutableArray alloc] init];
        }
        
        if (_deviceIPAddress == nil)
        {
            _deviceIPAddress = [[NSString alloc] init];
        }
    }
    return self;
}


+ (instancetype)sharedSettingData
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self loadInstance];
    });
    
    return sharedInstance;
}

+(NSString*)filePath
{
    static NSString* filePath = nil;
    if (!filePath) {
        filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"settingdata.plist"];
    }
    return filePath;
}

+(instancetype)loadInstance
{
    NSData* decodedData = [NSData dataWithContentsOfFile: [BLSettingData filePath]];
    if (decodedData) {
        BLSettingData* gameData = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
        if (gameData)
        {
            return gameData;
        }
    }
    
    return [[BLSettingData alloc] init];
}

-(void)save
{
    NSData* encodedData = [NSKeyedArchiver archivedDataWithRootObject: self];
    [encodedData writeToFile:[BLSettingData filePath] atomically:YES];
}

@end
