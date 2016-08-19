//
//  YMSPhotoPickerTheme.h
//  YangMingShan
//
//  Copyright 2016 Yahoo Inc.
//  Licensed under the terms of the BSD license. Please see LICENSE file in the project root for terms.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * This is the theme of customizable UI for photo picker. This is a singleton class, so remember use sharedInstance to access it instead of init method.
 *
 */
@interface YMSPhotoPickerTheme : NSObject

/**
 * @brief Describe a specific UIColor that you want to apply on whole picker view controllers tint color. If you already set tint color for your window, it automatically adopt on them.
 *
 */
@property (nonatomic, strong) UIColor *tintColor;

/**
 * @brief Describe a specific UIColor that you want to apply on title label text and drop down arrow image in the middle of navigation bar to display current album localized name.
 *
 */
@property (nonatomic, strong) UIColor *titleLabelTextColor;

/**
 * @brief Describe a specific UIColor that you want to apply on whole picker view controllers' navigation bar.
 *
 */
@property (nonatomic, strong) UIColor *navigationBarBackgroundColor;

/**
 * @brief Describe a specific UIColor that you want to apply on selected photo cell border and order badge background color.
 *
 */
@property (nonatomic, strong) UIColor *orderTintColor;

/**
 * @brief Describe a specific UIColor that you want to apply on selected photo cell order number text color.
 *
 */
@property (nonatomic, strong) UIColor *orderLabelTextColor;

/**
 * @brief Describe a specific UIColor that you want to apply on camera cell cover veil color. The veil alpha is 0.5 if user permits to access camera, otherwise, the alpha is 1.0.
 *
 */
@property (nonatomic, strong) UIColor *cameraVeilColor;

/**
 * @brief Describe a specific UIColor that you want to apply on camera cell icon color. The default color is white.
 *
 */
@property (nonatomic, strong) UIColor *cameraIconColor;

/**
 * @brief Describe a status bar style that apply on whole picker view controllers. The dafault style is UIStatusBarStyleDefault.
 *
 */
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

/**
 * @brief Describe a specify UIFont that you want to apply on title label text and drop down arrow image in the middle of navigation bar to display current album localized name.
 *
 */
@property (nonatomic, strong) UIFont *titleLabelFont;

/**
 * @brief Describe a specify UIFont that you want to apply to the table view showing album localized name.
 *
 */
@property (nonatomic, strong) UIFont *albumNameLabelFont;

/**
 * @brief Describe a specify UIFont that you want to apply to the table view showing photo count insdie album.
 *
 */
@property (nonatomic, strong) UIFont *photosCountLabelFont;

/**
 * @brief Describe a specify UIFont that you want to apply to the number in the bottom right of photo cells after they're selected, denoting order of selection.
 */
@property (nonatomic, strong) UIFont *selectionOrderLabelFont;

/**
 * @brief Getting a shared instance of YMSPhotoPickerTheme.
 *
 * @return Instance of YMSPhotoPickerTheme.
 */
+ (instancetype)sharedInstance;

/**
 * @brief Reset theme to default.
 *
 */
- (void)reset;

@end
