//
//  YMSPhotoPickerConfiguration.h
//  YangMingShan
//
//  Created by Paul Ulric on 03/01/2017.
//  Copyright © 2017 Yahoo. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * These are the available source types the photo picker will allow the user to select.
 */
typedef NS_ENUM(NSUInteger, YMSPhotoPickerSourceType) {
    YMSPhotoPickerSourceTypePhoto,
    YMSPhotoPickerSourceTypeVideo,
    YMSPhotoPickerSourceTypeBoth
};

/**
 * These are the available sorting methods for the selected medias.
 */
typedef NS_ENUM(NSUInteger, YMSPhotoPickerSortingType) {
    YMSPhotoPickerSortingTypeSelection,
    YMSPhotoPickerSortingTypeCreationAscending,
    YMSPhotoPickerSortingTypeCreationDescending
};


/**
 * This is the centralized configuration for photo picker. This is a singleton class, so remember use sharedInstance to access it instead of init method.
 *
 */
@interface YMSPhotoPickerConfiguration : NSObject

/**
 * @brief Describe the number of thumbnails columns displayed while browsing the library, and therefore the number of thumbnails visible at once.
 *
 */
@property (nonatomic, assign) NSUInteger numberOfColumns;

/**
 * @brief Describe the type of medias that the user will be allowed to choose from.
 *
 */
@property (nonatomic, assign) YMSPhotoPickerSourceType sourceType;

/**
 * @brief Describe how the selected medias should be sorted.
 *
 */
@property (nonatomic, assign) YMSPhotoPickerSortingType sortingType;

/**
 * @brief Describe the orientations allowed.
 *
 */
@property (nonatomic, assign) UIInterfaceOrientationMask allowedOrientation;

/**
 * @brief Getting a shared instance of YMSPhotoPickerConfiguration.
 *
 * @return Instance of YMSPhotoPickerConfiguration.
 */
+ (instancetype)sharedInstance;

/**
 * @brief Reset configuration to default.
 *
 */
- (void)reset;

@end
