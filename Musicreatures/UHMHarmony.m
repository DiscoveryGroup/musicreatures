//
//  UHMHarmony.m
//  Musicreatures
//
//  Created by Petri J Myllys on 12/08/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMHarmony.h"
#import "UHMAudioController.h"
#import "UHMPolyVoicer.h"
#import "UHMMonoVoicer.h"

@interface UHMHarmony()

/// An array of available chords. Use the ChordName type declared in UHMChord.h to select chords easily. @see UHMChord
@property (strong, nonatomic) NSArray *chords;

/// Current chord. Contains relevant information relating to the chord and the corresponding scale. @see UHMChord
@property (strong, nonatomic) UHMChord *chord;

/// Current chord progression designating chord degrees for each step.
@property (strong, nonatomic) NSArray *progression;

/// Override status of the dynamic chord progression behavior.
@property (nonatomic) BOOL progressionOverride;

#pragma mark - Read-only property overrides

@property (nonatomic, readwrite) int root;
@property (nonatomic, readwrite) int relativeRoot;

#pragma mark - TBD - temporary prototype properties, maybe unnecessary

@property (nonatomic) int pulses;
@property (nonatomic) int bassPitch;
@property (strong, nonatomic) NSArray *melodyScale;

@end

@implementation UHMHarmony

-(id)init {
    self = [super init];
    
    if (self) {
        self.transposition = 0;
        self.tonality = HARMONIC_MINOR;
        self.bassPitch = self.transposition + 2*12 + self.chord.rootOffset;
    }
    
    return self;
}

-(void)updateHarmonyForPlayheadPosition:(int)step {
    int chordDegree = ((NSNumber*)[self.progression objectAtIndex:step]).intValue;
    self.chord = [self.chords objectAtIndex:chordDegree - 1];
}

-(void)playSynthWithNotes:(NSArray*)notes {
    [[UHMAudioController sharedAudioController] playSynthWithNotes:notes];
    [[UHMAudioController sharedAudioController] playBassWithNote:self.bassPitch];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(totalPulses))]) {
        self.pulses = ((NSNumber*)[change objectForKey:@"new"]).intValue;
        [self updateSynthModulationParameters];
    }
}

-(void)updateSynthModulationParameters {
    int transferFunction = 1 + self.pulses / 8.0;
    [self setSynthModulationMultiplier:transferFunction withIntensity:self.pulses * 10.0];
}

-(void)setSynthModulationMultiplier:(float)multiplier withIntensity:(float)intensity {
    [[UHMAudioController sharedAudioController] setSynthModulationMultiplier:multiplier];
}

-(void)createNewVoicing {
    static NSArray *previous = nil;
    NSArray *notes;
    
    if (self.intensity > 0.7) {
        [[UHMAudioController sharedAudioController] setNumberOfSynthVoices:3];
    }
    
    else if (self.intensity > 0.5) {
        [[UHMAudioController sharedAudioController] setNumberOfSynthVoices:4];
    }
    
    else if (self.intensity > 0.3) {
        [[UHMAudioController sharedAudioController] setNumberOfSynthVoices:4];
    }
    
    else {
        [[UHMAudioController sharedAudioController] setNumberOfSynthVoices:3];
    }
    
    if (self.intensity > 0.65) {
        if (arc4random() % 2 == 0) {
            notes = [UHMPolyVoicer createVoicingForChordDegree:self.chord.degree
                                                    scaleNotes:self.chord.scale
                                           scaleOffsetFromRoot:self.chord.rootOffset
                                                 transposition:self.transposition
                                                numberOfVoices:4
                                                previousVoices:previous
                                          progressionPrinciple:ASCENDING];
        }
        
        
        else {
            notes = [UHMPolyVoicer createVoicingForChordDegree:self.chord.degree
                                                    scaleNotes:self.chord.scale
                                           scaleOffsetFromRoot:self.chord.rootOffset
                                                 transposition:self.transposition
                                                numberOfVoices:4
                                                previousVoices:previous
                                          progressionPrinciple:EXPANDING];
        }
        
    }
    
    else {
        if (arc4random() % 2 == 0) {
            notes = [UHMPolyVoicer createVoicingForChordDegree:self.chord.degree
                                                    scaleNotes:self.chord.scale
                                           scaleOffsetFromRoot:self.chord.rootOffset
                                                 transposition:self.transposition
                                                numberOfVoices:4
                                                previousVoices:previous
                                          progressionPrinciple:DESCENDING];
        }
        
        
        else {
            notes = [UHMPolyVoicer createVoicingForChordDegree:self.chord.degree
                                                    scaleNotes:self.chord.scale
                                           scaleOffsetFromRoot:self.chord.rootOffset
                                                 transposition:self.transposition
                                                numberOfVoices:4
                                                previousVoices:previous
                                          progressionPrinciple:CONTRACTING];
        }
        
    }
    
    previous = [notes copy];
    
    [self playSynthWithNotes:notes];
}

-(void)setTonality:(Tonality)tonality {
    _tonality = tonality;
    
    self.chords = @[[[UHMChord alloc] initWithDegree:1 tonality:self.tonality],
                    [[UHMChord alloc] initWithDegree:2 tonality:self.tonality],
                    [[UHMChord alloc] initWithDegree:3 tonality:self.tonality],
                    [[UHMChord alloc] initWithDegree:4 tonality:self.tonality],
                    [[UHMChord alloc] initWithDegree:5 tonality:self.tonality],
                    [[UHMChord alloc] initWithDegree:6 tonality:self.tonality],
                    [[UHMChord alloc] initWithDegree:7 tonality:self.tonality]];

    [self selectProgressions];
}

-(void)overrideProgressionWithProgressionFromFileNamed:(NSString*)progressionFileName {
    NSLog(@"*** Musical properties overridden! ***");
    
    if (!progressionFileName) {
        self.progressionOverride = NO;
        return;
    }
    
    self.progressionOverride = YES;
    
    NSString *progressionPath = [[NSBundle mainBundle] pathForResource:progressionFileName ofType:@"txt"];
    NSString *chords = [NSString stringWithContentsOfFile:progressionPath encoding:NSUTF8StringEncoding error:nil];
    NSArray *bars = [chords componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSMutableArray *progression = [[NSMutableArray alloc] initWithCapacity:64];
    for (int i = 0; i < bars.count; i++) {
        NSArray *bar = [[bars objectAtIndex:i] componentsSeparatedByString:@" "];
        for (NSNumber *chord in bar) {
            [progression addObject:chord];
        }
    }
    
    self.progression = progression;
}

-(void)selectProgressions {
    NSString* progressionsPath;
    
    switch (self.tonality) {
        case MAJOR:
            progressionsPath = [[NSBundle mainBundle] pathForResource:@"MajorProgressions" ofType:@"txt"];
            break;
            
        case NATURAL_MINOR:
            progressionsPath = [[NSBundle mainBundle] pathForResource:@"NaturalMinorProgressions" ofType:@"txt"];
            break;
            
        case HARMONIC_MINOR:
            progressionsPath = [[NSBundle mainBundle] pathForResource:@"HarmonicMinorProgressions" ofType:@"txt"];
            break;
            
        default:
            break;
    }
    
    NSMutableArray *bars = [[NSMutableArray alloc] initWithCapacity:4];
    for (int i = 0; i < 4; i++) {
        [bars addObject:[[NSMutableArray alloc] init]];
    }
    
    NSString *progressions = [NSString stringWithContentsOfFile:progressionsPath encoding:NSUTF8StringEncoding error:nil];
    NSArray *rows = [progressions componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    for (int i = 0; i < rows.count; i++) {
        NSArray *bar = [[rows objectAtIndex:i] componentsSeparatedByString:@" "];
        NSMutableArray *k = [bars objectAtIndex:i % 4];
        [k addObject:bar];
    }
    
    NSMutableArray *progression = [[NSMutableArray alloc] initWithCapacity:64];
    
    for (int barFunction = 0; barFunction < 4; barFunction++) {
        int barIndex = arc4random() % ((NSMutableArray*)[bars objectAtIndex:barFunction]).count;
        for (NSNumber *chord in [[bars objectAtIndex:barFunction] objectAtIndex:barIndex]) {
            [progression addObject:chord];
        }
    }
    
    self.progression = progression;
}

-(void)setChord:(UHMChord *)chord {
    BOOL revoice = _chord != chord;

    _chord = chord;
    self.scale = self.chord.scale;
    self.bassPitch = self.transposition + 24 + self.chord.rootOffset;
    [[UHMAudioController sharedAudioController] playBassWithNote:self.bassPitch];
    
    if (revoice) [self createNewVoicing];
}

-(void)updateBassPitch {
    int previousBass = self.bassPitch;
    self.bassPitch = [UHMMonoVoicer nextNoteForChordDegree:self.chord.degree
                                                scaleNotes:self.chord.scale
                                       scaleOffsetFromRoot:self.chord.rootOffset
                           restrictSelectionToScaleDegrees:@[@1, @3, @5]
                                             transposition:self.transposition previousNote:previousBass];
    [[UHMAudioController sharedAudioController] playBassWithNote:self.bassPitch];
}

-(void)setScale:(NSArray *)scale {
    _scale = scale;
    self.relativeRoot = self.chord.rootOffset;
}

-(void)setTransposition:(int)transposition {
    _transposition = transposition;
    self.root = self.transposition + 5*12 + self.relativeRoot;
    self.chord = [self.chords objectAtIndex:((NSNumber*)[self.progression objectAtIndex:0]).intValue-1];
}

-(void)setRelativeRoot:(int)relativeRoot {
    _relativeRoot = relativeRoot;
    self.root = self.transposition + 5*12 + relativeRoot;
}

-(void)setProgression:(NSArray *)progression {
    _progression = progression;
}

@end
