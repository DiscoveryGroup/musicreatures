//
//  UHMStepProjectile.m
//  Musicreatures
//
//  Created by Petri J Myllys on 04/07/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMRestProjectile.h"
#import "UHMAppDelegate.h"
#import "UHMPlayViewController.h"

@implementation UHMRestProjectile

-(id)init {
    self = [super initWithSize:CGSizeMake(20, 20)];
    
    if (self) {
        self.texture = [SKTexture textureWithImageNamed:@"remove.png"];
        self.alpha = 0.5;
        self.blendMode = SKBlendModeAdd;
        
        self.physicsBody.categoryBitMask = stepProjectileCategory;
        self.physicsBody.collisionBitMask = 0;
        self.physicsBody.contactTestBitMask = creatureCategory;
        
        [self animate];
    }
    
    return self;
}

-(void)animate {
    SKAction *rotate = [SKAction rotateByAngle:2*M_PI duration:0.4];
    rotate.timingMode = SKActionTimingEaseIn;
    SKAction *rotateMore = [SKAction rotateByAngle:2*M_PI duration:0.4];
    rotateMore.timingMode = SKActionTimingEaseOut;
    SKAction *rotateBack = [SKAction rotateByAngle:-2*M_PI duration:0.4];
    rotateBack.timingMode = SKActionTimingEaseIn;
    SKAction *rotateBackMore = [SKAction rotateByAngle:-2*M_PI duration:0.4];
    rotateBackMore.timingMode = SKActionTimingEaseOut;
    
    SKAction *enlarge = [SKAction scaleTo:1.2 duration:0.4];
    enlarge.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *diminish = [SKAction scaleTo:1.0 duration:0.4];
    diminish.timingMode = SKActionTimingEaseInEaseOut;
    
    SKAction *wait = [SKAction waitForDuration:0.3];
    SKAction *waitMore = [SKAction waitForDuration:0.6];
    
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[waitMore,
                                                                       [SKAction group:@[rotate, enlarge]],
                                                                       [SKAction group:@[rotateMore, diminish]],
                                                                       wait,
                                                                       [SKAction group:@[rotateBack, enlarge]],
                                                                       [SKAction group:@[rotateBackMore, diminish]]]]]];
}

@end
