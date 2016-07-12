//
//  UIViewController+YMSPhotoHelper.h
//  YangMingShan
//
//  Copyright 2016 Yahoo Inc.
//  Licensed under the terms of the BSD license. Please see LICENSE file in the project root for terms.
//

#import <UIKit/UIKit.h>

#import "YMSPhotoPickerViewController.h"

/**
 * This is a UIViewController category to help you to present photo and album picker.
 *
 */
@interface UIViewController (YMSPhotoHelper)

/**
 * @brief Prsent UIImagePickerController with camera source type. Implement UIImagePickerControllerDelegate to get callbacks from UIImagePickerController. This function will help you to check and request user permission about camera access.
 *
 * @param delegate The UIImagePickerController delegate
 */
- (void)yms_presentCameraCaptureViewWithDelegate:(id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>)delegate;

/**
 * @brief Prsent default YMSPhotoPickerViewController with delegate. You can only pick single photo with this function. Implement YMSPhotoPickerViewControllerDelegate to get callbacks from YMSPhotoPickerViewController.
 *
 * @param delegate The YMSPhotoPickerViewController delegate.
 */
- (void)yms_presentAlbumPhotoViewWithDelegate:(id<YMSPhotoPickerViewControllerDelegate>)delegate;

/**
 * @brief Prsent customized YMSPhotoPickerViewController with delegate. See YMSPhotoPickerViewController.h for more details. Implement YMSPhotoPickerViewControllerDelegate to get callbacks from YMSPhotoPickerViewController.
 *
 * @param pickerViewController The customized YMSPhotoPickerViewController.
 * @param delegate The YMSPhotoPickerViewController delegate.
 */
- (void)yms_presentCustomAlbumPhotoView:(YMSPhotoPickerViewController *)pickerViewController delegate:(id<YMSPhotoPickerViewControllerDelegate>)delegate;

@end
