//
//  UIImage+XK.m
//  XKMusicAlbum
//
//  Created by 浪漫恋星空 on 2018/8/17.
//  Copyright © 2018年 浪漫恋星空. All rights reserved.
//

#import "UIImage+XK.h"

#ifndef UIImageReflectionMethods
#define UIImageReflectionMethods

CGImageRef CreateGradientImage (int pixelsWide, int pixelsHigh, CGFloat endPoint) {
    CGImageRef theCGImage = NULL;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef gradientBitmapContext = CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh,
                                                               8, 0, colorSpace, kCGImageAlphaNone);
    
    CGFloat colors[] = {0.0, 1.0, 1, 1.0};
    
    CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
    CGColorSpaceRelease(colorSpace);
    
    CGPoint gradientStartPoint = CGPointZero;
    CGPoint gradientEndPoint = CGPointMake(0, endPoint);
    
    if (endPoint < 0) {
        gradientEndPoint = CGPointMake(0, -endPoint);
    }
    
    CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint,
                                gradientEndPoint, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(grayScaleGradient);
    
    theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
    
    if (endPoint < 0) {
        CGContextClearRect(gradientBitmapContext, CGRectMake(0, 0, pixelsWide, pixelsHigh));
        CGContextTranslateCTM(gradientBitmapContext, 0.0, pixelsHigh);
        CGContextScaleCTM(gradientBitmapContext, 1.0, -1.0);
        CGContextDrawImage(gradientBitmapContext, CGRectMake(0, 0, pixelsWide, pixelsHigh), theCGImage);
        CGImageRelease(theCGImage);
        theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
    }
    
    CGContextRelease(gradientBitmapContext);
    
    return theCGImage;
}

static CGContextRef MyCreateBitmapContext (int pixelsWide, int pixelsHigh) {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef bitmapContext = CGBitmapContextCreate (NULL, pixelsWide, pixelsHigh, 8,
                                                        0, colorSpace,
                                                        (kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
    CGColorSpaceRelease(colorSpace);
    
    return bitmapContext;
}

#endif

@implementation UIImage (XK)

- (UIImage *)reflectionRotatedWithAlpha:(float)pcnt {
    int height = self.size.height;
    UIImage * fromImage = self;
    pcnt = 1.0 / pcnt;
    
    CGContextRef mainViewContentContext = MyCreateBitmapContext(fromImage.size.width, height);
    
    CGImageRef gradientMaskImage = CreateGradientImage(1, height, -(height * pcnt));
    
    CGContextClipToMask(mainViewContentContext, CGRectMake(0.0, 0.0, fromImage.size.width, height), gradientMaskImage);
    CGImageRelease(gradientMaskImage);
    
    CGContextDrawImage(mainViewContentContext, CGRectMake(0, 0, fromImage.size.width, fromImage.size.height), [fromImage CGImage]);
    
    CGImageRef reflectionImage = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);
    
    UIImage * theImage = [UIImage imageWithCGImage:reflectionImage];
    CGImageRelease(reflectionImage);
    
    return theImage;
}

- (UIImage *)reflectionWithHeight:(int)height {
    if (height == -1) {
        height = [self size].height;
    }
    
    if (height == 0) {
        return nil;
    }
    
    UIImage * fromImage = self;
    
    CGContextRef mainViewContentContext = MyCreateBitmapContext(fromImage.size.width, fromImage.size.height);
    CGImageRef gradientMaskImage = CreateGradientImage(1, height, height);
    
    CGContextClipToMask(mainViewContentContext, CGRectMake(0.0, 0.0, fromImage.size.width, height), gradientMaskImage);
    CGImageRelease(gradientMaskImage);
    
    CGContextTranslateCTM(mainViewContentContext, 0.0, fromImage.size.height);
    CGContextScaleCTM(mainViewContentContext, 1.0, -1.0);
    
    CGContextDrawImage(mainViewContentContext, CGRectMake(0, 0, fromImage.size.width, fromImage.size.height), [fromImage CGImage]);
    
    CGImageRef reflectionImage = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);
    
    UIImage * theImage = [UIImage imageWithCGImage:reflectionImage];
    
    CGImageRelease(reflectionImage);
    
    return theImage;
}

- (UIImage *)reflectionWithAlpha:(float)pcnt {
    int height = self.size.height;
    UIImage * fromImage = self;
    pcnt = 1.0 / pcnt;
    
    CGContextRef mainViewContentContext = MyCreateBitmapContext(fromImage.size.width, height);
    CGImageRef gradientMaskImage = CreateGradientImage(1, height, height * pcnt);
    
    CGContextClipToMask(mainViewContentContext, CGRectMake(0.0, 0.0, fromImage.size.width, height), gradientMaskImage);
    CGImageRelease(gradientMaskImage);
    
    CGContextTranslateCTM(mainViewContentContext, 0.0, height);
    CGContextScaleCTM(mainViewContentContext, 1.0, -1.0);
    
    CGContextDrawImage(mainViewContentContext, CGRectMake(0, 0, fromImage.size.width, fromImage.size.height), [fromImage CGImage]);
    
    CGImageRef reflectionImage = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);
    
    UIImage * theImage = [UIImage imageWithCGImage:reflectionImage];
    CGImageRelease(reflectionImage);
    
    return theImage;
}

@end
