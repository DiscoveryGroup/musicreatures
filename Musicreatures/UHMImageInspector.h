//
//  UHMImageInspector.h
//  Musicreatures
//
//  Created by Petri J Myllys on 02/12/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MODALITY
} ImageMusicalProperties;

@interface UHMImageInspector : NSObject

+(NSDictionary*)extractMusicalPropertiesFromImage:(UIImage*)image;

@end
