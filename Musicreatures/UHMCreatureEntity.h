//
//  UHMCreatureEntity.h
//  Musicreatures
//
//  Created by Petri J Myllys on 01/08/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UHMCreature;

@protocol UHMCreatureEntity <NSObject>

@required

@property (weak, nonatomic) UHMCreature* entity;

@end
