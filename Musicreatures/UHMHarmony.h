//
//  UHMHarmony.h
//  Musicreatures
//
//  Created by Petri J Myllys on 12/08/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UHMInstrument.h"
#import "UHMChord.h"

@interface UHMHarmony : NSObject

/**
 *  The chord degree I semitone offset from C.
 *
 *  This value determines the key signature of the whole playback, i.e., transposition from C.
 *  N.b. the instrument sample ranges are optimized for the root C.
 *  Especially the lowest octave ranges of the samples are significantly inharmonic and should not be over-emphasized.
 *
 *  An example: consider that the key signature (the actual tonal center of the harmonic progressions) is Minor. Now, the Minor scale (e.g. Aeolian mode of the scale determined by the degree I) should be C Minor.
 *  The TRANSPOSITION value should now designate the offset of the relative key (Eb Major) from C, and hence the value should be 3 (and not 0).
 *  @see TONIC_SCALE
 */
@property (nonatomic) int transposition;

@property (nonatomic) Tonality tonality;

@property (nonatomic) int polyphony;

/// Current root as a MIDI note number. Value is between [60..71].
@property (nonatomic, readonly) int root;

/// Current root as an offset from the tonic (the chord degree I) in semitones. The value is always non-negative (between [0..11]).
@property (nonatomic, readonly) int relativeRoot;

/// Current scale as semitone offsets from the root of the scale. The scale property does not contain information about the root of the scale; for such information, use the root property. @see root
@property (strong, nonatomic) NSArray *scale;

/// Current intensity level of the improvisation. Affects the voicings.
@property (nonatomic) double intensity;

/**
 Updates the harmony to correspond a playhead position.
 @param step    The playhead position (step) with which to match the harmony.
 */
-(void)updateHarmonyForPlayheadPosition:(int)step;

/**
 Overrides the dynamic chord progression behavior with a fixed progression.
 @param progressionFileName File name of the chord progression with which to override the default progression behavior. Passing in nil will reset the behavior to default.
 */
-(void)overrideProgressionWithProgressionFromFileNamed:(NSString*)progressionFileName;

-(void)updateBassPitch;

@end
