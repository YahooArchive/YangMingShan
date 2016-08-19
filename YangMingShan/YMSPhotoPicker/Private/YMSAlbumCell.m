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
@property (nonatomic, weak) IBOutlet UILabel *photosCountLabel;

@end

@implementation YMSAlbumCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.photosCountLabel.font = [YMSPhotoPickerTheme sharedInstance].photosCountLabelFont;
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

- (void)setPhotosCount:(NSUInteger)photosCount
{
    if (photosCount > 0) {
        self.photosCountLabel.text = [NSString stringWithFormat:@"(%zd)", photosCount];
    }
    else {
        self.photosCountLabel.text = @"";
    }
    _photosCount = photosCount;    
}

@end
