//
//  YMSPhotoPickerConfiguration.h
//  YangMingShanDemo
//
//  Created by Paul Ulric on 03/01/2017.
//  Copyright © 2017 Yahoo. All rights reserved.
//

#import <Foundation/Foundation.h>

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
