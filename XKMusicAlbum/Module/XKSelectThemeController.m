//
//  XKSelectThemeController.m
//  XKMusicAlbum
//
//  Created by 浪漫恋星空 on 2018/8/20.
//  Copyright © 2018年 浪漫恋星空. All rights reserved.
//

#import "XKSelectThemeController.h"
#import "XKVideoThemesData.h"
#import "XKVideoEffects.h"
#import <AVKit/AVKit.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface XKSelectThemeController ()<UITableViewDataSource, UITableViewDelegate, XKVideoEffectsDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray<UIImage *> *images;
@property (nonatomic, copy) NSString *mp4OutputPath;
@property (nonatomic, strong) XKVideoEffects *videoEffects;

@property (nonatomic, strong) AVPlayerViewController *playerVC;

@end

@implementation XKSelectThemeController

- (instancetype)initWithImages:(NSArray<UIImage *> *)images {
    if (self = [super init]) {
        _images = images;
        _mp4OutputPath = [self creatOutputFilePath];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"选择主题";
    [self.view addSubview:self.tableView];
}

- (NSString *)creatOutputFilePath {
    NSString *path = @"outputMovie.mp4";
    NSString *mp4OutputFile = [NSTemporaryDirectory() stringByAppendingPathComponent:path];
    return mp4OutputFile;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[XKVideoThemesData sharedInstance] fetchThemeData].count - 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class)];
    cell.textLabel.text = [NSString stringWithFormat:@"主题%ld", indexPath.row + 1];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    XKVideoTheme *theme = [[[XKVideoThemesData sharedInstance] fetchThemeData] objectForKey:[NSNumber numberWithInt:(int)indexPath.row + 1]];
    [self buildVideoEffect:theme.ID];
}

- (void)buildVideoEffect:(XKThemesType)themeType {
    self.videoEffects = [[XKVideoEffects alloc] init];
    self.videoEffects.delegate = self;
    self.videoEffects.currentThemeType = themeType;
    [self.videoEffects imagesToVideo:self.images.mutableCopy exportVideoFile:self.mp4OutputPath highestQuality:YES];
}

- (void)exportMP4SessionStatusCompleted {
    [SVProgressHUD showProgress:1 status:[NSString stringWithFormat:@"视频合成中(%.0f%%)", 1.0 * 100]];
    [SVProgressHUD dismiss];
    NSURL *url = [NSURL fileURLWithPath:self.mp4OutputPath];
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
    AVPlayerLayer *playLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    [self.playerVC.view.layer addSublayer:playLayer];
    [player play];
    self.playerVC.player = player;
    [self presentViewController:self.playerVC animated:YES completion:NULL];
}

- (void)exportMP4SessionStatusFailed {
    [SVProgressHUD showErrorWithStatus:@"视频导出失败"];
}

- (void)retrievingProgressMP4:(CGFloat)progress {
    [SVProgressHUD showProgress:progress status:[NSString stringWithFormat:@"视频合成中(%.0f%%)", progress * 100]];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
    }
    return _tableView;
}

- (AVPlayerViewController *)playerVC {
    if (!_playerVC) {
        _playerVC = [[AVPlayerViewController alloc] init];
    }
    return _playerVC;
}

@end
