//
//  XKVideoThemesData.m
//  XKMusicAlbum
//
//  Created by 浪漫恋星空 on 2018/8/17.
//  Copyright © 2018年 浪漫恋星空. All rights reserved.
//

#import "XKVideoThemesData.h"

@interface XKVideoThemesData ()

@property (nonatomic, strong) NSMutableDictionary *themesDict;

@end

@implementation XKVideoThemesData

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static XKVideoThemesData *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[XKVideoThemesData alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self initThemesData];
    }
    return self;
}

- (XKVideoTheme *)createThemeButterfly {
    XKVideoTheme *theme = [[XKVideoTheme alloc] init];
    theme.ID = XKThemesTypeButterfly;
    theme.thumbImageName = @"themeButterfly";
    theme.name = @"Butterfly";
    theme.textStar = @"butterfly";
    theme.textSparkle = @"beautifully";
    theme.bgMusicFile = @"1.mp3";
    theme.bgVideoFile = @"bgVideo01.mov";
    theme.animationActions = @[[NSNumber numberWithInt:XKAnimationActionTypeStar], [NSNumber numberWithInt:XKAnimationActionTypePhotoLinearScroll], [NSNumber numberWithInt:XKAnimationActionTypePhotoCentringShow], [NSNumber numberWithInt:XKAnimationActionTypeTextSparkle]];
    return theme;
}

- (XKVideoTheme *)createThemeLeaf {
    XKVideoTheme *theme = [[XKVideoTheme alloc] init];
    theme.ID = XKThemesTypeLeaf;
    theme.thumbImageName = @"themeLeaf";
    theme.name = @"Leaf";
    theme.textStar = nil;
    theme.textSparkle = nil;
    theme.textGradient = nil;
    theme.bgMusicFile = @"2.mp3";
    theme.imageFile = nil;
    theme.scrollText = nil;
    theme.bgVideoFile = @"bgVideo02.m4v";
    theme.animationActions = @[[NSNumber numberWithInt:XKAnimationActionTypeMeteor], [NSNumber numberWithInt:XKAnimationActionTypePhotoDrop]];
    return theme;
}

- (XKVideoTheme *)createThemeStarshine {
    XKVideoTheme *theme = [[XKVideoTheme alloc] init];
    theme.ID = XKThemesTypeStarshine;
    theme.thumbImageName = @"themeStarshine";
    theme.name = @"Star";
    theme.textStar = nil;
    theme.textSparkle = nil;
    theme.textGradient = nil;
    theme.bgMusicFile = @"3.mp3";
    theme.imageFile = nil;
    theme.scrollText = nil;
    theme.bgVideoFile = @"bgVideo03.m4v";
    theme.animationActions = @[[NSNumber numberWithInt:XKAnimationActionTypePhotoParabola], [NSNumber numberWithInt:XKAnimationActionTypeMoveDot]];
    return theme;
}

- (XKVideoTheme *)createThemeFlare {
    XKVideoTheme *theme = [[XKVideoTheme alloc] init];
    theme.ID = XKThemesTypeFlare;
    theme.thumbImageName = @"themeFlare";
    theme.name = @"Flare";
    theme.textStar = nil;
    theme.textSparkle = nil;
    theme.textGradient = nil;
    theme.bgMusicFile = @"4.mp3";
    theme.imageFile = nil;
    theme.scrollText = nil;
    theme.bgVideoFile = @"bgVideo04.mov";
    theme.animationActions = @[[NSNumber numberWithInt:XKAnimationActionTypePhotoFlare], [NSNumber numberWithInt:XKAnimationActionTypeSky]];
    return theme;
}

- (XKVideoTheme *)createThemeFruit {
    XKVideoTheme *theme = [[XKVideoTheme alloc] init];
    theme.ID = XKThemesTypeFruit;
    theme.thumbImageName = @"themeFruit";
    theme.name = @"Fruit";
    theme.textStar = nil;
    theme.textSparkle = nil;
    theme.textGradient = nil;
    theme.bgMusicFile = @"5.mp3";
    theme.imageFile = nil;
    theme.scrollText = nil;
    theme.bgVideoFile = @"bgVideo05.mov";
    theme.animationActions = @[[NSNumber numberWithInt:XKAnimationActionTypePhotoEmitter]];
    return theme;
}

- (XKVideoTheme *)createThemeCartoon {
    XKVideoTheme *theme = [[XKVideoTheme alloc] init];
    theme.ID = XKThemesTypeCartoon;
    theme.thumbImageName = @"themeCartoon";
    theme.name = @"Cartoon";
    theme.textStar = nil;
    theme.textSparkle = nil;
    theme.textGradient = nil;
    theme.bgMusicFile = @"6.mp3";
    theme.imageFile = nil;
    theme.scrollText = nil;
    theme.bgVideoFile = @"bgVideo06.mov";
    theme.animationActions = @[[NSNumber numberWithInt:XKAnimationActionTypePhotoExplode], [NSNumber numberWithInt:XKAnimationActionTypePhotoSpin360]];
    return theme;
}

- (XKVideoTheme *)createThemeScience {
    XKVideoTheme *theme = [[XKVideoTheme alloc] init];
    theme.ID = XKThemesTypeScience;
    theme.thumbImageName = @"themeScience";
    theme.name = @"Science";
    theme.textStar = nil;
    theme.textSparkle = nil;
    theme.textGradient = nil;
    theme.bgMusicFile = @"7.mp3";
    theme.imageFile = nil;
    theme.scrollText = nil;
    theme.bgVideoFile = @"bgVideo07.mov";
    theme.animationActions = @[[NSNumber numberWithInt:XKAnimationActionTypePhotoExplodeDrop], [NSNumber numberWithInt:XKAnimationActionTypePhotoCentringShow]];
    return theme;
}

- (XKVideoTheme *)createThemeCloud {
    XKVideoTheme *theme = [[XKVideoTheme alloc] init];
    theme.ID = XKThemesTypeCloud;
    theme.thumbImageName = @"themeCloud";
    theme.name = @"Cloud";
    theme.textStar = nil;
    theme.textSparkle = nil;
    theme.textGradient = nil;
    theme.bgMusicFile = @"8.mp3";
    theme.imageFile = nil;
    theme.scrollText = nil;
    theme.bgVideoFile = @"bgVideo08.mov";
    theme.animationActions = @[[NSNumber numberWithInt:XKAnimationActionTypePhotoCloud], [NSNumber numberWithInt:XKAnimationActionTypePhotoCentringShow]];
    return theme;
}

- (void)initThemesData {
    XKVideoTheme *theme = nil;
    for (int i = XKThemesTypeNone; i <= XKThemesTypeCloud; i ++) {
        switch (i) {
            case XKThemesTypeNone:
                break;
            case XKThemesTypeFruit:
                theme = [self createThemeFruit];
                break;
            case XKThemesTypeCartoon:
                theme = [self createThemeCartoon];
                break;
            case XKThemesTypeFlare:
                theme = [self createThemeFlare];
                break;
            case XKThemesTypeStarshine:
                theme = [self createThemeStarshine];
                break;
            case XKThemesTypeScience:
                theme = [self createThemeScience];
                break;
            case XKThemesTypeLeaf:
                theme = [self createThemeLeaf];
                break;
            case XKThemesTypeButterfly:
                theme = [self createThemeButterfly];
                break;
            case XKThemesTypeCloud:
                theme = [self createThemeCloud];
                break;
        }
        if (i == XKThemesTypeNone) {
            [self.themesDict setObject:[NSNull null] forKey:[NSNumber numberWithInt:XKThemesTypeNone]];
        } else {
            [self.themesDict setObject:theme forKey:[NSNumber numberWithInt:i]];
        }
    }
}

- (NSMutableDictionary *)fetchThemeData {
    return self.themesDict;
}

- (NSMutableDictionary *)themesDict {
    if (!_themesDict) {
        _themesDict = @{}.mutableCopy;
    }
    return _themesDict;
}

@end
