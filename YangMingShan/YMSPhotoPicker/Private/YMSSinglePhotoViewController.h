//
//  YMSSinglePhotoViewController.h
//  YangMingShan
//
//  Copyright 2016 Yahoo Inc.
//  Licensed under the terms of the BSD license. Please see LICENSE file in the project root for terms.
//

#import <Photos/Photos.h>
#import <UIKit/UIKit.h>

/**
 * This is a subclass of UIViewController for displaying single photo view.
 */
@interface YMSSinglePhotoViewController : UIViewController

/**
 * @brief Initialize YMSSinglePhotoViewController with photo asset, image manager, and dismissalHandler block.
 *
 * @param asset The photo asset for displaying.
 * @param manager Reuse current image manager from photo picker.
 * @param dismissalHandler The block object which is invoked before single photo view will disapear.
 */
- (instancetype)initWithPhotoAsset:(PHAsset *)asset
                      imageManager:(PHImageManager *)manager
                  dismissalHandler:(void (^)(BOOL selected))dismissalHandler NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end
