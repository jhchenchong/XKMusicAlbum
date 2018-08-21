//
//  XKVideoEffects.h
//  XKMusicAlbum
//
//  Created by 浪漫恋星空 on 2018/8/17.
//  Copyright © 2018年 浪漫恋星空. All rights reserved.
//

#import "XKVideoThemesData.h"
#import <UIKit/UIKit.h>

@protocol XKVideoEffectsDelegate <NSObject>

@optional

- (void)exportMP4SessionStatusCompleted;
- (void)exportMP4SessionStatusFailed;
- (void)retrievingProgressMP4:(CGFloat)progress;

@end

@interface XKVideoEffects : NSObject

@property (nonatomic, weak) id<XKVideoEffectsDelegate> delegate;
@property (nonatomic, assign) XKThemesType currentThemeType;

- (void)imagesToVideo:(NSMutableArray *)photos exportVideoFile:(NSString *)exportVideoFile highestQuality:(BOOL)highestQuality;

@end
