//
//  UHMPlayScene.m
//  Musicreatures
//
//  Created by Petri J Myllys on 26/06/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMPlayScene.h"
#import "UHMAbstractPlaySceneSubclass.h"
#import "UHMAudioController.h"
#import "UHMAppDelegate.h"
#import "UHMPlayViewController.h"

@interface UHMPlayScene()

//@property (strong, nonatomic) SKSpriteNode *helpButton;

@end

@implementation UHMPlayScene {
    BOOL _gameStarted;
    BOOL _recordingStarted;
}

-(id)initWithSize:(CGSize)size {
    return [self initWithSize:size background:[[SKSpriteNode alloc] init]];
}

-(id)initWithSize:(CGSize)size background:(SKSpriteNode*)background {
    self = [super initWithSize:size background:background];
    
    if (self) {
        
        self.pauseButton = [[SKSpriteNode alloc] initWithImageNamed:@"pause.png"];
        self.pauseButton.name = @"pause";
        self.pauseButton.size = CGSizeMake(45.0f, 45.0f);
        self.pauseButton.position = CGPointMake(32.5f, self.frame.size.height - 32.5f);
        self.pauseButton.blendMode = SKBlendModeAlpha;
        self.pauseButton.alpha = 0.5;
        self.pauseButton.zPosition = 2.0;
        
        [self addChild:self.pauseButton];
        
//        self.helpButton = [[SKSpriteNode alloc] initWithImageNamed:@"pause.png"];
//        self.helpButton.name = @"help";
//        self.helpButton.size = CGSizeMake(45.0f, 45.0f);
//        self.helpButton.position = CGPointMake(self.frame.size.width - 32.5f, self.frame.size.height - 32.5f);
//        self.helpButton.blendMode = SKBlendModeAlpha;
//        self.helpButton.alpha = 0.5;
//        self.helpButton.zPosition = 2.0;
//        
//        [self addChild:self.helpButton];
        
        [[UHMAudioController sharedAudioController] prepareRecordingWithBitDepth:16];
        _recordingStarted = NO;
        
        
        self.solo = NO;
    }
    
    return self;
}

-(void)didMoveToView:(SKView *)view {
    _gameStarted = YES;
}

-(void)willMoveFromView:(SKView *)view {
    if ([self.view.scene isKindOfClass:[UHMMenuScene class]]) {
        ((UHMMenuScene*)self.view.scene).userInteractionEnabled = YES;
    }
}

/**
 Spawns a new creature at a specific position.
 @param position Spawn position for the creature, relative to the scene.
 */
-(void)spawnCreatureAtPosition:(CGPoint)position {
    if (!_recordingStarted) {
        [[UHMAudioController sharedAudioController] startRecording];
        _recordingStarted = YES;
        self.sharable = YES;
    }
    
    [super spawnCreatureAtPosition:position];
}

#pragma mark - Solo mode

-(void)setSolo:(BOOL)solo {
    [super setSolo:solo];
    
    if (solo) {
        [self pauseTimers:YES];
        
        __weak typeof(self) weakSelf = self;
        SKAction *fadePauseButton = [SKAction fadeAlphaTo:0.0 duration:0.2];
        SKAction *pauseButtonCompletion = [SKAction runBlock:^{
            weakSelf.pauseButton.hidden = YES;
//            weakSelf.helpButton.hidden = YES;
        }];
        [self.pauseButton runAction:[SKAction sequence:@[fadePauseButton, pauseButtonCompletion]] withKey:@"solo"];
//        [self.helpButton runAction:[SKAction sequence:@[fadePauseButton, pauseButtonCompletion]] withKey:@"solo"];
    }
    
    else {
        [self pauseTimers:NO];
        
        self.pauseButton.hidden = NO;
//        self.helpButton.hidden = NO;
        [self.pauseButton runAction:[SKAction fadeAlphaTo:0.5 duration:0.2] withKey:@"solo"];
//        [self.helpButton runAction:[SKAction fadeAlphaTo:0.5 duration:0.2] withKey:@"solo"];
    }
}

#pragma mark - Pausing

-(void)setPauseMode:(BOOL)pause {
    if (pause) self.pauseButton.hidden = YES;
    else self.pauseButton.hidden = NO;
    
    self.scene.paused = pause;
    
    if (pause) {
        if (((UHMAudioController*)[UHMAudioController sharedAudioController]).active == YES) {
            [[UHMAudioController sharedAudioController] setActive:NO];
        }
        
        [self pauseTimers:YES];
        
        UHMPlayViewController *viewController =
        (UHMPlayViewController*)((UHMAppDelegate*)[[UIApplication sharedApplication] delegate]).window.rootViewController;
        viewController.menuScene.background.texture = self.background.texture;
        viewController.menuScene.background.position = self.background.position;
        viewController.menuScene.background.size = self.background.size;
        
        [((SKView*)viewController.view) presentScene:viewController.menuScene transition:[SKTransition crossFadeWithDuration:0.5]];
    }
    
    else {
        [[UHMAudioController sharedAudioController] setActive:YES];
        [self pauseTimers:NO];
    }
}

/**
 Creates a background image for the pause menu.
 */
-(SKTexture*)createPauseBackground {
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 2.0);
    [self.view drawViewHierarchyInRect:self.view.frame afterScreenUpdates:YES];
    UIImage *capturedView = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [SKTexture textureWithImage:capturedView];
}

#pragma mark - Timers

-(void)pauseTimers:(BOOL)paused {
    static NSDate *nextScheduledProjectileLaunch, *pauseDate;
    
    if (paused && _gameStarted) {
        nextScheduledProjectileLaunch = self.projectileLaunchTimer.fireDate;
        pauseDate = [NSDate date];
        
        [self.projectileLaunchTimer invalidate];
        
        self.projectileLaunchTimer = nil;
        
        for (UHMCreature *creature in self.creatures) {
            [creature pauseTerminationTimer:YES];
            [creature pauseTremblingTimer:YES];
        }
    }
    
    else if (_gameStarted) {
        NSTimeInterval timePaused = -[pauseDate timeIntervalSinceNow];
        NSDate *nextProjectileLaunch = [nextScheduledProjectileLaunch dateByAddingTimeInterval:timePaused];
        
        if (!self.projectileLaunchTimer) {
            
            self.projectileLaunchTimer = [NSTimer scheduledTimerWithTimeInterval:4.0
                                                                          target:self
                                                                        selector:@selector(launchProjectile)
                                                                        userInfo:nil
                                                                         repeats:YES];
            
            self.projectileLaunchTimer.fireDate = nextProjectileLaunch;
        }
        
        for (UHMCreature *creature in self.creatures) {
            [creature pauseTerminationTimer:NO];
            [creature pauseTremblingTimer:NO];
        }
    }
}

#pragma mark - Quick help

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    //  Menu button (increased touch area)
    
    if (location.x < 60.0f && location.y > self.frame.size.height - 55.0f) {
        if (!self.solo) {
            self.pauseMode = YES;
            return;
        };
    }
    
//    // Quick help button (increased touch area)
//    
//    else if (location.x > self.frame.size.width - 60.0f && location.y > self.frame.size.height - 55.0f) {
//        if (!self.solo) {
//            NSLog(@"asd");
//            return;
//        };
//    }
    
    else [super touchesBegan:touches withEvent:event];
}

@end