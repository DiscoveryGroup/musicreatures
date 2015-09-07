//
//  UHMPolyVoicer.m
//  Musicreatures
//
//  Created by Petri J Myllys on 18/11/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMPolyVoicer.h"
#import "UHMMidiNote.h"

#define FLOOR 55
#define CEILING 96
#define OCTAVE_RANGE 6

@implementation UHMPolyVoicer

+(NSArray*)createVoicingForChordDegree:(int)chordDegree
                            scaleNotes:(NSArray*)scale
                   scaleOffsetFromRoot:(int)offset
                         transposition:(int)transposedSemitones
                        numberOfVoices:(int)voices
                        previousVoices:(NSArray*)previousVoices
                  progressionPrinciple:(MelodicProgression)melodicProgression
{
    // Collect all notes of the scale corresponding the new chord

    NSMutableArray *scaleNotes = [NSMutableArray arrayWithArray:scale];
    
    for (int i = 0; i < scaleNotes.count; i++) {
        [scaleNotes replaceObjectAtIndex:i
                              withObject:[NSNumber numberWithInt:((NSNumber*)[scaleNotes objectAtIndex:i]).intValue +
                                          offset +
                                          OCTAVE_RANGE * 12 +
                                          transposedSemitones]];
    }
    
    // Collect notes for the new chord
    
    NSMutableArray *notes = [[NSMutableArray alloc] init];
    
    if (voices > 0) [notes addObject:[UHMMidiNote noteWithInt:((NSNumber*)[scaleNotes objectAtIndex:0]).intValue]];
    if (voices > 1) [notes addObject:[UHMMidiNote noteWithInt:((NSNumber*)[scaleNotes objectAtIndex:2]).intValue]];
    if (voices > 2) [notes addObject:[UHMMidiNote noteWithInt:((NSNumber*)[scaleNotes objectAtIndex:4]).intValue]];
    if (voices > 3) [notes addObject:[UHMMidiNote noteWithInt:((NSNumber*)[scaleNotes objectAtIndex:1]).intValue]];
    if (voices > 4) [notes addObject:[UHMMidiNote noteWithInt:((NSNumber*)[scaleNotes objectAtIndex:6]).intValue]];
    
    if (!previousVoices || previousVoices.count != voices) {
        return [self createInitialVoicingFromNotes:notes numberOfVoices:voices];
    }
    
    // Sort previous voices descending
    
    NSArray *previousVoicesSorted = [previousVoices sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber *val1 = obj1;
        NSNumber *val2 = obj2;
        
        if (val1.intValue > val2.intValue) return NSOrderedAscending;
        else if (val1.intValue < val2.intValue) return NSOrderedDescending;
        else return NSOrderedSame;
    }];
    
    // Generate voicing based on the previous voicing, new notes, and melodic progression principle
    
    return [self createVoicingWithNotes:notes
                   sortedPreviousVoices:previousVoicesSorted
                   progressionPrinciple:melodicProgression];
}

+(NSArray*)createInitialVoicingFromNotes:(NSArray*)notes numberOfVoices:(int)voices {
    NSMutableArray *voicing = [[NSMutableArray alloc] initWithCapacity:voices];
    if (voices < 1)
        [NSException raise:@"Cannot create a voicing for non-positive number of voices." format:@"Number of voices %d is invalid.", voices];
    
    [voicing addObject:[NSNumber numberWithInt:[[notes objectAtIndex:0] pitch] - 12]];
    if (voices > 1)
        [voicing addObject:[NSNumber numberWithInt:[[notes objectAtIndex:1] pitch]]];
    if (voices > 2)
        [voicing addObject:[NSNumber numberWithInt:[[notes objectAtIndex:2] pitch] - 12]];
    if (voices > 3)
        [voicing addObject:[NSNumber numberWithInt:[[notes objectAtIndex:3] pitch] - 12]];
    if (voices > 4)
        [voicing addObject:[NSNumber numberWithInt:[[notes objectAtIndex:4] pitch] - 12]];
    
    return voicing;
}

+(NSArray*)createVoicingWithNotes:(NSMutableArray*)notes
             sortedPreviousVoices:(NSArray*)previousVoices
             progressionPrinciple:(MelodicProgression)melodicProgression
{
    if (melodicProgression == CONTRACTING)
        return [self createContractingVoicingWithNotes:notes sortedPreviousVoices:previousVoices];
    
    if (melodicProgression == EXPANDING)
        return [self createExpandingVoicingWithNotes:notes sortedPreviousVoices:previousVoices];
    
    NSMutableArray *voicing = [[NSMutableArray alloc] init];
    BOOL melodyVoice = YES;
    
    for (NSNumber *voice in previousVoices) {
        BOOL suitableFound = NO;
        int noteNumber = 0;
        int targetNoteNumber = 0;
        
        if (melodicProgression == ASCENDING) {
            if (melodyVoice) noteNumber = voice.intValue;
            else noteNumber = voice.intValue - 1;
        }
        
        else if (melodicProgression == DESCENDING) {
            if (melodyVoice) noteNumber = voice.intValue;
            else noteNumber = voice.intValue + 1;
        }
        
        while (!suitableFound) {
            if (melodicProgression == ASCENDING) noteNumber++;
            else if (melodicProgression == DESCENDING) noteNumber--;
            
            for (UHMMidiNote *target in notes) {
                targetNoteNumber = target.pitch;
                if (noteNumber % 12 == targetNoteNumber % 12) {
                    suitableFound = YES;
                    break;
                }
            }
        }
        
        while (noteNumber > CEILING) noteNumber -= 12;
        while (noteNumber < FLOOR) noteNumber += 12;
        
        [voicing addObject:[NSNumber numberWithInt:noteNumber]];
        [notes removeObject:[UHMMidiNote noteWithInt:targetNoteNumber]];
        melodyVoice = NO;
    }
    
    return voicing;
}

+(NSArray*)createContractingVoicingWithNotes:(NSMutableArray*)notes
                        sortedPreviousVoices:(NSArray*)previousVoices
{
    NSMutableArray *voicing = [[NSMutableArray alloc] init];
    BOOL descendVoice = YES;
    
    for (NSNumber *voice in previousVoices) {
        BOOL suitableFound = NO;
        int targetNoteNumber = 0;
        int noteNumber;
        if (descendVoice) noteNumber = voice.intValue;
        else noteNumber = voice.intValue-1;
        BOOL optimal = YES;
            
        while (!suitableFound) {
            if (descendVoice) {
                noteNumber--;
                
                for (UHMMidiNote *target in notes) {
                    targetNoteNumber = target.pitch;
                    if (noteNumber % 12 == targetNoteNumber % 12) {
                        suitableFound = YES;
                        break;
                    }
                }
            }
            
            else {
                if (optimal) noteNumber++;
                else noteNumber--;

                for (NSNumber *reserved in voicing) {
                    if (noteNumber >= reserved.intValue) {
                        optimal = NO;
                        continue;
                    }
                }
                
                for (UHMMidiNote *target in notes) {
                    targetNoteNumber = target.pitch;
                    if (noteNumber % 12 == targetNoteNumber % 12) {
                        suitableFound = YES;
                        break;
                    }
                }
            }
        }
        
        while (noteNumber > CEILING) noteNumber -= 12;
        while (noteNumber < FLOOR) noteNumber += 12;
        
        [voicing addObject:[NSNumber numberWithInt:noteNumber]];
        [notes removeObject:[UHMMidiNote noteWithInt:targetNoteNumber]];
        descendVoice = !descendVoice;
    }
    
    return voicing;
}

+(NSArray*)createExpandingVoicingWithNotes:(NSMutableArray*)notes
                      sortedPreviousVoices:(NSArray*)previousVoices
{
    if (abs(((NSNumber*)[previousVoices objectAtIndex:previousVoices.count-1]).intValue -
            ((NSNumber*)[previousVoices objectAtIndex:0]).intValue) > 15)
    {
        return [self createContractingVoicingWithNotes:notes sortedPreviousVoices:previousVoices];
    }
    
    NSMutableArray *voicing = [[NSMutableArray alloc] init];
    BOOL ascendVoice = YES;
    
    for (NSNumber *voice in previousVoices) {
        BOOL suitableFound = NO;
        int targetNoteNumber = 0;
        int noteNumber;
        if (ascendVoice) noteNumber = voice.intValue;
        else noteNumber = voice.intValue+1;
        
        while (!suitableFound) {
            if (ascendVoice) {
                noteNumber++;
                
                for (UHMMidiNote *target in notes) {
                    targetNoteNumber = target.pitch;
                    if (noteNumber % 12 == targetNoteNumber % 12) {
                        suitableFound = YES;
                        break;
                    }
                }
            }
            
            else {
                noteNumber--;
                
                for (UHMMidiNote *target in notes) {
                    targetNoteNumber = target.pitch;
                    if (noteNumber % 12 == targetNoteNumber % 12) {
                        suitableFound = YES;
                        break;
                    }
                }
            }
        }
        
        while (noteNumber > CEILING) noteNumber -= 12;
        while (noteNumber < FLOOR) noteNumber += 12;
        
        [voicing addObject:[NSNumber numberWithInt:noteNumber]];
        [notes removeObject:[UHMMidiNote noteWithInt:targetNoteNumber]];
        ascendVoice = NO;
    }
    
    return voicing;
}

@end
