//
//  UHMBox.h
//  Musicreatures
//
//  Created by Petri J Myllys on 28/09/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UHMProjectile.h"

@interface UHMBox : NSObject

@property (strong, nonatomic) NSArray *sides;
@property (strong, nonatomic) NSArray *joints;
@property (strong, nonatomic) UHMProjectile *content;

@end
