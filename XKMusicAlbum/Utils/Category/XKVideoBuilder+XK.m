//
//  XKVideoBuilder+XK.m
//  XKMusicAlbum
//
//  Created by 浪漫恋星空 on 2018/8/17.
//  Copyright © 2018年 浪漫恋星空. All rights reserved.
//

#import "XKVideoBuilder+XK.h"
#import <CoreText/CoreText.h>
#import "XKCurledViewHelper.h"
#import "UIImage+XK.h"
#import "XKAnimationHelper.h"

@interface LPParticleLayer : CALayer

@property (nonatomic, assign) UIBezierPath *particlePath;

@end

@implementation XKVideoBuilder (XK)

- (UIImage *)maskImageForImage:(CGFloat)width height:(CGFloat)maskHeight {
    CGFloat maskWidth = floorf(width);
    
    UIGraphicsBeginImageContext(CGSizeMake(maskWidth, maskHeight));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    id clearColor = (__bridge id) [UIColor clearColor].CGColor;
    id blackColor = (__bridge id) [UIColor blackColor].CGColor;
    CGFloat locations[] = { 0.0f, 0.5f, 1.0f };
    NSArray *colors = @[clearColor, blackColor, clearColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace,
                                                        (__bridge CFArrayRef)colors,
                                                        locations);
    CGFloat midX = floorf(maskWidth / 2);
    CGPoint startPoint = CGPointMake(midX, 0);
    CGPoint endPoint = CGPointMake(midX, (floorf(maskHeight / 2)));
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CFRelease(gradient);
    CFRelease(colorSpace);
    
    UIImage *maskImage =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return maskImage;
}

- (UIImage *)highlightedImageForImage:(UIImage *)image {
    CIImage *coreImage = [CIImage imageWithCGImage:image.CGImage];
    CIImage *output = [CIFilter filterWithName:@"CIColorControls"
                                 keysAndValues:kCIInputImageKey, coreImage,
                       @"inputBrightness", @1.0f,
                       nil].outputImage;
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:output fromRect:output.extent];
    UIImage *newImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return newImage;
}

- (UIBezierPath *)createPathForText:(NSString *)string fontHeight:(CGFloat)height {
    if ([string length] < 1) {
        return nil;
    }
    
    UIBezierPath *combinedGlyphsPath = nil;
    CGMutablePathRef letters = CGPathCreateMutable();
    
    CTFontRef font = CTFontCreateWithName(CFSTR("Helvetica"), height, NULL);
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge id)font, kCTFontAttributeName,
                           nil];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string
                                                                     attributes:attrs];
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attrString);
    CFArrayRef runArray = CTLineGetGlyphRuns(line);
    
    for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++) {
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        
        for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++) {
            CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
            CGGlyph glyph;
            CGPoint position;
            CTRunGetGlyphs(run, thisGlyphRange, &glyph);
            CTRunGetPositions(run, thisGlyphRange, &position);
            {
                CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
                CGAffineTransform t = CGAffineTransformMakeTranslation(position.x, position.y);
                CGPathAddPath(letters, &t, letter);
                CGPathRelease(letter);
            }
        }
    }
    CFRelease(line);
    
    combinedGlyphsPath = [UIBezierPath bezierPath];
    [combinedGlyphsPath moveToPoint:CGPointZero];
    [combinedGlyphsPath appendPath:[UIBezierPath bezierPathWithCGPath:letters]];
    
    CGPathRelease(letters);
    CFRelease(font);
    
    if (attrString) {
        attrString = nil;
    }
    return combinedGlyphsPath;
}

- (CAGradientLayer *)performEffectAnimation:(XKEffectDirection)effectDirection {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = [self colorsForStage:0];
    
    switch (effectDirection) {
        case XKEffectDirectionLeftToRight:
            gradientLayer.startPoint = CGPointMake(0.0, 0.5);
            gradientLayer.endPoint = CGPointMake(1.0, 0.5);
            break;
        case XKEffectDirectionRightToLeft:
            gradientLayer.startPoint = CGPointMake(1.0, 0.5);
            gradientLayer.endPoint = CGPointMake(0.0, 0.5);
            break;
        case XKEffectDirectionTopToBottom:
            gradientLayer.startPoint = CGPointMake(0.5, 0.0);
            gradientLayer.endPoint = CGPointMake(0.5, 1.0);
            break;
        case XKEffectDirectionBottomToTop:
            gradientLayer.startPoint = CGPointMake(0.5, 1.0);
            gradientLayer.endPoint = CGPointMake(0.5, 0.0);
            break;
        case XKEffectDirectionBottomLeftToTopRight:
            gradientLayer.startPoint = CGPointMake(0.0, 1.0);
            gradientLayer.endPoint = CGPointMake(1.0, 0.0);
            break;
        case XKEffectDirectionBottomRightToTopLeft:
            gradientLayer.startPoint = CGPointMake(1.0, 1.0);
            gradientLayer.endPoint = CGPointMake(0.0, 0.0);
            break;
        case XKEffectDirectionTopLeftToBottomRight:
            gradientLayer.startPoint = CGPointMake(0.0, 0.0);
            gradientLayer.endPoint = CGPointMake(1.0, 1.0);
            break;
        case XKEffectDirectionTopRightToBottomLeft: {
            gradientLayer.startPoint = CGPointMake(1.0, 0.0);
            gradientLayer.endPoint = CGPointMake(0.0, 1.0);
            break;
        }
    }
    
    CABasicAnimation *animation0 = [self animationForStage:0];
    CABasicAnimation *animation1 = [self animationForStage:1];
    CABasicAnimation *animation2 = [self animationForStage:2];
    CABasicAnimation *animation3 = [self animationForStage:3];
    CABasicAnimation *animation4 = [self animationForStage:4];
    CABasicAnimation *animation5 = [self animationForStage:5];
    CABasicAnimation *animation6 = [self animationForStage:6];
    CABasicAnimation *animation7 = [self animationForStage:7];
    CABasicAnimation *animation8 = [self animationForStage:8];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = animation8.beginTime + animation8.duration;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.repeatCount = 10;
    group.beginTime = 1.0;
    [group setAnimations:@[animation0, animation1, animation2, animation3, animation4, animation5, animation6, animation7, animation8]];
    
    [gradientLayer addAnimation:group forKey:@"animationOpacity"];
    
    return gradientLayer;
}

- (CABasicAnimation *)animationForStage:(NSUInteger)stage {
    CGFloat duration = 0.3;
    CGFloat inset = 0.1;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"colors"];
    animation.fromValue = [self colorsForStage:stage];
    animation.toValue = [self colorsForStage:stage + 1];
    animation.beginTime = stage * (duration - inset);
    animation.duration = duration;
    animation.repeatCount = 1;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    return animation;
}

- (NSArray *)colorsForStage:(NSUInteger)stage {
    UIColor *textColor = [UIColor whiteColor];
    UIColor *effectColor = [UIColor blackColor];
    NSMutableArray *array = @[].mutableCopy;
    
    for (int i = 0; i < 9; i++) {
        [array addObject:stage != 0 && stage == i ? (id)[effectColor CGColor] : (id)[textColor CGColor]];
    }
    
    return [NSArray arrayWithArray:array];
}

- (CAShapeLayer *)createMaskHoleLayer:(CGSize)viewBounds startTime:(NSTimeInterval)startTime {
    CGRect bounds = CGRectMake(viewBounds.width/2, -viewBounds.height/2, viewBounds.width*2, viewBounds.height*2);
    CGFloat kRadius = 80;
    CGRect circleRect = CGRectMake(CGRectGetMidX(bounds) - kRadius,
                                   CGRectGetMidY(bounds) - kRadius,
                                   2 * kRadius, 2 * kRadius);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:circleRect];
    [path appendPath:[UIBezierPath bezierPathWithRect:bounds]];
    
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.path = path.CGPath;
    circleLayer.fillRule = kCAFillRuleEvenOdd;
    circleLayer.bounds = CGPathGetBoundingBox(path.CGPath);
    circleLayer.position = CGPointMake(bounds.size.width/4, bounds.size.height/2);
    circleLayer.opacity = 0;
    
    NSTimeInterval animatedStartTime = startTime;
    CABasicAnimation *animationOpacityIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animationOpacityIn.fromValue = [NSNumber numberWithFloat:0.6];
    animationOpacityIn.toValue = [NSNumber numberWithFloat:0.8];
    animationOpacityIn.repeatCount = 1;
    animationOpacityIn.duration = 1;
    animationOpacityIn.beginTime = animatedStartTime;
    
    CGPoint startPoint = CGPointMake(bounds.size.width/4, bounds.size.height/3);
    CGPoint endPoint = CGPointMake(bounds.size.width/4, bounds.size.height/4);
    CABasicAnimation *animationMove = [CABasicAnimation animationWithKeyPath:@"position"];
    [animationMove setFromValue:[NSValue valueWithCGPoint:startPoint]];
    [animationMove setToValue:[NSValue valueWithCGPoint:endPoint]];
    [animationMove setDuration:animationOpacityIn.duration];
    animationMove.autoreverses = YES;
    animationMove.repeatCount = 1;
    animationMove.beginTime = animatedStartTime;
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = @0.1f;
    scaleAnimation.toValue = @5.0f;
    scaleAnimation.duration = 1.0f;
    scaleAnimation.repeatCount = 1;
    scaleAnimation.removedOnCompletion = NO;
    scaleAnimation.fillMode = kCAFillModeForwards;
    scaleAnimation.autoreverses = NO;
    scaleAnimation.beginTime = animatedStartTime + animationMove.duration;
    
    CABasicAnimation *animationOpacityOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animationOpacityOut.fromValue = [NSNumber numberWithFloat:0.8];
    animationOpacityOut.toValue = [NSNumber numberWithFloat:0.0];
    animationOpacityOut.repeatCount = 1;
    animationOpacityOut.duration = scaleAnimation.duration;
    animationOpacityOut.beginTime = animatedStartTime + animationMove.duration;
    
    [circleLayer addAnimation:animationOpacityIn forKey:@"opacityIn"];
    [circleLayer addAnimation:animationMove forKey:@"position"];
    [circleLayer addAnimation:scaleAnimation forKey:@"scale"];
    [circleLayer addAnimation:animationOpacityOut forKey:@"opacityOut"];
    
    return circleLayer;
}

- (UIImage *)getImageForVideoFrame:(NSURL *)videoFileURL atTime:(CMTime)time {
    NSURL *inputUrl = videoFileURL;
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:inputUrl options:nil];
    
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:time actualTime:NULL error:&thumbnailImageGenerationError];
    
    if (!thumbnailImageRef) {
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    }
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
    
    if (thumbnailImageRef) {
        CGImageRelease(thumbnailImageRef);
    }
    
    return thumbnailImage;
}

- (UIImage *)imageJoint:(UIImage *)imageTarget fromImage:(UIImage *)imageOriginal {
    CGSize size = CGSizeMake(imageTarget.size.width,imageTarget.size.height);
    UIGraphicsBeginImageContext(size);
    
    [imageTarget drawInRect:CGRectMake(0, 0, imageTarget.size.width, imageTarget.size.height)];
    
    float multiple = 1.5;
    [imageOriginal drawInRect:CGRectMake((arc4random()%(int)(size.width - imageOriginal.size.width*multiple)), imageTarget.size.height - imageOriginal.size.height, imageOriginal.size.width*multiple, imageOriginal.size.height*multiple)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

- (CALayer *)createPhotoLinearScrollLayer:(CGSize)viewBounds image:(UIImage *)image startTime:(NSTimeInterval)timeInterval {
    CALayer *layer = [CALayer layer];
    layer.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    layer.geometryFlipped = YES;
    
    UIImage* imageResult = [[XKCurledViewHelper sharedInstance] setImage:image forLayer:layer];
    
    CGPoint startPointIn = CGPointMake(viewBounds.width+imageResult.size.width, viewBounds.height/2);
    CGPoint middlePoint = CGPointMake(viewBounds.width/2, viewBounds.height/2);
    CGPoint endPointIn = CGPointMake(-imageResult.size.width, viewBounds.height/2);
    layer.opacity = 0.0;
    layer.position = endPointIn;
    
    // 1.
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.fromValue = @0.0f;
    fadeInAnimation.toValue = @1.0f;
    fadeInAnimation.additive = NO;
    fadeInAnimation.removedOnCompletion = NO;
    fadeInAnimation.beginTime = timeInterval;
    fadeInAnimation.duration = 3.0;
    fadeInAnimation.autoreverses = NO;
    fadeInAnimation.fillMode = kCAFillModeBoth;
    
    CABasicAnimation *moveInAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    [moveInAnimation setFromValue:[NSValue valueWithCGPoint:startPointIn]];
    [moveInAnimation setToValue:[NSValue valueWithCGPoint:middlePoint]];
    [moveInAnimation setDuration:2.0];
    moveInAnimation.beginTime = timeInterval;
    moveInAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    CAKeyframeAnimation *scaleInAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaleInAnimation.duration = 3.0;
    scaleInAnimation.beginTime = timeInterval;
    scaleInAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:.5f],
                               [NSNumber numberWithFloat:1.2f],
                               [NSNumber numberWithFloat:.8f],
                               [NSNumber numberWithFloat:1.2f],
                               nil];
    
    CABasicAnimation* shakeAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    shakeAnimation.fromValue = [NSNumber numberWithFloat:-M_PI/32];
    shakeAnimation.toValue = [NSNumber numberWithFloat:+M_PI/32];
    shakeAnimation.duration = 0.3;
    shakeAnimation.autoreverses = YES;
    shakeAnimation.repeatCount = 10;
    shakeAnimation.beginTime = moveInAnimation.beginTime + moveInAnimation.duration;
    
    
    
    dispatch_async_main_after(shakeAnimation.beginTime+(shakeAnimation.duration*shakeAnimation.repeatCount), ^{
        layer.position = endPointIn;;
    });
    
    CGFloat interval = moveInAnimation.beginTime + moveInAnimation.duration;
    CABasicAnimation *moveOutAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    [moveOutAnimation setFromValue:[NSValue valueWithCGPoint:middlePoint]];
    [moveOutAnimation setToValue:[NSValue valueWithCGPoint:endPointIn]];
    [moveOutAnimation setDuration:2.0];
    moveOutAnimation.beginTime = interval;
    moveOutAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation* rotateOutAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateOutAnimation.toValue = @((2 * M_PI) * 2);
    rotateOutAnimation.duration = 2.0f;
    rotateOutAnimation.beginTime = interval;
    rotateOutAnimation.removedOnCompletion = NO;
    rotateOutAnimation.autoreverses = NO;
    rotateOutAnimation.fillMode = kCAFillModeForwards;
    rotateOutAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *scaleOutAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleOutAnimation.fromValue = @1.2f;
    scaleOutAnimation.toValue = @0.0f;
    scaleOutAnimation.duration = 2.0f;
    scaleOutAnimation.removedOnCompletion = NO;
    scaleOutAnimation.fillMode = kCAFillModeForwards;
    scaleOutAnimation.autoreverses = NO;
    scaleOutAnimation.beginTime = interval;
    scaleOutAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [layer addAnimation:fadeInAnimation forKey:@"fadeIn"];
    [layer addAnimation:moveInAnimation forKey:@"positionIn"];
    [layer addAnimation:scaleInAnimation forKey:@"scaleIn"];
    [layer addAnimation:shakeAnimation forKey:@"shake"];
    [layer addAnimation:moveOutAnimation forKey:@"positionOut"];
    [layer addAnimation:rotateOutAnimation forKey:@"spinOut"];
    [layer addAnimation:scaleOutAnimation forKey:@"scaleOut"];
    
    return layer;
}

- (UIImage *)getCropImage:(UIImage *)originalImage videoSize:(CGSize)videoSize {
    if (originalImage == nil) {
        return nil;
    }
    
    CGFloat maxLen = MIN(videoSize.width, videoSize.height);
    UIImage *image = [self imageByScalingToMaxSize:originalImage maxLength:maxLen];
    
    if (image) {
        CGRect cropRect = CGRectMake(0, 0, maxLen, maxLen);
        image = [self getCropImage:image cropRect:cropRect];
    }
    
    return image;
}

- (UIImage *)imageByScalingToMaxSize:(UIImage *)originalImage maxLength:(CGFloat)maxLength {
    if (originalImage.size.width < maxLength)
        return originalImage;
    
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (originalImage.size.width > originalImage.size.height) {
        btHeight = maxLength;
        btWidth = originalImage.size.width * (maxLength / originalImage.size.height);
    } else {
        btWidth = maxLength;
        btHeight = originalImage.size.height * (maxLength / originalImage.size.width);
    }
    
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:originalImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)originalImage targetSize:(CGSize)targetSize {
    CGSize imageSize = originalImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor;
        } else {
            scaleFactor = heightFactor;
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIImage *newImage = nil;
    UIGraphicsBeginImageContext(targetSize);
    CGRect thumbnailRect = CGRectMake(thumbnailPoint.x, thumbnailPoint.y, scaledWidth, scaledHeight);
    [originalImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)getCropImage:(UIImage *)originalImage cropRect:(CGRect)cropRect {
    CGFloat oriWidth = cropRect.size.width;
    CGFloat oriHeight = originalImage.size.height * (oriWidth / originalImage.size.width);
    CGFloat oriX = cropRect.origin.x + (cropRect.size.width - oriWidth) / 2;
    CGFloat oriY = cropRect.origin.y + (cropRect.size.height - oriHeight) / 2;
    CGRect latestRect = CGRectMake(oriX, oriY, oriWidth, oriHeight);
    
    return [self getSubImageByCropRect:cropRect latestRect:latestRect originalImage:originalImage];
}

- (UIImage *)getSubImageByCropRect:(CGRect)cropRect latestRect:(CGRect)latestRect originalImage:(UIImage *)originalImage {
    CGRect squareFrame = cropRect;
    CGFloat scaleRatio = latestRect.size.width / originalImage.size.width;
    CGFloat x = (squareFrame.origin.x - latestRect.origin.x) / scaleRatio;
    CGFloat y = (squareFrame.origin.y - latestRect.origin.y) / scaleRatio;
    CGFloat w = squareFrame.size.width / scaleRatio;
    CGFloat h = squareFrame.size.width / scaleRatio;
    if (latestRect.size.width < cropRect.size.width) {
        CGFloat newW = originalImage.size.width;
        CGFloat newH = newW * (cropRect.size.height / cropRect.size.width);
        x = 0;
        y = y + (h - newH) / 2;
        w = newH;
        h = newH;
    }
    
    if (latestRect.size.height < cropRect.size.height) {
        CGFloat newH = originalImage.size.height;
        CGFloat newW = newH * (cropRect.size.width / cropRect.size.height);
        x = x + (w - newW) / 2;
        y = 0;
        w = newH;
        h = newH;
    }
    
    CGRect imageRect = CGRectMake(x, y, w, h);
    CGImageRef imageRef = originalImage.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, imageRect);
    CGSize size = CGSizeMake(imageRect.size.width, imageRect.size.height);
    
    UIImage* smallImage;
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, imageRect, subImageRef);
    
    if (context) {
        smallImage = [UIImage imageWithCGImage:subImageRef];
    } else {
        smallImage = nil;
    }
    UIGraphicsEndImageContext();
    CGImageRelease(subImageRef);
    
    return smallImage;
}

- (UIImage *)getBorderImage:(UIImage *)image {
    NSString *imageName = [NSString stringWithFormat:@"border_%i",(arc4random() % (int)12)];
    UIImage *imageBorder = [UIImage imageNamed:imageName];
    UIImage *imageResult = [self imageBorder:image fromBorderImage:imageBorder];
    
    return imageResult;
}

- (UIImage *)imageBorder:(UIImage *)imageTarget fromBorderImage:(UIImage *)imageBorder {
    int widthBorder = 4;
    CGSize size = CGSizeMake(imageTarget.size.width+2*widthBorder,imageTarget.size.height+2*widthBorder);
    UIGraphicsBeginImageContext(size);
    
    [imageTarget drawInRect:CGRectMake(widthBorder, widthBorder, imageTarget.size.width, imageTarget.size.height)];
    [imageBorder drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

- (CALayer *) createPhotoCentring:(CGSize)viewBounds image:(UIImage *)image startTime:(NSTimeInterval)timeInterval {
    CALayer *layerImage = [CALayer layer];
    
    UIImage *imageResult = [self getBorderImage:image];
    if (imageResult) {
        CGFloat size = viewBounds.width * 4 / 5;
        if (viewBounds.width > viewBounds.height) {
            size = viewBounds.height * 4 / 5;
        }
        
        layerImage.contents = (id)imageResult.CGImage;
        layerImage.bounds = CGRectMake(0, 0, size, size);
        layerImage.position = CGPointMake(viewBounds.width/2, viewBounds.height/2);
        layerImage.opacity = 0.0;
        
        double animatedStartTime = timeInterval;
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
        layerImage = nil;
    }
    return layerImage;
}

- (CALayer *)createPhotoDropLayer:(CGSize)viewBounds image:(UIImage *)image startTime:(NSTimeInterval)timeInterval xAxis:(CGFloat)xAxis {
    CALayer *layer = [CALayer layer];
    layer.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    
    UIImage *imageResult = [self getBorderImage:image];
    layer.contents = (id)imageResult.CGImage;
    
    CGPoint startPointIn = CGPointMake(xAxis, viewBounds.height + image.size.height);
    CGPoint middlePoint = CGPointMake(xAxis, viewBounds.height/2);
    CGPoint endPointIn = CGPointMake(xAxis, -image.size.height);
    layer.position = middlePoint;
    layer.opacity = 0.0;
    
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.fromValue = @0.0f;
    fadeInAnimation.toValue = @1.0f;
    fadeInAnimation.additive = NO;
    fadeInAnimation.removedOnCompletion = NO;
    fadeInAnimation.beginTime = timeInterval;
    fadeInAnimation.duration = 2.0;
    fadeInAnimation.autoreverses = NO;
    fadeInAnimation.fillMode = kCAFillModeBoth;
    
    CABasicAnimation *moveInAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    [moveInAnimation setFromValue:[NSValue valueWithCGPoint:startPointIn]];
    [moveInAnimation setToValue:[NSValue valueWithCGPoint:middlePoint]];
    [moveInAnimation setDuration:2.0];
    moveInAnimation.beginTime = timeInterval;
    moveInAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CAKeyframeAnimation *scaleInAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaleInAnimation.duration = 3.0;
    scaleInAnimation.beginTime = timeInterval;
    scaleInAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:.5f],
                               [NSNumber numberWithFloat:1.2f],
                               [NSNumber numberWithFloat:.85f],
                               [NSNumber numberWithFloat:1.f],
                               nil];
    
    CABasicAnimation* shakeAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    shakeAnimation.fromValue = [NSNumber numberWithFloat:-M_PI/32];
    shakeAnimation.toValue = [NSNumber numberWithFloat:+M_PI/32];
    shakeAnimation.duration = 0.3;
    shakeAnimation.autoreverses = YES;
    shakeAnimation.repeatCount = 10;
    shakeAnimation.beginTime = moveInAnimation.beginTime + moveInAnimation.duration;
    
    dispatch_async_main_after(shakeAnimation.beginTime+(shakeAnimation.duration*shakeAnimation.repeatCount), ^{
        layer.position = endPointIn;;
    });
    
    NSTimeInterval outTime = shakeAnimation.beginTime + (shakeAnimation.duration*shakeAnimation.repeatCount);
    CABasicAnimation *moveOutAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    [moveOutAnimation setFromValue:[NSValue valueWithCGPoint:middlePoint]];
    [moveOutAnimation setToValue:[NSValue valueWithCGPoint:endPointIn]];
    [moveOutAnimation setDuration:2.0];
    moveOutAnimation.beginTime = outTime;
    moveOutAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation* rotateOutAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateOutAnimation.toValue = @((2 * M_PI) * 2);
    rotateOutAnimation.duration = 2.0f;
    rotateOutAnimation.beginTime = outTime;
    rotateOutAnimation.removedOnCompletion = NO;
    rotateOutAnimation.autoreverses = NO;
    rotateOutAnimation.fillMode = kCAFillModeForwards;
    rotateOutAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *scaleOutAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleOutAnimation.fromValue = @1.0f;
    scaleOutAnimation.toValue = @0.0f;
    scaleOutAnimation.duration = 2.0f;
    scaleOutAnimation.removedOnCompletion = NO;
    scaleOutAnimation.fillMode = kCAFillModeForwards;
    scaleOutAnimation.autoreverses = NO;
    scaleOutAnimation.beginTime = outTime;
    scaleOutAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [layer addAnimation:fadeInAnimation forKey:@"fadeIn"];
    [layer addAnimation:moveInAnimation forKey:@"positionIn"];
    [layer addAnimation:scaleInAnimation forKey:@"scaleIn"];
    [layer addAnimation:shakeAnimation forKey:@"shake"];
    [layer addAnimation:rotateOutAnimation forKey:@"spinOut"];
    [layer addAnimation:scaleOutAnimation forKey:@"scaleOut"];
    
    return layer;
}

- (CALayer *)createPhotoParabolaLayer:(CGSize)viewBounds image:(UIImage *)image startTime:(NSTimeInterval)timeInterval xAxis:(CGFloat)xAxis {
    CALayer *layer = [CALayer layer];
    layer.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    layer.position = CGPointMake(xAxis, viewBounds.height*2/3);
    layer.opacity = 0.0;
    
    UIImage *curledImage = [[XKCurledViewHelper sharedInstance] setImage:image forLayer:layer];
    
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.fromValue = @0.0f;
    fadeInAnimation.toValue = @1.0f;
    fadeInAnimation.additive = NO;
    fadeInAnimation.removedOnCompletion = NO;
    fadeInAnimation.beginTime = timeInterval;
    fadeInAnimation.duration = 1.0;
    fadeInAnimation.autoreverses = NO;
    fadeInAnimation.fillMode = kCAFillModeBoth;
    
    CGFloat duration = 1.6f;
    CGFloat positionX = layer.position.x;
    CGFloat positionY = layer.position.y;
    int fromX = arc4random() % (int)viewBounds.width;
    int fromY = arc4random() % (int)positionY;
    int height = viewBounds.height;
    CGFloat cpx = positionX + (fromX - positionX)/2;
    CGFloat cpy = fromY / 2 - positionY;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, fromX, height);
    CGPathAddQuadCurveToPoint(path, NULL, cpx, cpy, positionX, positionY);
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    [animation setPath:path];
    CFRelease(path);
    path = nil;
    
    CGFloat from3DScale = 1 + arc4random() % 10 *0.1;
    CGFloat to3DScale = 0.8 + arc4random() % 5 *0.1;
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(from3DScale, from3DScale, from3DScale)], [NSValue valueWithCATransform3D:CATransform3DMakeScale(to3DScale, to3DScale, to3DScale)]];
    scaleAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.delegate = self;
    group.duration = duration;
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    group.animations = @[scaleAnimation, animation];
    group.beginTime = timeInterval;
    
    CABasicAnimation* shakeAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    shakeAnimation.fromValue = [NSNumber numberWithFloat:-M_PI/32];
    shakeAnimation.toValue = [NSNumber numberWithFloat:+M_PI/32];
    shakeAnimation.duration = 0.3;
    shakeAnimation.autoreverses = YES;
    shakeAnimation.repeatCount = 10;
    shakeAnimation.beginTime = group.beginTime + group.duration;
    
    [layer addAnimation:fadeInAnimation forKey:@"opacity"];
    [layer addAnimation:group forKey:@"position&transform"];
    [layer addAnimation:shakeAnimation forKey:@"shake"];
    
    int gap = 10;
    CALayer *layerReflection = [CALayer layer];
    layerReflection.bounds = CGRectMake(0, 0, layer.bounds.size.width, layer.bounds.size.height);
    layerReflection.position = CGPointMake(layer.bounds.size.width/2, -layer.bounds.size.height/2 - gap);
    UIImage *reflectionImage = [curledImage reflectionWithAlpha:0.5];
    layerReflection.contents = (id)[reflectionImage CGImage];
    [layer addSublayer:layerReflection];
    reflectionImage = nil;
    
    return layer;
}

- (CALayer *)createPhotoFlareLayer:(CGSize)viewBounds image:(UIImage *)image startTime:(NSTimeInterval)timeInterval xAxis:(CGFloat)xAxis {
    CALayer *layer = [CALayer layer];
    layer.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    layer.position = CGPointMake(xAxis, viewBounds.height/2);
    layer.geometryFlipped = YES;
    
    int x = 4;
    int y = 4;
    UIImage *imageResult = [self getBorderImage:image];
    NSArray *arrImage = [self splitImage:imageResult ByX:x andY:y];
    if (!arrImage || [arrImage count] < 1) {
        return layer;
    }
    
    CGFloat duration = 2.0f;
    float _xstep = imageResult.size.width / y;
    float _ystep = imageResult.size.height / x;
    for (int i = 0; i < x; ++i) {
        for (int j = 0; j < y; ++j) {
            CGRect rect = CGRectMake(_xstep * j, _ystep * i, _xstep, _ystep);
            UIImage* elementImage = arrImage[i * y + j];
            CALayer *layerPart = [CALayer layer];
            layerPart.frame = rect;
            layerPart.contents = (id)[elementImage CGImage];
            layerPart.opacity = 0.0;
            layerPart.geometryFlipped = YES;
            
            CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            fadeInAnimation.fromValue = @0.0f;
            fadeInAnimation.toValue = @1.0f;
            fadeInAnimation.additive = NO;
            fadeInAnimation.removedOnCompletion = NO;
            fadeInAnimation.beginTime = timeInterval;
            fadeInAnimation.duration = duration;
            fadeInAnimation.autoreverses = NO;
            fadeInAnimation.fillMode = kCAFillModeBoth;
            
            CGFloat positionX = layerPart.position.x;
            CGFloat positionY = layerPart.position.y;
            int fromX = arc4random() % (int)viewBounds.width;
            int fromY = arc4random() % (int)positionY;
            int height = viewBounds.height;
            CGFloat cpx = positionX + (fromX - positionX)/2;
            CGFloat cpy = fromY / 2 - positionY;
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, NULL, fromX, height);
            CGPathAddQuadCurveToPoint(path, NULL, cpx, cpy, positionX, positionY);
            
            CAKeyframeAnimation *moveInAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
            [moveInAnimation setPath:path];
            moveInAnimation.duration = duration;
            moveInAnimation.fillMode = kCAFillModeForwards;
            moveInAnimation.removedOnCompletion = NO;
            moveInAnimation.beginTime = timeInterval;
            CFRelease(path);
            
            [layerPart addAnimation:fadeInAnimation forKey:@"opacity"];
            [layerPart addAnimation:moveInAnimation forKey:@"position"];
            [layer addSublayer:layerPart];
        }
    }
    
    CABasicAnimation* shakeAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    shakeAnimation.fromValue = [NSNumber numberWithFloat:-M_PI / 32];
    shakeAnimation.toValue = [NSNumber numberWithFloat:+M_PI / 32];
    shakeAnimation.duration = 0.3;
    shakeAnimation.autoreverses = YES;
    shakeAnimation.repeatCount = 10;
    shakeAnimation.beginTime = duration + timeInterval;
    
    NSTimeInterval outTime = shakeAnimation.beginTime + shakeAnimation.duration*shakeAnimation.repeatCount + 3;
    CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.fromValue = [NSNumber numberWithFloat:1.0f];
    opacityAnim.toValue = [NSNumber numberWithFloat:0.f];
    opacityAnim.removedOnCompletion = NO;
    opacityAnim.fillMode =kCAFillModeForwards;
    opacityAnim.duration = duration;
    opacityAnim.beginTime = outTime;
    
    [layer addAnimation:shakeAnimation forKey:@"shake"];
    [layer addAnimation:opacityAnim forKey:@"opacity"];
    
    return layer;
}

- (NSArray *)splitImage:(UIImage *)image ByX:(int)x andY:(int)y {
    if (x < 1) {
        return nil;
    } else if (y < 1) {
        return nil;
    }
    if (![image isKindOfClass:[UIImage class]]) {
        return nil;
    }
    float _xstep = image.size.width / y;
    float _ystep = image.size.height / x;
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:x * y];
    for (int i=0; i<x; ++i) {
        for (int j=0; j<y; ++j) {
            CGRect rect = CGRectMake(_xstep * j, _ystep * i, _xstep, _ystep);
            CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
            UIImage* elementImage = [UIImage imageWithCGImage:imageRef];
            [arr addObject:elementImage];
        }
    }
    
    return arr;
}

- (CALayer *)createPhotoEmitterLayer:(CGSize)viewBounds image:(UIImage *)image startTime:(NSTimeInterval)timeInterval xAxis:(CGFloat)xAxis yAxis:(CGFloat)yAxis {
    CALayer *layer = [CALayer layer];
    layer.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    layer.position = CGPointMake(xAxis, yAxis);
    layer.opacity = 0.0;
    
    [[XKCurledViewHelper sharedInstance] setImage:image forLayer:layer];
    
    CGFloat duration = 1.6f;
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.fromValue = @0.0f;
    fadeInAnimation.toValue = @1.0f;
    fadeInAnimation.additive = NO;
    fadeInAnimation.removedOnCompletion = NO;
    fadeInAnimation.beginTime = timeInterval;
    fadeInAnimation.duration = duration;
    fadeInAnimation.autoreverses = NO;
    fadeInAnimation.fillMode = kCAFillModeBoth;
    
    CGFloat positionX = layer.position.x;
    CGFloat positionY = layer.position.y;
    int fromX = arc4random() % (int)viewBounds.width;
    int fromY = arc4random() % (int)positionY;
    int height = viewBounds.height;
    CGFloat cpx = positionX + (fromX - positionX)/2;
    CGFloat cpy = fromY/2 - positionY;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, fromX, height);
    CGPathAddQuadCurveToPoint(path, NULL, cpx, cpy, positionX, positionY);
    
    CAKeyframeAnimation *moveInAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    [moveInAnimation setPath:path];
    moveInAnimation.duration = duration;
    moveInAnimation.fillMode = kCAFillModeForwards;
    moveInAnimation.removedOnCompletion = NO;
    moveInAnimation.beginTime = timeInterval;
    CFRelease(path);
    
    [layer addAnimation:fadeInAnimation forKey:@"opacity"];
    [layer addAnimation:moveInAnimation forKey:@"position"];
    
    CALayer *layerPart = [self getRandomEmitterLayer:CGSizeMake(layer.bounds.size.width, layer.bounds.size.height) startTime:moveInAnimation.duration + moveInAnimation.beginTime];
    [layer addSublayer:layerPart];
    layer.masksToBounds = YES;
    
    return layer;
}

- (CALayer *)getRandomEmitterLayer:(CGSize)imageSize startTime:(NSTimeInterval)startTime {
    CALayer *layer = nil;
    NSTimeInterval timeInterval = startTime + 1;
    NSArray *startYPoints = [NSArray arrayWithObjects:[NSNumber numberWithFloat:imageSize.height/3], [NSNumber numberWithFloat:imageSize.height/2], [NSNumber numberWithFloat:imageSize.height*2/3], nil];
    switch (arc4random() % (int)5) {
        case 0:
        {
            NSString *str = @"Nice Day!";
            layer = [self buildGradientText:imageSize positon:CGPointMake(imageSize.width/2, imageSize.height - imageSize.height/4) text:str startTime:timeInterval];
            break;
        }
        case 1:
        {
            NSString *str = @"It's a beautiful day!";
            layer = [self buildAnimatedScrollText:imageSize text:str startPoint:CGPointMake(imageSize.width, [startYPoints[arc4random()%(int)3] floatValue]) startTime:timeInterval];
            break;
        }
        case 2:
        {
            layer = [self buildEmitterSnow:imageSize startTime:timeInterval];
            break;
        }
        case 3:
        {
            NSString *str = @"Miss You!";
            layer = [self buildEmitterSparkle:imageSize text:str startTime:timeInterval];
            break;
        }
        case 4:
        {
            layer = [self buildEmitterStar:imageSize startTime:timeInterval];
            break;
        }
        default:
            break;
    };
    
    return layer;
}

- (CALayer *)createPhotoExplodeLayer:(CGSize)viewBounds image:(UIImage *)image startTime:(NSTimeInterval)timeInterval {
    CALayer *layer = [CALayer layer];
    layer.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    layer.position = CGPointMake(viewBounds.width/2, viewBounds.height/2);
    layer.geometryFlipped = YES;
    
    int x = 5;
    int y = 5;
    UIImage *imageResult = [self getBorderImage:image];
    NSArray *arrImage = [self splitImage:imageResult ByX:x andY:y];
    if (!arrImage || [arrImage count]<1) {
        return layer;
    }
    
    CGFloat duration = 1.0f;
    float _xstep = imageResult.size.width/y;
    float _ystep = imageResult.size.height/x;
    for (int i  =0; i< x; ++i) {
        for (int j=0; j < y; ++j) {
            CGRect rect = CGRectMake(_xstep * j, _ystep * i, _xstep, _ystep);
            UIImage* elementImage = arrImage[i * y + j];
            CALayer *layerPart = [CALayer layer];
            layerPart.frame = rect;
            layerPart.contents = (id)[elementImage CGImage];
            layerPart.opacity = 0.0;
            layerPart.geometryFlipped = YES;
            
            CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            fadeInAnimation.fromValue = @0.0f;
            fadeInAnimation.toValue = @1.0f;
            
            CGFloat positionX = layerPart.position.x;
            CGFloat positionY = layerPart.position.y;
            int fromX = arc4random() % (int)viewBounds.width;
            int fromY = arc4random() % (int)viewBounds.height;
            CABasicAnimation *moveInAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
            [moveInAnimation setFromValue:[NSValue valueWithCGPoint:CGPointMake(fromX, fromY)]];
            [moveInAnimation setToValue:[NSValue valueWithCGPoint:CGPointMake(positionX, positionY)]];
            
            CAAnimationGroup *group = [CAAnimationGroup animation];
            group.duration = duration;
            group.fillMode = kCAFillModeForwards;
            group.removedOnCompletion = NO;
            group.animations = @[fadeInAnimation, moveInAnimation];
            group.beginTime = timeInterval;
            
            [layerPart addAnimation:group forKey:@"group"];
            [layer addSublayer:layerPart];
        }
    }
    
    CABasicAnimation* shakeAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    shakeAnimation.fromValue = [NSNumber numberWithFloat:-M_PI/32];
    shakeAnimation.toValue = [NSNumber numberWithFloat:+M_PI/32];
    shakeAnimation.duration = 0.3;
    shakeAnimation.autoreverses = YES;
    shakeAnimation.repeatCount = 10;
    shakeAnimation.beginTime = duration + timeInterval;
    
    NSTimeInterval outTime = shakeAnimation.beginTime + shakeAnimation.duration * shakeAnimation.repeatCount;
    CABasicAnimation *moveOutAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    [moveOutAnimation setFromValue:[NSValue valueWithCGPoint:layer.position]];
    [moveOutAnimation setToValue:[NSValue valueWithCGPoint:CGPointMake(0, viewBounds.height/2)]];
    [moveOutAnimation setDuration:2.0];
    moveOutAnimation.beginTime = outTime;
    moveOutAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation* rotateOutAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateOutAnimation.toValue = @((2 * M_PI) * 2);
    rotateOutAnimation.duration = 2.0f;
    rotateOutAnimation.beginTime = outTime;
    rotateOutAnimation.removedOnCompletion = NO;
    rotateOutAnimation.autoreverses = NO;
    rotateOutAnimation.fillMode = kCAFillModeForwards;
    rotateOutAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *scaleOutAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleOutAnimation.fromValue = @1.0f;
    scaleOutAnimation.toValue = @0.0f;
    scaleOutAnimation.duration = 2.0f;
    scaleOutAnimation.removedOnCompletion = NO;
    scaleOutAnimation.fillMode = kCAFillModeForwards;
    scaleOutAnimation.autoreverses = NO;
    scaleOutAnimation.beginTime = outTime;
    scaleOutAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [layer addAnimation:rotateOutAnimation forKey:@"spinOut"];
    [layer addAnimation:scaleOutAnimation forKey:@"scaleOut"];
    [layer addAnimation:shakeAnimation forKey:@"shake"];
    
    return layer;
}

- (CALayer *)createPhotoExplodeDropLayer:(CGSize)viewBounds image:(UIImage *)image startTime:(NSTimeInterval)timeInterval xAxis:(CGFloat)xAxis {
    CALayer *layer = [CALayer layer];
    layer.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    layer.position = CGPointMake(xAxis, viewBounds.height/2);
    layer.geometryFlipped = YES;
    
    int x = 4;
    int y = 4;
    UIImage *imageResult = [self getBorderImage:image];
    NSArray *arrImage = [self splitImage:imageResult ByX:x andY:y];
    if (!arrImage || [arrImage count] < 1) {
        return layer;
    }
    
    CGFloat duration = 3.0f;
    float _xstep = imageResult.size.width / y;
    float _ystep = imageResult.size.height / x;
    for (int i = 0; i < x; ++i) {
        for (int j = 0; j < y; ++j) {
            CGRect rect = CGRectMake(_xstep * j, _ystep * i, _xstep, _ystep);
            UIImage* elementImage = arrImage[i*y + j];
            CALayer *layerPart = [CALayer layer];
            layerPart.frame = rect;
            layerPart.contents = (id)[elementImage CGImage];
            layerPart.geometryFlipped = YES;
            
            layerPart.opacity = 0.0;
            CGPoint startPointIn = CGPointMake(((_xstep*(y-j)) + _xstep)/2, ((_ystep*i)+_ystep)/2);
            CGPoint middlePoint = layerPart.position;
            
            CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            fadeInAnimation.fromValue = @0.0f;
            fadeInAnimation.toValue = @1.0f;
            fadeInAnimation.additive = NO;
            fadeInAnimation.removedOnCompletion = NO;
            fadeInAnimation.beginTime = timeInterval;
            fadeInAnimation.duration = duration;
            fadeInAnimation.autoreverses = NO;
            fadeInAnimation.fillMode = kCAFillModeBoth;
            
            CABasicAnimation *moveInAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
            [moveInAnimation setFromValue:[NSValue valueWithCGPoint:startPointIn]];
            [moveInAnimation setToValue:[NSValue valueWithCGPoint:middlePoint]];
            [moveInAnimation setDuration:duration];
            moveInAnimation.beginTime = timeInterval;
            moveInAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            
            CABasicAnimation* rotateInAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            rotateInAnimation.fromValue = [NSNumber numberWithFloat:0];
            rotateInAnimation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
            rotateInAnimation.duration = duration;
            rotateInAnimation.beginTime = timeInterval;
            rotateInAnimation.removedOnCompletion = NO;
            rotateInAnimation.autoreverses = NO;
            rotateInAnimation.fillMode = kCAFillModeForwards;
            rotateInAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            
            [layerPart addAnimation:fadeInAnimation forKey:@"opacity"];
            [layerPart addAnimation:moveInAnimation forKey:@"position"];
            [layerPart addAnimation:rotateInAnimation forKey:@"rotateIn"];
            
            [layer addSublayer:layerPart];
        }
    }
    
    NSTimeInterval startTime = timeInterval + duration + 1;
    CGFloat durationExplode = 2.0;
    
    CGRect originalFrame = layer.frame;
    [[layer sublayers] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        LPParticleLayer *layerParticle = (LPParticleLayer *)obj;
        // Path
        CAKeyframeAnimation *moveAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        moveAnim.path = ([self pathForLayer:layerParticle parentRect:originalFrame].CGPath);
        moveAnim.removedOnCompletion = YES;
        moveAnim.fillMode=kCAFillModeForwards;
        NSArray *timingFunctions = [NSArray arrayWithObjects:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],nil];
        [moveAnim setTimingFunctions:timingFunctions];
        
        float r = (float)rand() / (float)RAND_MAX;
        NSTimeInterval speed = 2.35*r;
        
        CAKeyframeAnimation *transformAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        CATransform3D startingScale = layerParticle.transform;
        CATransform3D endingScale = CATransform3DConcat(CATransform3DMakeScale((float)rand() / (float)RAND_MAX, (float)rand() / (float)RAND_MAX, (float)rand() / (float)RAND_MAX), CATransform3DMakeRotation(M_PI*(1 + (float)rand() / (float)RAND_MAX), (float)rand() / (float)RAND_MAX, (float)rand() / (float)RAND_MAX, (float)rand() / (float)RAND_MAX));
        
        NSArray *boundsValues = [NSArray arrayWithObjects:[NSValue valueWithCATransform3D:startingScale],
                                 [NSValue valueWithCATransform3D:endingScale], nil];
        [transformAnim setValues:boundsValues];
        
        NSArray *times = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],
                          [NSNumber numberWithFloat:speed*.25], nil];
        [transformAnim setKeyTimes:times];
        
        
        timingFunctions = [NSArray arrayWithObjects:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                           [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                           [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                           nil];
        [transformAnim setTimingFunctions:timingFunctions];
        transformAnim.fillMode = kCAFillModeForwards;
        transformAnim.removedOnCompletion = NO;
        
        CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnim.fromValue = [NSNumber numberWithFloat:1.0f];
        opacityAnim.toValue = [NSNumber numberWithFloat:0.f];
        opacityAnim.removedOnCompletion = NO;
        opacityAnim.fillMode =kCAFillModeForwards;
        
        CAAnimationGroup *animGroup = [CAAnimationGroup animation];
        animGroup.animations = [NSArray arrayWithObjects:moveAnim,transformAnim,opacityAnim, nil];
        animGroup.duration = durationExplode;
        animGroup.fillMode = kCAFillModeForwards;
        animGroup.delegate = self;
        animGroup.beginTime = startTime;
        [animGroup setValue:layerParticle forKey:@"animationLayer"];
        
        [layerParticle addAnimation:animGroup forKey:nil];
        
    }];
    
    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOutAnimation.fromValue = @1.0f;
    fadeOutAnimation.toValue = @0.0f;
    fadeOutAnimation.additive = NO;
    fadeOutAnimation.removedOnCompletion = NO;
    fadeOutAnimation.beginTime = startTime + durationExplode - 1;
    fadeOutAnimation.duration = 1;
    fadeOutAnimation.autoreverses = NO;
    fadeOutAnimation.fillMode = kCAFillModeBoth;
    [layer addAnimation:fadeOutAnimation forKey:@"opacity"];
    
    return layer;
}

- (UIBezierPath *)pathForLayer:(CALayer *)layer parentRect:(CGRect)rect {
    UIBezierPath *particlePath = [UIBezierPath bezierPath];
    [particlePath moveToPoint:CGPointMake(rect.size.width/2, rect.size.height/2)];
    
    float r = ((float)rand()/(float)RAND_MAX) + 0.3f;
    float r2 = ((float)rand()/(float)RAND_MAX) + 0.4f;
    float r3 = r * r2;
    
    int upOrDown = (r <= 0.5) ? 1 : -1;
    CGPoint curvePoint = CGPointZero;
    CGPoint endPoint = CGPointZero;
    float maxLeftRightShift = 1.f * ((float)rand() / (float)RAND_MAX);
    
    CGFloat layerYPosAndHeight = ((layer.position.y+layer.frame.size.height))*(float)rand() / (float)RAND_MAX + arc4random()%(int)layer.frame.size.height/4;
    CGFloat layerXPosAndHeight = ((layer.position.x+layer.frame.size.width)) * r3;
    
    float endY = 320;
    if (layer.position.x <= rect.size.width * 0.5) {
        endPoint = CGPointMake(-layerXPosAndHeight, endY);
        curvePoint= CGPointMake((((layer.position.x * 0.5) * r3) * upOrDown)*maxLeftRightShift,-layerYPosAndHeight);
    } else {
        endPoint = CGPointMake(layerXPosAndHeight, endY);
        curvePoint= CGPointMake((((layer.position.x * 0.5) * r3) * upOrDown+rect.size.width) * maxLeftRightShift, -layerYPosAndHeight);
    }
    
    [particlePath addQuadCurveToPoint:endPoint
                         controlPoint:curvePoint];
    
    return particlePath;
}

- (CALayer *)createPhotoCloudLayer:(CGSize)viewBounds image:(UIImage *)image startTime:(NSTimeInterval)timeInterval left:(BOOL)left {
    CALayer *layer = [CALayer layer];
    layer.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    layer.position = CGPointMake(viewBounds.width/2, viewBounds.height/2);
    layer.opacity = 0.0;
    
    UIImage * imageResult = [[XKCurledViewHelper sharedInstance] setImage:image forLayer:layer];
    
    CGFloat duration = 10;
    CABasicAnimation *basicScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    basicScale.fromValue = [NSNumber numberWithFloat:0.0];
    basicScale.toValue = [NSNumber numberWithFloat:1.];
    basicScale.autoreverses = YES;
    basicScale.duration = duration/2;
    basicScale.fillMode = kCAFillModeForwards;
    basicScale.removedOnCompletion = NO;
    basicScale.beginTime = timeInterval+0.5;
    basicScale.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *basicOpa = [CABasicAnimation animationWithKeyPath:@"opacity"];
    basicOpa.fromValue = [NSNumber numberWithFloat:0.0];
    basicOpa.toValue = [NSNumber numberWithFloat:1.];
    basicOpa.autoreverses = YES;
    basicOpa.duration = duration/2;
    basicOpa.fillMode = kCAFillModeForwards;
    basicOpa.removedOnCompletion = NO;
    basicOpa.beginTime = timeInterval+0.5;
    basicOpa.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(viewBounds.width/2, -image.size.height/2)];
    if (left) {
        [path addCurveToPoint:CGPointMake(viewBounds.width/2 , viewBounds.height + image.size.height/4) controlPoint1:CGPointMake(viewBounds.width/2, -image.size.height/2) controlPoint2:CGPointMake(-image.size.width/2, viewBounds.height/2)];
    } else {
        [path addCurveToPoint:CGPointMake(viewBounds.width/2, viewBounds.height + image.size.height/4) controlPoint1:CGPointMake(viewBounds.width/2, -image.size.height/2) controlPoint2:CGPointMake(viewBounds.width+image.size.width/2, viewBounds.height/2)];
    }
    
    CAKeyframeAnimation *keyPosi = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    keyPosi.path = path.CGPath;
    keyPosi.fillMode = kCAFillModeForwards;
    keyPosi.removedOnCompletion = NO;
    keyPosi.duration = duration;
    keyPosi.beginTime = timeInterval;
    keyPosi.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [layer addAnimation:basicScale forKey:@"scale"];
    [layer addAnimation:basicOpa forKey:@"opacity"];
    [layer addAnimation:keyPosi forKey:@"position"];
    
    int gap = 10;
    CALayer *layerReflection = [CALayer layer];
    layerReflection.bounds = CGRectMake(0, 0, layer.bounds.size.width, layer.bounds.size.height);
    layerReflection.position = CGPointMake(layer.bounds.size.width/2, -layer.bounds.size.height/2 - gap);
    UIImage *reflectionImage = [imageResult reflectionWithAlpha:0.5];
    layerReflection.contents = (id)[reflectionImage CGImage];
    [layer addSublayer:layerReflection];
    reflectionImage = nil;
    
    return layer;
}

- (CALayer *)createPhotoSpin360Layer:(CGSize)viewBounds photos:(NSMutableArray *)photos  startTime:(NSTimeInterval)timeInterval position:(CGPoint)position {
    UIImage *imageTemp = photos[0];
    CALayer *layerImage = [CALayer layer];
    layerImage.bounds = CGRectMake(0, 0, imageTemp.size.width, imageTemp.size.height);
    layerImage.position = position;
    layerImage.cornerRadius = imageTemp.size.width/2;
    layerImage.borderWidth = 2.0;
    layerImage.borderColor = [UIColor colorWithRed:155/255.0f green:188/255.0f blue:220/255.0f alpha:1].CGColor;
    layerImage.masksToBounds = YES;
    
    CGFloat duration = 3.0;
    int repeatCount = 15;
    CAKeyframeAnimation *animTransform = [CAKeyframeAnimation animation];
    animTransform.values = [NSArray arrayWithObjects:
                            [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0, 0,1,0)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeRotation(3.13, 0,1,0)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeRotation(3.13, 0,1,0)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeRotation(6.26, 0,1,0)],
                            nil];
    animTransform.cumulative = YES;
    animTransform.duration = duration;
    animTransform.repeatCount = repeatCount;
    animTransform.removedOnCompletion = NO;
    animTransform.beginTime = timeInterval;
    animTransform.timingFunctions =
    [NSArray arrayWithObjects:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
     nil
     ];
    
    NSMutableArray *animPhotos = [NSMutableArray arrayWithCapacity:15];
    for (UIImage *image in photos) {
        [animPhotos addObject:(id)[image CGImage]];
    }
    layerImage.contents = (id)animPhotos[0];
    
    CGFloat interval = animTransform.beginTime;
    CAKeyframeAnimation *animContents = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    animContents.duration = duration*2;
    animContents.values = [NSArray arrayWithArray:animPhotos];
    animContents.beginTime = interval;
    animContents.repeatCount = repeatCount;
    animContents.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [layerImage addAnimation:animTransform forKey:@"transform"];
    [layerImage addAnimation:animContents forKey:@"contents"];
    
    [animPhotos removeAllObjects];
    animPhotos = nil;
    
    return layerImage;
}

- (CALayer *)createPhotoCarouselLayer:(CGSize)viewBounds image:(UIImage *)image startTime:(NSTimeInterval)timeInterval xAxis:(CGFloat)xAxis curWhich:(int)curWhich {
    CALayer *layer = [CALayer layer];
    layer.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    layer.position = CGPointMake(-image.size.width, viewBounds.height/2);
    layer.geometryFlipped = YES;
    
    [[XKCurledViewHelper sharedInstance] setImage:image forLayer:layer];
    
    CATransform3D finalTransform = [XKAnimationHelper tranformToBox:1 + curWhich];
    layer.transform = finalTransform;
    
    CGFloat duration = 5.0;
    CGPoint startPoint = CGPointMake(viewBounds.width + image.size.width / 2, viewBounds.height / 2);
    CGPoint endPoint = layer.position;
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.fromValue = @0.5f;
    fadeInAnimation.toValue = @1.0f;
    fadeInAnimation.additive = NO;
    fadeInAnimation.removedOnCompletion = NO;
    fadeInAnimation.beginTime = timeInterval;
    fadeInAnimation.duration = duration;
    fadeInAnimation.repeatCount = 3;
    fadeInAnimation.autoreverses = YES;
    fadeInAnimation.fillMode = kCAFillModeBoth;
    
    CABasicAnimation *moveInAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    [moveInAnimation setFromValue:[NSValue valueWithCGPoint:startPoint]];
    [moveInAnimation setToValue:[NSValue valueWithCGPoint:endPoint]];
    [moveInAnimation setDuration:duration];
    moveInAnimation.autoreverses = YES;
    moveInAnimation.repeatCount = 3;
    moveInAnimation.beginTime = timeInterval;
    moveInAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [layer addAnimation:fadeInAnimation forKey:@"opacity"];
    [layer addAnimation:moveInAnimation forKey:@"position"];
    
    return layer;
}

- (CAEmitterLayer *)makeEmitterAtPoint:(CGSize)viewBounds {
    CAEmitterLayer *emitterLayer = [CAEmitterLayer layer];
    emitterLayer.name = @"starLayer";
    emitterLayer.emitterPosition = CGPointMake(30, 10);
    emitterLayer.emitterZPosition = -43;
    emitterLayer.emitterSize = CGSizeMake(viewBounds.width, 10);
    emitterLayer.emitterDepth = 0.00;
    emitterLayer.emitterShape = kCAEmitterLayerCircle;
    emitterLayer.emitterMode = kCAEmitterLayerSurface;
    emitterLayer.renderMode = kCAEmitterLayerBackToFront;
    emitterLayer.seed = 721963909;
    
    return emitterLayer;
}

- (CAEmitterCell *) makeEmitterCellWithParticle:(NSString *)name {
    CAEmitterCell *emitterCell = [CAEmitterCell emitterCell];
    
    emitterCell.name = @"star";
    emitterCell.enabled = YES;
    
    emitterCell.contents = (id)[[UIImage imageNamed:name] CGImage];
    emitterCell.contentsRect = CGRectMake(0.00, 0.00, 1.00, 1.00);
    
    emitterCell.magnificationFilter = kCAFilterTrilinear;
    emitterCell.minificationFilter = kCAFilterLinear;
    emitterCell.minificationFilterBias = 0.00;
    
    emitterCell.scale = 0.72;
    emitterCell.scaleRange = 0.14;
    emitterCell.scaleSpeed = -0.25;
    
    emitterCell.color = [[UIColor colorWithRed:0.77 green:0.55 blue:0.60 alpha:0.55] CGColor];
    emitterCell.redRange = 0.9;
    emitterCell.greenRange = 0.8;
    emitterCell.blueRange = 0.7;
    emitterCell.alphaRange = 0.8;
    
    emitterCell.redSpeed = 0.92;
    emitterCell.greenSpeed = 0.84;
    emitterCell.blueSpeed = 0.74;
    emitterCell.alphaSpeed = 0.55;
    
    emitterCell.lifetime = 9.0;
    emitterCell.lifetimeRange = 2.37;
    emitterCell.birthRate = 0;
    emitterCell.velocity = -20.00;
    emitterCell.velocityRange = 2.00;
    emitterCell.xAcceleration = 1.00;
    emitterCell.yAcceleration = 10.00;
    emitterCell.zAcceleration = 12.00;
    
    emitterCell.spin = 0.384;
    emitterCell.spinRange = 0.925;
    emitterCell.emissionLatitude = 1.745;
    emitterCell.emissionLongitude = 1.745;
    emitterCell.emissionRange = 3.491;
    
    return emitterCell;
}

- (CAEmitterCell *)productEmitterCellWithContents:(id)contents {
    CAEmitterCell *cell = [CAEmitterCell emitterCell];
    cell.birthRate = 100;
    cell.lifetime = 1;
    cell.lifetimeRange = 0.5;
    cell.contents = contents;
    cell.color = [[UIColor whiteColor] CGColor];
    cell.velocity = 60;
    cell.emissionLongitude = M_PI * 2;
    cell.emissionRange = M_PI * 2;
    cell.velocityRange = 10;
    cell.spin = 10;
    
    return cell;
}

- (CAEmitterCell *)createRainLayer:(UIImage *)image {
    CAEmitterCell *cellLayer = [CAEmitterCell emitterCell];
    
    cellLayer.birthRate = 100.0;
    cellLayer.lifetime = 5;
    
    cellLayer.velocity = 1000;
    cellLayer.velocityRange = 0;
    
    cellLayer.scale = 0.2;
    cellLayer.contents = (id)[image CGImage];
    
    cellLayer.color = [[UIColor grayColor] CGColor];
    cellLayer.emissionLongitude = 0.1 * M_PI;
    cellLayer.spin = 0.1 * M_PI;
    
    return cellLayer;
}

- (CAEmitterCell *)createBirthdayLayer:(UIImage *)image {
    CAEmitterCell *cellLayer = [CAEmitterCell emitterCell];
    
    cellLayer.birthRate = 3.0;
    cellLayer.lifetime = 20;
    
    cellLayer.velocity = -100;
    cellLayer.velocityRange = 0;
    cellLayer.yAcceleration = 2;
    cellLayer.emissionRange = 0.5 * M_PI;
    cellLayer.scale = 1.3;
    cellLayer.contents = (id)[image CGImage];
    
    cellLayer.color = [[UIColor whiteColor] CGColor];
    
    return cellLayer;
}

- (CAEmitterCell *)sparkCell {
    CAEmitterCell *spark = [CAEmitterCell emitterCell];
    spark.contents = (id)[[UIImage imageNamed:@"spark"] CGImage];
    spark.birthRate = 3;
    spark.lifetime = 3;
    spark.scale = 0.1;
    spark.scaleRange = 0.2;
    spark.emissionRange = 2 * M_PI;
    spark.velocity = 60;
    spark.velocityRange = 8;
    spark.yAcceleration = -200;
    spark.alphaRange = 0.5;
    spark.alphaSpeed = -1;
    spark.spin = 1;
    spark.spinRange = 6;
    spark.alphaRange = 0.8;
    spark.redRange = 2;
    spark.greenRange = 1;
    spark.blueRange = 1;
    [spark setName:@"SparkCell"];
    return spark;
}

- (CAEmitterCell *)smokeCell {
    CAEmitterCell *smoke = [CAEmitterCell emitterCell];
    smoke.contents = (id)[[UIImage imageNamed:@"smoke"] CGImage];
    smoke.birthRate = 3;
    smoke.lifetime = 3;
    smoke.scale = 0.1;
    smoke.scaleSpeed = 1;
    smoke.alphaRange = 0.5;
    smoke.alphaSpeed = -0.7;
    smoke.spin = 1;
    smoke.spinRange = 0.8;
    smoke.blueRange = 0.3;
    smoke.velocity = 10;
    smoke.yAcceleration = 100;
    [smoke setName:@"SmokeCell"];
    
    return smoke;
}

- (void)doAnimation:(CAShapeLayer *)textShapeLayer emitterLayer:(CAEmitterLayer *)emitterLayer startTime:(NSTimeInterval)timeInterval {
    NSTimeInterval duration = 5;
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @0.8;
    alphaAnimation.toValue = @1;
    alphaAnimation.duration = duration*2;
    alphaAnimation.beginTime = timeInterval;
    
    CABasicAnimation *stroke = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    stroke.duration = duration;
    stroke.fromValue = [NSNumber numberWithFloat:0.1];
    stroke.toValue = [NSNumber numberWithFloat:1];
    stroke.removedOnCompletion = NO;
    stroke.beginTime = timeInterval;
    
    [textShapeLayer addAnimation:alphaAnimation forKey:@"opacity"];
    [textShapeLayer addAnimation:stroke forKey:@"StrokeAnimation"];
    
    emitterLayer.birthRate = 1;
    
    CAKeyframeAnimation *sparkle = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    sparkle.path = textShapeLayer.path;
    sparkle.fillMode = kCAAnimationPaced;
    sparkle.duration = duration;
    sparkle.removedOnCompletion = NO;
    sparkle.beginTime = timeInterval;
    [emitterLayer addAnimation:sparkle forKey:@"EmitterAnimation"];
}

- (CAEmitterCell *) createBlackWhiteDots:(BOOL)isBlack {
    CAEmitterCell* Dots = [CAEmitterCell emitterCell];
    Dots.birthRate = 10;
    Dots.lifetime = 0.5;
    Dots.scale = 0.3;
    Dots.scaleRange = 0.3;
    Dots.scaleSpeed = -0.25;
    
    Dots.spin = 0.384;
    Dots.spinRange = 0.925;
    Dots.emissionLatitude = 1.745;
    Dots.emissionLongitude = 1.745;
    Dots.emissionRange = 3.491;
    
    UIImage *image = [UIImage imageNamed:@"dot"];
    if (isBlack) {
        Dots.color = [[UIColor blackColor] CGColor];
    } else {
        Dots.color = [[UIColor whiteColor] CGColor];
    }
    Dots.contents = (id)[image CGImage];
    Dots.contentsRect = CGRectMake(0.00, 0.00, 1.00, 1.00);
    Dots.magnificationFilter = kCAFilterTrilinear;
    Dots.minificationFilter = kCAFilterLinear;
    
    return Dots;
}

@end
