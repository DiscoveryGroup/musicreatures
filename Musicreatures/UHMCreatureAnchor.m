//
//  UHMCreatureAnchor.m
//  Musicreatures
//
//  Created by Petri J Myllys on 28/07/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMCreatureAnchor.h"
#import "UHMPhysicsCategories.h"
#import "UHMMotionController.h"

@implementation UHMCreatureAnchor

@synthesize entity = _entity;

-(id)initWithParentCreature:(UHMCreature*)parent {
    self = [super init];
    
    if (self) {
        self.size = CGSizeMake(20, 20);
        self.alpha = 1;
        self.texture = [SKTexture textureWithImageNamed:@"circle_fill_opaque_white.png"];
        self.zPosition = 1;
        self.entity = parent;
        
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width / 2.0];
        
        self.physicsBody.categoryBitMask = creatureAnchorCategory;
        self.physicsBody.collisionBitMask = edgeCategory;
//        self.physicsBody.contactTestBitMask = 0;
        
        self.physicsBody.dynamic = YES;
        self.physicsBody.affectedByGravity = YES;
        self.physicsBody.allowsRotation = NO;
        self.physicsBody.density = 5;
        self.physicsBody.friction = 0;
        self.physicsBody.linearDamping = 2;
    }
    
    return self;
}

@end
