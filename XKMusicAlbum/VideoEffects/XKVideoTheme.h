//
//  XKVideoTheme.h
//  XKMusicAlbum
//
//  Created by 浪漫恋星空 on 2018/8/17.
//  Copyright © 2018年 浪漫恋星空. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XKVideoTheme : NSObject

@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, copy) NSString *thumbImageName;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *textStar;
@property (nonatomic, copy) NSString *textSparkle;
@property (nonatomic, copy) NSString *textGradient;
@property (nonatomic, copy) NSString *bgMusicFile;
@property (nonatomic, copy) NSString *imageFile;
@property (nonatomic, copy) NSArray *keyFrameTimes;
@property (nonatomic, strong) NSMutableArray *scrollText;
@property (nonatomic, strong) NSMutableArray *animationImages;
@property (nonatomic, copy) NSString *bgVideoFile;
@property (nonatomic, copy) NSArray *animationActions;

@end
