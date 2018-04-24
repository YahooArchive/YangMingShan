//
//  YMSCollectionViewCell.m
//  YangMingShanDemo
//
//  Created by Vyacheslav Khlichkin on 24.04.2018.
//  Copyright © 2018 Yahoo. All rights reserved.
//

#import "YMSCollectionViewCell.h"

@implementation YMSCollectionViewCell

#pragma mark - Accessibility

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (UIAccessibilityTraits)accessibilityTraits
{
    return UIAccessibilityTraitButton;  
}

- (void)accessibilityElementDidBecomeFocused
{
    UICollectionView *collectionView = (UICollectionView *)self.superview;
    [collectionView scrollToItemAtIndexPath:[collectionView indexPathForCell:self] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally|UICollectionViewScrollPositionCenteredVertically animated:NO];
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self);
}

@end
