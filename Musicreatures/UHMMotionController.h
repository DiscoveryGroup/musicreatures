//
//  UHMMotionController.h
//  Musicalizer
//
//  Created by Petri J Myllys on 06/06/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@interface UHMMotionController : CMMotionManager

@property (nonatomic) double roll;
@property (nonatomic) double smoothPitch;
@property (nonatomic) double smoothRoll;

@property (nonatomic) double accelerationMagnitude;

+(id)sharedMotionController;

@end
