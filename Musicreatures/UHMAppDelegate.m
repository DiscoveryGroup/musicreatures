//
//  UHMAppDelegate.m
//  Musicreatures
//
//  Created by Petri J Myllys on 26/06/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMAppDelegate.h"
#import "UHMAudioController.h"
#import "UHMMotionController.h"
#import "UHMPlayViewController.h"
#import "UHMPlayScene.h"

@interface UHMAppDelegate()

@property (weak, nonatomic) UIViewController *rootViewController;
@property (weak, nonatomic) UIViewController *presentedViewController;

/// View currently topmost.
@property (weak, nonatomic) UIView *topView;

/// Scene currently presented.
@property (weak, nonatomic) SKScene *presentedScene;

@end

@implementation UHMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    if ([self.rootViewController isMemberOfClass:[UHMPlayViewController class]] &&
        self.presentedViewController == NULL &&
        [self.presentedScene isMemberOfClass:[UHMPlayScene class]]) {
        
        ((UHMAbstractPlayScene*)self.presentedScene).pauseMode = YES;
        [[UHMMotionController sharedMotionController] setActive:NO];
    }
    
    else {
        [[UHMAudioController sharedAudioController] setActive:NO];
        [[UHMMotionController sharedMotionController] setActive:NO];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[UHMMotionController sharedMotionController] setActive:YES];
    
    if ([self.rootViewController isMemberOfClass:[UHMPlayViewController class]] &&
        self.presentedViewController == NULL &&
        [self.presentedScene isMemberOfClass:[UHMMenuScene class]]) {
        
        return;
    }
    
    else {
        [[UHMAudioController sharedAudioController] setActive:YES];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Getters

-(UIViewController*)rootViewController {
    return [[UIApplication sharedApplication] keyWindow].rootViewController;
}

-(UIViewController*)presentedViewController {
    return self.rootViewController.presentedViewController;
}

-(UIView*)topView {
    return self.rootViewController.view;
}

-(SKScene*)presentedScene {
    if ([self.topView isMemberOfClass:[SKView class]])
        return ((SKScene*)self.topView).scene;
    else
        return NULL;
}

@end
