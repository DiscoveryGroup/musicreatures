//
//  UHMCreatureAnchor.h
//  Musicreatures
//
//  Created by Petri J Myllys on 28/07/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "UHMCreatureEntity.h"

@interface UHMCreatureAnchor : SKSpriteNode <UHMCreatureEntity>

-(id)initWithParentCreature:(UHMCreature*)parent;

@end
