//
//  UHMEuclidean.h
//  Musicalizer
//
//  Created by Petri J Myllys on 09/06/14.
//  "Euclidean" rhythm algorithm. Based on Bjorklund (1999) / Toussaint (2005).
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UHMEuclidean : NSObject

+(NSArray*)computePatternOfLength:(int)slots withPulses:(int)pulses;
+(NSArray*)computePatternOfLength:(int)slots withPulses:(int)pulses rotations:(int)rotations;
+(NSArray*)computePatternOfLength:(int)slots withPulses:(int)pulses forceBeginWithOnset:(BOOL)forceFirstOnset;
+(NSArray*)findBestMatchForPattern:(NSArray*)pattern;

@end
