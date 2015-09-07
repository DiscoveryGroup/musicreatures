//
//  UHMChord.m
//  Musicreatures
//
//  Created by Petri J Myllys on 04/10/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMChord.h"

@interface UHMChord()

@property (nonatomic) Tonality tonality;

#pragma mark - Read-only property overrides

@property (nonatomic, readwrite) int degree;
@property (nonatomic, readwrite) int rootOffset;
@property (strong, nonatomic, readwrite) NSArray *scale;

@end

@implementation UHMChord

-(id)initWithDegree:(int)degree tonality:(Tonality)tonality {
    self = [super init];
    
    if (self) {
        self.tonality = tonality;
        self.degree = degree;
        self.scale = [[UHMChord scales] objectForKey:[self scaleAsString]];
    }
    
    return self;
}

-(void)setDegree:(int)degree {
    _degree = degree;
    
    NSArray *scaleDegrees;
    
    switch (self.tonality) {
        case MAJOR:
            scaleDegrees = [[UHMChord scales] objectForKey:@"Ionian"];
            break;
            
        case NATURAL_MINOR:
            scaleDegrees = [[UHMChord scales] objectForKey:@"Ionian"];
            break;
            
        case HARMONIC_MINOR:
            scaleDegrees = [[UHMChord scales] objectForKey:@"HarmonicMinor"];
            break;
            
        default:
            break;
    }
    
    switch (degree) {
        case 1:
            self.rootOffset = ((NSNumber*)[scaleDegrees objectAtIndex:0]).intValue;
            break;
        case 2:
            self.rootOffset = ((NSNumber*)[scaleDegrees objectAtIndex:1]).intValue;
            break;
        case 3:
            self.rootOffset = ((NSNumber*)[scaleDegrees objectAtIndex:2]).intValue;
            break;
        case 4:
            self.rootOffset = ((NSNumber*)[scaleDegrees objectAtIndex:3]).intValue;
            break;
        case 5:
            self.rootOffset = ((NSNumber*)[scaleDegrees objectAtIndex:4]).intValue;
            break;
        case 6:
            self.rootOffset = ((NSNumber*)[scaleDegrees objectAtIndex:5]).intValue;
            break;
        case 7:
            self.rootOffset = ((NSNumber*)[scaleDegrees objectAtIndex:6]).intValue;
            break;
            
        default:
            break;
    }
}

-(NSString*)scaleAsString {
    switch (self.tonality) {
        case MAJOR: case NATURAL_MINOR:
            switch (self.degree) {
                case 1: return @"Ionian";
                case 2: return @"Dorian";
                case 3: return @"Phrygian";
                case 4: return @"Lydian";
                case 5: return @"Mixolydian";
                case 6: return @"Aeolian";
                case 7: return @"Locrian";
                    
                default: return nil;
            }
            
            break;
            
        case HARMONIC_MINOR:
            switch (self.degree) {
                case 1: return @"HarmonicMinor";
                case 2: return @"LocrianSharp6";
                case 3: return @"IonianAug";
                case 4: return @"Romanian";
                case 5: return @"PhrygianDom";
                case 6: return @"LydianSharp2";
                case 7: return @"Ultralocrian";
                    
                default: return nil;
            }

            break;
            
        default:
            break;
    }
}

-(Mode)mode {
    switch (self.degree) {
        case 1: return IONIAN;
        case 2: return DORIAN;
        case 3: return PHRYGIAN;
        case 4: return LYDIAN;
        case 5: return MIXOLYDIAN;
        case 6: return AEOLIAN;
        case 7: return AEOLIAN;
            
        default: return -1;
    }
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
