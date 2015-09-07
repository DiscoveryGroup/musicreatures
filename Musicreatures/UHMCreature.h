//
//  UHMCreature.h
//  Musicreatures
//
//  Created by Petri J Myllys on 11/07/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UHMCreatureAnchor.h"
#import "UHMAbstractPlayScene.h"
#import "UHMCreatureEntity.h"
#import "UHMInstrument.h"
#import "UHMPattern.h"

typedef struct {
    float filterCutoff;
    float pitchShiftFactor;
} SonicBrightness;

typedef void(^patternUpdateCompletion)(BOOL);

@interface UHMCreature : NSObject <UHMCreatureEntity, UHMInstrument>

///// Creature name.
//@property (strong, nonatomic) NSString *name;

/// Creature position. Read-only - position is adjusted via creature physics body.
@property (nonatomic, readonly) CGPoint position;

/// Approximate creature size. Read-only - size is computed according to the components.
@property (nonatomic, readonly) CGSize size;

/// Creature color. Read-only - color is based on parent scene color map and is retrieved by the getter from the anchor.
@property (strong, nonatomic, readonly) SKColor *color;

/// Anchor the components are connected to. Determines creature position.
@property (strong, nonatomic) UHMCreatureAnchor *anchor;

/// Individual pulse components constituting the creature.
@property (strong, nonatomic) NSMutableArray *pulses;

/// Physics joints associated with the creature, component as key and joint as value.
@property (strong, nonatomic) NSMutableDictionary *joints;

/// Visual joints.
@property (strong, nonatomic) SKShapeNode *visualJoints;

/// Musical pattern associated with the creature. Read-only - pattern is replaced by modifying the contained noteArray.
@property (strong, atomic, readonly) UHMPattern *pattern;

/// The step of the pattern currently being played back.
@property (nonatomic) int currentStep;

/// The scene the creature is connected to.
@property (weak, nonatomic) UHMAbstractPlayScene *parentScene;

/// The sonic brightness of the sound. Positive values (..1.0) increase the brightness, negative values (-1.0..) darken the sound, 0 is neutral.
@property (nonatomic) SonicBrightness sonicBrightness;

// Methods documented in the implementation.

-(id)initWithName:(NSString*)name parentScene:(UHMAbstractPlayScene*)scene position:(CGPoint)position;
-(id)initWithName:(NSString*)name parentScene:(UHMAbstractPlayScene*)scene position:(CGPoint)position mortal:(BOOL)mortal;

-(void)updateComponents:(patternUpdateCompletion)completion;
-(void)updateColor;
-(void)updateMusicalProperties;

-(void)addPulseToPattern;
-(void)removePulseFromPattern;
-(void)updatePatternInPd;
-(void)pauseTremblingTimer:(BOOL)paused;

-(void)terminate;
-(void)willTerminate;
-(void)pauseTerminationTimer:(BOOL)paused;

@end