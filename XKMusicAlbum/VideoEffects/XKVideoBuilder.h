//
//  XKVideoBuilder.h
//  XKMusicAlbum
//
//  Created by 浪漫恋星空 on 2018/8/16.
//  Copyright © 2018年 浪漫恋星空. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CMTime.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

typedef NS_ENUM(NSUInteger, XKEffectDirection) {
    XKEffectDirectionLeftToRight,
    XKEffectDirectionRightToLeft,
    XKEffectDirectionTopToBottom,
    XKEffectDirectionBottomToTop,
    XKEffectDirectionTopLeftToBottomRight,
    XKEffectDirectionBottomRightToTopLeft,
    XKEffectDirectionBottomLeftToTopRight,
    XKEffectDirectionTopRightToBottomLeft
};

typedef NS_ENUM(NSUInteger, XKVideoBuilderTransitionType) {
    XKVideoBuilderTransitionTypeNone,
    XKVideoBuilderTransitionTypeCrossFade,
    XKVideoBuilderTransitionTypePush
};

@interface XKVideoBuilder : NSObject<CAAnimationDelegate>

@property (nonatomic, strong) AVURLAsset *commentary;

- (CALayer *)buildAnimatedPhotoCarousel:(CGSize)viewBounds photos:(NSMutableArray *)photos startTime:(NSTimeInterval)startTime;//1
- (CALayer *)buildAnimatedPhotoSpin360:(CGSize)viewBounds photos:(NSMutableArray *)photos startTime:(NSTimeInterval)startTime;//2
- (CALayer *)buildAnimatedPhotoCloud:(CGSize)viewBounds photos:(NSMutableArray *)photos startTime:(NSTimeInterval)startTime;//3
- (CALayer *)buildAnimatedPhotoExplodeDrop:(CGSize)viewBounds photos:(NSMutableArray *)photos startTime:(NSTimeInterval)startTime;//4
- (CALayer *)buildAnimatedPhotoExplode:(CGSize)viewBounds photos:(NSMutableArray *)photos startTime:(NSTimeInterval)startTime;//5
- (CALayer *)buildAnimationPhotoEmitter:(CGSize)viewBounds photos:(NSMutableArray *)photos startTime:(NSTimeInterval)startTime;//6
- (CALayer *)buildAnimatedPhotoFlare:(CGSize)viewBounds photos:(NSMutableArray *)photos startTime:(NSTimeInterval)startTime;//7
- (CALayer *)buildAnimatedPhotoParabola:(CGSize)viewBounds photos:(NSMutableArray *)photos startTime:(NSTimeInterval)startTime;//8
- (CALayer *)buildAnimatedPhotoDrop:(CGSize)viewBounds photos:(NSMutableArray *)photos startTime:(NSTimeInterval)startTime;//9
- (CALayer *)buildAnimatedPhotoCentringShow:(CGSize)viewBounds photos:(NSMutableArray *)photos startTime:(NSTimeInterval)startTime;//10
- (CALayer *)buildAnimatedPhotoLinearScroll:(CGSize)viewBounds photos:(NSMutableArray *)photos startTime:(NSTimeInterval)startTime;//11
- (CALayer *)buildAnimationFlashScreen:(CGSize)viewBounds startTime:(NSTimeInterval)timeInterval startOpacity:(BOOL)startOpacity;//
- (CALayer *)buildSpotlight:(CGSize)viewBounds startTime:(NSTimeInterval)startTime;//
- (CALayer *)buildGradientText:(CGSize)viewBounds positon:(CGPoint)postion text:(NSString *)text startTime:(NSTimeInterval)startTime;//
- (CAEmitterLayer *)buildEmitterSteam:(CGSize)viewBounds positon:(CGPoint)postion;//
- (CALayer *)buildAnimationRipple:(CGSize)viewBounds centerPoint:(CGPoint)centerPoint radius:(CGFloat)radius startTime:(NSTimeInterval)startTime;//
- (CALayer *)buildAnimatedScrollLine:(CGSize)viewBounds startTime:(CFTimeInterval)timeInterval lineHeight:(CGFloat)lineHeight image:(UIImage *)image;//
- (CALayer *)buildAnimatedScrollText:(CGSize)viewBounds text:(NSString *)text startPoint:(CGPoint)startPoint startTime:(NSTimeInterval)startTime;//
- (CALayer *)buildAnimationScrollScreen:(CGSize)viewBounds startTime:(NSTimeInterval)startTime;//
- (CALayer *)buildVideoFrameImage:(CGSize)viewBounds videoFile:(NSURL *)inputVideoURL startTime:(CMTime)startTime;//
- (CALayer *)buildAnimationImages:(CGSize)viewBounds imagesArray:(NSMutableArray *)imagesArray position:(CGPoint)position;//
- (CALayer *)buildImage:(CGSize)viewBounds image:(NSString *)imageFile position:(CGPoint)position;//
- (CAEmitterLayer *)buildEmitterRing:(CGSize)viewBounds startTime:(NSTimeInterval)startTime;//
- (CAEmitterLayer *)buildEmitterSnow:(CGSize)viewBounds startTime:(NSTimeInterval)startTime;//
- (CAEmitterLayer *)buildEmitterSnow2:(CGSize)viewBounds startTime:(NSTimeInterval)startTime;//
- (CAEmitterLayer *)buildEmitterHeart:(CGSize)viewBounds startTime:(NSTimeInterval)startTime;//
- (CAEmitterLayer *)buildEmitterFireworks:(CGSize)viewBounds startTime:(NSTimeInterval)startTime;//
- (CAEmitterLayer *)buildEmitterStar:(CGSize)viewBounds startTime:(NSTimeInterval)startTime;//
- (CAEmitterLayer *)buildEmitterMoveDot:(CGSize)viewBounds position:(CGPoint)position startTime:(NSTimeInterval)startTime;//
- (CAEmitterLayer *)buildEmitterBlackWhiteDot:(CGSize)viewBounds positon:(CGPoint)postion startTime:(NSTimeInterval)startTime;//
- (CAEmitterLayer *)buildEmitterSky:(CGSize)viewBounds startTime:(NSTimeInterval)startTime;//
- (CAEmitterLayer *)buildEmitterMeteor:(CGSize)viewBounds startTime:(NSTimeInterval)timeInterval pathN:(NSInteger)pathN;//
- (CAEmitterLayer *)buildEmitterRain:(CGSize)viewBounds;//
- (CAEmitterLayer *)buildEmitterFlower:(CGSize)viewBounds startTime:(NSTimeInterval)startTime;//
- (CAEmitterLayer *)buildEmitterBirthday:(CGSize)viewBounds;//
- (CAEmitterLayer *)buildEmitterFire:(CGSize)viewBounds position:(CGPoint)position;//
- (CAEmitterLayer *)buildEmitterSmoke:(CGSize)viewBounds position:(CGPoint)position;//
- (CAEmitterLayer *)buildEmitterSpark:(CGSize)viewBounds;//
- (CAShapeLayer *)buildEmitterSparkle:(CGSize)viewBounds text:(NSString *)text startTime:(NSTimeInterval)startTime;//
- (CALayer *)buildAnimationStarText:(CGSize)viewBounds text:(NSString *)text startTime:(NSTimeInterval)startTime;//

- (void)addCommentaryTrackToComposition:(AVMutableComposition *)composition withAudioMix:(AVMutableAudioMix *)audioMix;

@end
