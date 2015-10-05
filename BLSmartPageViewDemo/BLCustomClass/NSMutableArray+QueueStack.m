//
//  NSMutableArray+QueueStack.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/8/24.
//  Copyright (c) 2015年 Landyu. All rights reserved.
//

#import "NSMutableArray+QueueStack.h"

@implementation NSMutableArray (QueueStack)
// Queues are first-in-first-out, so we remove objects from the head
-(id)queuePop {
    if ([self count] == 0) {
        return nil;
    }
    
    id queueObject = [self objectAtIndex:0];
    
    [self removeObjectAtIndex:0];
    
    return queueObject;
}

// Add to the tail of the queue
-(void)queuePush:(id)anObject {
    [self addObject:anObject];
}

//Stacks are last-in-first-out.
-(id)stackPop {
    id lastObject = [self lastObject];
    
    if (lastObject)
        [self removeLastObject];
    
    return lastObject;
}

-(void)stackPush:(id)obj {
    [self addObject: obj];
}
@end
