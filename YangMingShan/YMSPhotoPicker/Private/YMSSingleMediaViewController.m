//
//  YMSSingleMediaViewController.m
//  YangMingShan
//
//  Copyright 2016 Yahoo Inc.
//  Licensed under the terms of the BSD license. Please see LICENSE file in the project root for terms.
//

#import "YMSSingleMediaViewController.h"
#import "YMSPlayerPreviewView.h"

#import "YMSPhotoPickerTheme.h"
#import "YMSPhotoPickerConfiguration.h"


@interface YMSSingleMediaViewController ()

@property (nonatomic, strong) PHAsset *currentAsset;
@property (nonatomic, weak) PHImageManager *imageManager;
@property (nonatomic, weak) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet YMSPlayerPreviewView *videoPreviewView;

@end

@implementation YMSSingleMediaViewController

- (instancetype)initWithAsset:(PHAsset *)asset imageManager:(PHImageManager *)manager
{
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleForClass:self.class]];
    if (self) {
        self.currentAsset = asset;
        self.imageManager = manager;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadContent];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [YMSPhotoPickerTheme sharedInstance].statusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [YMSPhotoPickerConfiguration sharedInstance].allowedOrientation;
}

#pragma mark - Private Helpers

- (void)loadContent
{
    CGSize mediaSize = CGSizeMake(self.currentAsset.pixelWidth, self.currentAsset.pixelHeight);
    
    if(self.currentAsset.mediaType == PHAssetMediaTypeImage) {
        [self.videoPreviewView setHidden:YES];
        _mediaPreviewFrame = [self getFinalImageFrameForSize:mediaSize inContainer:self.photoImageView];
        
        CGFloat scale = [UIScreen mainScreen].scale;
        CGSize imageSize = CGSizeMake(self.photoImageView.frame.size.width, self.photoImageView.frame.size.height);
        CGSize targetSize = CGSizeMake(imageSize.width * scale, imageSize.height * scale);
        [self.imageManager requestImageForAsset:self.currentAsset targetSize:targetSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            self.photoImageView.image = result;
        }];
    }
    else if(self.currentAsset.mediaType == PHAssetMediaTypeVideo) {
        [self.photoImageView setHidden:YES];
        _mediaPreviewFrame = [self getFinalImageFrameForSize:mediaSize inContainer:self.videoPreviewView];
        
        [self.imageManager requestPlayerItemForVideo:self.currentAsset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
                [(AVPlayerLayer*)self.videoPreviewView.layer setPlayer:player];
                [player play];
            });
        }];
    }
}

- (CGRect)getFinalImageFrameForSize:(CGSize)size inContainer:(UIView*)containerView
{
    CGRect containerFrame = containerView.frame;
    CGFloat ratioWidth = containerFrame.size.width / size.width;
    CGFloat ratioHeight = containerFrame.size.height / size.height;
    CGFloat ratio = MIN(ratioWidth, ratioHeight);
    
    CGFloat width = size.width * ratio;
    CGFloat height = size.height * ratio;
    CGFloat x = (containerFrame.size.width - width) / 2;
    CGFloat y = (containerFrame.size.height - height) / 2;
    CGRect frame = CGRectMake(x, y, width, height);
    return [containerView convertRect:frame toView:self.view];
}

@end
