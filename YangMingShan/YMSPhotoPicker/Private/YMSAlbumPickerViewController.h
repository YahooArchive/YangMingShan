//
//  YMSAlbumPickerViewController.h
//  YangMingShan
//
//  Copyright 2016 Yahoo Inc.
//  Licensed under the terms of the BSD license. Please see LICENSE file in the project root for terms.
//

#import <UIKit/UIKit.h>

/**
 * This is a subclass of UIViewController. Use initWithCollectionItems:selectedCollectionItem:dismissalHandler: to initialize.
 */
@interface YMSAlbumPickerViewController : UIViewController

/**
 * @brief Initialize YMSAlbumPickerViewController with whole album list, current selected album, and dismissalHandler block.
 *
 * @param collectionItems The whole ablum list array which contains NSDictionary object.
 * @param collectionItem Current selected album.
 * @param dismissalHandler The block object which is invoked before album picker will disapear.
 */
- (instancetype)initWithCollectionItems:(NSArray<NSDictionary *> *)collectionItems
                 selectedCollectionItem:(NSDictionary *)collectionItem
                       dismissalHandler:(void (^)(NSDictionary *selectedCollectionItem))dismissalHandler NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end
