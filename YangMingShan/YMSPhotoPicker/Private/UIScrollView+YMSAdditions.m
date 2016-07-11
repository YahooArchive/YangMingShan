//
//  UIScrollView+YMSAdditions.m
//  YangMingShan
//
//  Copyright 2016 Yahoo Inc.
//  Licensed under the terms of the BSD license. Please see LICENSE file in the project root for terms.
//

#import "UIScrollView+YMSAdditions.h"

#import <objc/runtime.h>

static const void *YMSLastContentOffset = &YMSLastContentOffset;
static const void *YMSScrollDirection = &YMSScrollDirection;

@implementation UIScrollView(YMSAdditions)

- (void)yms_scrollViewDidScroll
{
    if (self.lastContentOffset.y > self.contentOffset.y) {
        self.scrollDirection = YMSScrollViewScrollDirectionDown;
    }
    else if (self.lastContentOffset.y < self.contentOffset.y) {
        self.scrollDirection = YMSScrollViewScrollDirectionUp;
    }
    else if (self.lastContentOffset.x > self.contentOffset.x) {
        self.scrollDirection = YMSScrollViewScrollDirectionLeft;
    }
    else if (self.lastContentOffset.x < self.contentOffset.x) {
        self.scrollDirection = YMSScrollViewScrollDirectionRight;
    }
    else {
        self.scrollDirection = YMSScrollViewScrollDirectionUnknown;
    }

    self.lastContentOffset = self.contentOffset;
}

- (void)setLastContentOffset:(CGPoint)lastContentOffset
{
    objc_setAssociatedObject(self, YMSLastContentOffset, [NSValue valueWithCGPoint:lastContentOffset], OBJC_ASSOCIATION_COPY);
}

- (CGPoint)lastContentOffset
{
    return [objc_getAssociatedObject(self, YMSLastContentOffset) CGPointValue];
}

- (void)setScrollDirection:(YMSScrollViewScrollDirection)scrollDirection
{
    objc_setAssociatedObject(self, YMSScrollDirection, @(scrollDirection), OBJC_ASSOCIATION_ASSIGN);
}

- (YMSScrollViewScrollDirection)scrollDirection
{
    return [objc_getAssociatedObject(self,YMSScrollDirection) integerValue];
}

@end
