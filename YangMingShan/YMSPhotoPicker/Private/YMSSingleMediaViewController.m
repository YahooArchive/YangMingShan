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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerLeftConstraint;

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

- (CGRect)mediaPreviewFrame
{
    CGSize mediaSize = CGSizeMake(self.currentAsset.pixelWidth, self.currentAsset.pixelHeight);
    return [self getFinalImageFrameForSize:mediaSize inContainer:nil];
}

#pragma mark - Private Helpers

- (void)loadContent
{
    if(self.currentAsset.mediaType == PHAssetMediaTypeImage) {
        [self.videoPreviewView setHidden:YES];
        
        CGFloat scale = [UIScreen mainScreen].scale;
        CGSize imageSize = CGSizeMake(self.photoImageView.frame.size.width, self.photoImageView.frame.size.height);
        CGSize targetSize = CGSizeMake(imageSize.width * scale, imageSize.height * scale);
        [self.imageManager requestImageForAsset:self.currentAsset targetSize:targetSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            self.photoImageView.image = result;
        }];
    }
    else if(self.currentAsset.mediaType == PHAssetMediaTypeVideo) {
        [self.photoImageView setHidden:YES];
        
        [self.imageManager requestPlayerItemForVideo:self.currentAsset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
                [(AVPlayerLayer*)self.videoPreviewView.layer setPlayer:player];
                [player play];
            });
        }];
    }
}

// Can't take the container view frame into account because it may not have been updated at this point (auto-layout).
- (CGRect)getFinalImageFrameForSize:(CGSize)size inContainer:(UIView*)containerView
{
    CGFloat marginHorizontal = self.containerLeftConstraint.constant;
    CGFloat marginVertical = self.containerTopConstraint.constant;
    CGRect containerFrame = CGRectInset(self.view.bounds, marginHorizontal, marginVertical);
    CGFloat ratioWidth = containerFrame.size.width / size.width;
    CGFloat ratioHeight = containerFrame.size.height / size.height;
    CGFloat ratio = MIN(ratioWidth, ratioHeight);
    
    CGFloat width = size.width * ratio;
    CGFloat height = size.height * ratio;
    CGFloat x = (containerFrame.size.width - width) / 2;
    CGFloat y = (containerFrame.size.height - height) / 2;
    return CGRectMake(containerFrame.origin.x + x, containerFrame.origin.y + y, width, height);
}

@end
