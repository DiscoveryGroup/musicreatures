//
//  UHMMainMenuScene.m
//  Musicreatures
//
//  Created by Petri J Myllys on 02/07/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMMainMenuScene.h"
#import "UHMAppDelegate.h"
#import "UHMPlayViewController.h"
#import "UHMCameraViewController.h"
#import "UHMAudioController.h"
#import "UHMIntroScene.h"
#import "UIButton+MusicreaturesButton.h"
#import "UHMAboutScene.h"
#import "UHMPlayModes.h"
#import "UHMTutorialScene.h"

static BOOL SHOW_VERSION_NUMBER = NO;

@interface UHMMainMenuScene()

@property (strong, nonatomic) SKLabelNode *title;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UIButton *tutorialButton;
@property (strong, nonatomic) UILabel *loadingText;

/// Background particle emitter.
@property (strong, nonatomic) SKEmitterNode *bgParticles;

/**
 Pulsation animation.
 */
SKAction* pulseAction();

/**
 Fade out animation.
 */
SKAction* fadeOut();

/**
 Fade in animation.
 */
SKAction* fadeIn();

@end

@implementation UHMMainMenuScene

-(id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    
    if (self) {
        [self createBackground];
        [self createParticles];
        [self createTitle];

        if (SHOW_VERSION_NUMBER) [self showVersionInformation];
    }
    
    return self;
}

-(void)didMoveToView:(SKView *)view {
    SKAction *moveAction = [SKAction moveTo:CGPointMake(self.frame.size.width/2, self.frame.size.height - 60.0) duration:0.5];
    moveAction.timingMode = SKActionTimingEaseOut;
    
    UHMAppDelegate *app = (UHMAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (!app.hasLaunched) {
        [self.title runAction:moveAction];
        [self createButtons];
        app.hasLaunched = YES;
    }
    
    else {
        [self.title runAction:moveAction completion:^{
            [self createButtons];
        }];
    }
}

/**
 Creates background elements.
*/
-(void)createBackground {
    SKSpriteNode *background = [[SKSpriteNode alloc] initWithImageNamed:@"launch"];
    background.size = self.frame.size;
    background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:background];
}

/**
 Creates background particle emitter.
 */
-(void)createParticles {
    NSString *backgroundParticlesPath = [[NSBundle mainBundle] pathForResource:@"BackgroundParticles"
                                                                        ofType:@"sks"];
    
    self.bgParticles = [NSKeyedUnarchiver unarchiveObjectWithFile:backgroundParticlesPath];
    
    self.bgParticles.position = CGPointMake(0, 0);
    self.bgParticles.name = @"backgroundParticles";
    [self addChild:self.bgParticles];
}

/**
 Creates text title.
*/
-(void)createTitle {
    self.title = [[SKLabelNode alloc] initWithFontNamed:@"HelveticaNeue-UltraLight"];
    self.title.position = CGPointMake(self.frame.size.width/2, self.frame.size.height - self.title.frame.size.height / 2);
    self.title.text = NSLocalizedString(@"Musicreatures", nil);
    self.title.fontSize = 42;
    self.title.fontColor = [SKColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    self.title.alpha = 0.4;
    [self addChild:self.title];
}

/**
 Creates buttons.
*/
-(void)createButtons {
    self.playButton = [UIButton buttonWithMusicreaturesStyle];
    self.playButton.frame = CGRectMake(CGRectGetMidX(self.frame) - k_buttonWidth / 2,
                                       CGRectGetMidY(self.frame) - k_buttonHeight / 2 - 10.0,
                                       k_buttonWidth,
                                       k_buttonHeight);
    [self.playButton setTitle:NSLocalizedString(@"Play", nil)];
    [self.playButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    self.playButton.alpha = 0.0;
    [self.view addSubview:self.playButton];
    
    self.tutorialButton = [UIButton buttonWithMusicreaturesStyle];
    self.tutorialButton.frame = CGRectMake(self.playButton.frame.origin.x,
                                           self.playButton.frame.origin.y + k_buttonHeight + k_buttonPaddingBottom,
                                           k_buttonWidth,
                                           k_buttonHeight);
    
    [self.tutorialButton setTitle:NSLocalizedString(@"Learn", nil)];
    [self.tutorialButton addTarget:self action:@selector(startTutorial) forControlEvents:UIControlEventTouchUpInside];
    self.tutorialButton.alpha = 0.0;
    [self.view addSubview:self.tutorialButton];
    
    self.aboutButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width/2.0 - 100.0,
                                                                  self.frame.size.height - 70.0,
                                                                  200.0,
                                                                  50.0)];
    [self.aboutButton addTarget:self action:@selector(showInformation) forControlEvents:UIControlEventTouchUpInside];
    [self.aboutButton setTitle:NSLocalizedString(@"About Musicreatures", nil) forState:UIControlStateNormal];
    self.aboutButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    self.aboutButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self.aboutButton setTitleColor:[SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8] forState:UIControlStateNormal];
    [self.aboutButton setTitleColor:[SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5] forState:UIControlStateHighlighted];
    self.aboutButton.alpha = 0.0;
    
    [self.view addSubview:self.aboutButton];
    
    [UIButton matchSizesForButtons:@[self.playButton, self.tutorialButton]];
    
    [UIView animateWithDuration:0.4 animations:^{
        self.playButton.alpha = 1.0;
        self.tutorialButton.alpha = 1.0;
        self.aboutButton.alpha = 1.0;
    }];
}

/**
 Show app version information for debugging purposes.
*/
-(void)showVersionInformation {
    SKLabelNode *details = [[SKLabelNode alloc] initWithFontNamed:@"HelveticaNeue-Light"];
    details.position = CGPointMake(self.frame.size.width/2, 2.0);
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    NSString *bundleName = infoDictionary[(NSString *)kCFBundleNameKey];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = infoDictionary[(NSString*)kCFBundleVersionKey];
    
    details.text = [NSString stringWithFormat:@"%@ %@%@%@", bundleName, version, @".", build];
    details.fontSize = 14;
    details.fontColor = [SKColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
    
    [self addChild:details];
}

/**
 Present information about Musicreatures, University, and the research.
 */
-(void)showInformation {
    [UIView animateWithDuration:0.4 animations:^{
        self.playButton.alpha = 0.0;
        self.tutorialButton.alpha = 0.0;
    } completion:^(BOOL completed) {
        [self.playButton removeFromSuperview];
        [self.tutorialButton removeFromSuperview];
        
        [UIView animateWithDuration:0.5 animations:^{
            self.aboutButton.userInteractionEnabled = NO;
            self.aboutButton.frame = CGRectMake(self.aboutButton.frame.origin.x,
                                                10.0,
                                                self.aboutButton.frame.size.width,
                                                self.aboutButton.frame.size.height);
        }];
        
        UHMAboutScene *about = [[UHMAboutScene alloc] init];
        about.presenter = self;
        about.backgroundColor = [UIColor colorWithRed:0.184 green:0.463 blue:0.588 alpha:1.0];
        [self.view presentScene:about transition:[SKTransition crossFadeWithDuration:0.5]];
    }];
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
    [self fadeOutButtons];
    
    [UIView animateWithDuration:0.4 animations:^{
        self.bgParticles.alpha = 0.0;
    } completion:nil];
    
    UHMPlayViewController *viewController =
    (UHMPlayViewController*)((UHMAppDelegate*)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    
    if ([mode isEqualToString:@"play"])
        [viewController play];
    else
        [viewController startTutorial];
}

-(void)fadeOutButtons {
    [UIView animateWithDuration:0.4 animations:^{
        self.playButton.alpha = 0.0;
        self.tutorialButton.alpha = 0.0;
        self.aboutButton.alpha = 0.0;
    } completion:^(BOOL completed) {
        [self.playButton removeFromSuperview];
        [self.tutorialButton removeFromSuperview];
        [self.aboutButton removeFromSuperview];
    }];
}

#pragma mark - Animations

SKAction* pulseAction() {
    SKAction *inflate = [SKAction scaleTo:1.2 duration:0.1];
    inflate.timingMode = SKActionTimingEaseOut;
    
    SKAction *deflate = [SKAction scaleTo:1.0 duration:0.5];
    deflate.timingMode = SKActionTimingEaseOut;
    
    SKAction *wait = [SKAction waitForDuration:0.5];
    
    return [SKAction sequence:@[inflate, deflate, wait]];
}

SKAction* fadeOut() {
    return [SKAction fadeAlphaTo:0.0 duration:0.2];
}

SKAction* fadeIn() {
    return [SKAction fadeAlphaTo:0.5 duration:0.3];
}

@end