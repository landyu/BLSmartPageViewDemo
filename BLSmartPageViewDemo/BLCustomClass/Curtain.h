//
//  Curtain.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/12/28.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Curtain : NSObject
{

}
@property (strong, nonatomic) NSString *openCloseWriteToGroupAddress;
@property (strong, nonatomic) NSString *stopWriteToGroupAddress;
@property (strong, nonatomic) NSString *moveToPositionWriteToGroupAddress;
@property (strong, nonatomic) NSString *positionStatusReadFromGroupAddress;
@property (readwrite) NSUInteger curtainPosition;
@end
