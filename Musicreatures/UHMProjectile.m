//
//  UHMProjectile.m
//  Musicreatures
//
//  Created by Petri J Myllys on 04/07/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMProjectile.h"
#import "UHMPlayViewController.h"
#import "UHMPlayScene.h"

@interface UHMProjectile()

@property (nonatomic) double creaturesCenterOfMass;

static CGPoint findPosition();

@end

@implementation UHMProjectile

-(id)init {
    return [self initWithColor:[SKColor greenColor] size:CGSizeMake(30, 30)];
}

-(id)initWithSize:(CGSize)size {
    self = [super init];
    
    if (self) {
        self.size = size;
        self.position = findPosition();
        self.spawnTime = 0;
        
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width / 2];
        self.physicsBody.affectedByGravity = NO;
        self.physicsBody.angularDamping = 0.0f;
    }
    
    return self;
}

static CGPoint findPosition() {
    UHMPlayViewController *viewController = (UHMPlayViewController*)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    return CGPointMake(CGRectGetMidX(viewController.playScene.frame), viewController.playScene.frame.size.height);
}

-(void)addParticles {
    //  TBP
}

-(void)updateCourse {
    if (self.homingTarget) {
//        int jitter = (arc4random() % 3 - 1) * 5;
        double newVelocityX = self.physicsBody.velocity.dx + ((self.homingTarget.centerOfMass.x - self.position.x) / 300);
        double newVelocityY = self.physicsBody.velocity.dy + ((self.homingTarget.centerOfMass.y - self.position.y) / 800);
        
//        if (fabs(newVelocityX) > fabs(newVelocityY)) newVelocityY += (double)jitter;
//        else newVelocityX += jitter;
        
        self.physicsBody.velocity = CGVectorMake(newVelocityX, newVelocityY);
    }
}

@end
