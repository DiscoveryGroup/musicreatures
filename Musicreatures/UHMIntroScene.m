//
//  UHMIntroScene.m
//  Musicreatures
//
//  Created by Petri J Myllys on 22/08/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMIntroScene.h"
#import "UHMMainMenuScene.h"
#import "UIButton+MusicreaturesButton.h"
#import "UHMAppDelegate.h"
#import "UHMPlayViewController.h"

static CGFloat k_welcomeMessagePaddingTop = 60.0f;
static CGFloat k_welcomeMessageRowPadding = 40.0f;

@interface UHMIntroScene()

/// Welcome message displayed when the tutorial starts.
@property (strong, nonatomic) NSMutableArray *welcomeMessage;

/// Text for the tutorial page currently displayed.
@property (strong, nonatomic) UILabel *currentText;

/// Button for viewing the tutorial.
@property (strong, nonatomic) UIButton *okButton;

/// Button for skipping the tutorial.
@property (strong, nonatomic) UIButton *skipButton;

/// Button for displaying the next tutorial page.
@property (strong, nonatomic) UIButton *nextButton;

/// Background particles.
@property (strong, nonatomic) SKEmitterNode *particles;

/// Animation for demonstrating the look of pulses.
@property (strong, nonatomic) SKSpriteNode *pulseAnimation;

/// Animation for demonstrating the look of rests.
@property (strong, nonatomic) SKSpriteNode *restAnimation;

@end

@implementation UHMIntroScene

-(id)initWithSize:(CGSize)size{
    return [self initWithSize:size initialPage:0];
}

-(id)initWithSize:(CGSize)size initialPage:(int)page {
    self = [super initWithSize:size];
    
    if (self) {
        SKSpriteNode *background = [[SKSpriteNode alloc] initWithImageNamed:@"launch"];
        background.size = self.frame.size;
        background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:background];
        [self addParticles];
    }
    
    return self;
}

#pragma mark - Scene elements

/**
 Adds a background particle emitter to the scene.
 */
-(void)addParticles {
    NSString *backgroundParticlesPath = [[NSBundle mainBundle] pathForResource:@"BackgroundParticles"
                                                                        ofType:@"sks"];
    
    self.particles = [NSKeyedUnarchiver unarchiveObjectWithFile:backgroundParticlesPath];
    
    self.particles.position = CGPointMake(0, 0);
    self.particles.name = @"backgroundParticles";
    [self addChild:self.particles];
}

-(void)didMoveToView:(SKView *)view {
    [self createTextField];
    [self createWelcomeMessage];
    [self createButtons];
}

/**
 Adds an initial welcome message to the scene.
 */
-(void)createWelcomeMessage {
    self.welcomeMessage = [[NSMutableArray alloc] init];
    NSArray *welcomeMessageParts = [NSLocalizedString(@"Welcome to Musicreatures", nil) componentsSeparatedByString:@" "];
    
    for (NSString *part in welcomeMessageParts) {
        SKLabelNode *text = [[SKLabelNode alloc] initWithFontNamed:@"HelveticaNeue-UltraLight"];
        text.text = part;
        text.fontSize = 42;
        text.fontColor = [SKColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
        text.alpha = 0.0;
        
        [self.welcomeMessage addObject:text];
        [self addChild:text];
    }
    
    for (int textRow = 0; textRow < self.welcomeMessage.count; textRow++) {
        SKLabelNode *row = (SKLabelNode*)[self.welcomeMessage objectAtIndex:textRow];
        
        if (textRow == 0)
            row.position = CGPointMake(CGRectGetMidX(self.frame),
                                       self.frame.size.height - k_welcomeMessagePaddingTop);
        
        else
            row.position = CGPointMake(CGRectGetMidX(self.frame),
                                       self.frame.size.height - k_welcomeMessagePaddingTop - textRow * k_welcomeMessageRowPadding);
        
        [row runAction:[SKAction fadeAlphaTo:0.5 duration:0.4]];
    }
}

/**
 Adds a text field to the scene.
 */
-(void)createTextField {
    self.currentText = [[UILabel alloc] init];
    
    CGFloat padding = 10.0f;
    self.currentText.frame = CGRectMake(padding, padding, self.frame.size.width - padding * 2, self.frame.size.height - padding * 2);
    self.currentText.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:22];
    self.currentText.textColor = [SKColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    self.currentText.alpha = 0.8;
    self.currentText.textAlignment = NSTextAlignmentCenter;
    self.currentText.numberOfLines = 0;
    self.currentText.text = NSLocalizedString(@"Please learn", nil);
    [self.view addSubview:self.currentText];
}

/**
 Adds buttons for displaying and skipping the tutorial to the scene.
 */
-(void)createButtons {
    self.skipButton = [UIButton buttonWithMusicreaturesStyle];
    self.skipButton.frame = CGRectMake(self.frame.size.width / 4 - k_buttonWidth / 2,
                                       self.frame.size.height - k_buttonHeight - k_buttonPaddingBottom,
                                       k_buttonWidth,
                                       k_buttonHeight);
    
    [self.skipButton setTitle:NSLocalizedString(@"Skip", nil)];
    [self.skipButton addTarget:self action:@selector(moveToMenu) forControlEvents:UIControlEventTouchUpInside];
    
    self.okButton = [UIButton buttonWithMusicreaturesStyle];
    self.okButton.frame = CGRectMake(self.frame.size.width / 4 * 3 - k_buttonWidth / 2,
                                     self.frame.size.height - k_buttonHeight - k_buttonPaddingBottom,
                                     k_buttonWidth,
                                     k_buttonHeight);
    
    [self.okButton setTitle:NSLocalizedString(@"Ok", nil)];
    [self.okButton addTarget:self action:@selector(moveToTutorial) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.okButton];
    [self.view addSubview:self.skipButton];
}

#pragma mark - Navigation

/**
 Moves to the main menu from the initial screen.
 */
-(void)moveToMenu {
    for (SKLabelNode *row in self.welcomeMessage) {
        [row removeAllActions];
        [row runAction:[SKAction fadeAlphaTo:0.0 duration:0.5]];
    }
    
    [self.particles runAction:[SKAction fadeAlphaTo:0.0 duration:0.5]];
    
    [UIView animateWithDuration:1.0 animations:^{
        for (UIView *view in self.view.subviews) {
            view.alpha = 0.0;
        }
        
    } completion:^(BOOL finished) {
        for (UIView *view in self.view.subviews) {
            [view removeFromSuperview];
        }
        
        SKView *skView = (SKView*)self.view;
        UHMMainMenuScene *mainMenu = [UHMMainMenuScene sceneWithSize:skView.bounds.size];
        mainMenu.scaleMode = SKSceneScaleModeAspectFill;
        [skView presentScene:mainMenu];
    }];
}

/**
 Moves to the tutorial from the initial screen.
 */
-(void)moveToTutorial {
    NSMutableArray *currentViews = [[NSMutableArray alloc] init];
    for (UIView *view in self.view.subviews) {
        [currentViews addObject:view];
    }
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.skipButton.center = CGPointMake(self.skipButton.center.x, self.skipButton.center.y - 10.0);
        self.okButton.center = CGPointMake(self.okButton.center.x, self.okButton.center.y - 10.0);
    } completion:^(BOOL finished){
        for (SKLabelNode *row in self.welcomeMessage) {
            [row removeAllActions];
            [row runAction:[SKAction fadeAlphaTo:0.0 duration:0.3]];
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            for (UIView *view in currentViews) {
                view.alpha = 0.0;
            }
            
        } completion:^(BOOL finished) {
            for (UIView *view in currentViews) {
                [view removeFromSuperview];
            }
        }];
        
        [self.particles runAction:[SKAction fadeAlphaTo:0.0 duration:0.5]];
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.skipButton.center = CGPointMake(self.skipButton.center.x, self.frame.size.height + self.skipButton.frame.size.height);
            self.okButton.center = CGPointMake(self.okButton.center.x, self.frame.size.height + self.okButton.frame.size.height);
            
        } completion:^(BOOL finished){
            [self.skipButton removeFromSuperview];
            self.skipButton = nil;
            [self.okButton removeFromSuperview];
            self.okButton = nil;
            
            UHMPlayViewController *viewController =
            (UHMPlayViewController*)((UHMAppDelegate*)[[UIApplication sharedApplication] delegate]).window.rootViewController;
            [viewController startTutorial];
        }];
    }];
    
}

@end
