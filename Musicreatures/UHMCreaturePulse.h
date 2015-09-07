//
//  UHMCreatureComponent.h
//  Musicreatures
//
//  Created by Petri J Myllys on 28/07/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "UHMCreatureEntity.h"

@interface UHMCreaturePulse : SKSpriteNode <UHMCreatureEntity>

@property (nonatomic) BOOL enabled;

@property (nonatomic) SKSpriteNode *border;

-(id)initWithPosition:(CGPoint)position enabled:(BOOL)enabled;
-(id)initWithPosition:(CGPoint)position enabled:(BOOL)enabled radius:(int)radius parentCreature:(UHMCreature*)parent;
-(void)animateSpawn;
-(void)fadeOut:(void (^)())completion;
-(void)colorizeWithColor:(SKColor*)color;

@end
