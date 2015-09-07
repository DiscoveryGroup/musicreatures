//
//  UHMAbstractPlayScene.m
//  Musicreatures
//
//  Created by Petri J Myllys on 19/12/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMAbstractPlayScene.h"

#import "UHMPhysicsCategories.h"
#import "NSMutableArray+Queue.h"

#import "UHMAppDelegate.h"
#import "UHMPlayViewController.h"
#import "UHMAudioController.h"
#import "UHMMotionController.h"

#import "UHMEuclidean.h"
#import "UHMBoids.h"

#import "UHMCreatureEntity.h"
#import "UHMCreaturePulse.h"
#import "UHMPitchedCreature.h"
#import "UHMRestProjectile.h"
#import "UHMPulseProjectile.h"

#import "UHMBackgroundCreator.h"
#import "UHMImageInspector.h"

#import "UHMIntroScene.h"

#define PITCHED_CREATURES 5
#define COLOR_ROWS 24
#define COLOR_COLUMNS 16
#define MIN_LAUNCH_INTERVAL 2.5

static BOOL PROJECTILES = YES;

@interface UHMAbstractPlayScene() <SKPhysicsContactDelegate>

/// Creature moving algorithm.
@property (strong, nonatomic) UHMBoids *swarm;

/// Part names connecting creatures with sound playback objects in libpd.
@property (strong, nonatomic) NSMutableArray *partNames;

/// Projectiles currently in the scene.
@property (strong, nonatomic) NSMutableArray *projectiles;

/// Timer for launching projectiles.
@property (strong, nonatomic) NSTimer *projectileLaunchTimer;

/// Button for pausing the game and audio recording and for displaying the in-game menu.
@property (strong, nonatomic) SKSpriteNode *pauseButton;

/// Timer for touch duration recognition
@property (strong, nonatomic) NSTimer *touchDurationTimer;

/// Overlay displayed while the "solo" mode is active.
@property (strong, nonatomic) SKSpriteNode *soloOverlay;

/// Time value for background shader.
@property (strong, nonatomic) SKUniform *shaderTime;

@end

@implementation UHMAbstractPlayScene

@synthesize solo = _solo;

-(id)initWithSize:(CGSize)size {
    return [self initWithSize:size background:[[SKSpriteNode alloc] init]];
}

-(id)initWithSize:(CGSize)size background:(SKSpriteNode*)background {
    self = [super initWithSize:size];
    
    if (self) {
        
        // World
        
        self.background = background;
        [self addChild:self.background];
        
        self.soloOverlay = [SKSpriteNode spriteNodeWithColor:[UIColor grayColor] size:self.frame.size];
        self.soloOverlay.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        self.soloOverlay.zPosition = 0.0;
        self.soloOverlay.hidden = YES;
        self.soloOverlay.alpha = 0.0;
        self.soloOverlay.blendMode = SKBlendModeAdd;
        [self addChild:self.soloOverlay];
        
        [self addParticles];
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsBody.categoryBitMask = edgeCategory;
        
        self.physicsWorld.contactDelegate = self;
        
        // Creatures
        
        self.creatures = [[NSMutableArray alloc] init];
        self.swarm = [[UHMBoids alloc] initWithBoids:self.creatures frame:self.frame.size];
        self.partNames = [NSMutableArray arrayWithArray:@[@"mbira", @"pizz", @"bar", @"perc1", @"perc2"]];
        
        self.harmony = [[UHMHarmony alloc] init];
        self.rhythm = [[UHMRhythm alloc] init];
        [self.rhythm addObserver:self.harmony
                      forKeyPath:NSStringFromSelector(@selector(totalPulses))
                         options:NSKeyValueObservingOptionNew
                         context:NULL];
        
        // Projectiles
        
        self.projectiles = [[NSMutableArray alloc] init];
        
        // Audio
        
        UHMAudioController *audio = [UHMAudioController sharedAudioController];
        [audio setGlobalSteps:MAX_STEPS];
        [audio setGlobalTempo:110];
        [audio setGlobalSwing:0.4];
        if (!audio.active) audio.active = YES;

        self.sharable = NO;
    }
    
    return self;
}

#pragma mark - Background

/**
 Creates a background image and maps its colors according to the row and column constants.
 @param image    Image from which to create the background.
 */
-(void)createBackgroundWithImage:(UIImage*)image {
    UIImage *filteredBackgroundImage = [UHMBackgroundCreator createFilteredBackgroundImage:image size:CGSizeMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0)];
    
    self.background.texture = [SKTexture textureWithImage:filteredBackgroundImage];
    self.background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    
    double screenAspectRatioA = self.frame.size.height / self.frame.size.width;
    double screenAspectRatioB = self.frame.size.width / self.frame.size.height;
    double imageAspectRatioA = image.size.height / image.size.width;
    double imageAspectRatioB = image.size.width / image.size.height;
    double stretchFactor = fmax(screenAspectRatioA / imageAspectRatioA,
                                screenAspectRatioB / imageAspectRatioB);
    self.background.size = CGSizeMake(self.frame.size.width * stretchFactor * BACKGROUND_SCALE,
                                      self.frame.size.height * stretchFactor * BACKGROUND_SCALE);
    
    self.colorMap = [[UHMColorMap alloc] initWithImage:filteredBackgroundImage
                                                  rows:COLOR_ROWS
                                               columns:COLOR_COLUMNS];
    
//    [self addFxLayer];
}

/**
 Inspects the background image for musical property mapping.
 @param image   Image to inspect.
 */
-(void)inspectBackgroundImage:(UIImage*)image {
    NSDictionary *properties = [UHMImageInspector extractMusicalPropertiesFromImage:image];
    
    if ([[properties valueForKey:@"tonality"] isEqualToString:@"major"])
        self.harmony.tonality = MAJOR;
    
    else if ([[properties valueForKey:@"tonality"] isEqualToString:@"harmonicMinor"])
        self.harmony.tonality = HARMONIC_MINOR;
    
    else if ([[properties valueForKey:@"tonality"] isEqualToString:@"naturalMinor"])
        self.harmony.tonality = NATURAL_MINOR;
    
    CGFloat tempo = ((NSNumber*)[properties valueForKey:@"tempo"]).floatValue;
    [[UHMAudioController sharedAudioController] setGlobalTempo:tempo];
    
    int transposition = ((NSNumber*)[properties valueForKey:@"transposition"]).floatValue;
    self.harmony.transposition = transposition;
    
    //    int polyphony = ((NSNumber*)[properties valueForKey:@"polyphony"]).floatValue;
    //    self.harmony.polyphony = polyphony;
}

-(void)configureMusicalPropertiesManually {
    NSLog(@"Configuring musical properties manually.");
    self.harmony.tonality = NATURAL_MINOR;
    [[UHMAudioController sharedAudioController] setGlobalTempo:110];
    self.harmony.transposition = 0;
    [self.harmony overrideProgressionWithProgressionFromFileNamed:@"TutorialProgression"];
}

#pragma mark - Particles

/**
 Adds the background particle emitter.
 */
-(void)addParticles {
    NSString *backgroundParticlesPath = [[NSBundle mainBundle] pathForResource:@"BackgroundParticles"
                                                                        ofType:@"sks"];
    
    SKEmitterNode *bgParticleEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:backgroundParticlesPath];
    
    bgParticleEmitter.position = CGPointMake(0, 0);
    bgParticleEmitter.name = @"backgroundParticles";
    [self addChild:bgParticleEmitter];
}

#pragma mark - FX

-(void)addFxLayer {
    SKShader *bgShader = [SKShader shaderWithFileNamed:@"movement.fsh"];
    self.shaderTime = [SKUniform uniformWithName:@"time" float:0.0];
    bgShader.uniforms = @[self.shaderTime];
    self.background.shader = bgShader;
}

#pragma mark - Creatures

/**
 Spawns a new creature at a specific position.
 @param position Spawn position for the creature, relative to the scene.
 */
-(void)spawnCreatureAtPosition:(CGPoint)position {
    UHMCreature *creature;
    
    NSString *creatureName = [self.partNames dequeue];
    
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

/**
 Creates a new pitched creature.
 @param  name Name for the creature. Should match the sound playback object in libpd.
 @param  position Spawn position for the creature.
 @return The created pitched creature.
 */
-(UHMPitchedCreature*)createPitchedCreatureWithName:(NSString*)name position:(CGPoint)position {
    return [[UHMPitchedCreature alloc] initWithName:name parentScene:self position:position];
}

/**
 Creates a new percussive creature.
 @param  name Name for the creature. Should match the sound playback object in libpd.
 @param  position Spawn position for the creature.
 @return The created percussive creature.
 */
-(UHMPercussiveCreature*)createPercussiveCreatureWithName:(NSString*)name position:(CGPoint)position {
    return [[UHMPercussiveCreature alloc] initWithName:name parentScene:self position:position];
}

/**
 Terminates a creature.
 @param creature Creature to terminate.
 */
-(void)terminateCreature:(UHMCreature*)creature {
    SKAction *diminish = [SKAction scaleTo:0.0 duration:2.0];
    SKAction *fade = [SKAction fadeAlphaTo:0.0 duration:2.0];
    SKAction *disappear = [SKAction group:@[diminish, fade]];
    SKAction *fadeOutJoints = [SKAction fadeAlphaTo:0.0f duration:0.2f];
    
    [creature.visualJoints runAction:fadeOutJoints completion:^{
        [creature.visualJoints removeFromParent];
        
        [[UHMAudioController sharedAudioController] removeInstrumentFromPlayback:creature];
        
        for (SKPhysicsJoint *joint in [creature.joints allValues]) {
            [self.physicsWorld removeJoint:joint];
        }
        
        for (UHMCreaturePulse *component in creature.pulses) {
            component.physicsBody.categoryBitMask = 0;
            component.physicsBody.collisionBitMask = 0;
            
            [component removeActionForKey:@"tremble"];
            
            [component.physicsBody applyImpulse:CGVectorMake((0.5 - (double)arc4random() / 0x100000000) * 5,
                                                             (0.5 - (double)arc4random() / 0x100000000) * 5)];
            [component runAction:disappear completion:^(){
                [component removeFromParent];
            }];
        }
        
        [creature.anchor.physicsBody applyImpulse:CGVectorMake((0.5 - (double)arc4random() / 0x100000000) * 2,
                                                               (0.5 - (double)arc4random() / 0x100000000) * 2)];
        [creature.anchor runAction:disappear completion:^(){
            [creature.anchor removeFromParent];
            [self.creatures removeObject:creature];
            [self.partNames enqueue:creature.name];
            [self.swarm removeBoid:creature];
        }];
    }];
}

#pragma mark - Updating

-(void)update:(NSTimeInterval)currentTime {
    [self removeOutOfBoundProjectiles];
    [self.swarm updatePositions];
    [self updateProjectileCourses];
    
    [self updateGravity];
    [self updateBackgroundPosition];
    [self updateParticlePosition];
    
    [self updateCreatureProperties];
//    self.shaderTime.floatValue = fmod(currentTime, 2.0 * M_PI);
}

-(void)didSimulatePhysics {
    for (UHMCreature *c in self.creatures) {        
        if (c.pulses.count == 1) {
            if (c.visualJoints.path) c.visualJoints.path = nil;
            continue;
        };
        
        CGMutablePathRef path = CGPathCreateMutable();
        
        for (UHMCreaturePulse *p in c.pulses) {
            CGPathMoveToPoint(path, NULL, c.anchor.position.x, c.anchor.position.y);
            CGPathAddLineToPoint(path, NULL, p.position.x, p.position.y);
        }
        
        c.visualJoints.path = path;
        CGPathRelease(path);
    }
}

/**
 Removes projectiles outside the scene boundaries.
 */
-(void)removeOutOfBoundProjectiles {
    for (SKNode *node in self.children) {
        
        if ([node isMemberOfClass:[UHMPulseProjectile class]] || [node isMemberOfClass:[UHMRestProjectile class]]) {
            UHMProjectile *projectile = (UHMProjectile*)node;
            
            if (
                projectile.position.x < - projectile.size.width / 2 ||
                projectile.position.y < - projectile.size.height / 2 ||
                projectile.position.x > self.frame.size.width + projectile.size.width / 2 ||
                projectile.position.y > self.frame.size.height + projectile.size.height / 2
                )
            {
                [self removeProjectile:projectile];
            }
        }
    }
}

/**
 Updates the background image position for parallax effect.
 */
-(void)updateBackgroundPosition {
    UHMMotionController *motion = [UHMMotionController sharedMotionController];
    double pitch = motion.deviceMotion.attitude.pitch;
    double roll = motion.roll;
    self.background.position = CGPointMake(self.frame.size.width / 2 - roll * 30, self.frame.size.height / 2 + pitch * 30);
}

/**
 Updates the particle emitter position for parallax effect.
 */
-(void)updateParticlePosition {
    UHMMotionController *motion = [UHMMotionController sharedMotionController];
    double pitch = motion.smoothPitch;
    double roll = motion.smoothRoll;
    
    SKEmitterNode *smallParticles = (SKEmitterNode*)[self childNodeWithName:@"backgroundParticles"];
    smallParticles.position = CGPointMake(self.frame.size.width / 2 - roll * 40, self.frame.size.height / 2 + pitch * 40);
}

/**
 Updates the global gravity.
 */
-(void)updateGravity {
    UHMMotionController *motion = [UHMMotionController sharedMotionController];
    double pitch = motion.deviceMotion.attitude.pitch;
    double roll = motion.roll;
    
    self.physicsWorld.gravity = CGVectorMake(roll * 2, -pitch * 2);
}

-(void)updateCreatureProperties {
    if ([self updateCreatureColors]) {
        [self updateCreatureMusicalProperties];
    }
}

/**
 Updates the colors of the creatures.
 @return YES if color was updated, NO otherwise
 */
-(BOOL)updateCreatureColors {
    static double lastColorUpdateTime;
    
    if (self.colorMap != NULL && (CACurrentMediaTime() > lastColorUpdateTime + 0.2)) {
        
        for (UHMCreature *creature in self.creatures) {
            [creature updateColor];
        }
        
        lastColorUpdateTime = CACurrentMediaTime();
        
        return YES;
    }
    
    return NO;
}

/**
 Updates the musical properties of the creatures.
 */
-(void)updateCreatureMusicalProperties {
    for (UHMCreature *creature in self.creatures) {
        [creature updateMusicalProperties];
    }
}

/**
 Updates the projectile courses.
 */
-(void)updateProjectileCourses {
    for (UHMProjectile *projectile in self.projectiles) {
        [projectile updateCourse];
    }
}

#pragma mark - Actions

/**
 Launches a projectile.
 */
-(void)launchProjectile {
    if (!PROJECTILES) return;
    if (self.creatures.count == 0) return;
    
    if ([self.projectileLaunchTimer isValid]) {
        NSTimeInterval oldInterval = self.projectileLaunchTimer.timeInterval;
        NSTimeInterval newInterval = fmax(oldInterval - 0.1, MIN_LAUNCH_INTERVAL);
        [self.projectileLaunchTimer invalidate];
        
        self.projectileLaunchTimer = [NSTimer scheduledTimerWithTimeInterval:newInterval
                                                                      target:self
                                                                    selector:@selector(launchProjectile)
                                                                    userInfo:nil
                                                                     repeats:YES];
    }
    
    
    static int launchCounter = 0;
    UHMProjectile *projectile;
    
    if ((launchCounter % 5) != 4) {
        projectile = [[UHMPulseProjectile alloc] init];
        projectile.homingTarget = self.swarm;
    } else {
        projectile = [[UHMRestProjectile alloc] init];
        projectile.homingTarget = self.swarm;
    }
    
    [self addChild:projectile];
//    [projectile addParticles];
    [self.projectiles addObject:projectile];
    [projectile.physicsBody applyImpulse:CGVectorMake(0, -1)];
    [self startProjectileLifespanForProjectile:projectile];
    
    launchCounter++;
}

-(void)startProjectileLifespanForProjectile:(UHMProjectile*)projectile {
    __weak typeof(projectile) weakProjectile = projectile;
    
    SKAction *fadeOut = [SKAction fadeAlphaTo:0.05 duration:8.0];
    SKAction *completion = [SKAction runBlock:^{
        [self removeProjectile:weakProjectile];
    }];
    
    [projectile runAction:[SKAction sequence:@[fadeOut, completion]] withKey:@"lifespan"];
}

-(void)removeProjectile:(UHMProjectile*)projectile {
    [projectile removeActionForKey:@"lifespan"];
    
    [self.projectiles removeObject:projectile];
    projectile.physicsBody.contactTestBitMask = 0;
    
    __weak typeof(projectile) weakProjectile = projectile;
    [projectile runAction:[SKAction scaleTo:0.0 duration:0.3] completion:^ {
        [weakProjectile removeFromParent];
    }];
}

#pragma mark - Collisions

-(void)didBeginContact:(SKPhysicsContact *)contact {
    static UHMProjectile *previousProjectile;
    
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
    
    if ((second.categoryBitMask == stepProjectileCategory || second.categoryBitMask == pulseProjectileCategory) &&
        second == previousProjectile.physicsBody)
        return;
    
    if (first.categoryBitMask == creatureCategory && second.categoryBitMask == stepProjectileCategory) {
        previousProjectile = (UHMProjectile*)second.node;
        [self removeProjectile:(UHMProjectile*)second.node];
        
        if ([first.node conformsToProtocol:@protocol(UHMCreatureEntity)]) {
            SKNode <UHMCreatureEntity> *creatureEntity = (SKNode <UHMCreatureEntity> *)first.node;
            UHMCreature *creature = creatureEntity.entity;
            
            [creature removePulseFromPattern];
        }
    }
    
    if (first.categoryBitMask == creatureCategory && second.categoryBitMask == pulseProjectileCategory) {
        previousProjectile = (UHMProjectile*)second.node;
        [self removeProjectile:(UHMProjectile*)second.node];
        
        if ([first.node conformsToProtocol:@protocol(UHMCreatureEntity)]) {
            SKNode <UHMCreatureEntity> *creatureEntity = (SKNode <UHMCreatureEntity> *)first.node;
            UHMCreature *creature = creatureEntity.entity;
            
            [creature addPulseToPattern];
        }
    }
}

#pragma mark - Touch

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
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
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    //  Disable solo mode
    
    if (self.solo) {
        self.solo = NO;
    }
    
    //  Creature spawning
    
    else if (self.creatures.count < 5) {
        [self spawnCreatureAtPosition:location];
        
        if (!self.projectileLaunchTimer) {
            [self launchProjectile];
            self.projectileLaunchTimer = [NSTimer scheduledTimerWithTimeInterval:4.0
                                                                          target:self
                                                                        selector:@selector(launchProjectile)
                                                                        userInfo:nil
                                                                         repeats:YES];
        }
    }
    
    //  Touch ended before solo timer finished
    
    if (!self.solo && self.touchDurationTimer) {
        [self.touchDurationTimer invalidate];
        self.touchDurationTimer = nil;
    }
}



#pragma mark - Solo mode

-(void)moveToSoloMode:(NSTimer*)timer {
    if (![timer.userInfo isKindOfClass:[NSNumber class]]) return;
    
    if (((NSNumber*)(timer.userInfo)).boolValue) {
        [self setSolo:YES];
    }
}

-(void)setSolo:(BOOL)solo {
    _solo = solo;
    __weak typeof(self) weakSelf = self;
    
    if (solo) {
        self.swarm.active = NO;
        for (UHMCreature *creature in self.creatures) {
            creature.anchor.physicsBody.affectedByGravity = NO;
            creature.anchor.physicsBody.velocity = CGVectorMake(0.0, 0.0);
            for (UHMCreaturePulse *pulse in creature.pulses) {
                pulse.physicsBody.affectedByGravity = NO;
                pulse.physicsBody.velocity = CGVectorMake(0.0, 0.0);
            }
        }
        
        NSMutableArray *projectilesToTerminate = [[NSMutableArray alloc] initWithCapacity:self.projectiles.count];
        
        for (UHMProjectile *projectile in self.projectiles) {
            [projectilesToTerminate addObject:projectile];
        }
        
        for (UHMProjectile *projectile in projectilesToTerminate) {
            [self removeProjectile:projectile];
        }
        
        [[UHMAudioController sharedAudioController] setImprovise:YES];
        
        // Visual elements
        
        self.soloOverlay.hidden = NO;
        SKAction *fadeOverlay = [SKAction fadeAlphaTo:0.25 duration:0.5];
        [self.soloOverlay runAction:fadeOverlay withKey:@"solo"];
    }
    
    else {
        self.swarm.active = YES;
        for (UHMCreature *creature in self.creatures) {
            creature.anchor.physicsBody.affectedByGravity = NO;
            for (UHMCreaturePulse *pulse in creature.pulses) {
                pulse.physicsBody.affectedByGravity = YES;
            }
        }
        
        [[UHMAudioController sharedAudioController] setImprovise:NO];
        
        // Visual elements
        
        SKAction *fade = [SKAction fadeAlphaTo:0.0 duration:0.2];
        SKAction *completion = [SKAction runBlock:^{
            weakSelf.soloOverlay.hidden = YES;
        }];
        
        [self.soloOverlay runAction:[SKAction sequence:@[fade, completion]] withKey:@"solo"];
    }
}



#pragma mark - Ending

-(void)endGame {
    NSMutableArray *creaturesToTerminate = [[NSMutableArray alloc] initWithCapacity:self.creatures.count];
    NSMutableArray *projectilesToTerminate = [[NSMutableArray alloc] initWithCapacity:self.projectiles.count];
    
    for (SKNode *node in self.children) {
        [node removeFromParent];
    }
    
    for (UHMCreature *creature in self.creatures) {
        [creaturesToTerminate addObject:creature];
    }
    
    for (UHMCreature *creature in creaturesToTerminate) {
        [creature willTerminate];
    }
    
    for (UHMProjectile *projectile in self.projectiles) {
        [projectilesToTerminate addObject:projectile];
    }
    
    for (UHMProjectile *projectile in projectilesToTerminate) {
        [self removeProjectile:projectile];
    }
    
    if ([self.projectileLaunchTimer isValid]) {
        [self.projectileLaunchTimer invalidate];
    }
    
    self.projectileLaunchTimer = nil;
    
    @try {
        [self.rhythm removeObserver:self.harmony forKeyPath:NSStringFromSelector(@selector(totalPulses))];
    }
    @catch(id NSRangeException) {
        // There is no corresponding observer
    }
}

@end
