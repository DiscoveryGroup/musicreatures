//
//  UHMPulseProjectile.m
//  Musicreatures
//
//  Created by Petri J Myllys on 03/07/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMPulseProjectile.h"
#import "UHMAppDelegate.h"
#import "UHMPlayViewController.h"

@implementation UHMPulseProjectile

-(id)init {
    self = [super initWithSize:CGSizeMake(20, 20)];
    
    if (self) {
        self.texture = [SKTexture textureWithImageNamed:@"add.png"];
        self.alpha = 0.5;
        self.blendMode = SKBlendModeAdd;
        
        self.physicsBody.categoryBitMask = pulseProjectileCategory;
        self.physicsBody.collisionBitMask = 0;
        self.physicsBody.contactTestBitMask = creatureCategory;
        
        [self animate];
    }
    
    return self;
}

/**
 Adds a particle emitter to the projectile.
 */
-(void)addParticles {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"PlusParticles"
                                                     ofType:@"sks"];
    
    SKEmitterNode *emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    emitter.position = CGPointMake(0, 0);
    emitter.name = @"backgroundParticles";
    emitter.targetNode = self.parent;
    [self addChild:emitter];
}

-(void)animate {
    SKAction *diminishSlow = [SKAction scaleTo:0.8 duration:0.6];
    diminishSlow.timingMode = SKActionTimingEaseInEaseOut;
    
    SKAction *diminish = [SKAction scaleTo:0.8 duration:0.1];
    diminish.timingMode = SKActionTimingEaseOut;
    SKAction *enlarge = [SKAction scaleTo:1.0 duration:0.1];
    enlarge.timingMode = SKActionTimingEaseIn;
    
    SKAction *backToNormal = [SKAction scaleTo:1.2 duration:0.4];
    backToNormal.timingMode = SKActionTimingEaseInEaseOut;
    
    [self runAction:[SKAction repeatActionForever: [SKAction sequence:@[diminishSlow,
                                                                        [SKAction repeatAction:[SKAction sequence:@[enlarge, diminish]] count:4],
                                                                        backToNormal]]]];
}

@end
