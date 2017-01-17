//
//  YMSSingleMediaTransition.m
//  YangMingShanDemo
//
//  Created by Paul Ulric on 11/01/2017.
//  Copyright © 2017 Yahoo. All rights reserved.
//

#import "YMSSingleMediaTransition.h"
#import "YMSSingleMediaViewController.h"


@implementation YMSSingleMediaTransition

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    NSTimeInterval animationDuration = [self transitionDuration:transitionContext];
    
    UIVisualEffectView *blurredBackgroundView = [[UIVisualEffectView alloc] initWithFrame:toViewController.view.frame];
    [containerView addSubview:blurredBackgroundView];
    
    UIImageView *sourceImageView = [[UIImageView alloc] initWithImage:self.sourceImage];
    sourceImageView.contentMode = UIViewContentModeScaleAspectFill;
    sourceImageView.clipsToBounds = YES;
    [containerView addSubview:sourceImageView];
    
    if(self.isPresenting) {
        blurredBackgroundView.effect = nil;
        sourceImageView.frame = self.thumbnailFrame;
        
        [UIView animateWithDuration:animationDuration delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:5.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            sourceImageView.frame = self.detailFrame;
            blurredBackgroundView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        } completion:^(BOOL finished) {
            [containerView addSubview:toViewController.view];
            [sourceImageView removeFromSuperview];
            [blurredBackgroundView removeFromSuperview];
            
            [transitionContext completeTransition:finished];
        }];
    }
    else {
        blurredBackgroundView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        sourceImageView.frame = self.detailFrame;
        
        [fromViewController.view removeFromSuperview];
        
        [UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            sourceImageView.frame = self.thumbnailFrame;
            blurredBackgroundView.effect = nil;
        } completion:^(BOOL finished) {
            [sourceImageView removeFromSuperview];
            [blurredBackgroundView removeFromSuperview];
            
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}


- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.isPresenting = YES;
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.isPresenting = NO;
    return self;
}

@end
