//
//  UHMMenuScene.m
//  Musicreatures
//
//  Created by Petri J Myllys on 04/08/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMMenuScene.h"
#import "UHMAppDelegate.h"
#import "UHMPlayViewController.h"
#import "UHMCreature.h"
#import "UIButton+MusicreaturesButton.h"
#import "UHMProgressMeter.h"
#import "UHMMainMenuScene.h"
#import "UHMPlayScene.h"

typedef enum {
    PROGRESS_METER = 1
} TaggedElement;

typedef void(^ShareTransitionCompleted)(BOOL);
typedef void(^ButtonRemovalCompleted)(BOOL completed);

@interface UHMMenuScene() {
    float _menuTopElementVerticalPosition;
    float _menuBottomElementVerticalPosition;
}

@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) UIView *menuView;
@property (strong, nonatomic) UIView *shareView;

@property (nonatomic, readwrite) BOOL isConvertingAudio;

@end

@implementation UHMMenuScene

@synthesize pathToAudioFile;

+(id)sceneWithSize:(CGSize)size {
    return [[self alloc] initWithSize:size];
}

-(id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    
    if (self) {
        [self createBackground];
        _menuTopElementVerticalPosition = 80.0;
    }
    
    return self;
}

-(void)createBackground {
    self.background = [[SKSpriteNode alloc] init];
    self.background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    self.background.size = CGSizeMake(self.frame.size.width, self.frame.size.height);
    self.background.color = [SKColor blackColor];
    self.background.colorBlendFactor = 0.65;
    [self addChild:self.background];
}

-(void)createTitle {
    self.title = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 25.0, self.view.frame.size.width, 50.0)];
    self.title.text = NSLocalizedString(@"Paused", nil);
    self.title.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:36];
    self.title.textAlignment = NSTextAlignmentCenter;
    self.title.textColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.6];
    [self.view addSubview:self.title];
}

-(void)didMoveToView:(SKView *)view {
    [[UHMAudioController sharedAudioController] pauseRecording];
    
    [self createMenuElements];
    [self createShareElements];
    [self createTitle];
    
    self.menuView.alpha = 0.0;
    [self.view addSubview:self.menuView];
    [UIView animateWithDuration:0.5 animations:^{
        self.menuView.alpha = 1.0;
    } completion:nil];
    
    UHMPlayViewController *viewController =
    (UHMPlayViewController*)((UHMAppDelegate*)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    
    if (viewController.helpPopup) {
        [viewController.helpPopup remove];
        viewController.helpPopup = nil;
    }
}

-(void)willMoveFromView:(SKView *)view {
//    for (UIView *subview in self.view.subviews) {
//        [subview removeFromSuperview];
//    }
    
    self.userInteractionEnabled = NO;
}

-(void)createMenuElements {
    self.menuView = [[UIView alloc] initWithFrame:self.frame];
    
    UIButton *continueButton = [UIButton buttonWithMusicreaturesStyle];
    
    [continueButton setTitle:NSLocalizedString(@"Continue", nil)];
    [continueButton addTarget:self action:@selector(unpause) forControlEvents:UIControlEventTouchUpInside];
    
    continueButton.frame = CGRectMake(CGRectGetMidX(self.frame) - k_buttonWidth,
                                      _menuTopElementVerticalPosition + k_buttonHeight / 2,
                                      k_buttonWidth * 2.0,
                                      k_buttonHeight);
    [self.menuView addSubview:continueButton];
    
    UIButton *takeNewPhotoButton = [UIButton buttonWithMusicreaturesStyle];
    takeNewPhotoButton.frame = CGRectMake(CGRectGetMidX(self.frame) - k_buttonWidth,
                                          continueButton.frame.origin.y + k_buttonHeight + k_buttonPaddingBottom,
                                          k_buttonWidth * 2.0,
                                          k_buttonHeight);
    
    [takeNewPhotoButton setTitle:(NSLocalizedString(@"New photo", nil))];
    [takeNewPhotoButton addTarget:self action:@selector(reset) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:takeNewPhotoButton];
    
    UIButton *mainMenuButton = [UIButton buttonWithMusicreaturesStyle];
    mainMenuButton.frame = CGRectMake(CGRectGetMidX(self.frame) - k_buttonWidth,
                                      takeNewPhotoButton.frame.origin.y + k_buttonHeight + k_buttonPaddingBottom,
                                      k_buttonWidth * 2.0,
                                      k_buttonHeight);
    
    [mainMenuButton setTitle:NSLocalizedString(@"Main menu", nil)];
    [mainMenuButton addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:mainMenuButton];
    
    UIButton *shareButton = [UIButton buttonWithMusicreaturesStyle];
    shareButton.frame = CGRectMake(CGRectGetMidX(self.frame) - k_buttonWidth,
                                   mainMenuButton.frame.origin.y + k_buttonHeight + k_buttonPaddingBottom,
                                   k_buttonWidth * 2.0,
                                   k_buttonHeight);
    
    [shareButton setTitle:NSLocalizedString(@"Stop and share", nil)];
    
    [UIButton matchSizesForButtons:@[continueButton, takeNewPhotoButton, mainMenuButton, shareButton]];
    
    UHMPlayViewController *viewController =
    (UHMPlayViewController*)((UHMAppDelegate*)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    
    if (viewController.playScene.sharable) {
        [shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    }
    
    else {
        shareButton.alpha = 0.2;
        shareButton.userInteractionEnabled = NO;
    }
    
    [self.menuView addSubview:shareButton];
    
    _menuBottomElementVerticalPosition = shareButton.frame.origin.y;
}

-(void)createShareElements {
    self.shareView = [[UIView alloc] initWithFrame:self.frame];
    
    float progressMeterFrameSideLength = self.frame.size.width * 3.0 / 4.0;
    UHMProgressMeter *conversionProgressMeter = [[UHMProgressMeter alloc] initWithFrame:CGRectMake((self.frame.size.width - progressMeterFrameSideLength) / 2.0,
                                                                                                   _menuTopElementVerticalPosition,
                                                                                                   progressMeterFrameSideLength,
                                                                                                   progressMeterFrameSideLength)];
    conversionProgressMeter.tag = PROGRESS_METER;
    [self.shareView addSubview:conversionProgressMeter];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = NSLocalizedString(@"Preparing", nil);
    label.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:36];
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    label.frame = CGRectMake(CGRectGetMidX(self.frame) - label.frame.size.width / 2.0,
                             conversionProgressMeter.frame.origin.y + conversionProgressMeter.frame.size.height / 2.0 - label.frame.size.height / 2.0,
                             label.frame.size.width,
                             label.frame.size.height);
    label.textColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.8];
    [self.shareView addSubview:label];
    
    UIButton *conversionCancelButton = [UIButton buttonWithMusicreaturesStyle];
    conversionCancelButton.frame = CGRectMake(CGRectGetMidX(self.frame) - k_buttonWidth,
                                              _menuBottomElementVerticalPosition,
                                              k_buttonWidth * 2.0,
                                              k_buttonHeight);
    
    [conversionCancelButton setTitle:NSLocalizedString(@"Skip sharing", nil) forState:UIControlStateNormal];
    [conversionCancelButton addTarget:self action:@selector(cancelConversion) forControlEvents:UIControlEventTouchUpInside];
    [self.shareView addSubview:conversionCancelButton];
    [conversionCancelButton autosize];
    
    self.shareView.alpha = 0.0;
    self.shareView.frame = CGRectMake(self.frame.size.width,
                                      0.0,
                                      self.shareView.frame.size.width,
                                      self.shareView.frame.size.height);
}

-(void)unpause {
    UHMPlayViewController *viewController =
    (UHMPlayViewController*)((UHMAppDelegate*)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    
    viewController.playScene.pauseMode = NO;
    [[UHMAudioController sharedAudioController] unpauseRecording];
    [self removeButtons:nil];
    [self.view presentScene:viewController.playScene transition:[SKTransition crossFadeWithDuration:0.5]];
}

-(void)reset {
    UHMPlayViewController *viewController =
    (UHMPlayViewController*)((UHMAppDelegate*)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    
    [self removeButtons:nil];
    [viewController resetToCamera];
}

-(void)removeButtons:(ButtonRemovalCompleted)completion {
    [UIView animateWithDuration:0.4 animations:^{
        for (UIView *subview in self.view.subviews) {
            subview.alpha = 0.0;
        }
    } completion:^(BOOL finished) {
        for (UIView *subview in self.view.subviews) {
            [subview removeFromSuperview];
        }
        
        if (!completion) return;
        completion(YES);
    }];
}

#pragma mark - Sharing

/**
 Initiates the audio file sharing.
 */
-(void)share{
    self.isConvertingAudio = YES;
    
    [self moveToConversionViewWithCompletionHandler:^(BOOL completion) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        NSString *sourcePath = [documentsPath stringByAppendingString:@"/recorded.wav"];
        
        [self convertAudioFromPath:sourcePath];
    }];
}

/**
 Converts audio from uncompressed wave format to compressed aac.
 @param sourcePath  Path to the source audio file in wave format.
 */
-(void)convertAudioFromPath:(NSString*)sourcePath {
    [self stopAudio];
    self.view.paused = YES;
    self.pathToAudioFile = sourcePath;
    
    [[UHMAudioController sharedAudioController] convertAudioFromPath:sourcePath
                                                    progressDelegate:self
                                                        fileDelegate:self
                                                          completion:^
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                self.shareView.alpha = 0.0;
            } completion:^(BOOL finished)
             {
                 self.view.paused = NO;
                 [self.shareView removeFromSuperview];
                 
                 // Present sharing options
                 
                 if ([[UHMAudioController sharedAudioController] fadeOutFinishedSuccessfully]) [self showSharingOptions];
             }];
        });
    }];
}

/**
 Stops the audio recording and playback.
 */
-(void)stopAudio {
    [[UHMAudioController sharedAudioController] stopRecording];
    [[UHMAudioController sharedAudioController] setActive:NO];
    [[UHMAudioController sharedAudioController] resetAudio];
}

/**
 Changes the menu to reflect the audio exporting progress.
 @param completionBlock Completion handler for the exporting process.
 */
-(void)moveToConversionViewWithCompletionHandler:(ShareTransitionCompleted)completionBlock {
    for (UIView *view in self.menuView.subviews) view.userInteractionEnabled = NO;
    for (UIView *view in self.shareView.subviews) view.userInteractionEnabled = YES;
    
    [self.view addSubview:self.shareView];
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.title.alpha = 0.0;
        
        self.menuView.alpha = 0.0;
        self.menuView.frame = CGRectMake(-self.frame.size.width,
                                         0.0,
                                         self.menuView.frame.size.width,
                                         self.menuView.frame.size.height);
        
        self.shareView.alpha = 1.0;
        self.shareView.frame = self.view.frame;
    } completion:^(BOOL finished) {
        [self.menuView removeFromSuperview];
        completionBlock(YES);
    }];
}

/**
 Displays the sharing options.
 */
-(void)showSharingOptions {
    UHMPlayViewController *viewController =
    (UHMPlayViewController*)((UHMAppDelegate*)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    
    NSURL *soundFileUrl = [NSURL fileURLWithPath:self.pathToAudioFile isDirectory:NO];
    NSArray *activityItems = @[soundFileUrl];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [viewController presentViewController:controller animated:YES completion:nil];
    [controller setCompletionHandler:^(NSString *activityType, BOOL completed) {
        [[UHMAudioController sharedAudioController] purgeTemporaryFiles];
        [self exit];
    }];
}

/**
 Cancels the wave-to-aac audio conversion.
 */
-(void)cancelConversion {
    [[UHMAudioController sharedAudioController] cancelConversion];
    [[UHMAudioController sharedAudioController] purgeTemporaryFiles];
    self.view.paused = NO;
    [self exit];
}

/**
 Stops audio and exits the play scene.
 */
-(void)exit {
    UHMPlayViewController *viewController =
    (UHMPlayViewController*)((UHMAppDelegate*)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    
    [self removeButtons:^(BOOL completed) {
        [viewController resetToMenu];
    }];
}

#pragma mark - Audio conversion progress delegate methods

-(void)didMakeAudioConversionProgress:(Float64)progress {
    [((UHMProgressMeter*)[self.shareView viewWithTag:PROGRESS_METER]) setProgress:progress];
}

-(void)didFinishAudioConversion {
    [((UHMProgressMeter*)[self.shareView viewWithTag:PROGRESS_METER]) setProgress:1.0f];
}

@end
