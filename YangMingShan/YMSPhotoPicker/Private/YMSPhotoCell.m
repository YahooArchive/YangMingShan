//
//  YMSPhotoCell.m
//  YangMingShan
//
//  Copyright 2016 Yahoo Inc.
//  Licensed under the terms of the BSD license. Please see LICENSE file in the project root for terms.
//
//  Part of this code was derived from code authored by David Robles
//  This code includes sample code from the following StackOverflow posting: http://stackoverflow.com/questions/10497397/from-catransform3d-to-cgaffinetransform

#import "YMSPhotoCell.h"

#import "YMSPhotoPickerTheme.h"

static const CGFloat YMSHightedAnimationDuration = 0.15;
static const CGFloat YMSUnhightedAnimationDuration = 0.4;
static const CGFloat YMSHightedAnimationTransformScale = 0.9;
static const CGFloat YMSUnhightedAnimationSpringDamping = 0.5;
static const CGFloat YMSUnhightedAnimationSpringVelocity = 6.0;

@interface YMSPhotoCell()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIView *selectionVeil;
@property (nonatomic, assign) BOOL enableSelectionIndicatorViewVisibility;
@property (nonatomic, weak) PHImageManager *imageManager;
@property (nonatomic, assign) PHImageRequestID imageRequestID;
@property (nonatomic, assign) BOOL animateSelection;
@property (nonatomic, assign, getter=isAnimatingHighlight) BOOL animateHighlight;
@property (nonatomic, weak) IBOutlet UILabel *selectionOrderLabel;
@property (nonatomic, strong) UIImage *thumbnailImage;

- (void)cancelImageRequest;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

@end

@implementation YMSPhotoCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
    [self addGestureRecognizer:self.longPressGestureRecognizer];

    self.selectionOrderLabel.textColor = [YMSPhotoPickerTheme sharedInstance].orderLabelTextColor;
    self.selectionOrderLabel.font = [YMSPhotoPickerTheme sharedInstance].selectionOrderLabelFont;

    self.selectionVeil.layer.borderWidth = 4.0;

    self.selectionOrderLabel.backgroundColor = [YMSPhotoPickerTheme sharedInstance].orderTintColor;
    self.selectionVeil.layer.borderColor = [YMSPhotoPickerTheme sharedInstance].orderTintColor.CGColor;

    [self prepareForReuse];
}

- (void)prepareForReuse
{
    [super prepareForReuse];

    [self cancelImageRequest];

    self.imageView.image = nil;
    self.enableSelectionIndicatorViewVisibility = NO;
    self.selectionVeil.alpha = 0.0;
    self.selectionOrderLabel.alpha = 0.0;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];

    [self setSelected:selected animated:self.animateSelection];
}

- (void)setSelectionOrder:(NSUInteger)selectionOrder
{
    _selectionOrder = selectionOrder;
    self.selectionOrderLabel.text = [NSString stringWithFormat:@"%zd", selectionOrder];
}

- (void)dealloc
{
    [self cancelImageRequest];
}

#pragma mark - Publics

- (void)loadPhotoWithManager:(PHImageManager *)manager forAsset:(PHAsset *)asset targetSize:(CGSize)size
{
    self.imageManager = manager;
    self.imageRequestID = [self.imageManager requestImageForAsset:asset
                                                       targetSize:size
                                                      contentMode:PHImageContentModeAspectFill
                                                          options:nil
                                                    resultHandler:^(UIImage *result, NSDictionary *info) {
                                                        // Set the cell's thumbnail image if it's still showing the same asset.
                                                        if ([self.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                                                            self.thumbnailImage = result;
                                                        }
                                                    }];
}

- (void)setNeedsAnimateSelection
{
    self.animateSelection = YES;
}

- (void)animateHighlight:(BOOL)highlighted
{
    if (highlighted) {
        self.animateHighlight = YES;
        [UIView animateWithDuration:YMSHightedAnimationDuration delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.transform = CGAffineTransformMakeScale(YMSHightedAnimationTransformScale, YMSHightedAnimationTransformScale);
        } completion:^(BOOL finished) {
            self.animateHighlight = NO;
        }];
    }
    else {
        [UIView animateWithDuration:YMSUnhightedAnimationDuration delay:self.isAnimatingHighlight? YMSHightedAnimationDuration: 0 usingSpringWithDamping:YMSUnhightedAnimationSpringDamping initialSpringVelocity:YMSUnhightedAnimationSpringVelocity options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
}

#pragma mark - Privates

- (void)setThumbnailImage:(UIImage *)thumbnailImage
{
    _thumbnailImage = thumbnailImage;
    self.imageView.image = thumbnailImage;
}

- (void)cancelImageRequest
{
    if (self.imageRequestID != PHInvalidImageRequestID) {
        [self.imageManager cancelImageRequest:self.imageRequestID];
        self.imageRequestID = PHInvalidImageRequestID;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (!animated) {
        self.selectionVeil.alpha = selected ? 1.0 : 0.0;
        self.selectionOrderLabel.alpha = selected ? 1.0 : 0.0;
        self.enableSelectionIndicatorViewVisibility = selected;
    }
    else {
        self.enableSelectionIndicatorViewVisibility = YES;
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.selectionVeil.alpha = selected ? 1.0 : 0.0;
            self.selectionOrderLabel.alpha = selected ? 1.0 : 0.0;
        } completion:^(BOOL finished) {
            self.enableSelectionIndicatorViewVisibility = selected;
        }];
    }
    self.animateSelection = NO;
}

@end
