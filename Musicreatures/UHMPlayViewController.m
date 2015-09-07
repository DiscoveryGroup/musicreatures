//
//  UHMPlayViewController.m
//  Musicreatures
//
//  Created by Petri J Myllys on 26/06/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMPlayViewController.h"
#import "UHMIntroScene.h"
#import "UHMTutorialScene.h"
#import "UHMMainMenuScene.h"
#import "UHMPlayScene.h"
#import "UHMAppDelegate.h"
#import "UHMPitchedCreature.h"
#import "UHMViewAnimator.h"
#import "UHMActivityIndicator.h"

@interface UHMPlayViewController()

@property (strong, nonatomic) UHMActivityIndicator *activityIndicator;
@property (nonatomic) BOOL tutorialMode;

@end

@implementation UHMPlayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Touch
    
    self.view.multipleTouchEnabled = YES;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    SKView *skView = (SKView*)self.view;
    
    if (!skView.scene) {
//        skView.frameInterval = 2;
        
        skView.showsFPS = NO;
        skView.showsNodeCount = NO;
        skView.showsDrawCount = NO;
        skView.showsPhysics = NO;
        
        // Scenes
        
        [self presentScene];
    }
}

-(void)presentScene {
    SKView *skView = (SKView*)self.view;
    SKScene *sceneToPresent;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenTutorial"]) {
        sceneToPresent = [UHMIntroScene sceneWithSize:skView.bounds.size];
    }
    else {
        sceneToPresent = [UHMMainMenuScene sceneWithSize:skView.bounds.size];
    }

    sceneToPresent.scaleMode = SKSceneScaleModeAspectFill;
    [skView presentScene:sceneToPresent];
}

/**
 Moves to the Musicreatures play mode. Animates current elements and the transition to the next view controller.
 */
-(void)play {
    [self preparePlaySceneWithMode:@"play"];
}

/**
 Starts the tutorial.
 */
-(void)startTutorial {
    [self preparePlaySceneWithMode:@"tutorial"];
}

-(void)preparePlaySceneWithMode:(NSString*)mode {
    self.activityIndicator = [[UHMActivityIndicator alloc] init];
    self.activityIndicator.center = self.view.center;
    self.activityIndicator.alpha = 0.0;
    [self.view addSubview:self.activityIndicator];
    [UIView animateWithDuration:0.5 animations:^{
        self.activityIndicator.alpha = 1.0;
    } completion:nil];
    
    dispatch_queue_t sampleLoadQueue = dispatch_queue_create("Sample Loading Queue", NULL);
    dispatch_queue_t nextViewPreparationQueue = dispatch_queue_create("Next View Preparation Queue", NULL);
    
    dispatch_async(sampleLoadQueue, ^{
        if ([[UHMAudioController sharedAudioController] pdPatch] == nil) {
            [[UHMAudioController sharedAudioController] loadPatch];
            [[UHMAudioController sharedAudioController] loadSamples];
        }
    });
    
    dispatch_async(nextViewPreparationQueue, ^{
        [[UHMAudioController sharedAudioController] setActive:NO];
        
        if ([mode isEqualToString:@"play"]) {
            self.tutorialMode = NO;
            [self prepareForPlaying];
        }
        
        else {
            self.tutorialMode = YES;
            [self prepareForTutorial];
        }
    });
}

-(void)prepareForPlaying {
    UHMPlayViewController *viewController =
    (UHMPlayViewController*)((UHMAppDelegate*)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    SKView *skView = (SKView*)viewController.view;
    
    viewController.playScene = [UHMPlayScene sceneWithSize:skView.bounds.size];
    viewController.playScene.scaleMode = SKSceneScaleModeAspectFill;
    viewController.playScene.paused = YES;
    
    viewController.menuScene = [UHMMenuScene sceneWithSize:skView.bounds.size];
    viewController.menuScene.scaleMode = SKSceneScaleModeAspectFill;
    
//    captureController.modalPresentationStyle = UIModalPresentationCustom;
    UHMCameraViewController *captureController = [[UHMCameraViewController alloc] init];
    captureController.transitioningDelegate = viewController;
    captureController.imageDelegate = viewController;
    
    [self transitFromViewController:viewController toController:captureController];
}

-(void)prepareForTutorial {
    UHMPlayViewController *viewController =
    (UHMPlayViewController*)((UHMAppDelegate*)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    SKView *skView = (SKView*)viewController.view;
    UIImage *image = [UIImage imageNamed:@"tutorial_bg.jpg"];
    
    viewController.playScene = [UHMTutorialScene sceneWithSize:skView.bounds.size];
    viewController.playScene.scaleMode = SKSceneScaleModeAspectFill;
    viewController.playScene.paused = YES;
    
    viewController.menuScene = [UHMMenuScene sceneWithSize:skView.bounds.size];
    viewController.menuScene.scaleMode = SKSceneScaleModeAspectFill;
    
    [viewController didCaptureImage:image withError:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UHMAudioController sharedAudioController] setGlobalPlaybackState:YES];
        
        [self.activityIndicator finishActivityIndicationWithCompletion:^{
            self.activityIndicator = nil;
            [skView presentScene:viewController.playScene transition:[SKTransition crossFadeWithDuration:1.0]];
        }];
    });
}

/**
 Presents a new view controller with animation.
 @param fromController   View controller to transition from.
 @param toController     View controller to transition to.
 */
-(void)transitFromViewController:(UIViewController*)fromController toController:(UIViewController*)toController {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator finishActivityIndicationWithCompletion:^{
            self.activityIndicator = nil;
            [fromController presentViewController:toController animated:YES completion:nil];
        }];
    });
}

-(void)resetToMenu {
    [[UHMAudioController sharedAudioController] stopRecording];
    [[UHMAudioController sharedAudioController] setActive:NO];
    [[UHMAudioController sharedAudioController] resetAudio];
    [[UHMAudioController sharedAudioController] purgeTemporaryFiles];
    [self.playScene endGame];
    self.playScene = nil;
    self.menuScene = nil;
    
    SKView *skView = (SKView*)self.view;
    SKScene *mainMenu = [UHMMainMenuScene sceneWithSize:skView.bounds.size];
    mainMenu.scaleMode = SKSceneScaleModeAspectFill;
    [skView presentScene:mainMenu transition:[SKTransition crossFadeWithDuration:1.5]];
}

-(void)resetToCamera {
    [[UHMAudioController sharedAudioController] stopRecording];
    [[UHMAudioController sharedAudioController] setActive:NO];
    [[UHMAudioController sharedAudioController] resetAudio];
    [self.playScene endGame];
    self.playScene = nil;
    
    self.tutorialMode = NO;
    self.playScene = [UHMPlayScene sceneWithSize:self.view.bounds.size];
    self.playScene.scaleMode = SKSceneScaleModeAspectFill;
    self.playScene.paused = YES;
    
    UHMCameraViewController *captureController = [[UHMCameraViewController alloc] init];
    
    captureController.transitioningDelegate = self;
    captureController.imageDelegate = self;
    
    [self presentViewController:captureController animated:YES completion:nil];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(void)updatePulseIndex:(int)currentPulse forCreatureName:(NSString*)creatureName {
    for (UHMCreature* part in self.playScene.creatures) {
        if ([part.name isEqualToString:creatureName]) {
            part.currentStep = currentPulse;
        }
    }
}

#pragma mark - Image captured

-(void)didCaptureImage:(UIImage*)image withError:(NSError*)error
{
    if(!error) {
        [self.playScene createBackgroundWithImage:image];
        
        if (self.tutorialMode) [self.playScene configureMusicalPropertiesManually];
        else [self.playScene inspectBackgroundImage:image];
    }
    
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Capture Error"
                                                        message:@"Problem capturing photo."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
    }
}

-(void)didFinishCapturing {
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenCameraHelp"]) {
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenCameraHelp"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
}

#pragma mark - Transition

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    
    UHMViewAnimator *animator = [[UHMViewAnimator alloc] init];
    return animator;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    UHMViewAnimator *animator = [[UHMViewAnimator alloc] init];
    return animator;
}

@end
