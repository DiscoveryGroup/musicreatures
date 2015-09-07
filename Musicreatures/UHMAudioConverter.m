//
//  UHMAudioConverter.m
//  Musicreatures
//
//  Created by Petri J Myllys on 13/11/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMAudioConverter.h"

typedef void (^AudioFadeOutCompleted)(void);

@interface UHMAudioConverter()

@property (strong, nonatomic) AVAssetReader *assetReader;
@property (strong, nonatomic) AVAssetWriter *assetWriter;
@property (strong, nonatomic) AVAssetExportSession *audioFadeOutExporter;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundAudioProcessingId;
@property (strong, nonatomic) NSString *filePath;
@property (nonatomic) Float64 conversionProgress;
@property (strong, nonatomic) NSTimer *progressTimer;

@end

@implementation UHMAudioConverter

-(id)initWithProgressDelegate:(id<UHMAudioConversionProgressDelegate>)progressDelegate fileDelegate:(id<UHMAudioConversionFileDelegate>)fileDelegate {
    self = [super init];
    
    if (self) {
        self.conversionProgressDelegate = progressDelegate;
        self.conversionFileDelegate = fileDelegate;
    }
    
    return self;
}

/**
 Converts audio from uncompressed wave format to compressed aac.
 @param sourcePath      Path to the source audio file in wave format.
 @param completed       Completion handler.
 */
-(void)convertAudioFromPath:(NSString*)sourcePath completion:(AudioConversionCompleted)completed {
    // Prepare to keep the conversion running if the app goes to background
    [self beginBackgroundAudioProcessing];
    
    self.filePath = sourcePath;
    
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                          target:self
                                                        selector:@selector(updateProgress)
                                                        userInfo:nil
                                                         repeats:YES];
    
    // Delete old destination file
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *destinationPath = [documentsPath stringByAppendingString:@"/compressed.m4a"];
    
    [self removeOldFile:destinationPath];
    
    // Reader
    
    NSURL *assetURL = [NSURL fileURLWithPath:sourcePath];
	AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    
    NSLog(@"Original duration: %f", CMTimeGetSeconds(songAsset.duration));
    
	NSError *assetError = nil;
	self.assetReader = [AVAssetReader assetReaderWithAsset:songAsset
                                                     error:&assetError];
	if (assetError) {
		NSLog (@"Error: %@", assetError);
		return;
	}
    
    AVAssetReaderOutput *assetReaderOutput = [AVAssetReaderAudioMixOutput
                                              assetReaderAudioMixOutputWithAudioTracks:songAsset.tracks
                                              audioSettings: nil];
    
    if (![self.assetReader canAddOutput:assetReaderOutput]) {
        NSLog (@"Could not add asset reader output.");
        return;
    }
    
    [self.assetReader addOutput: assetReaderOutput];
    
    
    // Writer
    
    NSURL *exportURL = [NSURL fileURLWithPath:destinationPath];
    NSError *writerError = nil;
    
    self.assetWriter = [AVAssetWriter assetWriterWithURL:exportURL
                                                fileType:AVFileTypeMPEG4
                                                   error:&writerError];
    if (writerError) {
        NSLog (@"Error: %@", writerError);
        return;
    }
    
    AudioChannelLayout channelLayout;
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    
    // Compression settings
    
    NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                                    [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                    [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
                                    [NSNumber numberWithInt:128000], AVEncoderBitRateKey,
                                    [NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)], AVChannelLayoutKey,
                                    nil];
    
    AVAssetWriterInput *assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                                              outputSettings:outputSettings];
    if ([self.assetWriter canAddInput:assetWriterInput]) {
        [self.assetWriter addInput:assetWriterInput];
    } else {
        NSLog (@"Could not add asset writer input.");
        return;
    }
    assetWriterInput.expectsMediaDataInRealTime = NO;
    
    // Write the compressed file
    
    [self.assetWriter startWriting];
    [self.assetReader startReading];
    AVAssetTrack *soundTrack = [songAsset.tracks objectAtIndex:0];
    CMTime startTime = CMTimeMake (0, soundTrack.naturalTimeScale);
    [self.assetWriter startSessionAtSourceTime: startTime];
    
    // Initiate conversion queue
    
    dispatch_queue_t mediaInputQueue =
	dispatch_queue_create("mediaInputQueue", NULL);
    [assetWriterInput requestMediaDataWhenReadyOnQueue:mediaInputQueue
                                            usingBlock: ^
     {
         while (assetWriterInput.readyForMoreMediaData) {
             CMSampleBufferRef nextBuffer = [assetReaderOutput copyNextSampleBuffer];
             
             if (nextBuffer) {
                 [assetWriterInput appendSampleBuffer:nextBuffer];
                 
                 // Update conversion progress
                 
                 CMTime presentTime = CMSampleBufferGetPresentationTimeStamp(nextBuffer);
                 self.conversionProgress = CMTimeGetSeconds(presentTime) / CMTimeGetSeconds(songAsset.duration);
             }
             
             else {
                 [assetWriterInput markAsFinished];
                 
                 NSLog(@"Compressed file duration: %f", CMTimeGetSeconds(songAsset.duration));
                 
                 [self.assetWriter finishWritingWithCompletionHandler:^{
                     self.assetWriter = nil;
                     [self endBackgroundAudioProcessing];
                     
                     self.filePath = destinationPath;
                     self.conversionProgress = 1.0f;
                     
                     // Create a fade out
                     
                     [self beginBackgroundAudioProcessing];
                     [self fadeOutAudioFileFromPath:destinationPath completion:^{
                         [self endBackgroundAudioProcessing];
                         
                         if (self.fadeOutStatus == AVAssetExportSessionStatusCompleted) {
                             NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
                             NSString *documentsPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
                             self.filePath = [documentsPath stringByAppendingString:@"/musicreatures.m4a"];
                         }
                         
                         if ([self.conversionFileDelegate respondsToSelector:@selector(setPathToAudioFile:)])
                             [self.conversionFileDelegate setPathToAudioFile:self.filePath];
                         
                         completed();
                     }];
                     
                 }];
                 
                 [self.assetReader cancelReading];
                 break;
             }
         }
     }];
}

/**
 Creates a fade out to the exported aac audio file.
 @param sourcePath  Path to the audio file to be faded out.
 @param completed   Completion handler for the fade out processing.
 */
-(void)fadeOutAudioFileFromPath:(NSString*)sourcePath completion:(AudioFadeOutCompleted)completed {
    Float64 minimumFadeDurationInSeconds = 1.5;
    Float64 maximumFadeDurationInSeconds = 4.0;
    
    AVURLAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:sourcePath]];
    
    self.audioFadeOutExporter = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetAppleM4A];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *destinationPath = [documentsPath stringByAppendingString:@"/musicreatures.m4a"];
    
    [self removeOldFile:destinationPath];
    
    self.audioFadeOutExporter.outputURL = [NSURL fileURLWithPath:destinationPath];
    self.audioFadeOutExporter.outputFileType = AVFileTypeAppleM4A;
    
    AVMutableAudioMix *exportAudioMix = [AVMutableAudioMix audioMix];
    
    AVMutableAudioMixInputParameters *exportAudioMixInputParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:asset.tracks.lastObject];
    Float64 end = CMTimeGetSeconds(asset.duration);
    Float64 fadeDuration = end * 0.025;
    if (end < minimumFadeDurationInSeconds + 0.5) fadeDuration = 0.0;
    else if (end > 240.0) fadeDuration = maximumFadeDurationInSeconds;
    else if (fadeDuration < minimumFadeDurationInSeconds) fadeDuration = minimumFadeDurationInSeconds;
    
    NSLog(@"Fade file duration: %f", end);
    
    Float64 begin = end - fadeDuration;
    
    [exportAudioMixInputParameters setVolumeRampFromStartVolume:1.0 toEndVolume:0.0 timeRange:CMTimeRangeMake(CMTimeMakeWithSeconds(begin, 1), CMTimeSubtract(CMTimeMakeWithSeconds(end, 1), CMTimeMakeWithSeconds(begin, 1)))];
    NSArray *audioMixParameters = @[exportAudioMixInputParameters];
    exportAudioMix.inputParameters = audioMixParameters;
    
    self.audioFadeOutExporter.audioMix = exportAudioMix;
    
    [self.audioFadeOutExporter exportAsynchronouslyWithCompletionHandler:completed];
}

/**
 Inform delegate that progress has been made.
 */
-(void)updateProgress {
    if ([self.conversionProgressDelegate respondsToSelector:@selector(didMakeAudioConversionProgress:)]) {
        Float64 progress = 0.85 * self.conversionProgress + 0.15 * self.audioFadeOutExporter.progress;
        if (fabs(progress - 1.0) < 0.0001) {
            [self.progressTimer invalidate];
            self.progressTimer = nil;
        }
        [self.conversionProgressDelegate didMakeAudioConversionProgress:progress];
    }
}

-(void)purgeTemporaryFiles {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *original = [documentsPath stringByAppendingString:@"/recorded.wav"];
    NSString *compressed = [documentsPath stringByAppendingString:@"/compressed.m4a"];
    NSString *faded = [documentsPath stringByAppendingString:@"/musicreatures.m4a"];
    
    [self removeOldFile:original];
    [self removeOldFile:compressed];
    [self removeOldFile:faded];
}

/**
 Removes an old file.
 @param pathToFile  Path to the file to be removed.
 */
-(void)removeOldFile:(NSString*)pathToFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:pathToFile]) {
        NSError *error = nil;
        [fileManager removeItemAtPath:pathToFile error:&error];
        if (error) {
            NSLog(@"Error deleting old compressed file: %@", error);
        }
        
        else NSLog(@"File at path %@ deleted.", pathToFile);
    } else {
        NSLog(@"File %@ does not exist.\nThere is no need to delete.", pathToFile);
    }
}

-(void)beginBackgroundAudioProcessing {
    NSLog(@"Background processing started");
    self.backgroundAudioProcessingId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"Background processing expired");
        [self endBackgroundAudioProcessing];
    }];
}

-(void)endBackgroundAudioProcessing {
    NSLog(@"Background processing ended");
    [[UIApplication sharedApplication] endBackgroundTask: self.backgroundAudioProcessingId];
    self.backgroundAudioProcessingId = UIBackgroundTaskInvalid;
}

/**
 Cancels the wave-to-aac audio conversion.
 */
-(void)cancelConversion {
    [self.assetWriter cancelWriting];
    self.assetWriter = nil;
    
    [self.assetReader cancelReading];
    self.assetReader = nil;
    
    [self.audioFadeOutExporter cancelExport];
    self.audioFadeOutExporter = nil;
    
    [self.progressTimer invalidate];
    self.progressTimer = nil;
}

/**
 Returns the conversion process status.
 */
-(AVAssetWriterStatus)conversionStatus {
    return self.assetWriter.status;
}

/**
 Returns the fade out process status.
 */
-(AVAssetExportSessionStatus)fadeOutStatus {
    return self.audioFadeOutExporter.status;
}

@end
