//
//  XKAnimationHelper.m
//  XKMusicAlbum
//
//  Created by 浪漫恋星空 on 2018/8/17.
//  Copyright © 2018年 浪漫恋星空. All rights reserved.
//

#import "XKAnimationHelper.h"

@interface XKAnimationHelper ()<CAAnimationDelegate>


@end

@implementation XKAnimationHelper

+ (CATransform3D)tranformToBox:(int)boxNumber {
    CATransform3D transform = CATransform3DIdentity;
    if (boxNumber == 2) {
        CATransform3D tmp = CATransform3DIdentity;
        transform = CATransform3DRotate(transform, 0.3326f, 0, 1, 0);
        tmp = CATransform3DIdentity;
        tmp.m34 = 0.0100f;
        transform = CATransform3DConcat(transform, tmp);
        transform = CATransform3DTranslate(transform, -5.6863f, -0.0000f, -0.0000f);
        transform = CATransform3DScale(transform, 1.0000f, 0.8725f, 1.0000f);
        transform = CATransform3DScale(transform, 1.0784f, 1.0000f, 1.0000f);
    } else if (boxNumber == 3) {
        CATransform3D tmp = CATransform3DIdentity;
        transform = CATransform3DRotate(transform, -0.3450f, 0, 1, 0);
        tmp = CATransform3DIdentity;
        tmp.m34 = 0.0100f;
        transform = CATransform3DConcat(transform, tmp);
        transform = CATransform3DTranslate(transform, 5.8824f, 0.0000f, 0.0000f);
        transform = CATransform3DScale(transform, 1.0000f, 0.8725f, 1.0000f);
        transform = CATransform3DScale(transform, 1.0884f, 1.0000f, 1.0000f);
    } else if (boxNumber == 4) {
        CATransform3D tmp = CATransform3DIdentity;
        transform = CATransform3DRotate(transform, -0.3450f, 0, 1, 0);
        tmp = CATransform3DIdentity;
        tmp.m34 = 0.0100f;
        transform = CATransform3DConcat(transform, tmp);
        transform = CATransform3DTranslate(transform, 5.8824f, 0.0000f, 0.0000f);
        transform = CATransform3DScale(transform, 1.0000f, 0.6461f, 1.0000f);
        transform = CATransform3DScale(transform, 1.0784f, 1.0000f, 1.0000f);
    } else if (boxNumber == 1) {
        CATransform3D tmp = CATransform3DIdentity;
        transform = CATransform3DRotate(transform, 0.3326f, 0, 1, 0);
        tmp = CATransform3DIdentity;
        tmp.m34 = 0.0100f;
        transform = CATransform3DConcat(transform, tmp);
        transform = CATransform3DTranslate(transform, -5.6863f, -0.0000f, -0.0000f);
        transform = CATransform3DScale(transform, 1.0000f, 0.6561f, 1.0000f);
        transform = CATransform3DScale(transform, 1.0684f, 1.0000f, 1.0000f);
    }
    return transform;
}

- (CAKeyframeAnimation *)animationPageUrl:(float)duration startTime:(NSTimeInterval)startTime show:(BOOL)show {
    CATransform3D transform = CATransform3DIdentity;
    float zDistanse = 800.0;
    transform.m34 = 1.0 / -zDistanse;
    
    CATransform3D transform1 = CATransform3DRotate(transform, -M_PI_2/10, 0, 1, 0);
    CATransform3D transform2 = CATransform3DRotate(transform, -M_PI_2, 0, 1, 0);
    
    CAKeyframeAnimation* keyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    keyframeAnimation.duration = duration;
    keyframeAnimation.values = [NSArray arrayWithObjects:
                                [NSValue valueWithCATransform3D:transform],
                                [NSValue valueWithCATransform3D:transform1],
                                [NSValue valueWithCATransform3D:transform2],
                                nil];
    if (show) {
        keyframeAnimation.values = [NSArray arrayWithObjects:
                                    [NSValue valueWithCATransform3D:transform2],
                                    [NSValue valueWithCATransform3D:transform1],
                                    [NSValue valueWithCATransform3D:transform],
                                    nil];
    }
    
    keyframeAnimation.keyTimes = [NSArray arrayWithObjects:
                                  [NSNumber numberWithFloat:0],
                                  [NSNumber numberWithFloat:.2],
                                  [NSNumber numberWithFloat:1.0],
                                  nil];
    keyframeAnimation.timingFunctions = [NSArray arrayWithObjects:
                                         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                                         nil];
    keyframeAnimation.removedOnCompletion = NO;
    keyframeAnimation.fillMode = kCAFillModeForwards;
    keyframeAnimation.beginTime = startTime;
    
    return keyframeAnimation;
}

// 旋转
- (CABasicAnimation *)animationRotation:(float)duration degree:(float)degree direction:(int)direction repeatCount:(int)repeatCount {
    CATransform3D rotationTransform  = CATransform3DMakeRotation(degree, 0, 0,direction);
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    animation.toValue = [NSValue valueWithCATransform3D:rotationTransform];
    animation.duration = duration;
    animation.autoreverses = NO;
    animation.cumulative = YES;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.repeatCount = repeatCount;
    animation.delegate = self;
    
    return animation;
}

// 缩放
- (CABasicAnimation *)animationScale:(NSNumber *)Multiple orgin:(NSNumber *)orginMultiple durTimes:(float)time Rep:(float)repeatTimes {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue = orginMultiple;
    animation.toValue = Multiple;
    animation.duration = time;
    animation.autoreverses = YES;
    animation.repeatCount = repeatTimes;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    return animation;
}

// 点移动
- (CABasicAnimation *)animationMovePoint:(float)time point:(CGPoint)point {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation"];
    animation.toValue = [NSValue valueWithCGPoint:point];
    animation.removedOnCompletion = NO;
    animation.duration = time;
    animation.fillMode = kCAFillModeForwards;
    
    return animation;
}

// 横向移动
- (CABasicAnimation *)animationMoveX:(float)time X:(NSNumber *)x {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    animation.toValue = x;
    animation.duration = time;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    return animation;
}

// 纵向移动
- (CABasicAnimation *)animationMoveY:(float)time Y:(NSNumber *)y {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animation.toValue = y;
    animation.duration = time;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    return animation;
}

// 有闪烁次数的动画
- (CABasicAnimation *)animationOpacityTimes:(float)repeatTimes durTimes:(float)time; {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:1.0];
    animation.toValue = [NSNumber numberWithFloat:0.0];
    animation.repeatCount = repeatTimes;
    animation.duration = time;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.autoreverses = YES;
    
    return  animation;
}

// 路径动画
- (CAKeyframeAnimation *)keyframeAniamtion:(CGMutablePathRef)path durTimes:(float)time Rep:(float)repeatTimes {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path = path;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.autoreverses = NO;
    animation.duration = time;
    animation.repeatCount = repeatTimes;
    
    return animation;
}

// Z轴旋转
- (CABasicAnimation *)animationRotationZ:(float)repeatTimes durationTimes:(float)time startTime:(NSTimeInterval)startTime {
    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotation.toValue = [NSNumber numberWithFloat:-4 * M_PI];
    rotation.duration = time;
    rotation.repeatCount = repeatTimes;
    rotation.autoreverses = YES;
    rotation.beginTime = startTime;
    
    return  rotation;
}

@end
