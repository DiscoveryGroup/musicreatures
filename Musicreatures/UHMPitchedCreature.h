//
//  UHMPitchedCreature.h
//  Musicreatures
//
//  Created by Petri J Myllys on 01/07/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "UHMCreature.h"

@interface UHMPitchedCreature : UHMCreature

/// The pitch of the sound as a MIDI Note Number.
@property (nonatomic) int pitch;

@end
