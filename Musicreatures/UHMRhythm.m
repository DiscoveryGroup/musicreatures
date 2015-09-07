//
//  UHMRhythm.m
//  Musicreatures
//
//  Created by Petri J Myllys on 25/09/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMRhythm.h"
#import "UHMEuclidean.h"
#import "UHMAudioController.h"

@interface UHMRhythm()

@property (strong, nonatomic) NSMutableDictionary *currentPulses;

@end

@implementation UHMRhythm

@synthesize name = _name;

-(id)init {
    self = [super init];
    
    if (self) {
        self.currentPulses = [[NSMutableDictionary alloc] init];
        self.name = @"synth";
    }
    
    return self;
}

-(int)totalPulses {
    int pulses = 0;
    
    for (NSNumber *pulsesPerPattern in self.currentPulses.allValues) {
        pulses += pulsesPerPattern.intValue;
    }
    
    return pulses;
}

-(void)storeNumberOfPulses:(int)pulses forInstrument:(id<UHMInstrument>)instrument {
    [self willChangeValueForKey:NSStringFromSelector(@selector(totalPulses))];
    
    [self.currentPulses setValue:[NSNumber numberWithInt:pulses]
                          forKey:[NSString stringWithFormat:@"%@", instrument.name]];
    
    [self didChangeValueForKey:NSStringFromSelector(@selector(totalPulses))];
    
    int pulsesToPlay;
    if (self.totalPulses > 12) pulsesToPlay = 12;
    else pulsesToPlay = self.totalPulses;
    
    NSArray *sumPattern = [UHMEuclidean computePatternOfLength:16 withPulses:pulsesToPlay forceBeginWithOnset:YES];
    [[UHMAudioController sharedAudioController] setPattern:sumPattern forInstrument:self];
}

@end