//
//  UHMMidiNote.m
//  Musicreatures
//
//  Created by Petri J Myllys on 18/11/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMMidiNote.h"

@implementation UHMMidiNote

+(UHMMidiNote*)noteWithInt:(int)integer {
    UHMMidiNote *o = [[UHMMidiNote alloc] init];
    o.pitch = integer;
    return o;
}

-(NSComparisonResult)compare:(UHMMidiNote *)otherNumber {
    if (self.pitch % 12 == otherNumber.pitch % 12) return NSOrderedSame;
    if (self.pitch < otherNumber.pitch) return NSOrderedAscending;
    return NSOrderedDescending;
}

-(BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[UHMMidiNote class]]) return NO;
    if (self.pitch % 12 == ((UHMMidiNote*)object).pitch % 12) return YES;
    return NO;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"%d", self.pitch];
}

@end
