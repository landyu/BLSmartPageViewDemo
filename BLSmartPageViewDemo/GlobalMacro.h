//
//  GlobalMacro.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/9/18.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#ifndef GlobalMacro_h
#define GlobalMacro_h

#if 1

#define LogInfo(frmt, ...)      NSLog(@"%s(%d): " frmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else

// Logging Disabled

#define LogError(frmt, ...)     {}
#define LogWarn(frmt, ...)      {}
#define LogInfo(frmt, ...)      {}
#define LogVerbose(frmt, ...)   {}

#define LogCError(frmt, ...)    {}
#define LogCWarn(frmt, ...)     {}
#define LogCInfo(frmt, ...)     {}
#define LogCVerbose(frmt, ...)  {}

#define LogTrace()              {}
#define LogCTrace(frmt, ...)    {}

#endif


#define PageJumpNotification @"BL.BLSmartPageViewDemo.PageJumpNotification"
#define TunnellingSendQueueKeyPath @"tunnellingSendQueue"
#define TunnellingSendQueueOperateQueue "BL.BLSmartPageViewDemo.TunnellingSendQueueOperateQueue"
#define TunnellingConnectSuccessNotification @"BL.BLSmartPageViewDemo.TunnellingConnectSuccessNotification"

#endif /* GlobalMacro_h */
