//
//  UHMMidiValueConverter.h
//  Musicreatures
//
//  Created by Petri J Myllys on 18/11/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UHMMusicalTerms.h"

@interface UHMMidiValueConverter : NSObject

+(int)convertMidiNoteNumberToScaleDegree:(int)midiNoteNumber scaleRoot:(int)rootNoteNumber mode:(Mode)mode;

@end
