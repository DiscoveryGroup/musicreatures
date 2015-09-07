//
//  UHMMonoVoicer.m
//  Musicreatures
//
//  Created by Petri J Myllys on 04/12/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMMonoVoicer.h"

#define FLOOR 20
#define CEILING 40
#define OCTAVE_RANGE 2

@implementation UHMMonoVoicer

+(int)nextNoteForChordDegree:(int)chordDegree
                  scaleNotes:(NSArray *)scale
         scaleOffsetFromRoot:(int)offset
restrictSelectionToScaleDegrees:(NSArray *)scaleDegreesToUse
               transposition:(int)transposedSemitones
                previousNote:(int)previousNote
{
    NSMutableArray *scaleNotes = [NSMutableArray arrayWithArray:scale];
    
    for (int i = 0; i < scaleNotes.count; i++) {
        [scaleNotes replaceObjectAtIndex:i
                              withObject:[NSNumber numberWithInt:((NSNumber*)[scaleNotes objectAtIndex:i]).intValue +
                                          offset +
                                          OCTAVE_RANGE * 12 +
                                          transposedSemitones]];
    }
    
    NSMutableArray *notes = [[NSMutableArray alloc] init];
    
    if (!scaleDegreesToUse) notes = scaleNotes;
    
    else
        for (NSNumber *degree in scaleDegreesToUse)
            [notes addObject:[scaleNotes objectAtIndex:((NSNumber*)degree).intValue-1]];
    
    int up = previousNote + 1;
    int down = previousNote - 1;
    int suitable = -1;
    
    while (suitable < 0) {
        for (NSNumber *target in notes) {
            if (up % 12 == target.intValue % 12) {
                suitable = up;
                break;
            }

            if (down % 12 == target.intValue % 12) {
                suitable = down;
                break;
            }
        }
        
        up++;
        down--;
    }
    
    while (suitable > CEILING) suitable -= 12;
    while (suitable < FLOOR) suitable += 12;
    
    return suitable;
}

@end
