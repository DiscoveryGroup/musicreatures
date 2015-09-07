//
//  UHMBackgroundCreator.h
//  Musicreatures
//
//  Created by Petri J Myllys on 05/08/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UHMBackgroundCreator : NSObject

+(UIImage*)createFilteredBackgroundImage:(UIImage*)image size:(CGSize)size;

@end
