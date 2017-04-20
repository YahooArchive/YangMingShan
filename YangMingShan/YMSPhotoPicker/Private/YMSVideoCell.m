//
//  YMSVideoCell.m
//  YangMingShanDemo
//
//  Created by Paul Ulric on 03/01/2017.
//  Copyright © 2017 Yahoo. All rights reserved.
//

#import "YMSVideoCell.h"

@interface YMSVideoCell()

@property (nonatomic, weak) IBOutlet UIView *videoOverlay;
@property (nonatomic, weak) IBOutlet UILabel *videoDuration;

@end

@implementation YMSVideoCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    CAGradientLayer *gradientLayer = [self createDurationOverlay];
    [self.videoOverlay.layer insertSublayer:gradientLayer atIndex:0];
}

#pragma mark - Publics

- (void)loadPhotoWithManager:(PHImageManager *)manager forAsset:(PHAsset *)asset targetSize:(CGSize)size
{
    [super loadPhotoWithManager:manager forAsset:asset targetSize:size];
    
    int duration = (int)asset.duration;
    int minutes = duration / 60;
    int seconds = duration % 60;
    self.videoDuration.text = [NSString stringWithFormat:@"%i:%02i", minutes, seconds];
}

#pragma mark - Privates

- (CAGradientLayer*)createDurationOverlay
{
    UIColor *darkColor = [UIColor colorWithWhite:0 alpha:0.5];
    UIColor *lightColor = [UIColor clearColor];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.videoOverlay.bounds;
    gradientLayer.colors = @[(id)lightColor.CGColor, (id)darkColor.CGColor];
    gradientLayer.locations = @[@(0.2), @(1.0)];
    return gradientLayer;
}


@end
