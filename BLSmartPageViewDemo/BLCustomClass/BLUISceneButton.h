//
//  BLUISceneButton.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/9/1.
//  Copyright (c) 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLUISceneButton : UIButton

@property (nonatomic, copy)NSString *objName;
@property (nonatomic, copy)NSNumber *sceneDelayDuration;
//@property (nonatomic)NSUInteger sceneCount;
@property (nonatomic, retain)NSMutableDictionary *sceneSequenceMutableDict;


@end
