//
//  UHMAbstractPlayScene.h
//  Musicreatures
//
//  Created by Petri J Myllys on 19/12/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "UHMColorMap.h"
#import "UHMHarmony.h"
#import "UHMRhythm.h"

#define BACKGROUND_SCALE 1.3
#define MAX_STEPS 64

@class UHMCreature;

/// An abstract main play scene. This abstract scene should be subclassed.
@interface UHMAbstractPlayScene : SKScene

/// Creatures currently alive.
@property (strong, nonatomic) NSMutableArray *creatures;

/// Background image.
@property (strong, nonatomic) SKSpriteNode *background;

/// Color map corresponding the background image.
@property (strong, nonatomic) UHMColorMap *colorMap;

/// Musical harmony of the currently alive creatures.
@property (strong, nonatomic) UHMHarmony *harmony;

/// Musical rhythm of the currently alive creatures.
@property (strong, nonatomic) UHMRhythm *rhythm;

/// Status of the creatures: whether or not they are "frozen" (accepting no changes to their patterns).
@property (nonatomic) BOOL solo;

/// Pauses all the necessary elements to make the game pause.
@property (nonatomic) BOOL pauseMode;

/// Flag that tells whether any music has been created.
@property (nonatomic) BOOL sharable;

-(id)initWithSize:(CGSize)size background:(SKSpriteNode*)background;
-(void)createBackgroundWithImage:(UIImage*)image;
-(void)inspectBackgroundImage:(UIImage*)image;
-(void)configureMusicalPropertiesManually;
-(void)terminateCreature:(UHMCreature*)creature;
-(void)endGame;

@end
