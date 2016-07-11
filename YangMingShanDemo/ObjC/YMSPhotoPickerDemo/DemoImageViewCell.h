//
//  DemoImageViewCell.h
//  YangMingShanDemo
//
//  Copyright 2016 Yahoo Inc.
//  Licensed under the terms of the BSD license. Please see LICENSE file in the project root for terms.
//

#import <UIKit/UIKit.h>

@interface DemoImageViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIButton *deleteButton;
@property (nonatomic, strong) UIImage *photoImage;

@end
