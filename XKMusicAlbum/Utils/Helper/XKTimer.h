//
//  XKTimer.h
//  XKTimer
//
//  Created by 浪漫恋星空 on 2018/2/11.
//  Copyright © 2018年 浪漫恋星空. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XKTimer : NSObject

/**
 初始化定时器
 
 @param seconds 定时器的时间间隔
 @param repeats 定时器是否需要重复
 @param queue   执行线程
 @param handler 间隔执行的操作
 @return 定时器
 */
+ (XKTimer *)xk_timerWIthTimeInterval:(NSTimeInterval)seconds
                              repeats:(BOOL)repeats
                                queue:(dispatch_queue_t)queue
                              handler:(dispatch_block_t)handler;

/**
 初始化定时器(在主线程)
 
 @param seconds 定时器的时间间隔
 @param repeats 定时器是否需要重复
 @param handler 间隔执行的操作
 @return 定时器
 */
+ (XKTimer *)xk_timerWIthTimeInterval:(NSTimeInterval)seconds
                              repeats:(BOOL)repeats
                              handler:(dispatch_block_t)handler;

/**
 开始定时器
 */
- (void)fire;

/**
 暂停定时器
 */
- (void)frozen;

/**
 销毁定时器
 */
- (void)invalidate;

@end
