//
//  UHMAudioController.m
//  Musicalizer
//
//  Created by Petri J Myllys on 06/06/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMAudioController.h"
#import "PdBase.h"
#import "UHMAppDelegate.h"
#import "UHMPlayViewController.h"
#import "UHMHarmony.h"

static UHMAudioController *sharedAudioController = nil;
static const BOOL LOAD_SAMPLES = YES;

/// Use additional frequency modulation oscillators for richer improvisation synth sound.
/// This is computationally expensive and causes stutter and dropouts to the audio playback on Apple A5 SOC (newer models have not been tested).
static const BOOL USE_FM = NO;

@interface UHMAudioController()

void showAudioAlert();
NSString* instrumentNameForInstrument(id<UHMInstrument> instrument);

@property (strong, nonatomic) UHMAudioConverter *audioConverter;
@property (nonatomic) BOOL fmSynthesizers;
@property (nonatomic) BOOL recording;
@property (nonatomic, readwrite) int playheadPosition;

@end

@implementation UHMAudioController

+(id)sharedAudioController {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedAudioController = [[self alloc] init];
    });
    
    return sharedAudioController;
}

-(id)init {
    self = [super init];

    if (self) {
        PdAudioStatus audioStatus = [self configurePlaybackWithSampleRate:44100 numberChannels:2 inputEnabled:NO mixingEnabled:NO];
        
        if (audioStatus == PdAudioOK) {
        }
        
        else if (audioStatus == PdAudioPropertyChanged) {
            NSLog(@"Audio configured with modified playback properties.");
            NSLog(@"Applied audio settings:");
            NSLog(@"* Sample rate: %d", self.sampleRate);
            NSLog(@"* Number of channels: %d", self.numberChannels);
            NSLog(@"* Input enabled: %c", self.inputEnabled);
            NSLog(@"* Mixing enabled: %c", self.mixingEnabled);
            NSLog(@"* Ticks per buffer: %d", self.ticksPerBuffer);
            NSLog(@"* Audio active: %c", self.active);
        }
        
        else if (audioStatus == PdAudioError) {
            showAudioAlert();
        }
        
        else {
            showAudioAlert();
            NSLog(@"PdAudioStatus unrecognized. This should not happen.");
            NSLog(@"* PdAudioStatus: %dd", audioStatus);
        }
        
        self.recording = YES;
    }
    
    return self;
}

void showAudioAlert() {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                    message:@"Something unexpected happened while setting up the audio playback."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert show];
}

-(void)loadPatch {
    self.pdPatch = [PdBase openFile:@"MusicreaturesPatch.pd" path:[[NSBundle mainBundle] resourcePath]];
    
    if (self.pdPatch) {
        [PdBase setDelegate:self];
        [PdBase subscribe:@"playbackAtIndexZero"];
        [PdBase subscribe:@"pulse"];
        
        [PdBase subscribe:@"mbira-currentPulse"];
        [PdBase subscribe:@"pizz-currentPulse"];
        [PdBase subscribe:@"bar-currentPulse"];
        [PdBase subscribe:@"perc1-currentPulse"];
        [PdBase subscribe:@"perc2-currentPulse"];
        
        [self setFmSynthesizers:USE_FM];
    }
    
    else {
        showAudioAlert();
    }
}

-(void)loadSamples {
    if (LOAD_SAMPLES && self.pdPatch) {
        NSArray *samplePaths = [[NSBundle mainBundle] pathsForResourcesOfType:@"wav" inDirectory:nil];
        
        for (NSString *path in samplePaths) {
            
            NSString *sampleName = [path lastPathComponent];
            
            [PdBase sendMessage:@"read"
                  withArguments:@[@"-resize",
                                  [NSString stringWithFormat:@"%@", sampleName],
                                  [sampleName stringByDeletingPathExtension]]
                     toReceiver:@"loadSample"];
            
        }
    }
    
    else {
        NSLog(@"Samples not loaded.");
    }
}

/**
 Resets the audio.
 */
-(void)resetAudio {
    UHMPlayViewController *viewController =
    (UHMPlayViewController*)((UHMAppDelegate*)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    
    for (UHMCreature *creature in viewController.playScene.creatures) {
        [self removeInstrumentFromPlayback:creature];
    }
}

-(void)removeInstrumentFromPlayback:(id<UHMInstrument>)instrument {
    [self sendMessage:instrument.name withArguments:@[@0] toDestination:@"setPattern" formatArgumentsAsList:YES];
    [PdBase sendFloat:0 toReceiver:[NSString stringWithFormat:@"%@-steps", instrument.name]];
}

#pragma mark - Receiving from Pd

-(void)receivePrint:(NSString *)message {
    NSLog(@"%@",message);
}

-(void)receiveBangFromSource:(NSString *)source {
    if ([source isEqualToString:@"recordingStopped"]) {
        self.recording = NO;
    }
    
    else if ([source isEqualToString:@"playbackAtIndexZero"]) {
        
    }
}

-(void)receiveSymbol:(NSString *)symbol fromSource:(NSString *)source {
    
}

-(void)receiveFloat:(float)received fromSource:(NSString *)source {
    UHMPlayViewController *viewController =
    (UHMPlayViewController*)((UHMAppDelegate*)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    
    // Updating the global playhead position
    
    if ([source isEqualToString:@"pulse"]) {
        if ((int)received == 0) {
            [viewController.playScene.harmony updateHarmonyForPlayheadPosition:0];
        }
        
        self.playheadPosition = (int)received;
        return;
    };
    
    // Updating the current creature pulses
    
    NSArray *sourceComponents = [source componentsSeparatedByString:@"-"];
    BOOL validMessage = NO;
    
    if ([sourceComponents objectAtIndex:0] != nil && [sourceComponents objectAtIndex:1] != nil) {
        validMessage = YES;
    }
    
    if (validMessage) {
        NSString *name = [sourceComponents objectAtIndex:0];
        
        if ([[sourceComponents objectAtIndex:1] isEqualToString:@"currentPulse"])
            [viewController updatePulseIndex:received forCreatureName:name];
        
    }
}

#pragma mark - Global playback settings

-(void)setGlobalTempo:(double)bpm {
    float pulseSpeed = bpm * 16 / 4;
    [PdBase sendFloat:60000 / pulseSpeed toReceiver:@"tempo"];
}

-(void)setGlobalPlaybackState:(BOOL)playState {
    [PdBase sendFloat:playState toReceiver:@"play"];
}

-(void)setGlobalSteps:(int)steps {
    [PdBase sendFloat:steps toReceiver:@"steps"];
}

-(void)setGlobalSwing:(float)swing {
    [PdBase sendFloat:swing toReceiver:@"swing"];
}

#pragma mark - Pattern configuration

-(void)setPattern:(NSArray*)pattern forInstrument:(id<UHMInstrument>)instrument {
    [self sendMessage:instrument.name
        withArguments:pattern
        toDestination:@"setPattern"
formatArgumentsAsList:YES];
    
    [self setPatternLength:(int)pattern.count forInstrument:instrument];
}

-(void)setPatternLength:(int)steps forInstrument:(id<UHMInstrument>)instrument {
    NSString *instrumentName = instrumentNameForInstrument(instrument);
    [PdBase sendFloat:steps toReceiver:[NSString stringWithFormat:@"%@-steps", instrumentName]];
}

#pragma mark - Sample-based instruments

/**
 Sets sample settings corresponding a pitch for a pitched instrument. Only applicable to pitched instruments.
 @param pitchInMidi Pitch, as a MIDI note number, according to which to set the sample settings.
 @param instrument  Instrument for which to set the settings.
 */
-(void)setPitch:(int)pitchInMidi forInstrument:(id<UHMInstrument>)instrument {
    NSString *instrumentName = instrumentNameForInstrument(instrument);
    
    [self setSampleTableForNote:pitchInMidi forInstrumentNamed:instrumentName];
    [self setPitchShiftFactorForNote:pitchInMidi forInstrumentNamed:instrumentName];
}

/**
 Sets sample and filtering settings corresponding a high-level sonic brightness concept.
 @param brightness  Sonic brightness according to which to set the sample and filtering settings.
 @param instrument  Instrument for which to set the settings.
 @param filterOnly  Adjust only the filter settings and leave sample playback as is.
 */
-(void)setSonicBrightness:(SonicBrightness)brightness forInstrument:(id<UHMInstrument>)instrument useOnlyFiltering:(BOOL)filterOnly {
    [self setFilterCutoffFrequency:brightness.filterCutoff forInstrument:instrument];
    if (!filterOnly) [self setPitchShiftFactor:brightness.pitchShiftFactor forInstrumentNamed:instrumentNameForInstrument(instrument)];
}

/**
 Sets the sample player of an instrument to read a sample corresponding a given MIDI note.
 @param midiNoteNumber  MIDI note number according to which to select the sample table.
 @param instrumentName  Instrument for which to set the sample.
 */
-(void)setSampleTableForNote:(int)midiNoteNumber forInstrumentNamed:(NSString*)instrumentName {
    NSString *noteName = [NSString stringWithFormat:@"c%d", (int)floor(midiNoteNumber / 12.0 - 1)]; // Only the C-samples are used in the current version
    
    [self sendMessage:@"set"
        withArguments:@[[NSString stringWithFormat:@"%@-%@", instrumentName, noteName]]
        toDestination:[NSString stringWithFormat:@"%@-sampleTable", instrumentName] formatArgumentsAsList:NO];
}

/**
 Sets the sample table for the sample player of an instrument.
 @param instrument  Instrument for which to set the sample.
 */
-(void)setSampleForInstrument:(id<UHMInstrument>)instrument {
    NSString *instrumentName = instrumentNameForInstrument(instrument);
    
    [self sendMessage:@"set"
        withArguments:@[[NSString stringWithFormat:@"%@", instrumentName]]
        toDestination:[NSString stringWithFormat:@"%@-sampleTable", instrumentName] formatArgumentsAsList:NO];
}

/**
 Sets the sample player of an instrument to pitch shift the current sample to match a give MIDI note.
 @param midiNoteNumber  MIDI note number according to which to pitch shift the sample.
 @param instrumentName  Instrument for which to set the pitch shifting value.
 */
-(void)setPitchShiftFactorForNote:(int)midiNoteNumber forInstrumentNamed:(NSString*)instrumentName {
    double semitone = pow(2.0, 1.0/12.0), intervalShift = midiNoteNumber % 12;
    double pitchShift;
    
    if (intervalShift < 6) pitchShift = pow(semitone, intervalShift);
    else pitchShift = pow(semitone, -12.0 + intervalShift);
    
    [PdBase sendFloat:pitchShift
           toReceiver:[NSString stringWithFormat:@"%@-pitchShiftFactor", instrumentName]];
}

/**
 Sets an instrument's sample player's pitch shift factor.
 @param pitchShift      Pitch shift factor (value < 1.0 shifts down, value > 1.0 shifts up).
 @param instrumentName  Instrument for which to set the pitch shift factor.
 */
-(void)setPitchShiftFactor:(float)pitchShift forInstrumentNamed:(NSString*)instrumentName {
    [PdBase sendFloat:pitchShift
           toReceiver:[NSString stringWithFormat:@"%@-pitchShiftFactor", instrumentName]];
}

/**
 Sets an instrument's sample player's filtering cutoff frequency.
 @param cutoff          Filter cutoff frequency.
 @param instrument      Instrument for which to set the cutoff frequency.
 */
-(void)setFilterCutoffFrequency:(float)cutoff forInstrument:(id<UHMInstrument>)instrument {
    [PdBase sendFloat:cutoff
           toReceiver:[NSString stringWithFormat:@"%@-filterCutoff", instrumentNameForInstrument(instrument)]];
}

/**
 Plays a note immediately with a given instrument.
 @param instrument  Instrument with which to play the note.
 */
-(void)playNoteAsynchroniouslyWithInstrument:(id<UHMInstrument>)instrument {
    [PdBase sendBangToReceiver:[NSString stringWithFormat:@"%@-spawn", instrument.name]];
}

#pragma mark - Synthesized instruments

/**
 Plays a chord with the improvisation synthesizer.
 @param midiNotes   MIDI note numbers of the notes in the chord to be played.
 */
-(void)playSynthWithNotes:(NSArray*)midiNotes {
    [PdBase sendList:midiNotes toReceiver:@"synthNotes"];
}

-(void)setNumberOfSynthVoices:(int)voices {
    int maxVoices = 5;
    
    for (int i = 1; i <= voices; i++) {
        [PdBase sendFloat:1 toReceiver:[NSString stringWithFormat:@"useSynth-%d", i]];
    }
    
    for (int i = voices + 1; i <= maxVoices; i++) {
        [PdBase sendFloat:0 toReceiver:[NSString stringWithFormat:@"useSynth-%d", i]];
    }
}

/**
 Plays a note with the improvisatory lead synthesizer.
 @param midiNote   MIDI note number of the note to be played.
 */
-(void)playLeadWithNote:(int)midiNote {
    [PdBase sendFloat:midiNote toReceiver:@"leadNote"];
}

/**
 Sets the frequency modulator for the improvisation synthesizer.
 @param multiplier  Multiplicator for the modulator frequencies.
 */
-(void)setSynthModulationMultiplier:(float)multiplier {
    [PdBase sendFloat:multiplier toReceiver:@"synthModulatorMultiplier"];
}

-(void)setSynthGainEnvelope:(NSArray*)breakpoints {
    [PdBase sendList:breakpoints toReceiver:@"synthGainEnvelope"];
}

-(void)setSynthFilterCutoffFrequency:(float)cutoff {
    [PdBase sendFloat:cutoff toReceiver:@"synthFilterCutoff"];
}

-(void)setSynthSoftness:(float)softness {
    [PdBase sendFloat:softness toReceiver:@"synthSoftness"];
}

/**
 Sets the modulator intensity for the improvisation synthesizer.
 @param modulationIntensity Intensity for the modulator oscillator.
 */
-(void)setSynthModulationIntensity:(float)modulationIntensity {
    [PdBase sendFloat:modulationIntensity toReceiver:@"synthModulatorIntensity"];
}

-(void)playHat {
    [PdBase sendBangToReceiver:@"playHat"];
}

-(void)playSnare {
    [PdBase sendBangToReceiver:@"playSnare"];
}

-(void)playBassWithNote:(int)midiNote {
    [PdBase sendFloat:midiNote toReceiver:@"bassNote"];
}

-(void)setBassFilterEnvelope:(NSArray*)breakpoints {
    [PdBase sendList:breakpoints toReceiver:@"bassFilterEnvelope"];
}

-(void)setKickFilterCutoffFrequency:(float)cutoff {
    [PdBase sendFloat:cutoff toReceiver:@"kickFilterCutoff"];
}

#pragma mark - Setters

-(void)setImprovise:(BOOL)improvise {
    _improvise = improvise;
    if (!improvise) [self setMainGain:1.0];
    [PdBase sendFloat:improvise toReceiver:@"improvise"];
}

-(void)setMainGain:(float)gain {
    float maingain;
    if (gain < 0.0) maingain = 0.0f;
    else if (gain > 1.0) maingain = 1.0f;
    else maingain = gain;
    [PdBase sendFloat:maingain toReceiver:@"mainGain"];
}

-(void)setFmSynthesizers:(BOOL)fmSynthesizers {
    _fmSynthesizers = fmSynthesizers;
    [PdBase sendFloat:fmSynthesizers toReceiver:@"useFmSynthesizers"];
}

#pragma mark - Recording

/**
 Prepares recording of the sound ouput.
 @param bitDepth        Bit depth of the soundfile to be created.
 */
-(void)prepareRecordingWithBitDepth:(int)bitDepth {
    NSNumber *bytes;
    if (bitDepth < 24) bytes = @2;
    else if (bitDepth < 32) bytes = @3;
    else bytes = @4;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *pathToSoundFile = [documentsPath stringByAppendingString:@"/recorded.wav"];
    NSLog(@"Recording path: %@", pathToSoundFile);
    
    [PdBase sendMessage:@"open" withArguments:@[@"-bytes", bytes, pathToSoundFile] toReceiver:@"record"];
}

/**
 Start the recording of the sound output.
 */
-(void)startRecording {
    [PdBase sendMessage:@"start" withArguments:nil toReceiver:@"record"];
    self.recording = YES;
}

/**
 Stop the recording of the sound ouput.
 */
-(void)stopRecording {
    [PdBase sendMessage:@"stop" withArguments:nil toReceiver:@"record"];
}

/**
 Pause the recording of the sound output.
 */
-(void)pauseRecording {
    [PdBase sendMessage:@"pause" withArguments:nil toReceiver:@"record"];
}

/**
 Continue the paused recording of the sound output.
 */
-(void)unpauseRecording {
    [PdBase sendMessage:@"unpause" withArguments:nil toReceiver:@"record"];
}

#pragma mark - Audio conversion

-(void)convertAudioFromPath:(NSString*)sourcePath
           progressDelegate:(id<UHMAudioConversionProgressDelegate>)progressDelegate
               fileDelegate:(id<UHMAudioConversionFileDelegate>)fileDelgate
                 completion:(AudioConversionCompleted)completed
{
    self.audioConverter = [[UHMAudioConverter alloc] initWithProgressDelegate:progressDelegate fileDelegate:fileDelgate];
    [self.audioConverter convertAudioFromPath:sourcePath completion:completed];
}

-(void)cancelConversion {
    [self.audioConverter cancelConversion];
    self.audioConverter = nil;
}

-(BOOL)fadeOutFinishedSuccessfully {
    return (self.audioConverter.fadeOutStatus == AVAssetExportSessionStatusCompleted);
}

-(void)purgeTemporaryFiles {
    [self.audioConverter purgeTemporaryFiles];
}

#pragma mark - Helper functions

/**
 Formats a message for various Pure Data-specific purposes.
 */
-(void)sendMessage:(NSString*)message withArguments:(NSArray*)arguments toDestination:(NSString*)destination formatArgumentsAsList:(BOOL)format {
    NSArray *argumentsToSend;
    
    if (format) argumentsToSend = prepareArrayForSending(arguments);
    else argumentsToSend = arguments;
    
    [PdBase sendMessage:message withArguments:argumentsToSend toReceiver:destination];
}

/**
 Returns the name of an instrument as a string.
 @param     instrument  Instrument for which to get the name.
 @return    Name for the instrument.
 */
NSString* instrumentNameForInstrument(id<UHMInstrument> instrument) {
    NSString *instrumentName = [[NSString alloc] init];
    if ([instrument conformsToProtocol:@protocol(UHMInstrument)]) instrumentName = ((id<UHMInstrument>)instrument).name;
    return instrumentName;
}

/**
 Pure Data-specific array processing
 */
NSArray* prepareArrayForSending(NSArray* anArray) {
    NSMutableArray *patternToSend = [[NSMutableArray alloc] initWithArray:anArray copyItems:YES];
    [patternToSend insertObject:@0 atIndex:0];
    return patternToSend;
}

@end
