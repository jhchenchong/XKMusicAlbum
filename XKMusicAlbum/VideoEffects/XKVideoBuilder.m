//
//  XKVideoBuilder.m
//  XKMusicAlbum
//
//  Created by 浪漫恋星空 on 2018/8/16.
//  Copyright © 2018年 浪漫恋星空. All rights reserved.
//

#import "XKVideoBuilder.h"
#import "XKCurledViewHelper.h"
#import "XKVideoBuilder+XK.h"

@interface XKVideoBuilder ()

@property (nonatomic, assign) CMTime commentaryStartTime;
@property (nonatomic, assign) CMTime transitionDuration;
@property (nonatomic, copy) NSArray *clipTimeRanges;

@property (nonatomic, assign) CGSize thumbnailPhotoSize;
@property (nonatomic, assign) XKVideoBuilderTransitionType transitionType;

@end

@implementation XKVideoBuilder

- (instancetype)init {
    if (self = [super init]) {
        _commentaryStartTime = CMTimeMake(0, 1);
        _transitionDuration = CMTimeMake(1, 1);
        NSMutableArray *clipTimeRanges = [[NSMutableArray alloc] initWithCapacity:3];
        CMTimeRange defaultTimeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(5, 1));
        NSValue *defaultTimeRangeValue = [NSValue valueWithCMTimeRange:defaultTimeRange];
        [clipTimeRanges addObject:defaultTimeRangeValue];
        [clipTimeRanges addObject:defaultTimeRangeValue];
        [clipTimeRanges addObject:defaultTimeRangeValue];
        _clipTimeRanges = clipTimeRanges;
        _thumbnailPhotoSize = CGSizeMake(160, 160);
    }
    return self;
}

static CGImageRef createStarImage(CGFloat radius) {
    int i, count = 5;
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    CGImageRef image = NULL;
    size_t width = 2*radius;
    size_t height = 2*radius;
    size_t bytesperrow = width * 4;
    CGContextRef context = CGBitmapContextCreate((void *)NULL, width, height, 8, bytesperrow, colorspace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    CGContextClearRect(context, CGRectMake(0, 0, 2*radius, 2*radius));
    CGContextSetLineWidth(context, radius / 15.0);
    
    for( i = 0; i < 2 * count; i++ ) {
        CGFloat angle = i * M_PI / count;
        CGFloat pointradius = (i % 2) ? radius * 0.37 : radius * 0.95;
        CGFloat x = radius + pointradius * cos(angle);
        CGFloat y = radius + pointradius * sin(angle);
        if (i == 0) {
            CGContextMoveToPoint(context, x, y);
        } else {
            CGContextAddLineToPoint(context, x, y);
        }
    }
    CGContextClosePath(context);
    
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
    CGContextDrawPath(context, kCGPathFillStroke);
    CGColorSpaceRelease(colorspace);
    image = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    return image;
}

- (CAEmitterLayer *)buildEmitterRing:(CGSize)viewBounds startTime:(NSTimeInterval)startTime {
    CAEmitterLayer *ringEmitter = [CAEmitterLayer layer];
    ringEmitter.emitterPosition = CGPointMake(arc4random()%(int)viewBounds.width, arc4random()%(int)viewBounds.height);
    ringEmitter.emitterSize = CGSizeMake(50, 0);
    ringEmitter.emitterMode = kCAEmitterLayerOutline;
    ringEmitter.emitterShape = kCAEmitterLayerCircle;
    ringEmitter.renderMode = kCAEmitterLayerBackToFront;
    ringEmitter.beginTime = startTime;
    
    CAEmitterCell *ring = [CAEmitterCell emitterCell];
    [ring setName:@"ring"];
    ring.birthRate = 5;
    ring.velocity = 250;
    ring.scale = 0.5;
    ring.scaleSpeed = -0.2;
    ring.greenSpeed = -0.2;
    ring.redSpeed = -0.5;
    ring.blueSpeed = -0.5;
    ring.lifetime = 2;
    ring.color = [[UIColor whiteColor] CGColor];
    ring.contents = (id) [[UIImage imageNamed:@"DazTriangle"] CGImage];
    
    CAEmitterCell *circle = [CAEmitterCell emitterCell];
    [circle setName:@"circle"];
    circle.birthRate = 5;
    circle.emissionLongitude = M_PI * 0.5;
    circle.velocity = 50;
    circle.scale = 0.5;
    circle.scaleSpeed = -0.2;
    circle.greenSpeed = -0.1;
    circle.redSpeed = -0.2;
    circle.blueSpeed = 0.1;
    circle.alphaSpeed = -0.2;
    circle.lifetime = 4;
    circle.color = [[UIColor whiteColor] CGColor];
    circle.contents = (id) [[UIImage imageNamed:@"DazRing"] CGImage];
    
    
    CAEmitterCell* star = [CAEmitterCell emitterCell];
    [star setName:@"star"];
    star.birthRate = 5;
    star.velocity = 100;
    star.zAcceleration = -1;
    star.emissionLongitude = -M_PI;
    star.scale = 0.5;
    star.scaleSpeed = -0.2;
    star.greenSpeed = -0.1;
    star.redSpeed = 0.4;
    star.blueSpeed = -0.1;
    star.alphaSpeed = -0.2;
    star.lifetime = 2;
    star.color = [[UIColor whiteColor] CGColor];
    star.contents = (id) [[UIImage imageNamed:@"DazStarOutline"] CGImage];
    
    ringEmitter.emitterCells = [NSArray arrayWithObject:ring];
    ring.emitterCells = [NSArray arrayWithObjects:circle, star, nil];
    
    CABasicAnimation *burst = [CABasicAnimation animationWithKeyPath:@"emitterCells.ring.birthRate"];
    burst.fromValue = [NSNumber numberWithFloat:100.0];
    burst.toValue = [NSNumber numberWithFloat:0.0];
    burst.duration = 0.5;
    burst.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    burst.repeatCount = 5;
    
    [ringEmitter addAnimation:burst forKey:@"burst"];
    
    return ringEmitter;
}

- (CAEmitterLayer *)buildEmitterSnow:(CGSize)viewBounds startTime:(NSTimeInterval)startTime {
    CAEmitterLayer *snowEmitter = [CAEmitterLayer layer];
    snowEmitter.emitterPosition = CGPointMake(viewBounds.width / 2.0, viewBounds.height);
    snowEmitter.emitterSize = CGSizeMake(viewBounds.width * 2.0, 0.0);
    snowEmitter.beginTime = startTime;
    snowEmitter.emitterMode = kCAEmitterLayerOutline;
    snowEmitter.emitterShape = kCAEmitterLayerLine;
    
    CAEmitterCell *snowflake = [CAEmitterCell emitterCell];
    snowflake.birthRate = 1.0;
    snowflake.lifetime = 60.0;
    snowflake.velocity = 10;
    snowflake.velocityRange = 10;
    snowflake.yAcceleration = -30;
    snowflake.emissionRange = 0.5 * M_PI;
    snowflake.spinRange = 0.25 * M_PI;
    snowflake.contents = (id) [[UIImage imageNamed:@"DazFlake"] CGImage];
    snowflake.color = [[UIColor colorWithRed:0.600 green:0.658 blue:0.743 alpha:1.000] CGColor];
    
    snowEmitter.shadowOpacity = 1.0;
    snowEmitter.shadowRadius  = 0.0;
    snowEmitter.shadowOffset  = CGSizeMake(0.0, 1.0);
    snowEmitter.shadowColor   = [[UIColor whiteColor] CGColor];
    
    snowEmitter.emitterCells = [NSArray arrayWithObject:snowflake];
    
    return snowEmitter;
}

- (CAEmitterLayer *)buildEmitterSnow2:(CGSize)viewBounds startTime:(NSTimeInterval)startTime {
    CAEmitterLayer *parentLayer = [CAEmitterLayer layer];
    parentLayer.emitterPosition = CGPointMake(viewBounds.width/2.0, viewBounds.height+30);
    parentLayer.emitterSize = CGSizeMake(viewBounds.width*2, 0);
    parentLayer.emitterMode = kCAEmitterLayerOutline;
    parentLayer.emitterShape = kCAEmitterLayerLine;
    parentLayer.beginTime = startTime;
    
    parentLayer.shadowOpacity = 1.0;
    parentLayer.shadowRadius  = 0.0;
    parentLayer.shadowOffset  = CGSizeMake(0.0, 1.0);
    parentLayer.shadowColor   = [[UIColor whiteColor] CGColor];
    parentLayer.seed = (arc4random() % 100) + 1;
    
    CAEmitterCell *containerLayer = [CAEmitterCell emitterCell];
    containerLayer.birthRate = 3;
    containerLayer.velocity    = -1;
    containerLayer.lifetime    = 0.4;
    containerLayer.name = @"containerLayer";
    
    NSMutableArray *snowArray = [NSMutableArray array];
    for (int i = 1; i <= 13; i++) {
        NSString *imageName = [NSString stringWithFormat:@"snow%i",i];
        UIImage *image = [UIImage imageNamed:imageName];
        if (image) {
            [snowArray addObject:[self createFlowerLayer:image]];
        }
    }
    
    containerLayer.emitterCells = @[snowArray[0], snowArray[1], snowArray[3], snowArray[4], snowArray[5], snowArray[6], snowArray[7], snowArray[8], snowArray[9], snowArray[10], snowArray[11], snowArray[12]];
    parentLayer.emitterCells = @[containerLayer];
    
    return parentLayer;
}

- (CAEmitterCell *)createFlowerLayer:(UIImage *)image {
    CAEmitterCell *cellLayer = [CAEmitterCell emitterCell];
    cellLayer.birthRate = 3;
    cellLayer.lifetime = 10;
    
    cellLayer.velocity = -100;
    cellLayer.velocityRange = 20;
    cellLayer.yAcceleration = 2;
    cellLayer.emissionRange = 0.5 * M_PI;
    cellLayer.spinRange    = 0.5 * M_PI;
    cellLayer.scale = 0.2;
    cellLayer.scaleRange = 0.1;
    cellLayer.contents = (id)[image CGImage];
    
    cellLayer.color = [[UIColor whiteColor] CGColor];
    cellLayer.redRange = 1.0;
    cellLayer.greenRange = 1.0;
    cellLayer.blueRange = 1.0;
    
    return cellLayer;
}

- (CALayer *)buildAnimationStarText:(CGSize)viewBounds text:(NSString *)text startTime:(NSTimeInterval)startTime {
    if (!(text.length > 0)) {
        return nil;
    }
    CALayer *animatedTitleLayer = [CALayer layer];
    CGFloat height = viewBounds.height / 20;
    if (viewBounds.height < viewBounds.width) {
        height = viewBounds.width / 20;
    }
    CGFloat fontHeight = height;
    CATextLayer *titleLayer = [CATextLayer layer];
    titleLayer.string = text;
    titleLayer.font = (__bridge CFTypeRef)(@"Helvetica");
    titleLayer.fontSize = fontHeight;
    titleLayer.alignmentMode = kCAAlignmentCenter;
    titleLayer.bounds = CGRectMake(0, 0, viewBounds.width, fontHeight+10);
    
    [animatedTitleLayer addSublayer:titleLayer];
    
    NSTimeInterval animatedInStartTime = startTime;
    
    CALayer *ringOfStarsLayer = [CALayer layer];
    
    NSInteger starCount = 9, star;
    CGFloat starRadius = viewBounds.height / 15;
    CGFloat ringRadius = viewBounds.height * 0.5 / 2;
    CGImageRef starImage = createStarImage(starRadius);
    for (star = 0; star < starCount; star++) {
        CALayer *starLayer = [CALayer layer];
        CGFloat angle = star * 2 * M_PI / starCount;
        starLayer.bounds = CGRectMake(0, 0, 2 * starRadius, 2 * starRadius);
        starLayer.position = CGPointMake(ringRadius * cos(angle), ringRadius * sin(angle));
        starLayer.contents = (__bridge id)starImage;
        [ringOfStarsLayer addSublayer:starLayer];
    }
    CGImageRelease(starImage);
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.repeatCount = 1e100;
    rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    rotationAnimation.toValue = [NSNumber numberWithFloat:2 * M_PI];
    rotationAnimation.duration = 2.0;
    rotationAnimation.additive = YES;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.beginTime = animatedInStartTime;
    [ringOfStarsLayer addAnimation:rotationAnimation forKey:nil];
    
    animatedTitleLayer.position = CGPointMake(viewBounds.width / 2.0, viewBounds.height / 2.0);
    [animatedTitleLayer addSublayer:ringOfStarsLayer];
    
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.fromValue = @0.0f;
    fadeInAnimation.toValue = @1.0f;
    fadeInAnimation.additive = NO;
    fadeInAnimation.removedOnCompletion = NO;
    fadeInAnimation.beginTime = animatedInStartTime;
    fadeInAnimation.duration = 1.0;
    fadeInAnimation.autoreverses = NO;
    fadeInAnimation.fillMode = kCAFillModeBoth;
    
    NSTimeInterval animatedOutStartTime = rotationAnimation.beginTime + rotationAnimation.duration;
    
    CABasicAnimation* rotationAnimationLayer = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimationLayer.toValue = @((2 * M_PI) * -2);
    rotationAnimationLayer.duration = 3.0f;
    rotationAnimationLayer.beginTime = animatedOutStartTime;
    rotationAnimationLayer.removedOnCompletion = NO;
    rotationAnimationLayer.autoreverses = NO;
    rotationAnimationLayer.fillMode = kCAFillModeForwards;
    rotationAnimationLayer.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = @1.0f;
    scaleAnimation.toValue = @0.0f;
    scaleAnimation.duration = 1.0f;
    scaleAnimation.removedOnCompletion = NO;
    scaleAnimation.fillMode = kCAFillModeForwards;
    scaleAnimation.autoreverses = NO;
    scaleAnimation.beginTime = animatedOutStartTime;
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [animatedTitleLayer addAnimation:fadeInAnimation forKey:nil];
    [animatedTitleLayer addAnimation:rotationAnimationLayer forKey:@"spinOut"];
    [animatedTitleLayer addAnimation:scaleAnimation forKey:@"scaleOut"];
    
    return animatedTitleLayer;
}

- (CALayer *)buildAnimatedScrollLine:(CGSize)viewBounds startTime:(CFTimeInterval)timeInterval lineHeight:(CGFloat)lineHeight image:(UIImage *)image {
    CGFloat width = viewBounds.width;
    CGFloat height = viewBounds.height;
    
    CALayer *lineLayer = [CALayer layer];
    lineLayer.backgroundColor = [UIColor clearColor].CGColor;
    UIImage *maskImage = [self maskImageForImage:width height:lineHeight];
    lineLayer.contents = (id) maskImage.CGImage;
    lineLayer.contentsGravity = kCAGravityCenter;
    lineLayer.frame = CGRectMake(0, -height, width, height*1.25);
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position.y"];
    anim.byValue = @(height * 2);
    anim.repeatCount = 3;
    anim.duration = 3.0f;
    anim.beginTime = CMTimeGetSeconds(kCMTimeZero) + timeInterval;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [lineLayer addAnimation:anim forKey:@"shine"];
    
    if (image) {
        CALayer *shineLayer = [CALayer layer];
        UIImage *shineImage = [self highlightedImageForImage:image];
        shineLayer.contents = (id) shineImage.CGImage;
        shineLayer.frame = CGRectMake(0, 0, width, height);
        shineLayer.mask = lineLayer;
        return shineLayer;
    } else {
        return lineLayer;
    }
}

- (CALayer *)buildAnimatedScrollText:(CGSize)viewBounds text:(NSString *)text startPoint:(CGPoint)startPoint startTime:(NSTimeInterval)startTime {
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.string = text;
    textLayer.font = (__bridge CFTypeRef)(@"Helvetica");
    textLayer.fontSize = 18;
    textLayer.alignmentMode = kCAAlignmentCenter;
    
    CGFloat height = viewBounds.height / 6;
    if (viewBounds.height < viewBounds.width) {
        height = viewBounds.width / 6;
    }
    textLayer.bounds = CGRectMake(0, 0, viewBounds.width, height);
    
    CGPoint startPointIn = startPoint;
    CGPoint middlePoint = CGPointMake(viewBounds.width/2, startPoint.y);
    CGPoint endPointIn = CGPointMake(-viewBounds.width/2, startPoint.y);
    textLayer.position = endPointIn;
    
    CMTime animatedOutStartTime = CMTimeMake(1, 100);
    
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.fromValue = @0.0f;
    fadeInAnimation.toValue = @0.8f;
    fadeInAnimation.additive = NO;
    fadeInAnimation.removedOnCompletion = NO;
    fadeInAnimation.beginTime = CMTimeGetSeconds(animatedOutStartTime) + startTime;
    fadeInAnimation.duration = 3.0;
    fadeInAnimation.autoreverses = NO;
    fadeInAnimation.fillMode = kCAFillModeBoth;
    
    CABasicAnimation *moveInAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    [moveInAnimation setFromValue:[NSValue valueWithCGPoint:startPointIn]];
    [moveInAnimation setToValue:[NSValue valueWithCGPoint:middlePoint]];
    [moveInAnimation setDuration:2.0];
    moveInAnimation.beginTime = CMTimeGetSeconds(animatedOutStartTime) + startTime;
    moveInAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CAKeyframeAnimation *scaleInAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaleInAnimation.duration = 3.0;
    scaleInAnimation.beginTime = CMTimeGetSeconds(animatedOutStartTime) + startTime;
    scaleInAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:.5f],
                               [NSNumber numberWithFloat:1.2f],
                               [NSNumber numberWithFloat:.85f],
                               [NSNumber numberWithFloat:1.f],
                               nil];
    
    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOutAnimation.fromValue = @1.0f;
    fadeOutAnimation.toValue = @0.0f;
    fadeOutAnimation.additive = NO;
    fadeOutAnimation.removedOnCompletion = NO;
    fadeOutAnimation.beginTime = CMTimeGetSeconds(animatedOutStartTime) + 2 + startTime ;
    fadeOutAnimation.duration = 3.0;
    fadeOutAnimation.autoreverses = NO;
    fadeOutAnimation.fillMode = kCAFillModeBoth;
    
    CABasicAnimation *moveOutAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    [moveOutAnimation setFromValue:[NSValue valueWithCGPoint:middlePoint]];
    [moveOutAnimation setToValue:[NSValue valueWithCGPoint:endPointIn]];
    [moveOutAnimation setDuration:2.0];
    moveOutAnimation.beginTime = CMTimeGetSeconds(animatedOutStartTime) + 2 + startTime;
    moveOutAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation* rotateOutAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateOutAnimation.toValue = @((2 * M_PI) * 2);
    rotateOutAnimation.duration = 2.0f;
    rotateOutAnimation.beginTime = CMTimeGetSeconds(animatedOutStartTime) + 2 + startTime;
    rotateOutAnimation.removedOnCompletion = NO;
    rotateOutAnimation.autoreverses = NO;
    rotateOutAnimation.fillMode = kCAFillModeForwards;
    rotateOutAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *scaleOutAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleOutAnimation.fromValue = @1.0f;
    scaleOutAnimation.toValue = @0.0f;
    scaleOutAnimation.duration = 3.0f;
    scaleOutAnimation.removedOnCompletion = NO;
    scaleOutAnimation.fillMode = kCAFillModeForwards;
    scaleOutAnimation.autoreverses = NO;
    scaleOutAnimation.beginTime = CMTimeGetSeconds(animatedOutStartTime) + 2 + startTime;
    scaleOutAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [textLayer addAnimation:fadeInAnimation forKey:@"fadeIn"];
    [textLayer addAnimation:moveInAnimation forKey:@"positionIn"];
    [textLayer addAnimation:scaleInAnimation forKey:@"scaleIn"];
    [textLayer addAnimation:moveOutAnimation forKey:@"positionOut"];
    [textLayer addAnimation:fadeOutAnimation forKey:@"fadeOut"];
    [textLayer addAnimation:rotateOutAnimation forKey:@"spinOut"];
    [textLayer addAnimation:scaleOutAnimation forKey:@"scaleOut"];
    
    return textLayer;
}

- (CALayer *)buildAnimationScrollScreen:(CGSize)viewBounds startTime:(NSTimeInterval)startTime {
    CALayer *animatedScrollLayer = [CALayer layer];
    
    CALayer *scrollUpLayer = [CALayer layer];
    scrollUpLayer.backgroundColor = [[UIColor blackColor] CGColor];
    scrollUpLayer.frame = CGRectMake(0, 0, viewBounds.width, viewBounds.height / 2);
    
    CGPoint startPointUp = CGPointMake(viewBounds.width / 2, viewBounds.height / 2);
    CGPoint endPointUp = CGPointMake(viewBounds.width / 2, viewBounds.height+viewBounds.height);
    
    CABasicAnimation *animationMoveUp = [CABasicAnimation animationWithKeyPath:@"position"];
    [animationMoveUp setFromValue:[NSValue valueWithCGPoint:startPointUp]];
    [animationMoveUp setToValue:[NSValue valueWithCGPoint:endPointUp]];
    [animationMoveUp setDuration:3.0];
    animationMoveUp.beginTime = startTime;
    
    [scrollUpLayer setPosition:endPointUp];
    [scrollUpLayer addAnimation:animationMoveUp forKey:@"positionUp"];
    
    [animatedScrollLayer addSublayer:scrollUpLayer];
    
    CALayer *scrollDownLayer = [CALayer layer];
    scrollDownLayer.backgroundColor = [[UIColor blackColor] CGColor];
    scrollDownLayer.frame = CGRectMake(0, 0, viewBounds.width, viewBounds.height/2);
    
    CGPoint startPointDown = CGPointMake(viewBounds.width/2, viewBounds.height/2);
    CGPoint endPointDown = CGPointMake(viewBounds.width/2, -viewBounds.height);
    
    CABasicAnimation *animationMoveDown = [CABasicAnimation animationWithKeyPath:@"position"];
    [animationMoveDown setFromValue:[NSValue valueWithCGPoint:startPointDown]];
    [animationMoveDown setToValue:[NSValue valueWithCGPoint:endPointDown]];
    [animationMoveDown setDuration:3.0];
    animationMoveDown.beginTime = startTime;
    
    [scrollDownLayer setPosition:endPointDown];
    [scrollDownLayer addAnimation:animationMoveDown forKey:@"positionDown"];
    
    [animatedScrollLayer addSublayer:scrollDownLayer];
    
    return animatedScrollLayer;
}

- (CALayer *)buildAnimationFlashScreen:(CGSize)viewBounds startTime:(NSTimeInterval)timeInterval startOpacity:(BOOL)startOpacity {
    CALayer *animatedFlashLayer = [CALayer layer];
    animatedFlashLayer.bounds = CGRectMake(0, 0, viewBounds.width, viewBounds.height);
    animatedFlashLayer.position = CGPointMake(viewBounds.width/2, viewBounds.height/2);
    if (arc4random() % (int)2) {
        animatedFlashLayer.backgroundColor = [[UIColor whiteColor] CGColor];
    } else {
        animatedFlashLayer.backgroundColor = [[UIColor blackColor] CGColor];
    }
    
    animatedFlashLayer.opacity = 0;
    
    id startValue = nil;
    id endValue = nil;
    if (startOpacity) {
        startValue = @1.0f;
        endValue = @0.0f;
    } else {
        startValue = @0.0f;
        endValue = @1.0f;
    }
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = startValue;
    alphaAnimation.toValue = endValue;
    alphaAnimation.duration = 0.1f;
    alphaAnimation.beginTime = timeInterval;
    
    [animatedFlashLayer addAnimation:alphaAnimation forKey:@"opacity"];
    
    return animatedFlashLayer;
}

- (CALayer *)buildAnimationRipple:(CGSize)viewBounds centerPoint:(CGPoint)centerPoint radius:(CGFloat)radius startTime:(NSTimeInterval)startTime {
    NSArray *colors = @[
                        [UIColor colorWithRed:0.000 green:0.478 blue:1.000 alpha:1],
                        [UIColor colorWithRed:240/255.f green:159/255.f blue:254/255.f alpha:1],
                        [UIColor colorWithRed:204/255.f green:270/255.f blue:12/255.f alpha:1],
                        [UIColor colorWithRed:240/255.f green:159/255.f blue:10/255.f alpha:1],
                        [UIColor colorWithRed:240/255.f green:159/255.f blue:254/255.f alpha:1],
                        [UIColor colorWithRed:255/255.f green:137/255.f blue:167/255.f alpha:1],
                        [UIColor colorWithRed:126/255.f green:242/255.f blue:195/255.f alpha:1],
                        [UIColor colorWithRed:119/255.f green:152/255.f blue:255/255.f alpha:1],
                        [UIColor colorWithRed:240/255.f green:159/255.f blue:254/255.f alpha:1],
                        [UIColor colorWithRed:255/255.f green:137/255.f blue:167/255.f alpha:1],
                        [UIColor colorWithRed:126/255.f green:242/255.f blue:195/255.f alpha:1],
                        [UIColor colorWithRed:119/255.f green:152/255.f blue:255/255.f alpha:1],
                        [UIColor colorWithRed:240/255.f green:159/255.f blue:254/255.f alpha:1],
                        [UIColor colorWithRed:255/255.f green:137/255.f blue:167/255.f alpha:1],
                        [UIColor colorWithRed:126/255.f green:242/255.f blue:195/255.f alpha:1],
                        [UIColor colorWithRed:119/255.f green:152/255.f blue:255/255.f alpha:1],
                        [UIColor colorWithWhite:0.8 alpha:0.8],
                        ];
    
    UIColor *stroke = colors[arc4random() % (int)[colors count]];
    NSTimeInterval animationDuration = 3;
    NSTimeInterval pulseInterval = 0;
    CGFloat diameter = radius * 2;
    
    CAShapeLayer *circleShape = [CAShapeLayer layer];
    circleShape.cornerRadius = radius;
    circleShape.bounds = CGRectMake(0, 0, diameter, diameter);
    circleShape.position = centerPoint;
    circleShape.backgroundColor = stroke.CGColor;
    circleShape.strokeColor = [UIColor colorWithWhite:0.8 alpha:0.8].CGColor;
    circleShape.lineWidth = 3;
    circleShape.opacity = 0;
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
    scaleAnimation.fromValue = @0.0;
    scaleAnimation.toValue = @1.0;
    scaleAnimation.duration = animationDuration;
    
    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.duration = animationDuration;
    opacityAnimation.values = @[@0.45, @0.45, @0];
    opacityAnimation.keyTimes = @[@0, @0.2, @1];
    opacityAnimation.removedOnCompletion = NO;
    
    CAMediaTimingFunction *defaultCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = animationDuration + pulseInterval;
    animationGroup.repeatCount = 1;
    animationGroup.removedOnCompletion = NO;
    animationGroup.timingFunction = defaultCurve;
    animationGroup.beginTime = startTime;
    NSArray *animations = @[scaleAnimation, opacityAnimation];
    animationGroup.animations = animations;
    [circleShape addAnimation:animationGroup forKey:nil];
    
    return circleShape;
}

- (CALayer *)buildGradientText:(CGSize)viewBounds positon:(CGPoint)postion text:(NSString *)text startTime:(NSTimeInterval)startTime {
    CGFloat height = viewBounds.height / 10;
    UIBezierPath *path = [self createPathForText:text fontHeight:height];
    CGRect rectPath = CGPathGetBoundingBox(path.CGPath);
    CAShapeLayer *textLayer = [CAShapeLayer layer];
    textLayer.path = path.CGPath;
    textLayer.lineWidth = 1;
    textLayer.strokeColor = [UIColor darkGrayColor].CGColor;
    textLayer.fillColor = [[UIColor clearColor] CGColor];
    textLayer.geometryFlipped = NO;
    textLayer.opacity = 0;
    
    NSTimeInterval duration = 5;
    NSTimeInterval timeInterval = startTime;
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @0.8;
    alphaAnimation.toValue = @1;
    alphaAnimation.duration = duration*1.2;
    alphaAnimation.beginTime = timeInterval;
    
    CABasicAnimation *stroke = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    stroke.duration = duration;
    stroke.fromValue = [NSNumber numberWithFloat:0.1];
    stroke.toValue = [NSNumber numberWithFloat:1];
    stroke.removedOnCompletion = NO;
    stroke.beginTime = timeInterval;
    
    [textLayer addAnimation:stroke forKey:@"stroke"];
    [textLayer addAnimation:alphaAnimation forKey:@"opacity"];
    
    CAGradientLayer *gradientLayer = [self performEffectAnimation:arc4random() % (int)8];
    [gradientLayer addSublayer:textLayer];
    [gradientLayer setMask:textLayer];
    gradientLayer.position = postion;
    gradientLayer.bounds = rectPath;
    
    CABasicAnimation *positionAnimationOut = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAnimationOut.fromValue = [NSValue valueWithCGPoint:gradientLayer.position];
    positionAnimationOut.toValue = [NSValue valueWithCGPoint:CGPointZero];
    
    CABasicAnimation *boundsAnimationOut = [CABasicAnimation animationWithKeyPath:@"bounds"];
    boundsAnimationOut.fromValue = [NSValue valueWithCGRect:gradientLayer.bounds];
    boundsAnimationOut.toValue = [NSValue valueWithCGRect:CGRectZero];
    
    CABasicAnimation *opacityAnimationOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimationOut.fromValue = [NSNumber numberWithFloat:1.0];
    opacityAnimationOut.toValue = [NSNumber numberWithFloat:0.0];
    
    CABasicAnimation *rotateAnimationOut = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimationOut.fromValue = [NSNumber numberWithFloat:0 * M_PI];
    rotateAnimationOut.toValue = [NSNumber numberWithFloat:2 * M_PI];
    
    CAAnimationGroup *groupOut = [CAAnimationGroup animation];
    groupOut.beginTime = stroke.beginTime + stroke.duration;
    groupOut.duration = 1;
    groupOut.animations = [NSArray arrayWithObjects:positionAnimationOut, boundsAnimationOut, rotateAnimationOut, opacityAnimationOut, nil];
    groupOut.fillMode = kCAFillModeForwards;
    groupOut.removedOnCompletion = NO;
    
    [gradientLayer addAnimation:groupOut forKey:@"moveOut"];
    
    return gradientLayer;
}

- (CALayer *)buildImage:(CGSize)viewBounds image:(NSString *)imageFile position:(CGPoint)position {
    if (!imageFile || [imageFile isEqualToString:@""]) {
        return nil;
    }
    
    CALayer *layerImage = [CALayer layer];
    UIImage *image = [UIImage imageNamed:imageFile];
    layerImage.contents = (id)image.CGImage;
    layerImage.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    layerImage.opacity = 0.9;
    layerImage.position = position;
    
    return layerImage;
}

- (CALayer *)buildAnimationImages:(CGSize)viewBounds imagesArray:(NSMutableArray *)imagesArray position:(CGPoint)position {
    if ([imagesArray count] < 1) {
        return nil;
    }
    
    NSMutableArray *keyTimesArray = [[NSMutableArray alloc] init];
    double currentTime = CMTimeGetSeconds(kCMTimeZero);
    
    for (int seed = 0; seed < [imagesArray count]; seed++) {
        NSNumber *tempTime = [NSNumber numberWithFloat:(currentTime + (float)seed/[imagesArray count])];
        [keyTimesArray addObject:tempTime];
    }
    
    UIImage *image = [UIImage imageWithCGImage:(CGImageRef)imagesArray[0]];
    
    AVSynchronizedLayer *animationLayer = [AVSynchronizedLayer layer];
    animationLayer.opacity = 0.8;
    animationLayer.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    animationLayer.position = position;
    
    CAKeyframeAnimation *frameAnimation = [[CAKeyframeAnimation alloc] init];
    frameAnimation.beginTime = 0.1;
    [frameAnimation setKeyPath:@"contents"];
    frameAnimation.calculationMode = kCAAnimationDiscrete;
    [animationLayer setContents:[imagesArray lastObject]];
    frameAnimation.autoreverses = NO;
    frameAnimation.duration = 2.0;
    frameAnimation.repeatCount = 5;
    [frameAnimation setValues:imagesArray];
    [frameAnimation setKeyTimes:keyTimesArray];
    [frameAnimation setRemovedOnCompletion:NO];
    [animationLayer addAnimation:frameAnimation forKey:@"contents"];
    
    keyTimesArray = nil;
    frameAnimation = nil;
    
    return animationLayer;
}

- (CALayer *)buildSpotlight:(CGSize)viewBounds startTime:(NSTimeInterval)startTime {
    return [self createMaskHoleLayer:viewBounds startTime:startTime];
}

- (CALayer *)buildVideoFrameImage:(CGSize)viewBounds videoFile:(NSURL *)inputVideoURL startTime:(CMTime)startTime {
    CALayer *layerImage = [CALayer layer];
    
    UIImage *imageSnap = [self getImageForVideoFrame:inputVideoURL atTime:startTime];
    if (imageSnap) {
        NSString *imageName = [NSString stringWithFormat:@"attention_1"];
        UIImage *imgOriginal = [UIImage imageNamed:imageName];
        UIImage *imageResult = [self imageJoint:imageSnap fromImage:imgOriginal];
        
        layerImage.contents = (id)imageResult.CGImage;
        layerImage.frame = CGRectMake(0, 0, viewBounds.width, viewBounds.height);
        layerImage.opacity = 0.0;
        layerImage.position = CGPointMake(viewBounds.width/2, viewBounds.height/2);
        
        double animatedStartTime = CMTimeGetSeconds(startTime) - 1;
        CABasicAnimation* rotationInAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationInAnimation.toValue = @((2 * M_PI) * -2);
        rotationInAnimation.duration = 1.0f;
        rotationInAnimation.beginTime = animatedStartTime;
        rotationInAnimation.removedOnCompletion = NO;
        rotationInAnimation.autoreverses = NO;
        rotationInAnimation.fillMode = kCAFillModeForwards;
        rotationInAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        CABasicAnimation *scaleInAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleInAnimation.fromValue = @0.0f;
        scaleInAnimation.toValue = @1.0f;
        scaleInAnimation.removedOnCompletion = NO;
        scaleInAnimation.fillMode = kCAFillModeForwards;
        scaleInAnimation.autoreverses = NO;
        scaleInAnimation.duration = rotationInAnimation.duration + 1.0f;
        scaleInAnimation.beginTime = animatedStartTime;
        scaleInAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        CABasicAnimation *opacityInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityInAnimation.fromValue = [NSNumber numberWithFloat:0.9];
        opacityInAnimation.toValue = [NSNumber numberWithFloat:1.0];
        opacityInAnimation.repeatCount = 1;
        opacityInAnimation.duration = scaleInAnimation.duration;
        opacityInAnimation.beginTime = animatedStartTime;
        
        CABasicAnimation *opacityOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityOutAnimation.fromValue = [NSNumber numberWithFloat:1.0];
        opacityOutAnimation.toValue = [NSNumber numberWithFloat:0.0];
        opacityOutAnimation.repeatCount = 1;
        opacityOutAnimation.duration = opacityInAnimation.duration;
        opacityOutAnimation.beginTime = animatedStartTime + scaleInAnimation.duration;
        
        CABasicAnimation *boundsOutAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
        boundsOutAnimation.fromValue = [NSValue valueWithCGRect:layerImage.frame];
        boundsOutAnimation.toValue = [NSValue valueWithCGRect:CGRectZero];
        boundsOutAnimation.repeatCount = 1;
        boundsOutAnimation.duration = opacityOutAnimation.duration;
        boundsOutAnimation.beginTime = opacityOutAnimation.beginTime;
        
        CABasicAnimation *rotationOutAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationOutAnimation.toValue = @((2 * M_PI) * -2);
        rotationOutAnimation.removedOnCompletion = NO;
        rotationOutAnimation.fillMode = kCAFillModeForwards;
        rotationOutAnimation.autoreverses = NO;
        rotationOutAnimation.duration = opacityOutAnimation.duration;
        rotationOutAnimation.beginTime = opacityOutAnimation.beginTime;
        rotationOutAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        
        [layerImage addAnimation:rotationInAnimation forKey:@"rotationIn"];
        [layerImage addAnimation:scaleInAnimation forKey:@"scaleIn"];
        [layerImage addAnimation:opacityInAnimation forKey:@"opacityIn"];
        
        [layerImage addAnimation:opacityOutAnimation forKey:@"opacityOut"];
        [layerImage addAnimation:boundsOutAnimation forKey:@"boundsOut"];
        [layerImage addAnimation:rotationOutAnimation forKey:@"rotationOut"];
    } else {
        return nil;
    }
    return layerImage;
}

- (CALayer *)buildAnimatedPhotoLinearScroll:(CGSize)viewBounds photos:(NSMutableArray *)photos startTime:(NSTimeInterval)startTime {
    CALayer *layer = [CALayer layer];
    layer.bounds = CGRectMake(0, 0, viewBounds.width, viewBounds.height);
    layer.position = CGPointMake(viewBounds.width/2, viewBounds.height/2);
    
    NSTimeInterval timeInterval = startTime;
    for (UIImage *image in photos) {
        [layer addSublayer:[self createPhotoLinearScrollLayer:viewBounds image:image startTime:timeInterval]];
        timeInterval += 1.0;
    }
    
    return layer;
}

- (CALayer *)buildAnimatedPhotoCentringShow:(CGSize)viewBounds photos:(NSMutableArray *)photos startTime:(NSTimeInterval)startTime {
    CALayer *layer = [CALayer layer];
    layer.bounds = CGRectMake(0, 0, viewBounds.width, viewBounds.height);
    layer.position = CGPointMake(viewBounds.width/2, viewBounds.height/2);
    
    NSTimeInterval timeInterval = startTime;
    
    for (UIImage *obj in photos) {
        UIImage *image = [self getCropImage:obj videoSize:viewBounds];
        if (!image) {
            image = obj;
        }
        [layer addSublayer:[self createPhotoCentring:viewBounds image:image startTime:timeInterval]];
    }
    return layer;
}

- (CALayer *)buildAnimatedPhotoDrop:(CGSize)viewBounds photos:(NSMutableArray *)photos startTime:(NSTimeInterval)startTime {
    CALayer *layer = [CALayer layer];
    layer.bounds = CGRectMake(0, 0, viewBounds.width, viewBounds.height);
    layer.position = CGPointMake(viewBounds.width / 2, viewBounds.height / 2);
    
    CGFloat width = ((UIImage *)photos[0]).size.width;
    int count = floorf(viewBounds.width / width);
    CGFloat gap = ((int)viewBounds.width % (int)width) / (count + 1);
    int i = 0;
    NSTimeInterval timeInterval = startTime;
    for (UIImage *obj in photos) {
        UIImage *image = obj;
        if (i == count) {
            i = 0;
        }
        CGFloat xAxis = i * width + (i + 1) * gap + image.size.width / 2;
        [layer addSublayer:[self createPhotoDropLayer:viewBounds image:image startTime:timeInterval xAxis:xAxis]];
        timeInterval += 1.0;
        ++i;
        image = nil;
    }
    return layer;
}

- (CALayer *)buildAnimatedPhotoParabola:(CGSize)viewBounds photos:(NSMutableArray *)photos startTime:(NSTimeInterval)startTime {
    CALayer *layer = [CALayer layer];
    layer.bounds = CGRectMake(0, 0, viewBounds.width, viewBounds.height);
    layer.position = CGPointMake(viewBounds.width/2, viewBounds.height/2);
    
    CGFloat width = ((UIImage *)photos[0]).size.width;
    int count = floorf(viewBounds.width / width);
    CGFloat gap = ((int)viewBounds.width % (int)width) / (count + 1);
    int i = 0;
    NSTimeInterval timeInterval = startTime;
    for (UIImage *obj in photos) {
        UIImage *image = obj;
        if (i == count) {
            i = 0;
        }
        CGFloat xAxis = i * width + (i + 1) * gap + image.size.width / 2;
        [layer addSublayer:[self createPhotoParabolaLayer:viewBounds image:image startTime:timeInterval xAxis:xAxis]];
        timeInterval += 1.0;
        ++i;
        image = nil;
    }
    return layer;
}

- (CALayer *)buildAnimatedPhotoFlare:(CGSize)viewBounds photos:(NSMutableArray *)photos startTime:(NSTimeInterval)startTime {
    CALayer *layer = [CALayer layer];
    layer.bounds = CGRectMake(0, 0, viewBounds.width, viewBounds.height);
    layer.position = CGPointMake(viewBounds.width / 2, viewBounds.height / 2);
    
    CGFloat width = ((UIImage *)photos[0]).size.width;
    int count = floorf(viewBounds.width/width);
    CGFloat gap = ((int)viewBounds.width%(int)width)/(count+1);
    int i = 0;
    NSTimeInterval timeInterval = startTime;
    for (UIImage *obj in photos) {
        UIImage *image = obj;
        if (i == count) {
            i = 0;
        }
        CGFloat xAxis = i * width + (i + 1) * gap + image.size.width / 2;
        [layer addSublayer:[self createPhotoFlareLayer:viewBounds image:image startTime:timeInterval xAxis:xAxis]];
        timeInterval += 2.0;
        ++i;
        image = nil;
    }
    
    return layer;
}

- (CALayer *)buildAnimationPhotoEmitter:(CGSize)viewBounds photos:(NSMutableArray *)photos startTime:(NSTimeInterval)startTime {
    CALayer *layer = [CALayer layer];
    layer.bounds = CGRectMake(0, 0, viewBounds.width, viewBounds.height);
    layer.position = CGPointMake(viewBounds.width/2, viewBounds.height/2);
    
    CGSize size = ((UIImage *)photos[0]).size;
    CGFloat width = size.width;
    int countColumn = floorf(viewBounds.width / width);
    CGFloat gapColumn = ((int)viewBounds.width % (int)width) / (countColumn + 1);
    CGFloat height = size.height;
    int countRow = floorf(viewBounds.height / height);
    CGFloat gapRow = ((int)viewBounds.height % (int)height) / (countRow + 1);
    
    int i = 0;
    int j = 0;
    NSTimeInterval timeInterval = startTime;
    for (UIImage *image in photos) {
        if (i == countColumn) {
            i = 0;
            ++j;
        }
        if (j == countRow) {
            j = 0;
        }
        CGFloat xAxis = i*width + (i+1)*gapColumn + image.size.width/2;
        CGFloat yAxis = j*height + (j+1)*gapRow + image.size.height/2;
        [layer addSublayer:[self createPhotoEmitterLayer:viewBounds image:image startTime:timeInterval xAxis:xAxis yAxis:yAxis]];
        
        timeInterval += 1.0;
        ++i;
    }
    return layer;
}

- (CALayer *)buildAnimatedPhotoExplode:(CGSize)viewBounds photos:(NSMutableArray *)photos startTime:(NSTimeInterval)startTime {
    CALayer *layer = [CALayer layer];
    layer.bounds = CGRectMake(0, 0, viewBounds.width, viewBounds.height);
    layer.position = CGPointMake(viewBounds.width / 2, viewBounds.height / 2);
    
    NSTimeInterval timeInterval = startTime;
    for (UIImage *image in photos) {
        [layer addSublayer:[self createPhotoExplodeLayer:viewBounds image:image startTime:timeInterval]];
        timeInterval += 3.0;
    }
    return layer;
}

- (CALayer *)buildAnimatedPhotoExplodeDrop:(CGSize)viewBounds photos:(NSMutableArray *)photos startTime:(NSTimeInterval)startTime {
    CALayer *layer = [CALayer layer];
    layer.bounds = CGRectMake(0, 0, viewBounds.width, viewBounds.height);
    layer.position = CGPointMake(viewBounds.width/2, viewBounds.height/2);
    
    CGFloat width = ((UIImage *)photos[0]).size.width;
    int count = floorf(viewBounds.width/width);
    CGFloat gap = ((int)viewBounds.width%(int)width)/(count+1);
    int i = 0;
    NSTimeInterval timeInterval = startTime;
    for (UIImage *image in photos) {
        if (i == count) {
            i = 0;
        }
        
        CGFloat xAxis = i*width + (i+1)*gap + image.size.width/2;
        [layer addSublayer:[self createPhotoExplodeDropLayer:viewBounds image:image startTime:timeInterval xAxis:xAxis]];
        
        timeInterval += 2.0;
        ++i;
    }
    return layer;
}

- (CALayer *)buildAnimatedPhotoCloud:(CGSize)viewBounds photos:(NSMutableArray *)photos startTime:(NSTimeInterval)startTime {
    CALayer *layer = [CALayer layer];
    layer.bounds = CGRectMake(0, 0, viewBounds.width, viewBounds.height);
    layer.position = CGPointMake(viewBounds.width/2, viewBounds.height/2);
    
    int interval = 0;
    BOOL left = YES;
    NSTimeInterval timeInterval = startTime;
    for (UIImage *image in photos) {
        if (interval == 2) {
            interval = 0;
        }
        [layer addSublayer:[self createPhotoCloudLayer:viewBounds image:image startTime:timeInterval left:left]];
        
        left = !left;
        ++interval;
        if (interval == 2) {
            timeInterval += 3;
        }
    }
    return layer;
}

- (CALayer *)buildAnimatedPhotoSpin360:(CGSize)viewBounds photos:(NSMutableArray *)photos startTime:(NSTimeInterval)startTime {
    CALayer *layer = [CALayer layer];
    layer.bounds = CGRectMake(0, 0, viewBounds.width, viewBounds.height);
    layer.position = CGPointMake(viewBounds.width/2, viewBounds.height/2);
    
    CGSize sizeImage = ((UIImage *)photos[0]).size;
    CGPoint position = CGPointZero;
    int gap = 10;
    NSTimeInterval timeInterval = startTime;
    for (int i = 0; i < 4; ++i) {
        switch (i) {
            case 0:
                position = CGPointMake(gap + sizeImage.width / 2, gap + sizeImage.height / 2);
                [layer addSublayer:[self createPhotoSpin360Layer:viewBounds photos:photos startTime:timeInterval position:position]];
                break;
            case 1:
                position = CGPointMake(gap + sizeImage.width / 2, viewBounds.height - gap - sizeImage.height / 2);
                [layer addSublayer:[self createPhotoSpin360Layer:viewBounds photos:photos startTime:timeInterval position:position]];
                break;
            case 2:
                position = CGPointMake(viewBounds.width - gap - sizeImage.width / 2, viewBounds.height - gap - sizeImage.height / 2);
                [layer addSublayer:[self createPhotoSpin360Layer:viewBounds photos:photos startTime:timeInterval position:position]];
                break;
            case 3:
                position = CGPointMake(viewBounds.width - gap - sizeImage.width / 2, gap + sizeImage.height / 2);
                [layer addSublayer:[self createPhotoSpin360Layer:viewBounds photos:photos startTime:timeInterval position:position]];
                break;
            default:
                break;
        }
        
        timeInterval += 0.5;
    }
    return layer;
}

- (CALayer *)buildAnimatedPhotoCarousel:(CGSize)viewBounds photos:(NSMutableArray *)photos startTime:(NSTimeInterval)startTime {
    CALayer *layer = [CALayer layer];
    layer.bounds = CGRectMake(0, 0, viewBounds.width, viewBounds.height);
    layer.position = CGPointMake(viewBounds.width/2, viewBounds.height/2);
    
    CGFloat width = ((UIImage *)photos[0]).size.width;
    int count = floorf(viewBounds.width / width);
    CGFloat gap = ((int)viewBounds.width % (int)width) / (count + 1);
    int i = 0;
    int curWhich = 0;
    NSTimeInterval timeInterval = startTime;
    for (UIImage *image in photos) {
        if (curWhich == 4) {
            curWhich = 0;
        }
        CGFloat xAxis = i*width + (i+1)*gap + image.size.width/2;
        [layer addSublayer:[self createPhotoCarouselLayer:viewBounds image:image startTime:timeInterval xAxis:xAxis curWhich:curWhich]];
        
        ++i;
        ++curWhich;
        timeInterval += 0.5;
    }
    return layer;
}

- (CAEmitterLayer *)buildEmitterSteam:(CGSize)viewBounds positon:(CGPoint)postion {
    CAEmitterLayer *emitterLayer = [CAEmitterLayer layer];
    emitterLayer.emitterPosition = postion;
    emitterLayer.emitterSize = CGSizeMake(viewBounds.width, 0);
    
    CAEmitterCell *cell = [CAEmitterCell emitterCell];
    cell.birthRate = 30;
    cell.lifetime = 3.0;
    cell.lifetimeRange = 2;
    cell.color = [[UIColor whiteColor] CGColor];
    cell.contents = (id)[[UIImage imageNamed:@"steam.png"] CGImage];
    [cell setName:@"steam"];
    
    emitterLayer.emitterCells = @[cell];
    
    cell.velocity = 30;
    cell.velocityRange = 10;
    cell.emissionRange = M_PI_4;
    cell.scaleSpeed = 0.2;
    cell.spin = 1;
    cell.spinRange = 3;
    
    emitterLayer.renderMode = kCAEmitterLayerAdditive;
    emitterLayer.emitterShape = kCAEmitterLayerLine;
    
    return emitterLayer;
}

- (CAEmitterLayer *)buildEmitterHeart:(CGSize)viewBounds startTime:(NSTimeInterval)startTime {
    CAEmitterLayer *heartsEmitter = [CAEmitterLayer layer];
    heartsEmitter.emitterPosition = CGPointMake(arc4random() % (int)viewBounds.width, arc4random() % (int)viewBounds.height);
    heartsEmitter.emitterSize = CGSizeMake(viewBounds.width * 2.0, 0.0);
    
    heartsEmitter.emitterMode = kCAEmitterLayerVolume;
    heartsEmitter.emitterShape = kCAEmitterLayerRectangle;
    heartsEmitter.renderMode = kCAEmitterLayerAdditive;
    heartsEmitter.beginTime = startTime;
    
    CAEmitterCell *heart = [CAEmitterCell emitterCell];
    heart.name = @"heart";
    
    heart.emissionLongitude = M_PI / 2.0;
    heart.emissionRange = 0.55 * M_PI;
    heart.birthRate = 10;
    heart.lifetime = 10.0;
    
    heart.velocity = -120;
    heart.velocityRange = 60;
    heart.yAcceleration = 20;
    
    heart.contents = (id) [[UIImage imageNamed:@"DazHeart"] CGImage];
    heart.color = [[UIColor colorWithRed:0.5 green:0.0 blue:0.5 alpha:0.5] CGColor];
    heart.redRange = 0.3;
    heart.blueRange = 0.3;
    heart.alphaSpeed = -0.5 / heart.lifetime;
    
    heart.scale = 0.15;
    heart.scaleSpeed = 0.5;
    heart.spinRange = 2.0 * M_PI;
    
    heartsEmitter.emitterCells = [NSArray arrayWithObject:heart];
    CABasicAnimation *heartsBurst = [CABasicAnimation animationWithKeyPath:@"emitterCells.heart.birthRate"];
    heartsBurst.fromValue = [NSNumber numberWithFloat:150.0];
    heartsBurst.toValue = [NSNumber numberWithFloat:  0.0];
    heartsBurst.duration = 5.0;
    heartsBurst.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    [heartsEmitter addAnimation:heartsBurst forKey:@"heartsBurst"];
    
    return heartsEmitter;
}

- (CAEmitterLayer *)buildEmitterFireworks:(CGSize)viewBounds startTime:(NSTimeInterval)startTime {
    UIImage *image = [UIImage imageNamed:@"spark"];
    CAEmitterLayer *fireworksEmitter = [CAEmitterLayer layer];
    fireworksEmitter.emitterPosition = CGPointMake((arc4random()%(int)viewBounds.width*2/3)+30, (arc4random()%(int)viewBounds.height*2/3)+30);
    fireworksEmitter.renderMode = kCAEmitterLayerAdditive;
    fireworksEmitter.beginTime = startTime;
    
    CAEmitterCell *rocket = [CAEmitterCell emitterCell];
    rocket.emissionLongitude = (3 * M_PI) / 2;
    rocket.emissionLatitude = 0;
    rocket.birthRate = 1;
    rocket.lifetime = 1.6f;
    rocket.velocity = 150.0f;
    rocket.velocityRange = 150.0f;
    rocket.yAcceleration = -250;
    rocket.emissionRange = 8.0f * M_PI / 4;
    rocket.color = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5].CGColor;
    rocket.redRange = 0.5;
    rocket.greenRange = 0.5;
    rocket.blueRange = 0.5;
    
    [rocket setName:@"rocket"];
    
    CAEmitterCell *flare = [CAEmitterCell emitterCell];
    flare.contents = (id)image.CGImage;
    flare.emissionLongitude = (4 * M_PI) / 2;
    flare.scale = 0.4;
    flare.velocity = 100;
    flare.birthRate = 45;
    flare.lifetime = 1.5f;
    flare.yAcceleration = -350;
    flare.emissionRange = M_PI / 7;
    flare.alphaSpeed = -0.7;
    flare.scaleSpeed = -0.1;
    flare.scaleRange = 0.1;
    flare.beginTime = 0.01;
    flare.duration = 0.7;
    
    CAEmitterCell *firework = [CAEmitterCell emitterCell];
    firework.contents = (id)image.CGImage;
    firework.birthRate = 9999;
    firework.scale = 0.6;
    firework.velocity = 150.0f;
    firework.velocityRange = 0.0f;
    firework.lifetime = 2;
    firework.alphaSpeed = -0.2;
    firework.yAcceleration = -80;
    firework.beginTime = 1.5;
    firework.duration = 0.1;
    firework.emissionRange = 2 * M_PI;
    firework.scaleSpeed = -0.1;
    firework.spin = 2;
    
    [firework setName:@"firework"];
    
    CAEmitterCell *preSpark = [CAEmitterCell emitterCell];
    preSpark.birthRate = 80;
    preSpark.velocity = firework.velocity * 0.70;
    preSpark.lifetime = 1.7;
    preSpark.yAcceleration = firework.yAcceleration * 0.85;
    preSpark.beginTime = firework.beginTime - 0.2;
    preSpark.emissionRange = firework.emissionRange;
    preSpark.greenSpeed = 100;
    preSpark.blueSpeed = 100;
    preSpark.redSpeed = 100;
    
    [preSpark setName:@"preSpark"];
    
    CAEmitterCell *spark = [CAEmitterCell emitterCell];
    spark.contents = (id)image.CGImage;
    spark.lifetime = 0.05;
    spark.yAcceleration = -250;
    spark.beginTime = 0.8;
    spark.scale = 0.4;
    spark.birthRate = 10;
    
    preSpark.emitterCells = [NSArray arrayWithObjects:spark, nil];
    rocket.emitterCells = [NSArray arrayWithObjects:flare, firework, preSpark, nil];
    fireworksEmitter.emitterCells = [NSArray arrayWithObjects:rocket, nil];
    
    fireworksEmitter.birthRate = 5;
    
    return fireworksEmitter;
}

- (CAEmitterLayer *)buildEmitterStar:(CGSize)viewBounds startTime:(NSTimeInterval)startTime {
    CAEmitterLayer *starLayer = [self makeEmitterAtPoint:viewBounds];
    starLayer.beginTime = startTime;
    CAEmitterCell *starCell = [self makeEmitterCellWithParticle:@"star"];
    [starLayer setEmitterCells:@[starCell]];
    [starLayer setValue:@5 forKeyPath:@"emitterCells.star.birthRate"];
    
    return starLayer;
}

- (CAEmitterLayer *)buildEmitterMoveDot:(CGSize)viewBounds position:(CGPoint)position startTime:(NSTimeInterval)startTime {
    CAEmitterLayer* dotsEmitter = [CAEmitterLayer layer];
    dotsEmitter.emitterPosition = position;
    dotsEmitter.emitterSize = CGSizeMake(viewBounds.width, viewBounds.height);
    dotsEmitter.renderMode = kCAEmitterLayerPoints;
    dotsEmitter.emitterShape = kCAEmitterLayerRectangle;
    dotsEmitter.emitterMode = kCAEmitterLayerUnordered;
    dotsEmitter.beginTime = startTime;
    
    CAEmitterCell* dots = [CAEmitterCell emitterCell];
    dots.birthRate = 5;
    dots.lifetime = 5;
    dots.lifetimeRange = 0.5;
    
    dots.color = [[UIColor colorWithRed:0.8 green:0.6 blue:0.70 alpha:0.6] CGColor];
    dots.redRange = 0.9;
    dots.greenRange = 0.8;
    dots.blueRange = 0.7;
    dots.alphaRange = 0.8;
    
    dots.redSpeed = 0.92;
    dots.greenSpeed = 0.84;
    dots.blueSpeed = 0.74;
    dots.alphaSpeed = 0.55;
    
    dots.contents = (id)[[UIImage imageNamed:@"spark"] CGImage];
    
    dots.velocityRange = 500;
    dots.emissionRange = 360;
    dots.scale = 0.5;
    dots.scaleRange = 0.2;
    dots.alphaRange = 0.3;
    dots.alphaSpeed  = 0.5;
    
    [dots setName:@"dots"];
    
    dotsEmitter.emitterCells = [NSArray arrayWithObject:dots];
    
    return dotsEmitter;
}

- (CAEmitterLayer *)buildEmitterSky:(CGSize)viewBounds startTime:(NSTimeInterval)startTime {
    CAEmitterLayer *emitterLayer = [CAEmitterLayer layer];
    emitterLayer.emitterPosition = CGPointMake(viewBounds.width / 2, viewBounds.height / 2);
    emitterLayer.emitterSize = viewBounds;
    emitterLayer.renderMode = kCAEmitterLayerOldestLast;
    emitterLayer.emitterMode = kCAEmitterLayerSurface;
    emitterLayer.emitterShape = kCAEmitterLayerSphere;
    emitterLayer.seed = (arc4random() % 100) + 1;
    emitterLayer.beginTime = startTime;
    
    CAEmitterCell *cycleCell = [CAEmitterCell emitterCell];
    cycleCell.birthRate = 0.1;
    cycleCell.lifetime = 1;
    cycleCell.contents = (id)[[UIImage imageNamed:@"point"] CGImage];
    cycleCell.color = [[UIColor whiteColor] CGColor];
    cycleCell.velocity = 10;
    cycleCell.velocityRange = 2;
    cycleCell.alphaRange = 0.5;
    cycleCell.alphaSpeed = 2;
    cycleCell.scale = 0.1;
    cycleCell.scaleRange = 0.1;
    [cycleCell setName:@"starPoint"];
    
    CAEmitterCell *starCell = [CAEmitterCell emitterCell];
    starCell.birthRate = 3;
    starCell.lifetime = 2.02;
    
    CAEmitterCell *starCell0 = [CAEmitterCell emitterCell];
    starCell0.birthRate = 3;
    starCell0.lifetime = 1.02;
    starCell0.velocity = 0;
    starCell0.emissionRange = 2 * M_PI;
    starCell0.contents = (id)[[UIImage imageNamed:@"bgStar"] CGImage];
    starCell0.color = [[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5] CGColor];
    starCell0.alphaSpeed = 0.6;
    starCell0.scale = 0.4;
    [starCell0 setName:@"star"];
    
    CAEmitterCell *starCell1 = [CAEmitterCell emitterCell];
    starCell1.birthRate = 3;
    starCell1.lifetime = 1.02;
    starCell1.velocity = 0;
    starCell1.emissionRange = 2 * M_PI;
    
    CAEmitterCell *starCell2 = [CAEmitterCell emitterCell];
    starCell2.birthRate = 3;
    starCell2.lifetime = 1;
    starCell2.velocity = 0;
    starCell2.emissionRange = 2 * M_PI;
    starCell2.contents = (id)[[UIImage imageNamed:@"bgStar1"] CGImage];
    starCell2.color = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5].CGColor;
    starCell2.alphaSpeed = -0.5;
    starCell2.scale = starCell0.scale;
    
    emitterLayer.emitterCells = @[starCell];
    starCell.emitterCells = @[starCell0, starCell1];
    starCell1.emitterCells = @[starCell2];
    
    return emitterLayer;
}

- (CAEmitterLayer *)buildEmitterMeteor:(CGSize)viewBounds startTime:(NSTimeInterval)timeInterval pathN:(NSInteger)pathN {
    CAEmitterLayer *emitterLayer = [CAEmitterLayer layer];
    emitterLayer.emitterPosition = CGPointMake(160, 160);
    emitterLayer.emitterSize = viewBounds;
    emitterLayer.renderMode = kCAEmitterLayerAdditive;
    emitterLayer.emitterMode = kCAEmitterLayerPoints;
    emitterLayer.emitterShape = kCAEmitterLayerSphere;
    emitterLayer.opacity = 0;
    
    CAEmitterCell *cell1 = [self productEmitterCellWithContents:(id)[[UIImage imageNamed:@"star1"] CGImage]];
    cell1.scale = 0.3;
    cell1.scaleRange = 0.1;
    
    CAEmitterCell *cell2 = [self productEmitterCellWithContents:(id)[[UIImage imageNamed:@"cycle1"] CGImage]];
    cell2.scale = 0.05;
    cell2.scaleRange = 0.02;
    
    emitterLayer.emitterCells = @[cell1, cell2];
    
    NSTimeInterval duration = 5;
    CGMutablePathRef path = CGPathCreateMutable();
    CAKeyframeAnimation *animationPath = [CAKeyframeAnimation animationWithKeyPath:@"emitterPosition"];
    CGFloat centerWidth = viewBounds.width/2;
    CGFloat centerHeight = viewBounds.height/2;
    if (pathN < 1) {
        CGPathMoveToPoint(path, NULL, 0, 0);
        CGPathAddCurveToPoint(path, NULL, 50.0, 100.0, 50.0, 120.0, 50.0, 275.0);
        CGPathAddCurveToPoint(path, NULL, 50.0, 275.0, 150.0, 275.0, centerWidth, centerHeight);
        CGPathAddCurveToPoint(path, NULL, centerWidth, centerHeight, centerWidth, centerHeight, centerWidth, centerHeight);
    } else {
        CGPathMoveToPoint(path, NULL, viewBounds.width - 0, viewBounds.height - 0);
        CGPathAddCurveToPoint(path, NULL, viewBounds.width - 50.0, viewBounds.height - 100.0, viewBounds.width - 50.0, viewBounds.height - 120.0, viewBounds.width - 50.0, viewBounds.height - 275.0);
        CGPathAddCurveToPoint(path, NULL, viewBounds.width - 50.0, viewBounds.height - 275.0, viewBounds.width - 150.0, viewBounds.height - 275.0, centerWidth, centerHeight);
        CGPathAddCurveToPoint(path, NULL, centerWidth, centerHeight, centerWidth, centerHeight, centerWidth, centerHeight);
    }
    
    animationPath.path = path;
    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.duration = duration;
    opacityAnimation.values = @[@0.0, @0.5, @1];
    opacityAnimation.keyTimes = @[@0, @0.2, @1];
    opacityAnimation.removedOnCompletion = NO;
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = duration;
    animationGroup.repeatCount = 1;
    animationGroup.removedOnCompletion = NO;
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animationGroup.beginTime = timeInterval;
    NSArray *animations = @[animationPath, opacityAnimation];
    animationGroup.animations = animations;
    [emitterLayer addAnimation:animationGroup forKey:nil];
    
    dispatch_async_main_after((duration + 1), ^{
        emitterLayer.birthRate = 1;
        CGPathRelease(path);
    });
    
    return emitterLayer;
}

- (CAEmitterLayer *)buildEmitterRain:(CGSize)viewBounds {
    CAEmitterLayer *parentLayer = [CAEmitterLayer layer];
    parentLayer.emitterPosition = CGPointMake(viewBounds.width/2.0, viewBounds.height+10);
    parentLayer.emitterSize = CGSizeMake(viewBounds.width * 2.0, 0);
    
    parentLayer.emitterMode = kCAEmitterLayerOutline;
    parentLayer.emitterShape = kCAEmitterLayerLine;
    
    parentLayer.shadowOpacity = 1.0;
    parentLayer.shadowRadius = 0.0;
    parentLayer.shadowOffset = CGSizeMake(0.0, 1.0);
    parentLayer.shadowColor = [[UIColor whiteColor] CGColor];
    parentLayer.seed = (arc4random() % 100) + 1;
    
    UIImage *image = [UIImage imageNamed:@"rain"];
    CAEmitterCell * rainLayer = [self createRainLayer:image];
    
    parentLayer.emitterCells = @[rainLayer];
    
    return parentLayer;
}

- (CAEmitterLayer *)buildEmitterFlower:(CGSize)viewBounds startTime:(NSTimeInterval)startTime {
    CAEmitterLayer *parentLayer = [CAEmitterLayer layer];
    parentLayer.emitterPosition = CGPointMake(viewBounds.width/2.0, viewBounds.height-10);
    parentLayer.emitterSize = CGSizeMake(viewBounds.width * 2.0, 0);
    parentLayer.beginTime = startTime;
    
    parentLayer.emitterMode = kCAEmitterLayerOutline;
    parentLayer.emitterShape = kCAEmitterLayerLine;
    
    parentLayer.shadowOpacity = 1.0;
    parentLayer.shadowRadius = 0.0;
    parentLayer.shadowOffset = CGSizeMake(0.0, 1.0);
    parentLayer.shadowColor = [[UIColor whiteColor] CGColor];
    parentLayer.seed = (arc4random()%100)+1;
    
    CAEmitterCell* containerLayer = [CAEmitterCell emitterCell];
    containerLayer.birthRate = 1.0;
    containerLayer.velocity = -1;
    containerLayer.lifetime = 0.5;
    containerLayer.name = @"containerLayer";
    
    NSMutableArray *flowerArray = [NSMutableArray array];
    for (int i = 1; i <= 8; i++) {
        NSString *imageName = [NSString stringWithFormat:@"flower%i",i];
        UIImage *image = [UIImage imageNamed:imageName];
        if (image) {
            [flowerArray addObject:[self createFlowerLayer:image]];
        }
    }
    
    containerLayer.emitterCells = @[flowerArray[0], flowerArray[1], flowerArray[3], flowerArray[4], flowerArray[5], flowerArray[6], flowerArray[7]];
    parentLayer.emitterCells = @[containerLayer];
    
    return parentLayer;
}

- (CAEmitterLayer *)buildEmitterBirthday:(CGSize)viewBounds {
    CAEmitterLayer *parentLayer = [CAEmitterLayer layer];
    parentLayer.emitterPosition = CGPointMake(viewBounds.width/2.0, viewBounds.height);
    parentLayer.emitterSize = CGSizeMake(viewBounds.width * 2.0, 0);
    
    parentLayer.emitterMode = kCAEmitterLayerOutline;
    parentLayer.emitterShape = kCAEmitterLayerLine;
    
    parentLayer.shadowOpacity = 1.0;
    parentLayer.shadowRadius = 0.0;
    parentLayer.shadowOffset = CGSizeMake(0.0, 1.0);
    parentLayer.shadowColor = [[UIColor whiteColor] CGColor];
    parentLayer.seed = (arc4random() % 100) + 1;
    
    CAEmitterCell* containerLayer = [CAEmitterCell emitterCell];
    containerLayer.birthRate = 2;
    containerLayer.velocity    = -1;
    containerLayer.lifetime    = 0.5;
    containerLayer.name = @"containerLayer";
    
    UIImage *image = [UIImage imageNamed:@"birthday"];
    CAEmitterCell * birthdayLayer = [self createBirthdayLayer:image];
    
    containerLayer.emitterCells = @[birthdayLayer];
    parentLayer.emitterCells = @[containerLayer];
    
    return parentLayer;
}

- (CAEmitterLayer *)buildEmitterFire:(CGSize)viewBounds position:(CGPoint)position {
    CAEmitterLayer *fireEmitter = [CAEmitterLayer layer];
    fireEmitter.emitterPosition = position;
    fireEmitter.emitterSize = CGSizeMake(viewBounds.width/2.0, 0);
    fireEmitter.emitterMode = kCAEmitterLayerOutline;
    fireEmitter.emitterShape = kCAEmitterLayerLine;
    fireEmitter.renderMode = kCAEmitterLayerAdditive;
    
    CAEmitterCell* fire = [CAEmitterCell emitterCell];
    [fire setName:@"fire"];
    
    fire.birthRate = 100;
    fire.emissionLongitude  = M_PI;
    fire.velocity = -80;
    fire.velocityRange = 30;
    fire.emissionRange = 1;
    fire.yAcceleration = 200;
    fire.scaleSpeed = 0.2;
    fire.lifetime = 50;
    fire.lifetimeRange = (50.0 * 0.35);
    
    fire.color = [[UIColor colorWithRed:0.8 green:0.4 blue:0.2 alpha:0.1] CGColor];
    fire.contents = (id) [[UIImage imageNamed:@"DazFire"] CGImage];
    
    fireEmitter.emitterCells = [NSArray arrayWithObject:fire];
    
    int value = 1.5;
    [fireEmitter setValue:[NSNumber numberWithInt:(value * 40)]
               forKeyPath:@"emitterCells.fire.birthRate"];
    [fireEmitter setValue:[NSNumber numberWithFloat:value]
               forKeyPath:@"emitterCells.fire.lifetime"];
    [fireEmitter setValue:[NSNumber numberWithFloat:(value * 0.35)]
               forKeyPath:@"emitterCells.fire.lifetimeRange"];
    fireEmitter.emitterSize = CGSizeMake(3 * value, 0);
    
    return fireEmitter;
}

- (CAEmitterLayer *)buildEmitterSmoke:(CGSize)viewBounds position:(CGPoint)position {
    CAEmitterLayer *smokeEmitter = [CAEmitterLayer layer];
    smokeEmitter.emitterPosition = position;
    smokeEmitter.emitterMode = kCAEmitterLayerPoints;
    
    CAEmitterCell* smoke = [CAEmitterCell emitterCell];
    [smoke setName:@"smoke"];
    smoke.birthRate = 10;
    smoke.emissionLongitude = -M_PI / 2;
    smoke.lifetime = 5;
    smoke.velocity = -40;
    smoke.velocityRange = 10;
    smoke.emissionRange = M_PI / 4;
    smoke.spin = 1;
    smoke.spinRange = 6;
    smoke.yAcceleration = 60;
    smoke.contents = (id)[[UIImage imageNamed:@"DazSmoke"] CGImage];
    smoke.scale = 0.1;
    smoke.alphaSpeed = -0.12;
    smoke.scaleSpeed = 0.7;
    
    smokeEmitter.emitterCells    = [NSArray arrayWithObject:smoke];
    
    return smokeEmitter;
}

- (CAEmitterLayer *)buildEmitterSpark:(CGSize)viewBounds {
    CAEmitterCell *cell = [CAEmitterCell emitterCell];
    float defaultBirthRate = 10.0f;
    [cell setBirthRate:defaultBirthRate];
    [cell setVelocity:120];
    [cell setVelocityRange:40];
    [cell setYAcceleration:-45.0f];
    [cell setEmissionLongitude:-M_PI_2];
    [cell setEmissionRange:M_PI_4];
    [cell setScale:1.0f];
    [cell setScaleSpeed:2.0f];
    [cell setScaleRange:2.0f];
    cell.contents = (id) [[UIImage imageNamed:@"smoke15"] CGImage];
    [cell setColor:[UIColor colorWithRed:1.0 green:0.2 blue:0.1 alpha:0.5].CGColor];
    [cell setLifetime:1.0f];
    [cell setLifetimeRange:1.0f];
    
    CAEmitterLayer *emitter = [CAEmitterLayer layer];
    [emitter setEmitterCells:@[cell]];
    CGRect bounds = CGRectMake(0, 0, viewBounds.width/2, viewBounds.height);
    [emitter setFrame:bounds];
    CGPoint emitterPosition = CGPointMake(arc4random()%(int)viewBounds.width, arc4random()%(int)viewBounds.height);
    [emitter setEmitterPosition:emitterPosition];
    [emitter setEmitterSize:(CGSize){10.0f, 10.0f}];
    [emitter setEmitterShape:kCAEmitterLayerRectangle];
    [emitter setRenderMode:kCAEmitterLayerAdditive];
    emitter.geometryFlipped = YES;
    
    NSString *animationKey = @"position";
    CGFloat duration = 1.0f;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"emitterPosition"];
    CAEmitterLayer *presentation = (CAEmitterLayer*)[emitter presentationLayer];
    CGPoint currentPosition = [presentation emitterPosition];
    [animation setFromValue:[NSValue valueWithCGPoint:currentPosition]];
    [animation setToValue:[NSValue valueWithCGPoint:CGPointMake(arc4random()%(int)viewBounds.width/2, arc4random()%(int)viewBounds.height/2)]];
    [animation setDuration:duration];
    [animation setFillMode:kCAFillModeForwards];
    [animation setRemovedOnCompletion:NO];
    [emitter addAnimation:animation forKey:animationKey];
    
    return emitter;
}

- (CAShapeLayer *)buildEmitterSparkle:(CGSize)viewBounds text:(NSString *)text startTime:(NSTimeInterval)startTime {
    if (text.length < 1) {
        return nil;
    }
    
    CGFloat height = viewBounds.height / 10;
    CGPoint position = CGPointMake(viewBounds.width / 2, height + 20);
    UIBezierPath *path = [self createPathForText:text fontHeight:height];
    
    CAShapeLayer *textShapeLayer = [CAShapeLayer layer];
    textShapeLayer.path = path.CGPath;
    textShapeLayer.bounds = CGPathGetBoundingBox(path.CGPath);
    textShapeLayer.lineWidth = 1;
    textShapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    textShapeLayer.fillColor = [[UIColor clearColor] CGColor];
    textShapeLayer.geometryFlipped = NO;
    textShapeLayer.position = position;
    textShapeLayer.opacity = 0;
    
    CAEmitterLayer *emitterLayer = [CAEmitterLayer layer];
    emitterLayer.emitterCells = [NSArray arrayWithObjects:[self sparkCell], [self smokeCell], nil];
    emitterLayer.emitterShape = kCAEmitterLayerPoint;
    emitterLayer.birthRate = 0;
    emitterLayer.geometryFlipped = YES;
    
    [textShapeLayer addSublayer:emitterLayer];
    [self doAnimation:textShapeLayer emitterLayer:emitterLayer startTime:startTime];
    
    return textShapeLayer;
}

- (CAEmitterLayer *)buildEmitterBlackWhiteDot:(CGSize)viewBounds positon:(CGPoint)postion startTime:(NSTimeInterval)startTime {
    CAEmitterLayer* dotsEmitter = [CAEmitterLayer layer];
    dotsEmitter.emitterPosition = postion;
    dotsEmitter.emitterSize = CGSizeMake(viewBounds.width, viewBounds.height/12);
    dotsEmitter.renderMode = kCAEmitterLayerBackToFront;
    dotsEmitter.emitterShape = kCAEmitterLayerCircle;
    dotsEmitter.emitterMode = kCAEmitterLayerSurface;
    dotsEmitter.beginTime = startTime;
    
    CAEmitterCell* blackDots = [self createBlackWhiteDots:YES];
    CAEmitterCell* whiteDots = [self createBlackWhiteDots:NO];
    
    dotsEmitter.emitterCells = [NSArray arrayWithObjects:blackDots, whiteDots, nil];
    
    return dotsEmitter;
}

- (void)addCommentaryTrackToComposition:(AVMutableComposition *)composition withAudioMix:(AVMutableAudioMix *)audioMix {
    NSInteger i;
    NSArray *tracksToDuck = [composition tracksWithMediaType:AVMediaTypeAudio];
    
    CMTimeRange commentaryTimeRange = CMTimeRangeMake(self.commentaryStartTime, self.commentary.duration);
    if (CMTIME_COMPARE_INLINE(CMTimeRangeGetEnd(commentaryTimeRange), >, [composition duration])) {
        commentaryTimeRange.duration = CMTimeSubtract([composition duration], commentaryTimeRange.start);
    }
    AVMutableCompositionTrack *compositionCommentaryTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack * commentaryTrack = [[self.commentary tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    [compositionCommentaryTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, commentaryTimeRange.duration) ofTrack:commentaryTrack atTime:commentaryTimeRange.start error:nil];
    
    CMTime fadeTime = CMTimeMake(1, 1);
    CMTimeRange startRange = CMTimeRangeMake(kCMTimeZero, fadeTime);
    NSMutableArray *trackMixArray = [NSMutableArray array];
    AVMutableAudioMixInputParameters *trackMixComentray = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:commentaryTrack];
    [trackMixComentray setVolumeRampFromStartVolume:0.0f toEndVolume:0.2f timeRange:startRange];
    [trackMixArray addObject:trackMixComentray];
    
    for (i = 0; i < [tracksToDuck count]; ++i) {
        CMTimeRange timeRange = [[tracksToDuck objectAtIndex:i] timeRange];
        if (CMTIME_COMPARE_INLINE(CMTimeRangeGetEnd(timeRange), ==, kCMTimeInvalid)) {
            break;
        }
        
        CMTime halfSecond = CMTimeMake(1, 2);
        CMTime startTime = CMTimeSubtract(timeRange.start, halfSecond);
        CMTime endRangeStartTime = CMTimeAdd(timeRange.start, timeRange.duration);
        CMTimeRange endRange = CMTimeRangeMake(endRangeStartTime, halfSecond);
        if (startTime.value < 0) {
            startTime.value = 0;
        }
        
        [trackMixComentray setVolumeRampFromStartVolume:0.5f toEndVolume:0.2f timeRange:CMTimeRangeMake(startTime, halfSecond)];
        [trackMixComentray setVolumeRampFromStartVolume:0.2f toEndVolume:0.5f timeRange:endRange];
        [trackMixArray addObject:trackMixComentray];
    }
    audioMix.inputParameters = trackMixArray;
}

@end
