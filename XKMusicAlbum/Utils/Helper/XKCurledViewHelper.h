//
//  XKCurledViewHelper.h
//  XKMusicAlbum
//
//  Created by 浪漫恋星空 on 2018/8/16.
//  Copyright © 2018年 浪漫恋星空. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XKCurledViewHelper : NSObject

+ (instancetype)sharedInstance;

+ (UIImage *)rescaleImage:(UIImage *)image forLayer:(CALayer *)layer;
+ (UIBezierPath *)curlShadowPathWithShadowDepth:(CGFloat)shadowDepth
                            controlPointXOffset:(CGFloat)controlPointXOffset
                            controlPointYOffset:(CGFloat)controlPointYOffset
                                       forLayer:(CALayer*)layer;
- (UIImage *)setImage:(UIImage *)image forLayer:(CALayer *)layer;

@end
