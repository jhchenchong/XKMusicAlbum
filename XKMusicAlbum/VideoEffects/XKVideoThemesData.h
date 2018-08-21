//
//  XKVideoThemesData.h
//  XKMusicAlbum
//
//  Created by 浪漫恋星空 on 2018/8/17.
//  Copyright © 2018年 浪漫恋星空. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XKVideoTheme.h"

typedef NS_ENUM(NSUInteger, XKAnimationActionType) {
    XKAnimationActionTypeFireworks,
    XKAnimationActionTypeSnow,
    XKAnimationActionTypeSnow2,
    XKAnimationActionTypeHeart,
    XKAnimationActionTypeRing,
    XKAnimationActionTypeStar,
    XKAnimationActionTypeMoveDot,
    XKAnimationActionTypeSky,
    XKAnimationActionTypeMeteor,
    XKAnimationActionTypeRain,
    XKAnimationActionTypeFlower,
    XKAnimationActionTypeFire,
    XKAnimationActionTypeSmoke,
    XKAnimationActionTypeSpark,
    XKAnimationActionTypeSteam,
    XKAnimationActionTypeBirthday,
    XKAnimationActionTypeBlackWhiteDot,
    XKAnimationActionTypeScrollScreen,
    XKAnimationActionTypeSpotlight,
    XKAnimationActionTypeScrollLine,
    XKAnimationActionTypeRipple,
    XKAnimationActionTypeImage,
    XKAnimationActionTypeImageArray,
    XKAnimationActionTypeVideoFrame,
    XKAnimationActionTypeTextStar,
    XKAnimationActionTypeTextSparkle,
    XKAnimationActionTypeTextScroll,
    XKAnimationActionTypeTextGradient,
    XKAnimationActionTypeFlashScreen,
    XKAnimationActionTypePhotoLinearScroll,
    XKAnimationActionTypePhotoCentringShow,
    XKAnimationActionTypePhotoDrop,
    XKAnimationActionTypePhotoParabola,
    XKAnimationActionTypePhotoFlare,
    XKAnimationActionTypePhotoEmitter,
    XKAnimationActionTypePhotoExplode,
    XKAnimationActionTypePhotoExplodeDrop,
    XKAnimationActionTypePhotoCloud,
    XKAnimationActionTypePhotoSpin360,
    XKAnimationActionTypePhotoCarousel
};

typedef NS_ENUM(NSUInteger, XKThemesType) {
    XKThemesTypeNone,
    XKThemesTypeFruit,
    XKThemesTypeCartoon,
    XKThemesTypeFlare,
    XKThemesTypeStarshine,
    XKThemesTypeScience,
    XKThemesTypeLeaf,
    XKThemesTypeButterfly,
    XKThemesTypeCloud,
};

@interface XKVideoThemesData : NSObject

+ (instancetype)sharedInstance;
- (NSMutableDictionary *)fetchThemeData;

@end
