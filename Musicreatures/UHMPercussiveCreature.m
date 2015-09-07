//
//  UHMPercussiveCreature.m
//  Musicreatures
//
//  Created by Petri J Myllys on 11/07/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMPercussiveCreature.h"
#import "UHMAudioController.h"

@implementation UHMPercussiveCreature

@synthesize sonicBrightness = _sonicBrightness;

-(id)initWithName:(NSString*)name parentScene:(UHMAbstractPlayScene*)scene position:(CGPoint)position {
    return [self initWithName:name parentScene:scene position:position mortal:YES];
}

-(id)initWithName:(NSString *)name parentScene:(UHMAbstractPlayScene *)scene position:(CGPoint)position mortal:(BOOL)mortal {
    self = [super initWithName:name parentScene:scene position:position mortal:mortal];
    
    if (self) {
        SonicBrightness brightness;
        brightness.pitchShiftFactor = 1.0f;
        brightness.filterCutoff = 20000.0f;
        self.sonicBrightness = brightness;
        
        [[UHMAudioController sharedAudioController] setSampleForInstrument:self];
        [[UHMAudioController sharedAudioController] playNoteAsynchroniouslyWithInstrument:self];
    }
    
    return self;
}

-(void)updateMusicalProperties {
    CGFloat hue, saturation, brightness;
    [self.color getHue:&hue saturation:&saturation brightness:&brightness alpha:NULL];
    
    double pitchShift = 1.0 + 0.25 * (saturation - 0.5) + 0.5 * (brightness - 0.5);
    double cutoff = pow(10 * brightness, 4) + 400;
    
    SonicBrightness sonic;
    sonic.pitchShiftFactor = pitchShift;
    sonic.filterCutoff = cutoff;
    self.sonicBrightness = sonic;
}

-(void)setSonicBrightness:(SonicBrightness)sonicBrightness {
    _sonicBrightness = sonicBrightness;
    
    [[UHMAudioController sharedAudioController] setSonicBrightness:sonicBrightness forInstrument:self useOnlyFiltering:NO];
}

@end
