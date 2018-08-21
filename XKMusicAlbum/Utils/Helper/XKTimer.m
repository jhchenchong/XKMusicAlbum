//
//  XKTimer.m
//  XKTimer
//
//  Created by 浪漫恋星空 on 2018/2/11.
//  Copyright © 2018年 浪漫恋星空. All rights reserved.
//

#import "XKTimer.h"

@interface XKTimer()

@property (nonatomic,strong) dispatch_source_t timer;

@end

@implementation XKTimer

+ (XKTimer *)xk_timerWIthTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats queue:(dispatch_queue_t)queue handler:(dispatch_block_t)handler {
    NSAssert(seconds > 0, @"定时器的时长需要大于0");
    XKTimer *weakTimer = [[XKTimer alloc]init];
    weakTimer.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(weakTimer.timer, dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC), seconds * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(weakTimer.timer, ^{
        if (handler) {
            handler();
        }
        if (!repeats) {
            if (weakTimer.timer == nil) {
                return;
            }
            dispatch_source_cancel(weakTimer.timer);
        }
    });
    return weakTimer;
}

+ (XKTimer *)xk_timerWIthTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats handler:(dispatch_block_t)handler {
    return [XKTimer xk_timerWIthTimeInterval:seconds repeats:repeats queue:dispatch_get_main_queue() handler:handler];
}

- (void)fire {
    dispatch_resume(self.timer);
}

- (void)frozen {
    dispatch_suspend(self.timer);
}

- (void)invalidate {
    if (self.timer) {
        dispatch_source_cancel(self.timer);
    }
}

- (void)dealloc {
    [self invalidate];
}

@end
