//
//  UHMBoids.m
//  Musicreatures
//
//  Created by Petri J Myllys on 01/07/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMBoids.h"
#import "UHMPitchedCreature.h"
#import "UHMCreaturePulse.h"
#import "UHMMotionController.h"
#import "UHMLowPassFilter.h"

#define VALUE_SCALE 1

@interface UHMBoids()

@property (strong, nonatomic) NSMutableArray *boids;
@property (nonatomic) CGSize frameRectangle;
@property (nonatomic) double separation;
@property (strong, nonatomic) NSDictionary *motionFilters;

@end

@implementation UHMBoids

#pragma mark - Initialization

-(id)initWithFrame:(CGSize)frame {
    return [self initWithBoids:[[NSArray alloc] init] frame:frame];
}

-(id)initWithBoids:(NSArray *)boidArray frame:(CGSize)frame {
    self = [super init];
    
    if (self) {
        self.boids = [NSMutableArray arrayWithArray:boidArray];
        self.frameRectangle = frame;
        self.separation = 20;
        self.active = YES;
        
        [self createFilters];
    }
    
    return self;
}

-(void)createFilters {
    self.motionFilters = [[NSMutableDictionary alloc] init];
    [self.motionFilters setValue:[[UHMLowPassFilter alloc] init] forKey:@"accX"];
    [self.motionFilters setValue:[[UHMLowPassFilter alloc] init] forKey:@"accY"];
    [self.motionFilters setValue:[[UHMLowPassFilter alloc] init] forKey:@"accZ"];
}

-(void)addBoid:(UHMCreature *)boid {
    [self.boids addObject:boid];
}

-(void)removeBoid:(UHMCreature*)boid {
    [self.boids removeObject:boid];
}

#pragma mark - Main rules

/*
 *  Rule1 makes boids try to fly towards the centre of mass of neighbouring boids.
 */
-(CGVector)home:(UHMCreature*)evaluatedPart {
    CGPoint perceivedCenterOfMass = CGPointMake(0, 0);
    
    for (UHMCreature *p in self.boids) {
        if (![p isEqual:evaluatedPart]) {
            perceivedCenterOfMass.x = perceivedCenterOfMass.x + p.position.x;
            perceivedCenterOfMass.y = perceivedCenterOfMass.y + p.position.y;
        }
    }
    
    perceivedCenterOfMass.x = perceivedCenterOfMass.x / (double)(self.boids.count - 1);
    perceivedCenterOfMass.y = perceivedCenterOfMass.y / (double)(self.boids.count - 1);
    
    return CGVectorMake((perceivedCenterOfMass.x - evaluatedPart.position.x) / 50.0 * VALUE_SCALE,
                        (perceivedCenterOfMass.y - evaluatedPart.position.y) / 50.0 * VALUE_SCALE);
}

/*
 *  Rule2 makes boids try to keep a small distance away from other other boids.
 */
-(CGVector)keepDistance:(UHMCreature*)evaluatedPart {
    CGVector distanceVector = CGVectorMake(0, 0);
    
    for (UHMCreature *p in self.boids) {
        
        if (![p isEqual:evaluatedPart]) {
            
            double distanceX = p.position.x - evaluatedPart.position.x;
            double distanceY = p.position.y - evaluatedPart.position.y;
            double distance = sqrt(pow(distanceX, 2) + pow(distanceY, 2));
            
            if (distance < self.separation) {
                distanceVector.dx = distanceVector.dx - distanceX;
                distanceVector.dy = distanceVector.dy - distanceY;
            }
        }
    }
    
    return distanceVector;
}

#pragma mark - Additional computations

-(CGPoint)computeCenterOfMass {
    CGPoint center = CGPointMake(0, 0);
    
    for (UHMCreature *p in self.boids) {
        center.x = center.x + p.position.x;
        center.y = center.y + p.position.y;
    }
    
    center.x = center.x / (double)self.boids.count;
    center.y = center.y / (double)self.boids.count;
    
    return CGPointMake(center.x, center.y);
}

#pragma mark - Update

-(void)updatePositions {
    if (!self.active) return;
    
    if (self.boids.count == 0) {
        return;
    }
    
    if (self.boids.count == 1) {
        self.centerOfMass = [self computeCenterOfMass];
        return;
    }
    
    UHMMotionController *motion = [UHMMotionController sharedMotionController];
    self.separation = motion.accelerationMagnitude > 0.2 ? motion.accelerationMagnitude * 100.0 : 10.0;
    
    CGVector v1, v2;
    double anchorVelX, anchorVelY;
    
    for (UHMCreature *boid in self.boids) {
        v1 = [self home:boid];
        v2 = [self keepDistance:boid];
        
        anchorVelX = boid.anchor.physicsBody.velocity.dx + 0.5 * v1.dx + v2.dx;
        anchorVelY = boid.anchor.physicsBody.velocity.dy + 0.5 * v1.dy + v2.dy;
        
        boid.anchor.physicsBody.velocity = CGVectorMake(anchorVelX, anchorVelY);
    }
    
    self.centerOfMass = [self computeCenterOfMass];
}

@end