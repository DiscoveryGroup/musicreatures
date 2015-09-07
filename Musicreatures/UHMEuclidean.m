//
//  UHMEuclidean.m
//  Musicalizer
//
//  Created by Petri J Myllys on 09/06/14.
//  "Euclidean" rhythm algorithm. Based on Bjorklund (1999) / Toussaint (2005).
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMEuclidean.h"

@interface UHMEuclidean()

static NSArray* rotatePattern(NSMutableArray* pattern,int rotations);

@end

@implementation UHMEuclidean

// WARNING: ALGORITHM DOES NOT HANDLE INCORRECT INPUTS WHERE # OF PULSES > # OF SLOTS

+(NSArray*)computePatternOfLength:(int)slots withPulses:(int)pulses {
    return [self computePatternOfLength:slots withPulses:pulses rotations:0];
}

+(NSArray*)computePatternOfLength:(int)slots withPulses:(int)pulses rotations:(int)rotations {
    int divisor, level;
    NSMutableArray *rem = [[NSMutableArray alloc] init];
    NSMutableArray *count = [[NSMutableArray alloc] init];
    
    divisor = slots - pulses;
    [rem addObject: [NSNumber numberWithInt:pulses]];
    level = 0;
    
    while ([[rem objectAtIndex:level] intValue] > 1) {
        NSNumber *c = [NSNumber numberWithInt:divisor / [[rem objectAtIndex:level] intValue]];
        [count insertObject:c atIndex:level];
        
        NSNumber *r = [NSNumber numberWithInt:divisor % [[rem objectAtIndex:level] intValue]];
        [rem insertObject:r atIndex:level+1];
        
        divisor = [[rem objectAtIndex:level] intValue];
        level += 1;
    }
    
    [count insertObject:[NSNumber numberWithInt:divisor] atIndex:level];
    
    NSMutableArray *pattern = [[NSMutableArray alloc] init];
    return rotatePattern(buildPattern(pattern, level, rem, count), rotations);
}

+(NSArray*)computePatternOfLength:(int)slots withPulses:(int)pulses forceBeginWithOnset:(BOOL)forceFirstOnset {
    if (forceFirstOnset) {
        NSArray *pattern = [self computePatternOfLength:slots withPulses:pulses rotations:0];
        int rotationsRequired = rotationsRequiredToBeginWithOnset(pattern);
        return rotatePattern([NSMutableArray arrayWithArray:pattern], rotationsRequired);
    }
    
    return [self computePatternOfLength:slots withPulses:pulses rotations:0];
}

+(NSArray*)findBestMatchForPattern:(NSArray*)pattern {
    NSMutableArray *stepsWithPulses = [[NSMutableArray alloc] init];
    
    int index = 0;
    
    for (NSNumber *number in pattern) {
        if (number.intValue == 1) {
            [stepsWithPulses addObject:[NSNumber numberWithInt:index]];
        }
        
        index++;
    }
    
    int hits;
    int hitsInBestMatch = 0;
    NSArray *bestMatch = [[NSArray alloc] init];
    
    for (int pulses = (int)stepsWithPulses.count; pulses <= 16; pulses++) {
        
        for (int rotation = 0; rotation < 16; rotation++) {
            
            NSMutableArray *count = [[NSMutableArray alloc] init];
            
            index = 0;
            NSArray *candidate = [UHMEuclidean computePatternOfLength:16 withPulses:pulses rotations:rotation];
            
            for (NSNumber *number in candidate) {
                if (number.intValue == 1) {
                    [count addObject:[NSNumber numberWithInt:index]];
                }
                
                index++;
            }
            
            hits = 0;
            
            for (NSNumber *target in stepsWithPulses) {
                for (NSNumber *tryout in count) {
                    if (tryout.intValue == target.intValue) {
                        hits++;
                    }
                }
            }
            
            if (hits > hitsInBestMatch) {
                bestMatch = candidate;
                hitsInBestMatch = hits;
            }
        }
    }
    
    return bestMatch;
}

static NSMutableArray* buildPattern(NSMutableArray *pattern, int level, NSMutableArray *rem, NSMutableArray *count) {
    if (level == -1) {
        [pattern addObject:[NSNumber numberWithInt:0]];
    } else if (level == -2) {
        [pattern addObject:[NSNumber numberWithInt:1]];
    } else {
        for (int i=0; i < [[count objectAtIndex:level] intValue]; i++) {
            buildPattern(pattern, level-1, rem, count);
        }
        
        if ([[rem objectAtIndex:level] intValue] != 0) {
            buildPattern(pattern, level-2, rem, count);
        }
    }
    
    return pattern;
}

static NSArray* rotatePattern(NSMutableArray* pattern, int rotations) {
    for (int times = 0; times < rotations; times++) {
        NSObject *first = [pattern firstObject];
        [pattern addObject:first];
        [pattern removeObjectAtIndex:0];
    }
    
    return pattern;
}

static int rotationsRequiredToBeginWithOnset(NSArray* pattern) {
    int rotations = 0;
    
    for (NSNumber *bit in pattern) {
        if (bit.intValue == 1) {
            break;
        } else {
            rotations++;
        }
    }
    
    return rotations;
}

@end
