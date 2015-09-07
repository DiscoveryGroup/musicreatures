//
//  UHMNote.h
//  Musicreatures
//
//  Created by Petri J Myllys on 19/08/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UHMNote : NSObject

@property (nonatomic) int pitch;
@property (nonatomic, readonly) BOOL isPulse;

+(id)noteWithPitch:(int)pitch;
-(id)initWithPitch:(int)pitch;

@end
