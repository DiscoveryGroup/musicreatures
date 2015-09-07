//
//  UHMLowPassFilter.m
//  Musicalizer
//
//  Created by Petri J Myllys on 19/06/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMLowPassFilter.h"

@implementation UHMLowPassFilter {
    double x[2], y[2];
}

-(id)init {
    self = [super init];
    
    if (self) {
        x[0] = 0;
        x[1] = 0;
        y[0] = 0;
        y[1] = 0;
    }
    
    return self;
}

-(double)filterSignal:(double)input withSmoothingFactor:(double)smoothingFactor {
    double a = smoothingFactor;
    int t = 1;
    
    x[t] = input;
    
    y[t] = y[t-1] + a * (x[t-1] - y[t-1]);
    
    x[t-1] = x[t];
    y[t-1] = y[t];
    
    return y[t];
}

@end
