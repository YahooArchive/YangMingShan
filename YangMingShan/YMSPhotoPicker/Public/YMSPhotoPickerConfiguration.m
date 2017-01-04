//
//  YMSPhotoPickerConfiguration.m
//  YangMingShanDemo
//
//  Created by Paul Ulric on 03/01/2017.
//  Copyright © 2017 Yahoo. All rights reserved.
//

#import "YMSPhotoPickerConfiguration.h"

@implementation YMSPhotoPickerConfiguration

+ (instancetype)sharedInstance
{
    static YMSPhotoPickerConfiguration *instance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[YMSPhotoPickerConfiguration alloc] init];
        [instance reset];
    });
    return instance;
}

- (void)reset
{
    self.numberOfColumns = 3;
    self.sourceType = YMSPhotoPickerSourceTypePhoto;
}

@end
