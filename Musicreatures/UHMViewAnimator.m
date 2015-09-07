//
//  UHMViewAnimator.m
//  Musicreatures
//
//  Created by Petri J Myllys on 29/07/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMViewAnimator.h"
#import "UHMPlayViewController.h"

@interface UHMViewAnimator()

static void crossfadeControllers(UIViewController *fromController, UIViewController *toController);

@end

@implementation UHMViewAnimator

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    [[transitionContext containerView] addSubview:toViewController.view];
    toViewController.view.alpha = 0;
    
    if ([toViewController isKindOfClass:[UHMPlayViewController class]]) {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            float scalingFactor = BACKGROUND_SCALE / CAMERA_FRAME_SIZE_MULTIPLIER;
            fromViewController.view.transform = CGAffineTransformMakeScale(scalingFactor, scalingFactor);
            crossfadeControllers(fromViewController, toViewController);
        } completion:^(BOOL finished) {
            fromViewController.view.transform = CGAffineTransformIdentity;
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
    
    else {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromViewController.view.transform = CGAffineTransformMakeScale(4, 4);
            crossfadeControllers(fromViewController, toViewController);
        } completion:^(BOOL finished) {
            fromViewController.view.transform = CGAffineTransformIdentity;
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
}

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1.0;
}

static void crossfadeControllers(UIViewController *fromController, UIViewController *toController) {
    fromController.view.alpha = 0.0f;
    toController.view.alpha = 1.0f;
}

@end
