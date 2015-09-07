//
//  UHMRhythm.h
//  Musicreatures
//
//  Created by Petri J Myllys on 25/09/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UHMInstrument.h"

@interface UHMRhythm : NSObject <UHMInstrument>

/// Current total pulses per loop.
@property (nonatomic, readonly) int totalPulses;

-(void)storeNumberOfPulses:(int)pulses forInstrument:(id<UHMInstrument>)instrument;

@end
