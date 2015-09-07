//
//  UHMProjectile.h
//  Musicreatures
//
//  Created by Petri J Myllys on 04/07/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "UHMPhysicsCategories.h"
#import "UHMBoids.h"

@interface UHMProjectile : SKSpriteNode

@property (nonatomic) double spawnTime;
@property (weak, nonatomic) UHMBoids *homingTarget;

-(id)initWithSize:(CGSize)size;
-(void)addParticles;
-(void)updateCourse;

@end
