//
//  UHMAbstractPlaySceneSubclass.h
//  Musicreatures
//
//  Created by Petri J Myllys on 19/12/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMPlayScene.h"
#import "UHMPitchedCreature.h"
#import "UHMPercussiveCreature.h"
#import "UHMBoids.h"
#import "UHMProjectile.h"

/// The extensions in this header are to be used only by subclasses of UHMAbstractPlayScene.
/// Code using UHMAbstractPlayScene must not call these.
@interface UHMAbstractPlayScene (Subclass)

@property (strong, nonatomic) UHMBoids *swarm;
@property (strong, nonatomic) NSMutableArray *partNames;
@property (strong, nonatomic) NSMutableArray *projectiles;
@property (strong, nonatomic) SKSpriteNode *pauseButton;
@property (strong, nonatomic) NSTimer *projectileLaunchTimer;
@property (strong, nonatomic) NSTimer *touchDurationTimer;

-(void)spawnCreatureAtPosition:(CGPoint)position;

-(UHMPitchedCreature*)createPitchedCreatureWithName:(NSString*)name position:(CGPoint)position;

-(UHMPercussiveCreature*)createPercussiveCreatureWithName:(NSString*)name position:(CGPoint)position;

-(void)startProjectileLifespanForProjectile:(UHMProjectile*)projectile;

-(void)didBeginContact:(SKPhysicsContact *)contact;

-(void)launchProjectile;

-(void)removeProjectile:(UHMProjectile*)projectile;

-(void)moveToSoloMode:(NSTimer*)timer;

@end
