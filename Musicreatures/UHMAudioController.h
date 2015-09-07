//
//  UHMAudioController.h
//  Musicalizer
//
//  Created by Petri J Myllys on 06/06/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "PdAudioController.h"
#import "PdDispatcher.h"
#import "UHMAudioConverter.h"
#import "UHMPercussiveCreature.h"

@class UHMAppDelegate;

/**
 This API abstracts the underlying audio framework only partially. 
 Some refactoring and re-designing should take place.
 */
@interface UHMAudioController : PdAudioController <PdReceiverDelegate>

@property (nonatomic) void *pdPatch;
@property (nonatomic, readonly) int playheadPosition;
@property (nonatomic) BOOL improvise;

+(id)sharedAudioController;

#pragma mark - Initialization and global settings

/**
 Loads the main Pure Data patch containing also all the subpatches. 
 This method should not be used before the audio controller is properly initialized.
 */
-(void)loadPatch;

/**
 Loads the sample audio files for sample-based instruments.
 This method should not be used before the Pure Data patch has been loaded.
 */
-(void)loadSamples;

/**
 Sets the global tempo.
 @param bpm Tempo as beats per minute.
 */
-(void)setGlobalTempo:(double)bpm;

/**
 Sets the length of the main loop.
 Main loop steps affects the improvisation mode instruments, but the initial instruments' individual patterns override the main loop.
 @param steps   Number of steps for the main loop.
 */
-(void)setGlobalSteps:(int)steps;

/**
 Sets the global playback status. The global playback state is the main play-button for the audio.
 @param playState   Playback state. If YES, playback will be turned on, if NO, playback will be turned off.
 */
-(void)setGlobalPlaybackState:(BOOL)playState;

-(void)setGlobalSwing:(float)swing;

#pragma mark - Instrument settings

-(void)resetAudio;
/**
 Nullifies the pattern of an instrument thus resulting in the removal of that instrument from the playback.
 @param instrument  Instrument that is to be removed from the playback.
 */
-(void)removeInstrumentFromPlayback:(id<UHMInstrument>)instrument;
-(void)setPattern:(NSArray*)pattern forInstrument:(id<UHMInstrument>)instrument;
-(void)setPatternLength:(int)steps forInstrument:(id<UHMInstrument>)instrument;
-(void)playNoteAsynchroniouslyWithInstrument:(id<UHMInstrument>)instrument;

-(void)setSampleForInstrument:(id<UHMInstrument>)instrument;
-(void)setPitch:(int)pitchInMidi forInstrument:(id<UHMInstrument>)instrument;
-(void)setSonicBrightness:(SonicBrightness)brightness forInstrument:(id<UHMInstrument>)instrument useOnlyFiltering:(BOOL)filterOnly;

-(void)playSynthWithNotes:(NSArray*)midiNotes;
-(void)setSynthModulationMultiplier:(float)multiplier;
-(void)setSynthModulationIntensity:(float)modulationIntensity;
-(void)setSynthGainEnvelope:(NSArray*)breakpoints;
-(void)setSynthFilterCutoffFrequency:(float)cutoff;
-(void)setSynthSoftness:(float)softness;
-(void)setNumberOfSynthVoices:(int)voices;

-(void)playLeadWithNote:(int)midiNote;
-(void)setLeadGainMultiplier:(float)gain;
-(void)setLeadFilterCutoffFrequency:(float)frequency;

-(void)playSnare;
-(void)playHat;
-(void)setKickFilterCutoffFrequency:(float)cutoff;

-(void)playBassWithNote:(int)midiNote;
-(void)setBassFilterEnvelope:(NSArray*)breakpoints;

-(void)setMainGain:(float)gain;

#pragma mark - Recording

-(void)prepareRecordingWithBitDepth:(int)bitDepth;
-(void)startRecording;
-(void)stopRecording;
-(void)pauseRecording;
-(void)unpauseRecording;

#pragma mark - Audio conversion

-(void)convertAudioFromPath:(NSString*)sourcePath
           progressDelegate:(id<UHMAudioConversionProgressDelegate>)progressDelegate
               fileDelegate:(id<UHMAudioConversionFileDelegate>)fileDelgate
                 completion:(AudioConversionCompleted)completed;
-(void)cancelConversion;
-(BOOL)fadeOutFinishedSuccessfully;
-(void)purgeTemporaryFiles;

@end
