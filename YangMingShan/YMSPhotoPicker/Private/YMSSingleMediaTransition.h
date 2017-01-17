//
//  YMSSingleMediaTransition.h
//  YangMingShanDemo
//
//  Created by Paul Ulric on 11/01/2017.
//  Copyright © 2017 Yahoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YMSSingleMediaTransition : NSObject<UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

@property (nonatomic, assign) BOOL isPresenting;
@property (nonatomic, strong) UIImage *sourceImage;
@property (nonatomic, assign) CGRect thumbnailFrame;
@property (nonatomic, assign) CGRect detailFrame;

@end
