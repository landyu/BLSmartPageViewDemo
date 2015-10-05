//
//  BLPadSettingData.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/9/25.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLSettingData : NSObject <NSCoding>

@property (strong, nonatomic) NSString *deviceIPAddress;
+(instancetype)sharedSettingData;
-(void)save;
@end
