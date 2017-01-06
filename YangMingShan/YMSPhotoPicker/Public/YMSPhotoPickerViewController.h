//
//  YMSPhotoPickerViewController.h
//  YangMingShan
//
//  Copyright 2016 Yahoo Inc.
//  Licensed under the terms of the BSD license. Please see LICENSE file in the project root for terms.
//

#import <Photos/Photos.h>
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "YMSPhotoPickerTheme.h"
#import "YMSPhotoPickerConfiguration.h"

@protocol YMSPhotoPickerViewControllerDelegate;

/**
 * This is a subclass of UIViewController. Use method init to initialize and use yms_presentCustomAlbumPhotoView:delegate: inside UIViewController+YMSPhotoHelper.h to present it to be benitfited by album accessible condition check.
 *
 */
@interface YMSPhotoPickerViewController : UIViewController

/**
 * @brief Assign a delegate owner for YMSPhotoPickerViewController. It will notify you when YMSPhotoPickerViewController receives access denied or finish interaction with user.
 *
 */
@property (nonatomic, weak) id<YMSPhotoPickerViewControllerDelegate> delegate;

/**
 * @brief Set numberOfMediaToSelect to limit maximum number of media selections. Default value is 1 and you can set it to 0 for unlimited selections.
 *
 */
@property (nonatomic, assign) NSUInteger numberOfMediaToSelect;

/**
 * @brief Use YMSPhotoPickerTheme to customize the UI appearance for YMSPhotoPickerViewController, YMSSingleMediaViewController, and YMSAlbumPickerViewController. See YMSPhotoPickerTheme.h for more details.
 *
 */
@property (nonatomic, readonly) YMSPhotoPickerTheme *theme;

/**
 *  @brief Use this property to customize the returned item type for single selection. YES for UIImage, NO for PHAsset. Default value is YES.
 */
@property (nonatomic, assign) BOOL shouldReturnImageForSingleSelection;


@property (nonatomic, readonly) YMSPhotoPickerConfiguration* configuration;

@end

/**
 * This is the delegate protocol that an object should comply to, to indicate the results of presenting photo picking view controller.
 *
 */
@protocol YMSPhotoPickerViewControllerDelegate <NSObject>

@required
/**
 * @brief Invoked when view controller received photo album access denied from iOS. If accessDeniedType is YMSAccessDeniedTypeCamera or YMSAccessDeniedTypePhotoAlbum. You can present an alert view controller and direct user to iPhone/iPad settings to enable access permission.
 *
 * @param picker The view controller invoking the delegate method.
 */
- (void)photoPickerViewControllerDidReceivePhotoAlbumAccessDenied:(YMSPhotoPickerViewController *)picker;

/**
 * @brief Invoked when view controller received camera access denied from iOS. You can present an alert view controller and direct user to iPhone/iPad settings to enable access permission.
 *
 * @param picker The view controller invoking the delegate method.
 */
- (void)photoPickerViewControllerDidReceiveCameraAccessDenied:(YMSPhotoPickerViewController *)picker;

@optional
/**
 * @brief Invoked when view controller finish picking single media from camera or photo album. The picker does not dismiss itself; the client dismisses it in this callback.
 *
 * @param picker The view controller invoking the delegate method.
 * @param asset The PHAsset object user picked.
 */
- (void)photoPickerViewController:(YMSPhotoPickerViewController *)picker didFinishPickingMedia:(PHAsset *)asset;

/**
 * @brief Invoked when user press done button with greater than or equal to one media(s) from camera or photo album. The picker does not dismiss itself; the client dismisses it in this callback.
 *
 * @param picker The view controller invoking the delegate method.
 * @param assets The NSArray object contains PHAsset object(s) user picked.
 */
- (void)photoPickerViewController:(YMSPhotoPickerViewController *)picker didFinishPickingMedias:(NSArray<PHAsset*> *)assets;

/**
 * @brief Invoked when user press cancel button. The picker does not dismiss itself; the client dismisses it in this callback.
 *
 * @param picker The view controller invoking the delegate method.
 */
- (void)photoPickerViewControllerDidCancel:(YMSPhotoPickerViewController *)picker;

@end
