//
//  NSMutableArray+QueueStack.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/8/24.
//  Copyright (c) 2015年 Landyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (QueueStack)
- (id) queuePop;
- (void) queuePush:(id)obj;
- (id) stackPop;
- (void) stackPush:(id)obj;
@end
