//
//  XKVideoEffects.m
//  XKMusicAlbum
//
//  Created by 浪漫恋星空 on 2018/8/17.
//  Copyright © 2018年 浪漫恋星空. All rights reserved.
//

#import "XKVideoEffects.h"
#import "XKVideoBuilder.h"
#import "XKTimer.h"

@interface XKVideoEffects ()

@property (nonatomic, strong) XKVideoBuilder *videoBuilder;
@property (nonatomic, strong) NSMutableDictionary *themesDict;
@property (nonatomic, strong) AVAssetExportSession *exportSession;
@property (nonatomic, strong) XKTimer *timer;


@end

@implementation XKVideoEffects

- (instancetype)init {
    if (self = [super init]) {
        _currentThemeType = XKThemesTypeButterfly;
        _videoBuilder = [[XKVideoBuilder alloc] init];
        _themesDict = [[XKVideoThemesData sharedInstance] fetchThemeData];
    }
    return self;
}

- (void)imagesToVideo:(NSMutableArray *)photos exportVideoFile:(NSString *)exportVideoFile highestQuality:(BOOL)highestQuality {
    if (self.currentThemeType == XKThemesTypeNone) {
        return;
    }
    XKVideoTheme *currentTheme = [self.themesDict objectForKey:[NSNumber numberWithInt:self.currentThemeType]];
    [self buildVideoEffectsToMP4:exportVideoFile inputVideoFile:currentTheme.bgVideoFile photos:photos highestQuality:highestQuality];
}

- (BOOL)buildVideoEffectsToMP4:(NSString *)exportVideoFile inputVideoFile:(NSString *)inputVideoFile photos:(NSMutableArray *)photos highestQuality:(BOOL)highestQuality {
    if (!(inputVideoFile && inputVideoFile.length > 0) || !(exportVideoFile && exportVideoFile.length > 0) || (!photos || photos.count == 0)) {
        NSLog(@"Input filename or Output filename is invalied for convert to Mp4!");
        return NO;
    }
    NSString *fileName = [inputVideoFile stringByDeletingPathExtension];
    NSString *fileExt = [inputVideoFile pathExtension];
    NSURL *inputVideoURL = [[NSBundle mainBundle] URLForResource:fileName withExtension:fileExt];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:inputVideoURL options:nil];
    if (!asset || [asset tracksWithMediaType:AVMediaTypeVideo].count == 0) {
        return NO;
    }
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    NSArray *assetVideoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if (assetVideoTracks.count <= 0) {
        asset = [[AVURLAsset alloc] initWithURL:inputVideoURL options:nil];
        assetVideoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        if ([assetVideoTracks count] <= 0) {
            if (asset) {
                asset = nil;
            }
            return NO;
        }
    }
    AVAssetTrack *assetVideoTrack = [assetVideoTracks firstObject];
    [videoTrack insertTimeRange:assetVideoTrack.timeRange ofTrack:assetVideoTrack atTime:CMTimeMake(0, 1) error:nil];
    [videoTrack setPreferredTransform:assetVideoTrack.preferredTransform];
    if ([asset tracksWithMediaType:AVMediaTypeAudio].count > 0) {
        AVAssetTrack *assetAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        [audioTrack insertTimeRange:assetAudioTrack.timeRange ofTrack:assetAudioTrack atTime:CMTimeMake(0, 1) error:nil];
    } else {
        NSLog(@"Reminder: video hasn't audio!");
    }
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, assetVideoTrack.naturalSize.width, assetVideoTrack.naturalSize.height);
    videoLayer.frame = CGRectMake(0, 0, assetVideoTrack.naturalSize.width, assetVideoTrack.naturalSize.height);
    [parentLayer addSublayer:videoLayer];
    
    XKVideoTheme *currentTheme = [self.themesDict objectForKey:[NSNumber numberWithInt:self.currentThemeType]];
    NSMutableArray *animatedLayers = @[].mutableCopy;
    if (currentTheme && currentTheme.animationActions.count > 0) {
        for (NSNumber *animationAction in currentTheme.animationActions) {
            CALayer *animatedLayer = nil;
            switch (animationAction.integerValue) {
                case XKAnimationActionTypeFireworks: {
                    NSTimeInterval timeInterval = 0.1;
                    animatedLayer = [self.videoBuilder buildEmitterFireworks:assetVideoTrack.naturalSize startTime:timeInterval];
                    [animatedLayers addObject:(id)animatedLayer];
                }
                    break;
                case XKAnimationActionTypeSnow: {
                    NSTimeInterval timeInterval = 0.1;
                    animatedLayer = [self.videoBuilder buildEmitterSnow:assetVideoTrack.naturalSize startTime:timeInterval];
                    [animatedLayers addObject:(id)animatedLayer];
                }
                    break;
                case XKAnimationActionTypeSnow2: {
                    NSTimeInterval timeInterval = 0.1;
                    animatedLayer = [self.videoBuilder buildEmitterSnow2:assetVideoTrack.naturalSize startTime:timeInterval];
                    [animatedLayers addObject:(id)animatedLayer];
                }
                    break;
                case XKAnimationActionTypeHeart: {
                    NSTimeInterval timeInterval = 0.1;
                    animatedLayer = [self.videoBuilder buildEmitterHeart:assetVideoTrack.naturalSize startTime:timeInterval];
                    [animatedLayers addObject:(id)animatedLayer];
                }
                    break;
                case XKAnimationActionTypeRing: {
                    NSTimeInterval timeInterval = 0.1;
                    animatedLayer = [self.videoBuilder buildEmitterRing:assetVideoTrack.naturalSize startTime:timeInterval];
                    [animatedLayers addObject:(id)animatedLayer];
                }
                    break;
                case XKAnimationActionTypeStar: {
                    NSTimeInterval timeInterval = 0.1;
                    animatedLayer = [self.videoBuilder buildEmitterStar:assetVideoTrack.naturalSize startTime:timeInterval];
                    [animatedLayers addObject:(id)animatedLayer];
                }
                    break;
                case XKAnimationActionTypeMoveDot: {
                    NSTimeInterval timeInterval = 0.1;
                    animatedLayer = [self.videoBuilder buildEmitterMoveDot:assetVideoTrack.naturalSize position:CGPointMake(160, 240) startTime:timeInterval];
                    [animatedLayers addObject:(id)animatedLayer];
                }
                    break;
                case XKAnimationActionTypeSky: {
                    NSTimeInterval timeInterval = 0.1;
                    animatedLayer = [self.videoBuilder buildEmitterSky:assetVideoTrack.naturalSize startTime:timeInterval];
                    [animatedLayers addObject:(id)animatedLayer];
                }
                    break;
                case XKAnimationActionTypeMeteor: {
                    NSTimeInterval timeInterval = 0.1;
                    for (int i = 0; i < 2; i ++) {
                        animatedLayer = [self.videoBuilder buildEmitterMeteor:assetVideoTrack.naturalSize startTime:timeInterval pathN:i];
                        [animatedLayers addObject:(id)animatedLayer];
                    }
                }
                    break;
                case XKAnimationActionTypeRain: {
                    animatedLayer = [self.videoBuilder buildEmitterRain:assetVideoTrack.naturalSize];
                    [animatedLayers addObject:(id)animatedLayer];
                }
                    break;
                case XKAnimationActionTypeFlower: {
                    NSTimeInterval timeInterval = 0.1;
                    animatedLayer = [self.videoBuilder buildEmitterFlower:assetVideoTrack.naturalSize startTime:timeInterval];
                    [animatedLayers addObject:(id)animatedLayer];
                }
                    break;
                case XKAnimationActionTypeFire: {
                    if (currentTheme.imageFile.length > 0) {
                        UIImage *image = [UIImage imageNamed:currentTheme.imageFile];
                        animatedLayer = [self.videoBuilder buildEmitterFire:assetVideoTrack.naturalSize position:CGPointMake(assetVideoTrack.naturalSize.width / 2.0, image.size.height+10)];
                        [animatedLayers addObject:(id)animatedLayer];
                    }
                }
                    break;
                case XKAnimationActionTypeSmoke: {
                    animatedLayer = [self.videoBuilder buildEmitterSmoke:assetVideoTrack.naturalSize position:CGPointMake(assetVideoTrack.naturalSize.width / 2.0, 105)];
                    [animatedLayers addObject:(id)animatedLayer];
                }
                    break;
                case XKAnimationActionTypeSpark: {
                    animatedLayer = [self.videoBuilder buildEmitterSpark:assetVideoTrack.naturalSize];
                    [animatedLayers addObject:(id)animatedLayer];
                }
                    break;
                case XKAnimationActionTypeSteam: {
                    animatedLayer = [self.videoBuilder buildEmitterSteam:assetVideoTrack.naturalSize positon:CGPointMake(assetVideoTrack.naturalSize.width / 2, assetVideoTrack.naturalSize.height - assetVideoTrack.naturalSize.height / 8)];
                    [animatedLayers addObject:(id)animatedLayer];
                }
                    break;
                case XKAnimationActionTypeBirthday: {
                    animatedLayer = [self.videoBuilder buildEmitterBirthday:assetVideoTrack.naturalSize];
                    [animatedLayers addObject:(id)animatedLayer];
                }
                    break;
                case XKAnimationActionTypeBlackWhiteDot: {
                    for (int i = 0; i < 2; i ++) {
                        animatedLayer = [self.videoBuilder buildEmitterBlackWhiteDot:assetVideoTrack.naturalSize positon:CGPointMake(assetVideoTrack.naturalSize.width / 2, i * assetVideoTrack.naturalSize.height) startTime:2.0f];
                        [animatedLayers addObject:(id)animatedLayer];
                    }
                }
                    break;
                case XKAnimationActionTypeScrollScreen: {
                    NSTimeInterval timeInterval = 0.1;
                    animatedLayer = [self.videoBuilder buildAnimationScrollScreen:assetVideoTrack.naturalSize startTime:timeInterval];
                    [animatedLayers addObject:(id)animatedLayer];
                }
                    break;
                case XKAnimationActionTypeSpotlight: {
                    NSTimeInterval timeInterval = 0.1;
                    animatedLayer = [self.videoBuilder buildSpotlight:assetVideoTrack.naturalSize startTime:timeInterval];
                    [animatedLayers addObject:(id)animatedLayer];
                }
                    break;
                case XKAnimationActionTypeScrollLine: {
                    NSTimeInterval timeInterval = 0.1;
                    animatedLayer = [self.videoBuilder buildAnimatedScrollLine:assetVideoTrack.naturalSize startTime:timeInterval lineHeight:30.0f image:nil];
                    [animatedLayers addObject:(id)animatedLayer];
                }
                    break;
                case XKAnimationActionTypeRipple: {
                    NSTimeInterval timeInterval = 1.0;
                    animatedLayer = [self.videoBuilder buildAnimationRipple:assetVideoTrack.naturalSize centerPoint:CGPointMake(assetVideoTrack.naturalSize.width / 2, assetVideoTrack.naturalSize.height / 2) radius:assetVideoTrack.naturalSize.width / 2 startTime:timeInterval];
                    [animatedLayers addObject:(id)animatedLayer];
                }
                    break;
                case XKAnimationActionTypeImage: {
                    if (currentTheme.imageFile.length > 0) {
                        UIImage *image = [UIImage imageNamed:currentTheme.imageFile];
                        animatedLayer = [self.videoBuilder buildImage:assetVideoTrack.naturalSize image:currentTheme.imageFile position:CGPointMake(assetVideoTrack.naturalSize.width / 2, image.size.height / 2)];
                        [animatedLayers addObject:(id)animatedLayer];
                    }
                }
                    break;
                case XKAnimationActionTypeImageArray: {
                    if (currentTheme.animationImages) {
                        UIImage *image = [UIImage imageWithCGImage:(CGImageRef)currentTheme.animationImages[0]];
                        animatedLayer = [self.videoBuilder buildAnimationImages:assetVideoTrack.naturalSize imagesArray:currentTheme.animationImages position:CGPointMake(assetVideoTrack.naturalSize.width / 2, image.size.height / 2)];
                        [animatedLayers addObject:(id)animatedLayer];
                    }
                }
                    break;
                case XKAnimationActionTypeVideoFrame: {
                    if (currentTheme.keyFrameTimes.count > 0) {
                        for (NSNumber *timeSecond in currentTheme.keyFrameTimes) {
                            CMTime time = CMTimeMake([timeSecond doubleValue], 1);
                            if (CMTIME_COMPARE_INLINE([asset duration], >, time)) {
                                animatedLayer = [self.videoBuilder buildVideoFrameImage:assetVideoTrack.naturalSize videoFile:inputVideoURL startTime:time];
                                [animatedLayers addObject:(id)animatedLayer];
                            }
                        }
                    }
                }
                    break;
                case XKAnimationActionTypeTextStar: {
                    if (currentTheme.textStar.length > 0) {
                        NSTimeInterval startTime = 0.1;
                        animatedLayer = [self.videoBuilder buildAnimationStarText:assetVideoTrack.naturalSize text:currentTheme.textStar startTime:startTime];
                        [animatedLayer addSublayer:(id)animatedLayer];
                    }
                }
                    break;
                case XKAnimationActionTypeTextSparkle: {
                    if (currentTheme.textSparkle.length > 0) {
                        NSTimeInterval startTime = 10;
                        animatedLayer = [self.videoBuilder buildEmitterSparkle:assetVideoTrack.naturalSize text:currentTheme.textSparkle startTime:startTime];
                        [animatedLayers addObject:(id)animatedLayer];
                    }
                }
                    break;
                case XKAnimationActionTypeTextScroll: {
                    if ([currentTheme.scrollText count] > 0) {
                        NSArray *startYPoints = @[[NSNumber numberWithFloat:assetVideoTrack.naturalSize.height / 3], [NSNumber numberWithFloat:assetVideoTrack.naturalSize.height / 2], [NSNumber numberWithFloat:assetVideoTrack.naturalSize.height * 2 / 3]];
                        NSTimeInterval timeInterval = 0.0;
                        for (NSString *text in currentTheme.scrollText) {
                            animatedLayer = [self.videoBuilder buildAnimatedScrollText:assetVideoTrack.naturalSize text:text startPoint:CGPointMake(assetVideoTrack.naturalSize.width, [startYPoints[arc4random() % (int)3] floatValue]) startTime:timeInterval];
                            [animatedLayers addObject:(id)animatedLayer];
                            timeInterval += 2.0;
                        }
                    }
                }
                    break;
                case XKAnimationActionTypeTextGradient: {
                    if (currentTheme.textGradient.length > 0) {
                        NSTimeInterval timeInterval = 1.0;
                        animatedLayer = [self.videoBuilder buildGradientText:assetVideoTrack.naturalSize positon:CGPointMake(assetVideoTrack.naturalSize.width / 2, assetVideoTrack.naturalSize.height - assetVideoTrack.naturalSize.height / 4) text:currentTheme.textGradient startTime:timeInterval];
                        [animatedLayers addObject:(id)animatedLayer];
                    }
                }
                    break;
                case XKAnimationActionTypeFlashScreen: {
                    for (int timeSecond = 2; timeSecond < 12; timeSecond += 3) {
                        CMTime time = CMTimeMake(timeSecond, 1);
                        if (CMTIME_COMPARE_INLINE([asset duration], >, time)) {
                            animatedLayer = [self.videoBuilder buildAnimationFlashScreen:assetVideoTrack.naturalSize startTime:timeSecond startOpacity:YES];
                            [animatedLayers addObject:(id)animatedLayer];
                        }
                    }
                }
                    break;
                case XKAnimationActionTypePhotoLinearScroll: {
                    NSTimeInterval startTime = 3;
                    animatedLayer = [self.videoBuilder buildAnimatedPhotoLinearScroll:assetVideoTrack.naturalSize photos:photos startTime:startTime];
                    [animatedLayers addObject:(id)animatedLayer];
                }
                    break;
                case XKAnimationActionTypePhotoCentringShow: {
                    NSTimeInterval startTime = 10;
                    animatedLayer = [self.videoBuilder buildAnimatedPhotoCentringShow:assetVideoTrack.naturalSize photos:photos startTime:startTime];
                    [animatedLayers addObject:(id)animatedLayer];
                }
                    break;
                case XKAnimationActionTypePhotoDrop: {
                    NSTimeInterval startTime = 1;
                    animatedLayer = [self.videoBuilder buildAnimatedPhotoDrop:assetVideoTrack.naturalSize photos:photos startTime:startTime];
                    [animatedLayers addObject:(id)animatedLayer];
                }
                    break;
                case XKAnimationActionTypePhotoParabola: {
                    NSTimeInterval startTime = 1;
                    animatedLayer = [self.videoBuilder buildAnimatedPhotoParabola:assetVideoTrack.naturalSize photos:photos startTime:startTime];
                    [animatedLayers addObject:(id)animatedLayer];
                }
                    break;
                case XKAnimationActionTypePhotoFlare: {
                    NSTimeInterval startTime = 1;
                    animatedLayer = [self.videoBuilder buildAnimatedPhotoFlare:assetVideoTrack.naturalSize photos:photos startTime:startTime];
                    [animatedLayers addObject:(id)animatedLayer];
                }
                    break;
                case XKAnimationActionTypePhotoEmitter: {
                    NSTimeInterval startTime = 1;
                    animatedLayer = [self.videoBuilder buildAnimationPhotoEmitter:assetVideoTrack.naturalSize photos:photos startTime:startTime];
                    [animatedLayers addObject:(id)animatedLayer];
                }
                    break;
                case XKAnimationActionTypePhotoExplode: {
                    NSTimeInterval startTime = 1;
                    animatedLayer = [self.videoBuilder buildAnimatedPhotoExplode:assetVideoTrack.naturalSize photos:photos startTime:startTime];
                    [animatedLayers addObject:(id)animatedLayer];
                }
                    break;
                case XKAnimationActionTypePhotoExplodeDrop: {
                    NSTimeInterval startTime = 0.1;
                    animatedLayer = [self.videoBuilder buildAnimatedPhotoExplodeDrop:assetVideoTrack.naturalSize photos:photos startTime:startTime];
                    [animatedLayers addObject:(id)animatedLayer];
                }
                    break;
                case XKAnimationActionTypePhotoCloud: {
                    NSTimeInterval startTime = 0.1;
                    animatedLayer = [self.videoBuilder buildAnimatedPhotoCloud:assetVideoTrack.naturalSize photos:photos startTime:startTime];
                    [animatedLayers addObject:(id)animatedLayer];
                }
                    break;
                case XKAnimationActionTypePhotoSpin360: {
                    NSTimeInterval startTime = 0.1;
                    animatedLayer = [self.videoBuilder buildAnimatedPhotoSpin360:assetVideoTrack.naturalSize photos:photos startTime:startTime];
                    [animatedLayers addObject:(id)animatedLayer];
                }
                    break;
                case XKAnimationActionTypePhotoCarousel: {
                    NSTimeInterval startTime = 0.1;
                    animatedLayer = [self.videoBuilder buildAnimatedPhotoCarousel:assetVideoTrack.naturalSize photos:photos startTime:startTime];
                    [animatedLayers addObject:(id)animatedLayer];
                }
                    break;
            }
        }
        if (animatedLayers.count > 0) {
            for (CALayer *animatedLayer in animatedLayers) {
                [parentLayer addSublayer:animatedLayer];
            }
        }
    }
    
    AVMutableVideoCompositionInstruction *passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    passThroughInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [asset duration]);
    
    AVMutableVideoCompositionLayerInstruction *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:assetVideoTrack];
    passThroughInstruction.layerInstructions = [NSArray arrayWithObject:passThroughLayer];
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.instructions = [NSArray arrayWithObject:passThroughInstruction];
    videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    videoComposition.frameDuration = CMTimeMake(1, 30);
    videoComposition.renderSize =  assetVideoTrack.naturalSize;
    
    [animatedLayers removeAllObjects];
    animatedLayers = nil;
    
    AVMutableAudioMix *audioMix = nil;
    if (currentTheme && currentTheme.bgMusicFile.length > 0) {
        NSString *fileName = [currentTheme.bgMusicFile stringByDeletingPathExtension];
        NSString *fileExt = [currentTheme.bgMusicFile pathExtension];
        NSURL *bgMusicURL = [[NSBundle mainBundle] URLForResource:fileName withExtension:fileExt];
        AVURLAsset *assetMusic = [[AVURLAsset alloc] initWithURL:bgMusicURL options:nil];
        self.videoBuilder.commentary = assetMusic;
        audioMix = [AVMutableAudioMix audioMix];
        [self.videoBuilder addCommentaryTrackToComposition:composition withAudioMix:audioMix];
    }
    unlink([exportVideoFile UTF8String]);
    NSString *mp4Quality = AVAssetExportPresetMediumQuality;
    if (highestQuality) {
        mp4Quality = AVAssetExportPresetHighestQuality;
    }
    NSString *exportPath = exportVideoFile;
    NSURL *exportUrl = [NSURL fileURLWithPath:[exportPath stringByReplacingOccurrencesOfString:@" " withString:@""]];
    
    self.exportSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:mp4Quality];
    self.exportSession.outputURL = exportUrl;
    self.exportSession.outputFileType = AVFileTypeMPEG4;
    self.exportSession.shouldOptimizeForNetworkUse = YES;
    
    if (audioMix) {
        self.exportSession.audioMix = audioMix;
    }
    if (videoComposition) {
        self.exportSession.videoComposition = videoComposition;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.timer = [XKTimer xk_timerWIthTimeInterval:0.3 repeats:YES handler:^{
            [weakSelf retrievingProgressMP4];
        }];
        [weakSelf.timer fire];
    });
    [weakSelf.exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch ([weakSelf.exportSession status]) {
            case AVAssetExportSessionStatusCompleted: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.timer invalidate];
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(exportMP4SessionStatusCompleted)]) {
                        [weakSelf.delegate exportMP4SessionStatusCompleted];
                    }
                });
            }
                break;
            case AVAssetExportSessionStatusFailed: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.timer invalidate];
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(exportMP4SessionStatusFailed)]) {
                        [weakSelf.delegate exportMP4SessionStatusFailed];
                    }
                });
            }
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Export canceled");
                break;
            case AVAssetExportSessionStatusWaiting:
                NSLog(@"Export Waiting");
                break;
            case AVAssetExportSessionStatusExporting:
                NSLog(@"Export Exporting");
                break;
            default:
                break;
        }
    }];
    return YES;
}

- (void)retrievingProgressMP4 {
    if (self.exportSession) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(retrievingProgressMP4:)]) {
            [self.delegate retrievingProgressMP4:self.exportSession.progress];
        }
    }
}

@end
