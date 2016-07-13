//
//  YMSAlbumCell.h
//  YangMingShan
//
//  Copyright 2016 Yahoo Inc.
//  Licensed under the terms of the BSD license. Please see LICENSE file in the project root for terms.
//

#import <UIKit/UIKit.h>

/**
 * This is the customized UITableViewCell for album picker to display album information.
 */
@interface YMSAlbumCell : UITableViewCell

/**
 * @brief It is the identifier for alubm picker to display first photo in specific album.
 *
 */
@property (nonatomic, strong) NSString *representedAssetIdentifier;

/**
 * @brief Set thumbnail image to this to display on left align UIImageView.
 *
 */
@property (nonatomic, strong) UIImage *thumbnailImage;

/**
 * @brief Set album name to this to display on left align UILabel.
 *
 */
@property (nonatomic, strong) NSString *albumName;

/**
 * @brief Set photos count to this to display on the photos count UILabel.
 *
 */
@property (nonatomic, assign) NSUInteger photosCount;
 
@end
