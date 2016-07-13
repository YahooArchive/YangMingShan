//
//  YMSCameraCell.h
//  YangMingShan
//
//  Copyright 2016 Yahoo Inc.
//  Licensed under the terms of the BSD license. Please see LICENSE file in the project root for terms.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

/**
 * This is the customized UICollectionViewCell for photo picker as the camera preview.
 */
@interface YMSCameraCell : UICollectionViewCell

/**
 * @brief It is the session for monitoring current camera preview status.
 *
 */
@property (nonatomic, readonly) AVCaptureSession *session;

@end
