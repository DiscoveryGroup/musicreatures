//
//  UHMNote.m
//  Musicreatures
//
//  Created by Petri J Myllys on 19/08/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMNote.h"

@implementation UHMNote

+(id)noteWithPitch:(int)pitch {
    return [[UHMNote alloc] initWithPitch:pitch];
}

-(id)init {
    return [self initWithPitch:0];
}

-(id)initWithPitch:(int)pitch {
    self = [super init];
    
    if (self) {
        self.pitch = pitch;
    }
    
    return self;
}

-(BOOL)isPulse {
    if (self.pitch != 0) return YES;
    else return NO;
}

@end
