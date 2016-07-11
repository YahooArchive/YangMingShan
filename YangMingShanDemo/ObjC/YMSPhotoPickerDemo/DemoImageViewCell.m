//
//  DemoImageViewCell.m
//  YangMingShanDemo
//
//  Copyright 2016 Yahoo Inc.
//  Licensed under the terms of the BSD license. Please see LICENSE file in the project root for terms.
//

#import "DemoImageViewCell.h"

@interface DemoImageViewCell()

@property (nonatomic, weak) IBOutlet UIImageView *photoImageView;

@end

@implementation DemoImageViewCell

- (void)setPhotoImage:(UIImage *)photoImage
{
    self.photoImageView.image = photoImage;
    _photoImage = photoImage;
}

@end
