//
//  XKCurledViewHelper.m
//  XKMusicAlbum
//
//  Created by 浪漫恋星空 on 2018/8/16.
//  Copyright © 2018年 浪漫恋星空. All rights reserved.
//

#import "XKCurledViewHelper.h"

@implementation XKCurledViewHelper

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static XKCurledViewHelper *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[XKCurledViewHelper alloc] init];
    });
    return instance;
}

+ (UIImage *)rescaleImage:(UIImage *)image forLayer:(CALayer *)layer {
    UIImage* scaledImage = image;
    CGFloat borderWidth = layer.borderWidth;
    if (borderWidth > 0) {
        CGRect imageRect = CGRectMake(0.0, 0.0, layer.bounds.size.width - 2 * borderWidth, layer.bounds.size.height - 2 * borderWidth);
        if (image.size.width > imageRect.size.width || image.size.height > imageRect.size.height) {
            UIGraphicsBeginImageContext(imageRect.size);
            [image drawInRect:imageRect];
            scaledImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }
    return scaledImage;
}


+ (UIBezierPath *)curlShadowPathWithShadowDepth:(CGFloat)shadowDepth
                            controlPointXOffset:(CGFloat)controlPointXOffset
                            controlPointYOffset:(CGFloat)controlPointYOffset
                                       forLayer:(CALayer *)layer {
    CGSize viewSize = [layer bounds].size;
    CGPoint polyTopLeft = CGPointMake(0.0, controlPointYOffset);
    CGPoint polyTopRight = CGPointMake(viewSize.width, controlPointYOffset);
    CGPoint polyBottomLeft = CGPointMake(0.0, viewSize.height + shadowDepth);
    CGPoint polyBottomRight = CGPointMake(viewSize.width, viewSize.height +  shadowDepth);
    
    CGPoint controlPointLeft = CGPointMake(controlPointXOffset , controlPointYOffset);
    CGPoint controlPointRight = CGPointMake(viewSize.width - controlPointXOffset,  controlPointYOffset);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:polyTopLeft];
    [path addLineToPoint:polyTopRight];
    [path addLineToPoint:polyBottomRight];
    [path addCurveToPoint:polyBottomLeft
            controlPoint1:controlPointRight
            controlPoint2:controlPointLeft];
    
    [path closePath];
    
    return path;
}

- (void)configureBorder:(CGFloat)borderWidth
            shadowDepth:(CGFloat)shadowDepth
    controlPointXOffset:(CGFloat)controlPointXOffset
    controlPointYOffset:(CGFloat)controlPointYOffset
               forLayer:(CALayer *)layer {
    [layer setBorderWidth:borderWidth];
    [layer setBorderColor:[UIColor whiteColor].CGColor];
    [layer setShadowColor:[UIColor blackColor].CGColor];
    [layer setShadowOffset:CGSizeMake(0.0, 4.0)];
    [layer setShadowRadius:3.0];
    [layer setShadowOpacity:0.4];
    
    UIBezierPath *path = [XKCurledViewHelper curlShadowPathWithShadowDepth:shadowDepth controlPointXOffset:controlPointXOffset controlPointYOffset:controlPointYOffset forLayer:layer];
    [layer setShadowPath:path.CGPath];
}

- (UIImage *)setImage:(UIImage *)image forLayer:(CALayer *)layer {
    return [self setImage:image
              borderWidth:5.0
              shadowDepth:10.0
      controlPointXOffset:30.0
      controlPointYOffset:70.0
                 forLayer:layer];
}

- (UIImage *)setImage:(UIImage*)image
          borderWidth:(CGFloat)borderWidth
          shadowDepth:(CGFloat)shadowDepth
  controlPointXOffset:(CGFloat)controlPointXOffset
  controlPointYOffset:(CGFloat)controlPointYOffset
             forLayer:(CALayer *)layer {
    layer.backgroundColor = (__bridge CGColorRef)([UIColor lightGrayColor]);
    [self configureBorder:borderWidth
              shadowDepth:shadowDepth
      controlPointXOffset:controlPointXOffset
      controlPointYOffset:controlPointYOffset
                 forLayer:layer];
    
    UIImage *scaledImage = [XKCurledViewHelper rescaleImage:image forLayer:layer];
    layer.contents = (id)[scaledImage CGImage];
    return scaledImage;
}

@end
