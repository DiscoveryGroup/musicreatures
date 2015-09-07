//
//  UHMMonoVoicer.h
//  Musicreatures
//
//  Created by Petri J Myllys on 04/12/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UHMMonoVoicer : NSObject

+(int)nextNoteForChordDegree:(int)chordDegree
                  scaleNotes:(NSArray*)scale
         scaleOffsetFromRoot:(int)offset
restrictSelectionToScaleDegrees:(NSArray*)scaleDegreesToUse
               transposition:(int)transposedSemitones
                previousNote:(int)previousNote;

@end
