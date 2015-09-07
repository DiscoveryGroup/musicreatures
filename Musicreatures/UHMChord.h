//
//  UHMChord.h
//  Musicreatures
//
//  Created by Petri J Myllys on 04/10/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UHMMusicalTerms.h"

typedef enum {
    MAJOR,
    NATURAL_MINOR,
    HARMONIC_MINOR
} Tonality;

@interface UHMChord : NSObject

@property (nonatomic, readonly) int degree;
@property (nonatomic, readonly) int rootOffset;
@property (strong, nonatomic, readonly) NSArray *scale;

-(id)initWithDegree:(int)degree tonality:(Tonality)tonality;

@end
