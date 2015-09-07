//
//  UHMCreature.m
//  Musicreatures
//
//  Created by Petri J Myllys on 11/07/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMCreature.h"
#import "UHMCreaturePulse.h"
#import "UIColor+Compare.h"
#import "UHMEuclidean.h"
#import "UHMNote.h"
#import "UHMAudioController.h"

#define COMPONENT_RADIUS 12.0
#define CREATURE_TERMINATION_AGE 90.0

@interface UHMCreature()

/// Read-write override for the property.
@property (strong, atomic) UHMPattern *pattern;

/// Radius of the ring on which the individual pattern component circles are attached.
@property (nonatomic) CGFloat ringRadius;

/// Timer for terminating the creature.
@property (strong, nonatomic) NSTimer *terminationTimer;

/// Timer for starting trembling animation when near termination.
@property (strong, nonatomic) NSTimer *tremblingTimer;

/// Flag for disabling the creature termination by age.
@property (nonatomic) BOOL mortal;

SKAction* componentSpawnAnimation();
SKAction* stepHighlightAnimation();
SKAction* trembleAnimation();

@end

@implementation UHMCreature {
    int _previousPulses;
    NSDate* _scheduledTermination;
    NSDate* _terminationPauseDate;
    NSDate* _scheduledTrembling;
    NSDate* _tremblingPauseDate;
}

@synthesize position = _position;
@synthesize size = _size;
@synthesize entity = _entity;
@synthesize name = _name;

/**
 Initializes the creature and adds it to the scene passed in as a parameter.
 @param name     Name for the creature.
 @param scene    Scene to add the creature to.
 @param position Position to place the creature to.
 @return The initialized creature added to the scene.
 */
-(id)initWithName:(NSString*)name parentScene:(UHMAbstractPlayScene*)scene position:(CGPoint)position {
    return [self initWithName:name parentScene:scene position:position mortal:YES];
}

-(id)initWithName:(NSString *)name parentScene:(UHMAbstractPlayScene *)scene position:(CGPoint)position mortal:(BOOL)mortal {
    self = [super init];
    
    if (self) {
        self.name = name;
        self.entity = self;
        self.mortal = mortal;
        
        self.parentScene = scene;
        
        self.ringRadius = 0.0f;
        self.anchor = [[UHMCreatureAnchor alloc] initWithParentCreature:self];
        self.anchor.position = [self checkPosition:position];
        [self.parentScene addChild:self.anchor];
        
        self.pulses = [[NSMutableArray alloc] init];
        self.joints  = [[NSMutableDictionary alloc] init];
        self.visualJoints = [[SKShapeNode alloc] init];
        self.visualJoints.lineWidth = 0.1f;
        self.visualJoints.glowWidth = 0.3f;
        self.visualJoints.blendMode = SKBlendModeAdd;
        self.visualJoints.lineCap = kCGLineCapRound;
        self.visualJoints.zPosition = 1;
        self.visualJoints.alpha = 0.7f;
        [self.parentScene addChild:self.visualJoints];
        
        self.pattern = [UHMPattern patternWithArray:@[@1, @0, @0, @0, @0, @0, @0, @0,
                                                      @0, @0, @0, @0, @0, @0, @0, @0]];
        [self.parentScene.rhythm storeNumberOfPulses:self.pattern.pulses
                                       forInstrument:self];
        [self.pattern addObserver:self forKeyPath:@"noteArray" options:NSKeyValueObservingOptionNew context:NULL];
        
        [self updateComponents:^(BOOL finished) {
            if(finished){
                [self updatePatternInPd];
            }
        }];
        
        self.anchor.color = [self determineNewColor];
        
        if (self.mortal) {
            self.terminationTimer = [NSTimer scheduledTimerWithTimeInterval:CREATURE_TERMINATION_AGE
                                                                     target:self
                                                                   selector:@selector(terminate)
                                                                   userInfo:nil
                                                                    repeats:YES];
            
            self.tremblingTimer = [NSTimer scheduledTimerWithTimeInterval:0.9 * CREATURE_TERMINATION_AGE
                                                                   target:self
                                                                 selector:@selector(startTrembling)
                                                                 userInfo:nil
                                                                  repeats:YES];
        }
    }
    
    return self;
}

/**
 Adjusts position if too close to frame edges.
 @param position    The position to check.
 @return            The original position if not too close to frame edges, adjusted position otherwise.
 */
-(CGPoint)checkPosition:(CGPoint)position {
    CGPoint p = position;
    
    if (position.x < COMPONENT_RADIUS)
        p.x = COMPONENT_RADIUS;
        
    else if (position.x > (self.parentScene.frame.size.width - COMPONENT_RADIUS))
        p.x = self.parentScene.frame.size.width - COMPONENT_RADIUS;
    
    if (position.y < COMPONENT_RADIUS)
        p.y = COMPONENT_RADIUS;
    
    else if (position.y > (self.parentScene.frame.size.height - COMPONENT_RADIUS))
        p.y = self.parentScene.frame.size.height - COMPONENT_RADIUS;
    
    return p;
}

/**
 Places the creature to a position, adjusts position if too close to frame edges.
 @param position     The position to place the creature to.
 */
-(void)placeToPosition:(CGPoint)position {
    CGPoint spawnPosition;
    
    if (position.x < self.ringRadius)
        spawnPosition.x = self.ringRadius;
    else if (position.x > self.parentScene.frame.size.width - self.ringRadius - COMPONENT_RADIUS)
        spawnPosition.x = self.parentScene.frame.size.width - self.ringRadius - COMPONENT_RADIUS;
    else spawnPosition.x = position.x;
    
    if (position.y < self.ringRadius)
        spawnPosition.y = self.ringRadius;
    else if (position.y > self.parentScene.frame.size.height - self.ringRadius - COMPONENT_RADIUS)
        spawnPosition.y = self.parentScene.frame.size.height - self.ringRadius - COMPONENT_RADIUS;
    else spawnPosition.y = position.y;
    
    self.anchor.position = spawnPosition;
}

#pragma mark - Creature updating

/**
 Key-value observing of changes in the pattern, updates creature when changed.
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"noteArray"]) {        
        [self updateComponents:^(BOOL finished) {
            if(finished){
                [self updatePatternInPd];
                
                if ([object isKindOfClass:[UHMPattern class]]) {
                    int pulses = ((UHMPattern*)object).pulses;
                    [self.parentScene.rhythm storeNumberOfPulses:pulses
                                                   forInstrument:self];
                }
            }
        }];
    }
}

/**
 Updates creature components to match the current pattern.
 @param completion Block executed upon completion.
 */
-(void)updateComponents:(patternUpdateCompletion)completion {
    if (self.pattern.pulses == 0) {
        [self terminate];
        return;
    }
    
    NSMutableArray *currentPulses = [[NSMutableArray alloc] init];
    
    for (UHMNote *note in self.pattern.noteArray) {
        if (note.isPulse) {
            [currentPulses addObject:note];
        }
    }
    
    if (currentPulses.count > _previousPulses) {
        for (int addition = 0; addition < currentPulses.count - _previousPulses; addition++) {
            [self addPulseComponentAtIndex:_previousPulses];
        }
    }
    
    else if (currentPulses.count < _previousPulses) {
        for (int subtraction = 0; subtraction < _previousPulses - currentPulses.count; subtraction++) {
            [self removePulseComponent];
        }
    }
    
    _previousPulses = self.pattern.pulses;
    
    completion(YES);
}

/**
 Adds a new pulse component to the creature, positions the component according to its index.
 @param index    Index of the step for positioning.
 */
-(void)addPulseComponentAtIndex:(int)index {
    float x = self.anchor.position.x + self.ringRadius * cos(2*M_PI / self.pattern.pulses * index);
    float y = self.anchor.position.y + self.ringRadius * sin(2*M_PI / self.pattern.pulses * index);
    CGPoint p = CGPointMake(x, y);
    p = [self checkPosition:p];
    
    UHMCreaturePulse *component = [[UHMCreaturePulse alloc] initWithPosition:p
                                                                     enabled:YES
                                                                      radius:COMPONENT_RADIUS
                                                              parentCreature:self];
    
    [self.pulses insertObject:component atIndex:index];
    [self updateRingRadius];
    [self.parentScene addChild:component];
    [self updateColor];
    [component animateSpawn];
    
    [self connectComponentBody:component.physicsBody bodyPosition:component.position];
}

/**
 Creates a physics joint between the creature anchor and a component.
 @param componentBody   Component body to connect to the anchor
 @param bodyPos         Component position
 */
-(void)connectComponentBody:(SKPhysicsBody*)componentBody bodyPosition:(CGPoint)bodyPos {
    SKPhysicsJointSpring *joint = [SKPhysicsJointSpring jointWithBodyA:self.anchor.physicsBody
                                                                 bodyB:componentBody
                                                               anchorA:self.anchor.position
                                                               anchorB:bodyPos];

    joint.frequency = 2.5;
    joint.damping = 0.0;
    
    [self.joints setObject:joint forKey:componentBody.node];
    [self.parentScene.physicsWorld addJoint:joint];
}

/**
 Removes a pulse component from the creature with the 'last in first out' method.
 */
-(void)removePulseComponent {
    UHMCreaturePulse *pulseToRemove = [self.pulses lastObject];
    [self.pulses removeObject:pulseToRemove];
    
    for (SKPhysicsJoint *joint in pulseToRemove.physicsBody.joints) {
        [self.parentScene.physicsWorld removeJoint:joint];
        [self.joints removeObjectForKey:pulseToRemove];
    }
    
    [pulseToRemove fadeOut:^{
        [pulseToRemove removeFromParent];
        [self updateRingRadius];
    }];
}

-(void)updateRingRadius {
    if (self.pulses.count == 1) {
        self.ringRadius = 0.0f;
        return;
    }

    self.ringRadius = COMPONENT_RADIUS + 10.0f + self.pulses.count * 1.5;
}

/**
 Updates the colors of all the components in the creature.
 */
-(void)updateColor {
    SKColor *newColor = [self determineNewColor];
    
    SKAction *colorizeAction = [SKAction colorizeWithColor:newColor
                                          colorBlendFactor:1.0
                                                  duration:0.3];
    
    [self.anchor runAction:colorizeAction withKey:@"colorize"];
    
    for (UHMCreaturePulse *component in self.pulses) {
        [component colorizeWithColor:newColor];
    }
    CGFloat h, s, b;
    [newColor getHue:&h saturation:&s brightness:&b alpha:nil];
    b -= 0.2;
    b = b >= 0.2 ? b : b + 0.2;
    SKColor *jointColor = [SKColor colorWithHue:h saturation:s brightness:b alpha:1.0];
    self.visualJoints.strokeColor = jointColor;
}

/**
 Fetches a new color for the creature from the parent scene color map.
 @return New color for the creature.
 */
-(SKColor*)determineNewColor {
    CGPoint position = [self scalePositionToMatchColorMap];
    int column = position.x;
    int row = position.y;
    
    NSArray *RgbaValues = [[self.parentScene.colorMap.map objectAtIndex:row] objectAtIndex:column];
    return [SKColor colorWithRed:[[RgbaValues objectAtIndex:0] doubleValue]
                                        green:[[RgbaValues objectAtIndex:1] doubleValue]
                                         blue:[[RgbaValues objectAtIndex:2] doubleValue]
                                        alpha:0.1];
}

/**
 Scales creature position to correspond to the visible area of the background and the associated color map.
 @return Scaled position.
 */
-(CGPoint)scalePositionToMatchColorMap {
    float horizontalOffset = 0, verticalOffset = 0;
    CGSize frameSize = self.parentScene.frame.size;
    CGSize backgroundSize = self.parentScene.background.size;
    int columns = self.parentScene.colorMap.columns;
    int rows = self.parentScene.colorMap.rows;
    
    if (backgroundSize.width > frameSize.width || backgroundSize.height > frameSize.height) {
        horizontalOffset = (self.parentScene.background.size.width - self.parentScene.frame.size.width) / 2;
        verticalOffset = (self.parentScene.background.size.height - self.parentScene.frame.size.height) / 2;
    }
    
    int x = (horizontalOffset + self.position.x) / (backgroundSize.width / columns);
    int y = (verticalOffset + frameSize.height - self.position.y) / (backgroundSize.height / rows);
    
    return CGPointMake(x, y);
}

/**
 Highlights the creature component matching the step currently being played back.
 */
-(void)highlightCurrentStep {
    if (self.pulses.count > self.currentStep) {
        [((UHMCreaturePulse*)[self.pulses objectAtIndex:self.currentStep]).border runAction:stepHighlightAnimation()];
    }
}

/**
 Starts a trembling animation.
 */
-(void)startTrembling {
    __weak typeof(self) weakSelf = self;
    for (UHMCreaturePulse *component in weakSelf.pulses) {
        [component runAction:[SKAction repeatActionForever:trembleAnimation()] withKey:@"tremble"];
    }
}

-(void)pauseTremblingTimer:(BOOL)paused {
    if (!self.mortal) return;
    
    if (paused) {
        _scheduledTrembling = self.tremblingTimer.fireDate;
        _tremblingPauseDate = [NSDate date];
        
        if ([self.tremblingTimer isValid]) {
            [self.tremblingTimer invalidate];
        }
        
        self.tremblingTimer = nil;
    }
    
    else {
        NSTimeInterval timePaused = -[_tremblingPauseDate timeIntervalSinceNow];
        NSDate *nextProjectileLaunch = [_scheduledTrembling dateByAddingTimeInterval:timePaused];
        
        if (!self.tremblingTimer) {
            
            self.tremblingTimer = [NSTimer scheduledTimerWithTimeInterval:0.9 * CREATURE_TERMINATION_AGE
                                                                   target:self
                                                                 selector:@selector(startTrembling)
                                                                 userInfo:nil
                                                                  repeats:YES];
            
            self.tremblingTimer.fireDate = nextProjectileLaunch;
        }
    }
}

#pragma mark - Pattern modifying

/**
 Adds a pulse to the pattern.
 Replaces a rest step with the pulse, i.e. keeps the pattern step count unchanged and increases the number of pulses by one.
 */
-(void)addPulseToPattern {
    [self.pattern addPulse];
}

/**
 Removes a pulse from the pattern.
 Replaces a pulse with a rest, i.e. keeps the pattern step count unchanged and decreases the number of pulses by one.
 */
-(void)removePulseFromPattern {
    [self.pattern removePulse];
}

#pragma mark - Terminating

/**
 Prepares to terminate the creature.
 */
-(void)willTerminate {
    if (self.mortal) {
        if ([self.terminationTimer isValid]) [self.terminationTimer invalidate];
        self.terminationTimer = nil;
        
        if ([self.tremblingTimer isValid]) [self.tremblingTimer invalidate];
        self.tremblingTimer = nil;
    }

    // TBD: Keep better track of the concurrent operations dealing with the observers in order to avoid try-catch
    @try {
        [self.pattern removeObserver:self forKeyPath:NSStringFromSelector(@selector(noteArray))];
    }
    @catch(id NSRangeException) {
        // There is no corresponding observer
    }
    
    [self.parentScene.rhythm storeNumberOfPulses:0
                                   forInstrument:self];
}

/**
 Terminates the creature.
 */
-(void)terminate {
    [self willTerminate];
    [self.parentScene terminateCreature:self];
}

/**
 Pauses the timer used for triggering creature termination.
 */
-(void)pauseTerminationTimer:(BOOL)paused {
    if (!self.mortal) return;
    
    if (paused) {
        _scheduledTermination = self.terminationTimer.fireDate;
        _terminationPauseDate = [NSDate date];
        
        if ([self.terminationTimer isValid]) {
            [self.terminationTimer invalidate];
        }
        
        self.terminationTimer = nil;
    }
    
    else {
        NSTimeInterval timePaused = -[_terminationPauseDate timeIntervalSinceNow];
        NSDate *termination = [_scheduledTermination dateByAddingTimeInterval:timePaused];
        
        if (!self.terminationTimer) {
            
            self.terminationTimer = [NSTimer scheduledTimerWithTimeInterval:CREATURE_TERMINATION_AGE
                                                                     target:self
                                                                   selector:@selector(terminate)
                                                                   userInfo:nil
                                                                    repeats:YES];
            
            self.terminationTimer.fireDate = termination;
        }
    }
}

#pragma mark - Getters and setters

-(void)setPosition:(CGPoint)position {
    self.anchor.position = position;
}

-(CGPoint)position {
    return self.anchor.position;
}

-(CGSize)size {
    double radius = self.ringRadius + COMPONENT_RADIUS;
    return CGSizeMake(radius * 2, radius * 2);
}

-(SKColor*)color {
    return self.anchor.color;
}

-(void)setCurrentStep:(int)currentStep {
    _currentStep = currentStep;
    [self highlightCurrentStep];
}

#pragma mark - Musical updating

/**
 Implemented in sublasses.
 */
-(void)updateMusicalProperties {}

/**
 Updates the pattern table in libpd.
 */
-(void)updatePatternInPd {
    NSMutableArray *binaryPattern = [[NSMutableArray alloc] init];
    
    for (UHMNote *note in self.pattern.noteArray) {
        if (note.isPulse) {
            [binaryPattern addObject:@1];
        } else {
            [binaryPattern addObject:@0];
        }
    }
    
    [[UHMAudioController sharedAudioController] setPattern:binaryPattern forInstrument:self];
    [[UHMAudioController sharedAudioController] setPatternLength:self.pattern.steps forInstrument:self];
}

#pragma mark - Animation

/**
 Animates step highlighting.
 @return Highlight animation.
 */
SKAction* stepHighlightAnimation() {
    SKAction *inflate = [SKAction scaleBy:1.5 duration:0];
    SKAction *deflate = [inflate reversedAction];
    deflate.duration = 0.25;
    deflate.timingMode = SKActionTimingEaseOut;
    
    return [SKAction sequence:@[inflate, deflate]];
}

/**
 Animates trembling.
 @return Tremble animation.
 */
SKAction* trembleAnimation() {
    double moveX = (0.5 - (double)arc4random() / 0x100000000) * 10.0;
    double moveY = (0.5 - (double)arc4random() / 0x100000000) * 10.0;
    
    SKAction *move = [SKAction moveByX:moveX y:moveY duration:0.05];
    SKAction *moveBack = [SKAction moveByX:-moveX y:-moveY duration:0.05];
    
    return [SKAction sequence:@[move, moveBack]];
}

@end