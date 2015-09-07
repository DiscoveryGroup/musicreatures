//
//  UHMBoids.h
//  Musicreatures
//
//  Created by Petri J Myllys on 01/07/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UHMCreature.h"

@interface UHMBoids : NSObject

@property (nonatomic) CGPoint centerOfMass;
@property (nonatomic) BOOL active;

-(id)initWithBoids:(NSArray *)boidArray frame:(CGSize)frame;
-(void)addBoid:(UHMCreature*)boid;
-(void)removeBoid:(UHMCreature*)boid;
-(void)updatePositions;

@end
