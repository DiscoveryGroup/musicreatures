//
//  UHMAudioConverter.h
//  Musicreatures
//
//  Created by Petri J Myllys on 13/11/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef void (^AudioConversionCompleted)(void);

@protocol UHMAudioConversionFileDelegate

@property (strong, nonatomic) NSString *pathToAudioFile;

@end

@protocol UHMAudioConversionProgressDelegate

-(void)didMakeAudioConversionProgress:(Float64)progress;
-(void)didFinishAudioConversion;

@end

@interface UHMAudioConverter : NSObject

@property (weak, nonatomic) id conversionProgressDelegate;
@property (weak, nonatomic) id conversionFileDelegate;

-(id)initWithProgressDelegate:(id<UHMAudioConversionProgressDelegate>)progressDelegate fileDelegate:(id<UHMAudioConversionFileDelegate>)fileDelegate;

-(void)convertAudioFromPath:(NSString*)sourcePath completion:(AudioConversionCompleted)completed;
-(void)cancelConversion;

-(AVAssetWriterStatus)conversionStatus;
-(AVAssetExportSessionStatus)fadeOutStatus;

-(void)purgeTemporaryFiles;

@end
