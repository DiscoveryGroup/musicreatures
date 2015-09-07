//
//  UHMCreatureComponent.m
//  Musicreatures
//
//  Created by Petri J Myllys on 28/07/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMCreaturePulse.h"
#import "UHMPhysicsCategories.h"

@interface UHMCreaturePulse()

@property (strong, nonatomic) SKSpriteNode *center;

@end

@implementation UHMCreaturePulse

@synthesize entity = _entity;

-(id)initWithPosition:(CGPoint)position enabled:(BOOL)enabled {
    return [self initWithPosition:position enabled:enabled radius:10 parentCreature:nil];
}

-(id)initWithPosition:(CGPoint)position enabled:(BOOL)enabled radius:(int)radius parentCreature:(UHMCreature*)parent {
    self = [super init];
    
    if (self) {
        self.enabled = enabled;
        self.texture = [SKTexture textureWithImageNamed:@"circle_fill_opaque_white.png"];
        self.blendMode = SKBlendModeAlpha;
        self.alpha = 0.0f;
        self.position = position;
        self.size = CGSizeMake(radius * 2, radius * 2);
        self.zPosition = 0;
        self.entity = parent;
        
        self.center = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"circle_fill_opaque_white"]];
        self.center.size = CGSizeMake(self.size.width * 0.25, self.size.height * 0.25);
        self.center.position = CGPointMake(0.0f, 0.0f);
        self.center.zPosition = 2;
        self.center.alpha = 1.0;
        self.center.blendMode = SKBlendModeAlpha;
        [self addChild:self.center];
        
        self.border = [[SKSpriteNode alloc] init];
        if (enabled) self.border.texture = [SKTexture textureWithImageNamed:@"circle_border_gradient_white.png"];
        else self.border.texture = [SKTexture textureWithImageNamed:@"circle_border_thin_gradient_white.png"];
        
        self.border.position = CGPointMake(0, 0);
        self.border.alpha = 0.8;
        self.border.colorBlendFactor = 1.0;
        self.border.blendMode = SKBlendModeAlpha;
        self.border.size = self.size;
        [self addChild:self.border];
        
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
        
        self.physicsBody.categoryBitMask = creatureCategory;
        self.physicsBody.collisionBitMask = edgeCategory | creatureCategory;
        self.physicsBody.contactTestBitMask = 0;

        self.physicsBody.density = 1; // (double)arc4random() / 0x100000000;
        self.physicsBody.angularDamping = 2;
    }
    
    return self;
}

/**
 Animates component spawn.
 */
-(void)animateSpawn {
    SKAction *scaleToZero = [SKAction scaleTo:0 duration:0];
    SKAction *scaleToOverSize = [SKAction scaleTo:1.5 duration:0.2];
    scaleToOverSize.timingMode = SKActionTimingEaseOut;
    SKAction *scaleToFullSize = [SKAction scaleTo:1.0 duration:0.1];
    scaleToFullSize.timingMode = SKActionTimingEaseIn;
    
    [self runAction:[SKAction group:@[[SKAction fadeAlphaTo:1.0 duration:0.15],
                                      [SKAction sequence:@[scaleToZero, scaleToOverSize, scaleToFullSize]]]]];
}

-(void)fadeOut:(void (^)())completion {
    [self runAction:[SKAction scaleTo:0.0 duration:0.3] completion:completion];
    [self.border runAction:[SKAction scaleTo:0.0 duration:0.3]];
}

-(void)colorizeWithColor:(SKColor*)color {
    [self colorizeFillWithColor:color];
    [self colorizeBorderWithColor:color];
    [self colorizeCenterWithColor:color];
}

-(void)colorizeFillWithColor:(SKColor*)color {
    CGFloat h, s, b, fillSaturation, fillBrightness, fillAlpha;
    
    [color getHue:&h saturation:&s brightness:&b alpha:NULL];
    
    if (self.enabled) {
        fillSaturation = s + 0.04;
        fillBrightness = b < 0.80 ? b + 0.1 : b;
        fillAlpha = 0.9;
    }
    
    else {
        fillSaturation = s;
        fillBrightness = b;
        fillAlpha = 0.25;
    }
    
    SKAction *colorize = [SKAction colorizeWithColor:[SKColor colorWithHue:h saturation:fillSaturation brightness:fillBrightness alpha:fillAlpha]
                                    colorBlendFactor:1.0
                                            duration:0.3];
    
    [self runAction:colorize withKey:@"colorizeFill"];
}

-(void)colorizeBorderWithColor:(SKColor*)color {
    CGFloat h, s, b, borderSaturation, borderBrightness, borderAlpha;
    
    [color getHue:&h saturation:&s brightness:&b alpha:NULL];
    
    if (self.enabled) {
        borderSaturation = s + 0.1;
        borderBrightness = b < 0.95 ? b + 0.4 : b - 0.2;
        borderAlpha = 1.0;
    }
    
    else {
        borderSaturation = s - 0.3;
        borderBrightness = b < 0.95 ? b + 0.2 : b - 0.2;
        borderAlpha = 0.6;
    }
    
    SKAction *colorize = [SKAction colorizeWithColor:[SKColor colorWithHue:h saturation:borderSaturation brightness:borderBrightness alpha:borderAlpha]
                                    colorBlendFactor:1.0
                                            duration:0.3];
    
    [self.border runAction:colorize withKey:@"colorizeBorder"];
}

-(void)colorizeCenterWithColor:(SKColor*)color {
    CGFloat h, s, b;
    [color getHue:&h saturation:&s brightness:&b alpha:NULL];
    b += 0.2;
    b = b <= 1.0 ? b : 1.0;
    
    SKAction *colorize = [SKAction colorizeWithColor:[SKColor colorWithHue:h saturation:s brightness:b alpha:1.0]
                                    colorBlendFactor:1.0
                                            duration:0.3];
    
    [self.center runAction:colorize withKey:@"colorizeCenter"];
}

-(void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    
    if (self.border) {
        if (enabled) self.border.texture = [SKTexture textureWithImageNamed:@"circle_border_gradient_white.png"];
        else self.border.texture = [SKTexture textureWithImageNamed:@"circle_border_thin_gradient_white.png"];
    }
}

-(void)setSize:(CGSize)size {
    [super setSize:size];
    self.border.size = size;
}

@end
