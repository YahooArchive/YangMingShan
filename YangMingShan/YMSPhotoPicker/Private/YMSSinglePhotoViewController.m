//
//  YMSSinglePhotoViewController.m
//  YangMingShan
//
//  Copyright 2016 Yahoo Inc.
//  Licensed under the terms of the BSD license. Please see LICENSE file in the project root for terms.
//

#import "YMSSinglePhotoViewController.h"

#import "YMSPhotoPickerTheme.h"

typedef NS_ENUM(NSUInteger, PresentationStyle) {
    PresentationStyleDefault,
    PresentationStyleDark
};

@interface YMSSinglePhotoViewController ()

@property (nonatomic, copy) void (^dismissalHandler)(BOOL);
@property (nonatomic, strong) PHAsset *currentAsset;
@property (nonatomic, weak) PHImageManager *imageManager;
@property (nonatomic, weak) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, weak) IBOutlet UIView *navigationBarBackgroundView;
@property (nonatomic, weak) IBOutlet UIImageView *photoImageView;
@property (nonatomic, weak) IBOutlet UIScrollView *imageContainerView;
@property (nonatomic, assign) PresentationStyle presentationStyle;

- (IBAction)dismiss:(id)sender;
- (IBAction)selectCurrentPhoto:(id)sender;
- (IBAction)switchPresentationStyle:(id)sender;

@end

@implementation YMSSinglePhotoViewController

- (instancetype)initWithPhotoAsset:(PHAsset *)asset imageManager:(PHImageManager *)manager dismissalHandler:(void (^)(BOOL))dismissalHandler
{
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleForClass:self.class]];
    if (self) {
        self.currentAsset = asset;
        self.dismissalHandler = dismissalHandler;
        self.imageManager = manager;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    UINavigationItem *navigationItem = [[UINavigationItem alloc] init];
    navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"YMSIconCancel" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(dismiss:)];
    navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(selectCurrentPhoto:)];
    self.navigationBar.items = @[navigationItem];

    if (![[YMSPhotoPickerTheme sharedInstance].navigationBarBackgroundColor isEqual:[UIColor whiteColor]]) {
        [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [self.navigationBar setShadowImage:[UIImage new]];
        self.navigationBarBackgroundView.backgroundColor = [YMSPhotoPickerTheme sharedInstance].navigationBarBackgroundColor;
    }

    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize imageSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) * scale, (CGRectGetHeight([UIScreen mainScreen].bounds) - CGRectGetHeight(self.navigationBar.bounds)) * scale);

    CGSize targetSize = CGSizeMake(imageSize.width * scale, imageSize.height * scale);
    [self.imageManager requestImageForAsset:self.currentAsset targetSize:targetSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        self.photoImageView.image = result;
    }];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchPresentationStyle:)];
    [self.imageContainerView addGestureRecognizer:tapGestureRecognizer];

    self.presentationStyle = PresentationStyleDefault;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [YMSPhotoPickerTheme sharedInstance].statusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    if (self.presentationStyle == PresentationStyleDefault
        && self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular) {
        return NO;
    }
    return YES;
}

#pragma mark - IBActions

- (IBAction)dismiss:(id)sender
{
    if (self.dismissalHandler) {
        self.dismissalHandler(NO);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)selectCurrentPhoto:(id)sender
{
    if (self.dismissalHandler) {
        self.dismissalHandler(YES);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)switchPresentationStyle:(id)sender
{
    if (self.presentationStyle == PresentationStyleDefault) {
        [UIView animateWithDuration:0.15 animations:^{
            self.view.backgroundColor = [UIColor blackColor];
            self.navigationBar.alpha = 0.0;
            self.navigationBarBackgroundView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.presentationStyle = PresentationStyleDark;
            [self setNeedsStatusBarAppearanceUpdate];
        }];
    }
    else if (self.presentationStyle == PresentationStyleDark) {
        [UIView animateWithDuration:0.15 animations:^{
            self.view.backgroundColor = [UIColor whiteColor];
            self.navigationBar.alpha = 1.0;
            self.navigationBarBackgroundView.alpha = 1.0;
        } completion:^(BOOL finished) {
           self.presentationStyle = PresentationStyleDefault;
            [self setNeedsStatusBarAppearanceUpdate];
        }];
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.photoImageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale
{
    if (scale <= 1.0 && self.presentationStyle == PresentationStyleDark) {
        [self switchPresentationStyle:nil];
    }
}

@end
