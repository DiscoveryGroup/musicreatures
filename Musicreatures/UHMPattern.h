//
//  UHMPattern.h
//  Musicreatures
//
//  Created by Petri J Myllys on 13/08/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UHMPattern : NSObject

@property (strong, nonatomic) NSMutableArray *noteArray;
@property (nonatomic, readonly) int steps;
@property (nonatomic, readonly) int pulses;
@property (nonatomic, readonly) int rests;

+(id)patternWithArray:(NSArray*)array;
-(id)initWithArray:(NSArray*)array;

-(void)addPulse;
-(void)removePulse;

@end
