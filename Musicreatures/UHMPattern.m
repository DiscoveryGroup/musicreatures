//
//  UHMPattern.m
//  Musicreatures
//
//  Created by Petri J Myllys on 13/08/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMPattern.h"
#import "UHMNote.h"
#import "UHMEuclidean.h"

@implementation UHMPattern

+(id)patternWithArray:(NSArray*)array {
    return [[UHMPattern alloc] initWithArray:array];
}

-(id)init {
    return [self initWithArray:[[NSArray alloc] init]];
}

-(id)initWithArray:(NSArray *)array {
    self = [super init];
    
    if (self) {
        self.noteArray = [[NSMutableArray alloc] init];
        [self setPatternWithNumberArray:array];
    }
    
    return self;
}

#pragma mark - Pattern modifying

-(void)addPulse {
    if (self.pulses < self.steps) {
        [self setPatternWithNumberArray:[UHMEuclidean computePatternOfLength:self.steps
                                                                  withPulses:self.pulses+1
                                                         forceBeginWithOnset:YES]];
    }
}

-(void)removePulse {
    if (self.pulses > 0) {
        [self setPatternWithNumberArray:[UHMEuclidean computePatternOfLength:self.steps
                                                                  withPulses:self.pulses-1
                                                         forceBeginWithOnset:YES]];
    }
}

-(void)setPatternWithNumberArray:(NSArray*)array {
    [self willChangeValueForKey:NSStringFromSelector(@selector(noteArray))];
    
    if (self.steps > 0) {
        [self.noteArray removeAllObjects];
    }
    
    for (NSNumber *number in array) {
        [self.noteArray addObject:[UHMNote noteWithPitch:number.intValue]];
    }
    
    [self didChangeValueForKey:NSStringFromSelector(@selector(noteArray))];
}

#pragma mark - Getters

-(int)steps {
    return (int)self.noteArray.count;
}

-(int)pulses {
    int pulsesInPattern = 0;
    
    if (self.noteArray) {
        for (UHMNote *note in self.noteArray) {
            if (note.isPulse) {
                pulsesInPattern++;
            }
        }
    }
    
    return pulsesInPattern;
}

-(int)rests {
    int restsInPattern = 0;
    
    if (self.noteArray) {
        for (UHMNote *note in self.noteArray) {
            if (!note.isPulse) {
                restsInPattern++;
            }
        }
    }
    
    return restsInPattern;
}

@end
