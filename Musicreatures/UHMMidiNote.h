//
//  UHMMidiNote.h
//  Musicreatures
//
//  Created by Petri J Myllys on 18/11/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UHMMidiNote : NSObject

@property (nonatomic) int pitch;

+(UHMMidiNote*)noteWithInt:(int)integer;

@end
