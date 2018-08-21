//
//  XKSelectImageController.m
//  XKMusicAlbum
//
//  Created by 浪漫恋星空 on 2018/8/16.
//  Copyright © 2018年 浪漫恋星空. All rights reserved.
//

#import "XKSelectImageController.h"
#import <HXPhotoPicker/HXPhotoPicker.h>
#import "XKSelectThemeController.h"
#import "XKVideoBuilder+XK.h"
#import <SVProgressHUD/SVProgressHUD.h>

static const CGFloat kPhotoViewMargin = 12.0;

@interface XKSelectImageController ()<HXPhotoViewDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) HXPhotoManager *manager;
@property (nonatomic, strong) HXPhotoView *photoView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) HXDatePhotoToolManager *toolManager;

@property (nonatomic, strong) UIButton *bottomView;
@property (nonatomic, assign) BOOL needDeleteItem;
@property (nonatomic, strong) NSMutableArray<UIImage *> *images;

@end

@implementation XKSelectImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSubViews];
}

- (void)initSubViews {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"选择图片";
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    CGFloat width = scrollView.frame.size.width;
    HXPhotoView *photoView = [HXPhotoView photoManager:self.manager];
    photoView.frame = CGRectMake(kPhotoViewMargin, kPhotoViewMargin, width - kPhotoViewMargin * 2, 0);
    photoView.delegate = self;
    photoView.previewShowDeleteButton = YES;
    photoView.showAddCell = YES;
    photoView.hideDeleteButton = YES;
    [photoView.collectionView reloadData];
    photoView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:photoView];
    self.photoView = photoView;
    
    [self.view addSubview:self.bottomView];
    
    UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(doNext)];
    
    self.navigationItem.rightBarButtonItems = @[nextItem];
}

- (void)doNext {
    if (self.images.count > 0) {
        XKSelectThemeController *selectThemeController = [[XKSelectThemeController alloc] initWithImages:self.images.copy];
        [self.navigationController pushViewController:selectThemeController animated:YES];
    } else {
        [SVProgressHUD showErrorWithStatus:@"请先选择图片"];
    }
}

#pragma mark -- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    HXPhotoModel *model;
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        model = [HXPhotoModel photoModelWithImage:image];
        if (self.manager.configuration.saveSystemAblum) {
            [HXPhotoTools savePhotoToCustomAlbumWithName:self.manager.configuration.customAlbumName photo:model.thumbPhoto];
        }
    } else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *url = info[UIImagePickerControllerMediaURL];
        NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                         forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:opts];
        float second = 0;
        second = urlAsset.duration.value/urlAsset.duration.timescale;
        model = [HXPhotoModel photoModelWithVideoURL:url videoTime:second];
        if (self.manager.configuration.saveSystemAblum) {
            [HXPhotoTools saveVideoToCustomAlbumWithName:self.manager.configuration.customAlbumName videoURL:url];
        }
    }
    if (self.manager.configuration.useCameraComplete) {
        self.manager.configuration.useCameraComplete(model);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- HXPhotoViewDelegate
- (void)photoView:(HXPhotoView *)photoView imageChangeComplete:(NSArray<UIImage *> *)imageList {
    for (UIImage *image in imageList) {
        [self.images addObject:[[[XKVideoBuilder alloc] init] getCropImage:image videoSize:CGSizeMake(160, 160)]];
    }
}

- (void)photoView:(HXPhotoView *)photoView deleteNetworkPhoto:(NSString *)networkPhotoUrl {
    
}

- (void)photoView:(HXPhotoView *)photoView updateFrame:(CGRect)frame {
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, CGRectGetMaxY(frame) + kPhotoViewMargin);
}

- (void)photoView:(HXPhotoView *)photoView currentDeleteModel:(HXPhotoModel *)model currentIndex:(NSInteger)index {
    
}

- (BOOL)photoViewShouldDeleteCurrentMoveItem:(HXPhotoView *)photoView {
    return self.needDeleteItem;
}

- (void)photoView:(HXPhotoView *)photoView gestureRecognizerBegan:(UILongPressGestureRecognizer *)longPgr indexPath:(NSIndexPath *)indexPath {
    [UIView animateWithDuration:0.25 animations:^{
        self.bottomView.alpha = 0.5;
    }];
}

- (void)photoView:(HXPhotoView *)photoView gestureRecognizerChange:(UILongPressGestureRecognizer *)longPgr indexPath:(NSIndexPath *)indexPath {
    CGPoint point = [longPgr locationInView:self.view];
    if (point.y >= self.bottomView.hx_y) {
        [UIView animateWithDuration:0.25 animations:^{
            self.bottomView.alpha = 1;
        }];
    }else {
        [UIView animateWithDuration:0.25 animations:^{
            self.bottomView.alpha = 0.5;
        }];
    }
}

- (void)photoView:(HXPhotoView *)photoView gestureRecognizerEnded:(UILongPressGestureRecognizer *)longPgr indexPath:(NSIndexPath *)indexPath {
    CGPoint point = [longPgr locationInView:self.view];
    if (point.y >= self.bottomView.hx_y) {
        self.needDeleteItem = YES;
        [self.photoView deleteModelWithIndex:indexPath.item];
    } else {
        self.needDeleteItem = NO;
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.bottomView.alpha = 0;
    }];
}

- (HXPhotoManager *)manager {
    if (!_manager) {
        _manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhoto];
        _manager.configuration.openCamera = YES;
        _manager.configuration.lookLivePhoto = YES;
        _manager.configuration.photoMaxNum = 20;
        _manager.configuration.maxNum = 20;
        _manager.configuration.saveSystemAblum = YES;
        _manager.configuration.showDateSectionHeader = NO;
        _manager.configuration.requestImageAfterFinishingSelection = YES;
        __weak typeof(self) weakSelf = self;
        _manager.configuration.shouldUseCamera = ^(UIViewController *viewController, HXPhotoConfigurationCameraType cameraType, HXPhotoManager *manager) {
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = (id)weakSelf;
            imagePickerController.allowsEditing = NO;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
            imagePickerController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            [viewController presentViewController:imagePickerController animated:YES completion:nil];
        };
    }
    return _manager;
}

- (UIButton *)bottomView {
    if (!_bottomView) {
        _bottomView = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bottomView setTitle:@"删除" forState:UIControlStateNormal];
        [_bottomView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_bottomView setBackgroundColor:[UIColor redColor]];
        _bottomView.frame = CGRectMake(0, self.view.hx_h - 50, self.view.hx_w, 50);
        _bottomView.alpha = 0;
    }
    return _bottomView;
}
- (HXDatePhotoToolManager *)toolManager {
    if (!_toolManager) {
        _toolManager = [[HXDatePhotoToolManager alloc] init];
    }
    return _toolManager;
}

- (NSMutableArray<UIImage *> *)images {
    if (!_images) {
        _images = @[].mutableCopy;
    }
    return _images;
}

@end
