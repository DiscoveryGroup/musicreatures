//
//  UHMTutorialScene.m
//  Musicreatures
//
//  Created by Petri J Myllys on 18/12/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMTutorialScene.h"
#import "UHMAbstractPlaySceneSubclass.h"
#import "UHMHelpPopup.h"
#import "NSMutableArray+Queue.h"
#import "UHMMotionController.h"
#import "UHMPulseProjectile.h"
#import "UHMRestProjectile.h"
#import "UIButton+MusicreaturesButton.h"
#import "UHMPlayViewController.h"
#import "UHMAppDelegate.h"
#import "UHMMainMenuScene.h"
#import "UHMActivityIndicator.h"
#import "UHMShadowedLabel.h"

@interface UHMTutorialScene()

@property (strong, nonatomic) UHMHelpPopup *helpPopup;
@property (strong, nonatomic) NSMutableArray *helpResourceQueue;
@property (nonatomic) BOOL allowTouch;
@property (nonatomic) BOOL allowSolo;
@property (nonatomic) double accumulatedRotation;
@property (nonatomic) double accumulatedAcceleration;
@property (strong, nonatomic) NSTimer *projectileLaunchTimer;
@property (strong, nonatomic) NSTimer *soloTimer;
@property (nonatomic) NSUInteger killCount;
@property (strong, nonatomic) UIButton *quitButton;
@property (nonatomic) BOOL willContinueToGame;

@end

@implementation UHMTutorialScene

-(id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    
    if (self) {
        self.allowTouch = YES;
        self.allowSolo = NO;
        
        self.helpResourceQueue = [[NSMutableArray alloc] init];
        [self.helpResourceQueue enqueue:@"MovingHelp"];
        [self.helpResourceQueue enqueue:@"ColorHelp"];
        [self.helpResourceQueue enqueue:@"ScatterHelp"];
        [self.helpResourceQueue enqueue:@"PulseHelp"];
        [self.helpResourceQueue enqueue:@"RestHelp"];
        [self.helpResourceQueue enqueue:@"ImprovisationHelp"];
        [self.helpResourceQueue enqueue:@"ImprovisationGesturesHelp"];
        [self.helpResourceQueue enqueue:@"LifespanHelp"];
        [self.helpResourceQueue enqueue:@"ReadyHelp"];
    }
    
    return self;
}

-(void)didMoveToView:(SKView *)view {
    self.helpPopup = [[UHMHelpPopup alloc] initWithFrame:CGRectMake(0.0f,
                                                                    0.0f,
                                                                    self.view.frame.size.width,
                                                                    0.0f)
                                          containerFrame:self.frame
                                                helpText:NSLocalizedString(@"CreateGroupHelp", nil)
                                          helpIdentifier:CREATE_GROUP_HELP];
    [self.view addSubview:self.helpPopup];
    [self.helpPopup addObserver:self forKeyPath:@"isHidden" options:NSKeyValueObservingOptionNew context:NULL];
    self.helpPopup.hidden = NO;
    
    self.quitButton = [UIButton buttonWithMusicreaturesStyle];
    self.quitButton.frame = CGRectMake(CGRectGetMidX(self.frame) - k_buttonWidth * 1.8 / 2,
                                       self.frame.size.height,
                                       k_buttonWidth * 1.8,
                                       k_buttonHeight);
    
    [self.quitButton setTitle:NSLocalizedString(@"Cancel tutorial", nil)];
    [self.quitButton addTarget:self action:@selector(quitTutorialWithPreparation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.quitButton];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.quitButton.center = CGPointMake(self.quitButton.center.x, self.frame.size.height - k_buttonHeight);
    }];
}

-(void)quitTutorialWithPreparation {
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.quitButton.center = CGPointMake(self.quitButton.center.x, self.quitButton.center.y - 10.0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.quitButton.center = CGPointMake(self.quitButton.center.x, self.frame.size.height + self.quitButton.frame.size.height);
        } completion:nil];
        
        [self quitTutorial];
    }];
}

-(void)quitTutorial {
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenCameraHelp"]) {
//        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hasSeenCameraHelp"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
    
    [self.helpPopup removeObserver:self forKeyPath:@"isHidden"];
    self.helpPopup.hidden = YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        for (UIView *subview in self.view.subviews) {
            subview.alpha = 0.0;
        }
    } completion:^(BOOL finished) {
        for (UIView *subview in self.view.subviews) {
            [subview removeFromSuperview];
        }
        
        [[UHMAudioController sharedAudioController] setActive:NO];
        [[UHMAudioController sharedAudioController] resetAudio];
        
        SKView *skView = (SKView*)self.view;
        SKScene *mainMenu = [UHMMainMenuScene sceneWithSize:skView.bounds.size];
        mainMenu.scaleMode = SKSceneScaleModeAspectFill;
        [skView presentScene:mainMenu transition:[SKTransition crossFadeWithDuration:0.5]];
    }];
}

-(void)continueToGame {
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenCameraHelp"]) {
//        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hasSeenCameraHelp"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
    
    [self.helpPopup removeObserver:self forKeyPath:@"isHidden"];
    self.helpPopup.hidden = YES;
    
    [UIView animateWithDuration:0.25 animations:^{
        for (UIView *subview in self.view.subviews) {
            subview.alpha = 0.0;
        }
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.view.alpha = 0.0;
                             self.view.transform = CGAffineTransformScale(self.view.transform, 1.2, 1.2);
                         } completion:^(BOOL finished) {
                             for (UIView *subview in self.view.subviews) {
                                 [subview removeFromSuperview];
                             }
                             
                             UHMPlayViewController *viewController =
                             (UHMPlayViewController*)((UHMAppDelegate*)[[UIApplication sharedApplication] delegate]).window.rootViewController;
                             [viewController resetToCamera];
                             self.willContinueToGame = YES;
                         }];
    }];
}

-(void)willMoveFromView:(SKView *)view {
    if (self.willContinueToGame) return;
    UHMPlayViewController *viewController =
    (UHMPlayViewController*)((UHMAppDelegate*)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    [viewController.playScene endGame];
    viewController.playScene = nil;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isKindOfClass:[UHMHelpPopup class]] && [keyPath isEqualToString:@"isHidden"]) {
        BOOL isHidden = [[change objectForKey: NSKeyValueChangeNewKey] boolValue];
        if (!isHidden) return;
        
        if (self.helpPopup.identifier == PULSE_HELP || self.helpPopup.identifier == REST_HELP) {
            [self.projectileLaunchTimer invalidate];
            self.projectileLaunchTimer = nil;
            
            for (UHMProjectile *projectile in self.projectiles) {
                [self removeProjectile:projectile];
            }
        }
        
        else if (self.helpPopup.identifier == READY_HELP) [self continueToGame];
        
        if (self.helpResourceQueue.count > 0) {
            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(teachNextItem) userInfo:nil repeats:NO];
        }
    }
}

-(void)setSolo:(BOOL)solo {
    if (!self.allowSolo) return;
    
    [super setSolo:solo];
    
//    if (self.helpPopup.identifier != IMPROVISATION_HELP) return;
//    
//    if (solo)
//        self.soloTimer = [NSTimer scheduledTimerWithTimeInterval:1.2 target:self selector:@selector(allowAdvancingFromSolo) userInfo:nil repeats:NO];
//    else {
//        [self.soloTimer invalidate];
//        self.soloTimer = nil;
//    }
    
}

-(void)allowAdvancingFromSolo {
    self.helpPopup.allowToBeDismissed = YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.allowTouch) return;
    
    if (!self.allowSolo) {
        [self spawnCreatureAtPosition:[[touches anyObject] locationInNode:self]];
        if (((self.helpPopup.identifier == CREATE_GROUP_HELP && !self.helpPopup.allowToBeDismissed) ||
            (self.helpPopup.identifier == CREATE_MORE_GROUPS_HELP && !self.helpPopup.allowToBeDismissed)) &&
            self.creatures.count > 2)
            self.helpPopup.allowToBeDismissed = YES;
        
        return;
    }
    
    //  A touch is already registered
    
    if (self.touchDurationTimer || self.solo) return;
    
    //  Touch began
    
    else {
        self.touchDurationTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                                   target:self
                                                                 selector:@selector(moveToSoloMode:)
                                                                 userInfo:[NSNumber numberWithBool:YES]
                                                                  repeats:NO];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.allowTouch) return;
    if (!self.allowSolo) return;
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    //  Disable solo mode
    
    if (self.solo) {
        self.solo = NO;
    }
    
    //  Spawn creature
    
    else if (self.partNames.count > 0) {
        [self spawnCreatureAtPosition:location];
        if ((self.helpPopup.identifier == CREATE_MORE_GROUPS_HELP && !self.helpPopup.allowToBeDismissed) && self.creatures.count > 2)
            self.helpPopup.allowToBeDismissed = YES;
    }
    
    //  Touch ended before solo timer finished
    
    if (!self.solo && self.touchDurationTimer) {
        [self.touchDurationTimer invalidate];
        self.touchDurationTimer = nil;
    }
}

-(void)spawnCreatureAtPosition:(CGPoint)position {
    UHMCreature *creature;
    
    NSString *creatureName = [self.partNames dequeue];
    if (!creatureName) return;
    
    if ([creatureName isEqualToString:@"mbira"] ||
        [creatureName isEqualToString:@"pizz"] ||
        [creatureName isEqualToString:@"bar"]) {
        creature = [self createPitchedCreatureWithName:creatureName position:position];
    }
    
    else {
        creature = [self createPercussiveCreatureWithName:creatureName position:position];
    }
    
    [self.creatures addObject:creature];
    [self.swarm addBoid:creature];
}

-(UHMPitchedCreature*)createPitchedCreatureWithName:(NSString*)name position:(CGPoint)position {
    return [[UHMPitchedCreature alloc] initWithName:name parentScene:self position:position mortal:NO];
}

-(UHMPercussiveCreature*)createPercussiveCreatureWithName:(NSString*)name position:(CGPoint)position {
    return [[UHMPercussiveCreature alloc] initWithName:name parentScene:self position:position mortal:NO];
}

-(void)launchPulseProjectile {
    UHMProjectile *projectile = [[UHMPulseProjectile alloc] init];
    [self launchProjectile:projectile];
}

-(void)launchRestProjectile {
    UHMProjectile *projectile = [[UHMRestProjectile alloc] init];
    [self launchProjectile:projectile];
}

-(void)launchProjectile:(UHMProjectile*)projectile {
    projectile.homingTarget = self.swarm;
    [self addChild:projectile];
    [self.projectiles addObject:projectile];
    [projectile.physicsBody applyImpulse:CGVectorMake(0, -1)];
    [self startProjectileLifespanForProjectile:projectile];
}

-(void)didBeginContact:(SKPhysicsContact *)contact {
    SKPhysicsBody *first;
    SKPhysicsBody *second;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        first = contact.bodyA;
        second = contact.bodyB;
    }
    
    else {
        first = contact.bodyB;
        second = contact.bodyA;
    }
    
    if (first.categoryBitMask == creatureCategory &&
        (second.categoryBitMask == stepProjectileCategory || second.categoryBitMask == pulseProjectileCategory))
    {
        self.helpPopup.allowToBeDismissed = YES;
    }
    
    [super didBeginContact:contact];
}

-(void)teachNextItem {
    NSString *upcomingHelpResource;
    if (self.creatures.count < 3 && self.helpResourceQueue.count > 1) upcomingHelpResource = @"CreateMoreGroupsHelp";
    else upcomingHelpResource = [self.helpResourceQueue dequeue];
    
    if ([upcomingHelpResource isEqualToString:@"CreateMoreGroupsHelp"]) {
        self.helpPopup.identifier = CREATE_MORE_GROUPS_HELP;
        self.helpPopup.allowToBeDismissed = NO;
    }
    
    else if ([upcomingHelpResource isEqualToString:@"MovingHelp"]) {
        self.helpPopup.identifier = MOVING_HELP;
        self.helpPopup.allowToBeDismissed = NO;
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(measureRotation:) userInfo:nil repeats:YES];
    }
    
    else if ([upcomingHelpResource isEqualToString:@"ColorHelp"]) {
        self.helpPopup.identifier = COLOR_HELP;
    }
    
    else if ([upcomingHelpResource isEqualToString:@"ScatterHelp"]) {
        self.helpPopup.identifier = SCATTER_HELP;
        self.helpPopup.allowToBeDismissed = NO;
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(measureCurrentAcceleration:) userInfo:nil repeats:YES];
    }
    
    else if ([upcomingHelpResource isEqualToString:@"PulseHelp"]) {
        self.helpPopup.identifier = PULSE_HELP;
        self.helpPopup.allowToBeDismissed = NO;
        [self launchPulseProjectile];
        self.projectileLaunchTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(launchPulseProjectile) userInfo:nil repeats:YES];
    }
    
    else if ([upcomingHelpResource isEqualToString:@"RestHelp"]) {
        self.helpPopup.identifier = REST_HELP;
        self.helpPopup.allowToBeDismissed = NO;
        [self launchRestProjectile];
        self.projectileLaunchTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(launchRestProjectile) userInfo:nil repeats:YES];
    }
    
    else if ([upcomingHelpResource isEqualToString:@"ImprovisationHelp"]) {
        self.helpPopup.identifier = IMPROVISATION_HELP;
        self.allowSolo = YES;
        self.helpPopup.allowToBeDismissed = NO;
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(measureAccumulatedAcceleration:) userInfo:nil repeats:YES];
    }
    
    else if ([upcomingHelpResource isEqualToString:@"ImprovisationGesturesHelp"]) {
        self.helpPopup.identifier = IMPROVISATION_GESTURES_HELP;
        self.helpPopup.allowToBeDismissed = YES;
    }
    
    else if ([upcomingHelpResource isEqualToString:@"LifespanHelp"]) {
        self.helpPopup.identifier = LIFESPAN_HELP;
        self.allowTouch = NO;
        self.allowSolo = NO;
        self.helpPopup.allowToBeDismissed = NO;
        self.killCount = self.creatures.count;
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(killCreature:) userInfo:nil repeats:YES];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.quitButton.center = CGPointMake(self.quitButton.center.x, self.quitButton.center.y - 10.0);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.quitButton.center = CGPointMake(self.quitButton.center.x, self.frame.size.height + self.quitButton.frame.size.height);
            } completion:nil];
        }];
    }
    
    else if ([upcomingHelpResource isEqualToString:@"ReadyHelp"]) {
        //  Help popup text
        
        NSString *text = NSLocalizedString(upcomingHelpResource, nil);
        NSDictionary *textAttributes = @{NSFontAttributeName: self.helpPopup.info.font};
        CGRect textFrame = [text boundingRectWithSize:CGSizeMake(self.frame.size.width - 2 * 10.0f,
                                                                 CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:textAttributes
                                              context:nil];
        self.helpPopup.identifier = READY_HELP;
        self.allowSolo = YES;
        self.helpPopup.allowToBeDismissed = NO;
        self.helpPopup.verticalOffset = self.view.frame.size.height - ceil(textFrame.size.height) - 1.5f * k_buttonHeight - 20.0f;
        self.helpPopup.useFade = YES;
        
        //  Title text
        
        UILabel *title = [[UHMShadowedLabel alloc] initWithFrame:CGRectMake(10.0,
                                                                            30.0,
                                                                            self.frame.size.width - 2 * 10.0,
                                                                            60.0)];
        title.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:33];
        title.textColor = [UIColor colorWithWhite:1.0 alpha:0.75];
        title.textAlignment = NSTextAlignmentCenter;
        title.numberOfLines = 0;
        title.text = NSLocalizedString(@"Congratulations!", nil);
        title.alpha = 0.0;
        [self.view addSubview:title];
        title.transform = CGAffineTransformScale(title.transform, 0.5, 0.5);
        
        //  Sub-title text

        UILabel *info = [[UHMShadowedLabel alloc] init];
        info.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:22];
        info.textColor = [UIColor colorWithWhite:1.0 alpha:0.75];
        info.textAlignment = NSTextAlignmentCenter;
        info.numberOfLines = 0;
        info.text = NSLocalizedString(@"Tutorial completed", nil);
        
        NSDictionary *infoAttributes = @{NSFontAttributeName: info.font};
        CGRect infoFrame = [info.text boundingRectWithSize:CGSizeMake(self.frame.size.width - 2 * 10.0f,
                                                                             CGFLOAT_MAX)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:infoAttributes
                                                          context:nil];
        info.frame = CGRectMake((self.frame.size.width - infoFrame.size.width) / 2.0f,
                                90.0f,
                                infoFrame.size.width,
                                infoFrame.size.height);
        info.alpha = 0.0;
        [self.view addSubview:info];
        
        //  Animation
        
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            title.alpha = 1.0f;
        } completion:nil];
        
        [UIView animateWithDuration:0.5 delay:0.3 options:UIViewAnimationOptionCurveLinear animations:^{
            info.alpha = 1.0f;
        } completion:nil];
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            title.transform = CGAffineTransformScale(title.transform, 2.1, 2.1);
        } completion:^(BOOL finished) {
            self.helpPopup.hidden = NO;
            
            [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                title.transform = CGAffineTransformScale(title.transform, 0.909, 0.909);
            } completion:nil];
        }];
        
        //  Button
        
        [self.quitButton setTitle:NSLocalizedString(@"Continue", nil) forState:UIControlStateNormal];
        [self.quitButton removeTarget:self action:@selector(quitTutorialWithPreparation) forControlEvents:UIControlEventTouchUpInside];
        [self.quitButton addTarget:self action:@selector(continueToGame) forControlEvents:UIControlEventTouchUpInside];
        
        [UIView animateWithDuration:0.2 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.quitButton.center = CGPointMake(self.quitButton.center.x, self.frame.size.height - self.quitButton.frame.size.height);
        } completion:nil];
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenTutorial"]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenTutorial"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    [self.helpPopup replaceTextWithString:NSLocalizedString(upcomingHelpResource, nil)];
    
    if (![upcomingHelpResource isEqualToString:@"ReadyHelp"]) {
        self.helpPopup.hidden = NO;
    }
}

-(void)killCreature:(NSTimer*)timer {
    if (self.killCount > 0) {
        [[self.creatures objectAtIndex:self.killCount-1] terminate];
        self.killCount--;
    }
    
    else {
        [timer invalidate];
        self.helpPopup.allowToBeDismissed = YES;
    }
}

-(void)measureRotation:(NSTimer*)timer {
    double acceleration = [[UHMMotionController sharedMotionController] accelerationMagnitude];
    if (acceleration > 0.35) return;
    
    double pitch = fabs([[UHMMotionController sharedMotionController] smoothPitch]);
    double roll = fabs([[UHMMotionController sharedMotionController] smoothRoll]);
    if (pitch < (M_PI / 6.0) && roll < (M_PI / 6.0)) return;
    self.accumulatedRotation += fmax(pitch, roll);
    
    if (self.accumulatedRotation > 6.0f) {
        [timer invalidate];
        self.helpPopup.allowToBeDismissed = YES;
    }
}

-(void)measureCurrentAcceleration:(NSTimer*)timer {
    if ([[UHMMotionController sharedMotionController] accelerationMagnitude] > 0.35) {
        [timer invalidate];
        self.helpPopup.allowToBeDismissed = YES;
    }
}

-(void)measureAccumulatedAcceleration:(NSTimer*)timer {
    double acceleration = [[UHMMotionController sharedMotionController] accelerationMagnitude];
    if (acceleration < 0.2) return;
    if (!self.solo) return;
    
    self.accumulatedAcceleration += acceleration;
    
    if (self.accumulatedAcceleration > 10.0f) {
        [timer invalidate];
        self.helpPopup.allowToBeDismissed = YES;
    }
}

@end
