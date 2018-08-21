//
//  XKVideoBuilder+XK.h
//  XKMusicAlbum
//
//  Created by 浪漫恋星空 on 2018/8/17.
//  Copyright © 2018年 浪漫恋星空. All rights reserved.
//

#import "XKVideoBuilder.h"

static inline void dispatch_async_main_after(NSTimeInterval after, dispatch_block_t block) {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(after * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

@interface XKVideoBuilder (XK)

- (UIImage *)maskImageForImage:(CGFloat)width height:(CGFloat)maskHeight;
- (UIImage *)highlightedImageForImage:(UIImage *)image;
- (UIBezierPath *) createPathForText:(NSString *)string fontHeight:(CGFloat)height;
- (CAGradientLayer *)performEffectAnimation:(XKEffectDirection)effectDirection;
- (CAShapeLayer *)createMaskHoleLayer:(CGSize)viewBounds startTime:(NSTimeInterval)startTime;
- (UIImage *)getImageForVideoFrame:(NSURL *)videoFileURL atTime:(CMTime)time;
- (UIImage *)imageJoint:(UIImage *)imageTarget fromImage:(UIImage *)imageOriginal;
- (CALayer *)createPhotoLinearScrollLayer:(CGSize)viewBounds image:(UIImage *)image startTime:(NSTimeInterval)timeInterval;
- (UIImage *)getCropImage:(UIImage *)originalImage cropRect:(CGRect)cropRect;
- (UIImage *)getCropImage:(UIImage *)originalImage videoSize:(CGSize)videoSize;
- (CALayer *)createPhotoCentring:(CGSize)viewBounds image:(UIImage *)image startTime:(NSTimeInterval)timeInterval;
- (CALayer *)createPhotoDropLayer:(CGSize)viewBounds image:(UIImage *)image startTime:(NSTimeInterval)timeInterval xAxis:(CGFloat)xAxis;
- (CALayer *)createPhotoParabolaLayer:(CGSize)viewBounds image:(UIImage *)image startTime:(NSTimeInterval)timeInterval xAxis:(CGFloat)xAxis;
- (CALayer *)createPhotoFlareLayer:(CGSize)viewBounds image:(UIImage *)image startTime:(NSTimeInterval)timeInterval xAxis:(CGFloat)xAxis;
- (CALayer *)createPhotoEmitterLayer:(CGSize)viewBounds image:(UIImage *)image startTime:(NSTimeInterval)timeInterval xAxis:(CGFloat)xAxis yAxis:(CGFloat)yAxis;
- (CALayer *)createPhotoExplodeLayer:(CGSize)viewBounds image:(UIImage *)image startTime:(NSTimeInterval)timeInterval;
- (CALayer *)createPhotoExplodeDropLayer:(CGSize)viewBounds image:(UIImage *)image startTime:(NSTimeInterval)timeInterval xAxis:(CGFloat)xAxis;
- (CALayer *)createPhotoCloudLayer:(CGSize)viewBounds image:(UIImage *)image startTime:(NSTimeInterval)timeInterval left:(BOOL)left;
- (CALayer *)createPhotoSpin360Layer:(CGSize)viewBounds photos:(NSMutableArray *)photos  startTime:(NSTimeInterval)timeInterval position:(CGPoint)position;
- (CALayer *)createPhotoCarouselLayer:(CGSize)viewBounds image:(UIImage *)image startTime:(NSTimeInterval)timeInterval xAxis:(CGFloat)xAxis curWhich:(int)curWhich;
- (CAEmitterLayer *)makeEmitterAtPoint:(CGSize)viewBounds;
- (CAEmitterCell *) makeEmitterCellWithParticle:(NSString *)name;
- (CAEmitterCell *)productEmitterCellWithContents:(id)contents;
- (CAEmitterCell *)createRainLayer:(UIImage *)image;
- (CAEmitterCell *)createBirthdayLayer:(UIImage *)image;
- (CAEmitterCell *)sparkCell;
- (CAEmitterCell *)smokeCell;
- (void)doAnimation:(CAShapeLayer *)textShapeLayer emitterLayer:(CAEmitterLayer *)emitterLayer startTime:(NSTimeInterval)timeInterval;
- (CAEmitterCell *) createBlackWhiteDots:(BOOL)isBlack;

@end
