//
//  UIViewController+YMSPhotoHelper.m
//  YangMingShan
//
//  Copyright 2016 Yahoo Inc.
//  Licensed under the terms of the BSD license. Please see LICENSE file in the project root for terms.
//

#import "UIViewController+YMSPhotoHelper.h"

#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

#import "YMSNavigationController.h"

@implementation UIViewController (YMSPhotoHelper)

- (void)yms_presentCameraCaptureViewWithDelegate:(id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>)delegate
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(status == AVAuthorizationStatusAuthorized) {
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = delegate;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
        else if(status == AVAuthorizationStatusDenied
                || status == AVAuthorizationStatusRestricted) {
            if ([delegate isKindOfClass:[YMSPhotoPickerViewController class]]) {
                YMSPhotoPickerViewController *pickerViewController = (YMSPhotoPickerViewController *)delegate;
                if ([pickerViewController.delegate respondsToSelector:@selector(photoPickerViewControllerDidReceiveCameraAccessDenied:)]) {
                    [pickerViewController.delegate photoPickerViewControllerDidReceiveCameraAccessDenied:pickerViewController];
                }
            }
        }
        else if(status == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^() {
                    if(granted){
                        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                        imagePickerController.delegate = delegate;
                        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                        [self presentViewController:imagePickerController animated:YES completion:nil];
                    }
                    else {
                        if ([delegate isKindOfClass:[YMSPhotoPickerViewController class]]) {
                            YMSPhotoPickerViewController *pickerViewController = (YMSPhotoPickerViewController *)delegate;
                            if ([pickerViewController.delegate respondsToSelector:@selector(photoPickerViewControllerDidReceiveCameraAccessDenied:)]) {
                                [pickerViewController.delegate photoPickerViewControllerDidReceiveCameraAccessDenied:pickerViewController];
                            }
                        }
                    }
                });
            }];
        }
    }
    else {
        // Camera is not support in this device, the reason we don't need to handle it because the only iOS8+ environment which does not support camera is iPhone simulator.
    }
}

- (void)yms_presentAlbumPhotoViewWithDelegate:(id<YMSPhotoPickerViewControllerDelegate>)delegate
{
    [self yms_presentCustomAlbumPhotoView:[[YMSPhotoPickerViewController alloc] init] delegate:delegate];
}

- (void)yms_presentCustomAlbumPhotoView:(YMSPhotoPickerViewController *)pickerViewController delegate:(id<YMSPhotoPickerViewControllerDelegate>)delegate
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    YMSNavigationController *navigationController = [[YMSNavigationController alloc] initWithRootViewController:pickerViewController];
    
    if (status == PHAuthorizationStatusAuthorized) {
        pickerViewController.delegate = delegate;
        [self presentViewController:navigationController animated:YES completion:nil];
    }
    else if (status == PHAuthorizationStatusDenied
             || status == PHAuthorizationStatusRestricted) {
        if ([delegate respondsToSelector:@selector(photoPickerViewControllerDidReceivePhotoAlbumAccessDenied:)]) {
            [delegate photoPickerViewControllerDidReceivePhotoAlbumAccessDenied:pickerViewController];
        }
    }
    else if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^() {
                if (status == PHAuthorizationStatusAuthorized) {
                    pickerViewController.delegate = delegate;
                    [self presentViewController:navigationController animated:YES completion:nil];
                }
                else {
                    // Access has been denied
                    if ([delegate respondsToSelector:@selector(photoPickerViewControllerDidReceivePhotoAlbumAccessDenied:)]) {
                        [delegate photoPickerViewControllerDidReceivePhotoAlbumAccessDenied:pickerViewController];
                    }
                }
            });
        }];
    }
    else {
        // Cannot recognize current status. Do nothing here.
    }
}

@end
