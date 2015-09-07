//
//  UHMMidiValueConverter.m
//  Musicreatures
//
//  Created by Petri J Myllys on 18/11/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMMidiValueConverter.h"

@implementation UHMMidiValueConverter

+(int)convertMidiNoteNumberToScaleDegree:(int)midiNoteNumber scaleRoot:(int)rootNoteNumber mode:(Mode)mode {
    int note = midiNoteNumber % 12;
    int root = rootNoteNumber % 12;
    int offsetFromScaleRoot = note - root;
    NSArray *scale;

    switch (mode) {
        case IONIAN:
            scale = [[UHMMidiValueConverter scales] objectForKey:@"Ionian"];
            break;
            
        case DORIAN:
            scale = [[UHMMidiValueConverter scales] objectForKey:@"Dorian"];
            break;
            
        case PHRYGIAN:
            scale = [[UHMMidiValueConverter scales] objectForKey:@"Phrygian"];
            break;
            
        case LYDIAN:
            scale = [[UHMMidiValueConverter scales] objectForKey:@"Lydian"];
            break;
            
        case MIXOLYDIAN:
            scale = [[UHMMidiValueConverter scales] objectForKey:@"Mixolydian"];
            break;
            
        case AEOLIAN:
            scale = [[UHMMidiValueConverter scales] objectForKey:@"Aeolian"];
            break;
            
        case LOCRIAN:
            scale = [[UHMMidiValueConverter scales] objectForKey:@"Locrian"];
            break;
            
        default:
            break;
    }
    
    for (int i = 0; i < scale.count; i++)
        if (((NSNumber*)[scale objectAtIndex:i]).intValue == offsetFromScaleRoot) return i+1;
    
    return -1; // Note does not belong to the scale
}

+(NSDictionary*)scales {
    static NSDictionary *scalesDictionary = nil;
    
    if (!scalesDictionary) {
        NSString* scalesListPath = [[NSBundle mainBundle] pathForResource:@"Scales" ofType:@"plist"];
        scalesDictionary = [[NSDictionary alloc] initWithContentsOfFile:scalesListPath];
    }
    
    return scalesDictionary;
}

@end
