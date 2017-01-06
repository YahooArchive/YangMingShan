//
//  YMSAlbumCell.m
//  YangMingShan
//
// Copyright 2016 Yahoo Inc.
// Licensed under the terms of the BSD license. Please see LICENSE file in the project root for terms.
//

#import "YMSAlbumCell.h"
#import "YMSPhotoPickerTheme.h"

@interface YMSAlbumCell()

@property (nonatomic, weak) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, weak) IBOutlet UILabel *albumNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *mediasCountLabel;

@end

@implementation YMSAlbumCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.mediasCountLabel.font = [YMSPhotoPickerTheme sharedInstance].mediasCountLabelFont;
    self.albumNameLabel.font = [YMSPhotoPickerTheme sharedInstance].albumNameLabelFont;
}

- (NSString *)YMS_cellIdentifier
{
    return @"YMSAlbumCell";
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage
{
    self.thumbnailImageView.image = thumbnailImage;
    _thumbnailImage = thumbnailImage;
}

- (void)setAlbumName:(NSString *)albumName
{
    self.albumNameLabel.text = albumName;
    _albumName = albumName;
}

- (void)setMediasCount:(NSUInteger)mediasCount
{
    if (mediasCount > 0) {
        self.mediasCountLabel.text = [NSString stringWithFormat:@"(%zd)", mediasCount];
    }
    else {
        self.mediasCountLabel.text = @"";
    }
    _mediasCount = mediasCount;
}

@end
