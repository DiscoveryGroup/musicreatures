//
//  UHMColorMap.h
//  Musicreatures
//
//  Created by Petri J Myllys on 06/08/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UHMColorMap : NSObject <NSCopying>

@property (strong, nonatomic, readonly) NSMutableArray *map;
@property (nonatomic, readonly) int rows;
@property (nonatomic, readonly) int columns;

-(id)initWithImage:(UIImage*)image rows:(int)rows columns:(int)columns;

@end
