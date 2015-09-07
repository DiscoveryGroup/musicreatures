//
//  UHMLowPassFilter.h
//  Musicalizer
//
//  Created by Petri J Myllys on 19/06/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UHMLowPassFilter : NSObject

-(double)filterSignal:(double)input withSmoothingFactor:(double)smoothingFactor;

@end
