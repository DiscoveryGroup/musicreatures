//
//  UHMPitchedCreature.m
//  Musicreatures
//
//  Created by Petri J Myllys on 01/07/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMPitchedCreature.h"
#import "UHMAudioController.h"
#import "UHMNote.h"

#define PITCH_LOWER_BOUNDARY 24
#define PITCH_UPPER_BOUNDARY 84

@implementation UHMPitchedCreature

@synthesize sonicBrightness = _sonicBrightness;

@synthesize entity = _entity;

-(id)initWithName:(NSString*)name hostScene:(UHMAbstractPlayScene*)scene {
    return [self initWithName:name
                    parentScene:scene
                     position:CGPointMake((arc4random() % ((int)self.parentScene.frame.size.width / 2)) + (self.parentScene.frame.size.width / 4),
                                          (arc4random() % ((int)self.parentScene.frame.size.height / 2)) + (self.parentScene.frame.size.height / 4))];
}

-(id)initWithName:(NSString*)name parentScene:(UHMAbstractPlayScene*)scene position:(CGPoint)position {
    return [self initWithName:name parentScene:scene position:position mortal:YES];
}

-(id)initWithName:(NSString *)name parentScene:(UHMAbstractPlayScene *)scene position:(CGPoint)position mortal:(BOOL)mortal {
    self = [super initWithName:name parentScene:scene position:position mortal:mortal];
    
    if (self) {
        self.pitch = self.parentScene.harmony.root;
        SonicBrightness brightness;
        brightness.pitchShiftFactor = 0.0f;
        brightness.filterCutoff = 20000.0f;
        self.sonicBrightness = brightness;
        [self updateMusicalProperties];
        
        [[UHMAudioController sharedAudioController] playNoteAsynchroniouslyWithInstrument:self];
    }
    
    return self;
}

-(void)updateMusicalProperties {
    int octave = 4;
    int additionToScaleRoot = 0;
    int complexity;
    
    CGFloat hue, saturation, brightness;
    [self.color getHue:&hue saturation:&saturation brightness:&brightness alpha:NULL];
    
    if (brightness < 0.10) octave = 1;
    else if (brightness < 0.30) octave = 2;
    else if (brightness < 0.60) octave = 3;
    else if (brightness < 0.80) octave = 4;
    else if (brightness < 0.85) octave = 5;
    else if (brightness < 1.00) octave = 6;
    
    int scale[7];
    
    int currentNotes[7];
    int priorityIndex;
    
    for (int i = 0; i < 7; i++) {
        switch (i) {
            case 0: priorityIndex = 0;
                break;
                
            case 1: priorityIndex = 4;
                break;
                
            case 2: priorityIndex = 2;
                break;
                
            case 3: priorityIndex = 5;
                break;
                
            case 4: priorityIndex = 1;
                break;
                
            case 5: priorityIndex = 6;
                break;
                
            case 6: priorityIndex = 3;
                break;
                
            default: priorityIndex = 0;
                break;
        }
        
        currentNotes[priorityIndex] = ((NSNumber*)[self.parentScene.harmony.scale objectAtIndex:i]).intValue;
    }
    
    memcpy(&scale, &currentNotes, sizeof(currentNotes));
    
    if (saturation < 0.10) complexity = 1;
    else if (saturation < 0.20) complexity = 2;
    else if (saturation < 0.35) complexity = 3;
    else if (saturation < 0.50) complexity = 4;
    else if (saturation < 0.65) complexity = 5;
    else if (saturation < 0.85) complexity = 6;
    else complexity = 7;
    
    additionToScaleRoot = scale[self.currentStep % ((arc4random() % complexity) + 1)];
    
    int newPitch = octave * 12 + 12 + additionToScaleRoot + self.parentScene.harmony.transposition + self.parentScene.harmony.relativeRoot;
    while (newPitch < PITCH_LOWER_BOUNDARY) newPitch += 12;
    while (newPitch > PITCH_UPPER_BOUNDARY) newPitch -= 12;
    
    self.pitch = newPitch;
    
    // Filtering
    
    double cutoff = pow(10 * brightness, 4) + 850;
    
    SonicBrightness sonic;
    sonic.pitchShiftFactor = 1.0;
    sonic.filterCutoff = cutoff;
    self.sonicBrightness = sonic;
}

-(void)setPitch:(int)pitch {
    if (pitch != _pitch) {
        _pitch = pitch;
        
        [[UHMAudioController sharedAudioController] setPitch:pitch forInstrument:self];
    }
}

-(void)setSonicBrightness:(SonicBrightness)sonicBrightness {
    _sonicBrightness = sonicBrightness;
    
    [[UHMAudioController sharedAudioController] setSonicBrightness:sonicBrightness forInstrument:self useOnlyFiltering:YES];
}

@end
