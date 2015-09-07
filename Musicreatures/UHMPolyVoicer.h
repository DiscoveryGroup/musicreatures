//
//  UHMPolyVoicer.h
//  Musicreatures
//
//  Created by Petri J Myllys on 18/11/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ASCENDING,
    DESCENDING,
    CONTRACTING,
    EXPANDING
} MelodicProgression;

@interface UHMPolyVoicer : NSObject

+(NSArray*)createVoicingForChordDegree:(int)chordDegree
                            scaleNotes:(NSArray*)scale
                   scaleOffsetFromRoot:(int)offset
                         transposition:(int)transposedSemitones
                        numberOfVoices:(int)voices
                        previousVoices:(NSArray*)previousVoices
                  progressionPrinciple:(MelodicProgression)melodicProgression;

@end
