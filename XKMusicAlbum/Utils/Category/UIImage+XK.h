//
//  UIImage+XK.h
//  XKMusicAlbum
//
//  Created by 浪漫恋星空 on 2018/8/17.
//  Copyright © 2018年 浪漫恋星空. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (XK)

- (UIImage *)reflectionWithHeight:(int)height;
- (UIImage *)reflectionWithAlpha:(float)pcnt;
- (UIImage *)reflectionRotatedWithAlpha:(float)pcnt;

@end
