//
//  UHMColorMap.m
//  Musicreatures
//
//  Created by Petri J Myllys on 06/08/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMColorMap.h"
#import "GPUImage.h"

@interface UHMColorMap()

@property (strong, nonatomic) NSMutableArray *map;
@property (nonatomic) int rows;
@property (nonatomic) int columns;

@property (strong, nonatomic) NSMutableArray *colors;

@end

@implementation UHMColorMap

/**
 *  Initialises a color map with image divided into rows and columns.
 *  @param  image   The image the map is based on.
 *  @param  rows    Rows for the map.
 *  @param  columns Columns for the map.
 */
-(id)initWithImage:(UIImage*)image rows:(int)rows columns:(int)columns {
    self = [super init];
    
    if (self) {
        self.colors = [[NSMutableArray alloc] init];
        
        self.rows = rows;
        self.columns = columns;
        
        for (int row = 0; row < rows; row++) {
            
            [self.colors addObject:[[NSMutableArray alloc] init]];
            
            for (int column = 0; column < columns; column++) {
                
                GPUImagePicture *source = [[GPUImagePicture alloc] initWithImage:image];
                
                // Crop image according to rows and columns
                
                GPUImageCropFilter *crop = [[GPUImageCropFilter alloc] init];
                
                crop.cropRegion = CGRectMake(column * (1.0f / columns),
                                             row * (1.0f / rows),
                                             1.0f / columns,
                                             1.0f / rows);
                
                GPUImageAverageColor *color = [[GPUImageAverageColor alloc] init];
                
                // Average colors in cropped region
                
                [color setColorAverageProcessingFinishedBlock:^(CGFloat red,
                                                                CGFloat green,
                                                                CGFloat blue,
                                                                CGFloat alpha,
                                                                CMTime frameTime)
                 {
                     [[self.colors objectAtIndex:row] insertObject:@[[NSNumber numberWithFloat:red],
                                                                  [NSNumber numberWithFloat:green],
                                                                  [NSNumber numberWithFloat:blue],
                                                                  [NSNumber numberWithFloat:alpha]] atIndex:column];
                 }];
                
                // Image processing chain
                
                [source addTarget:crop];
                [crop addTarget:color];
                [color useNextFrameForImageCapture];
                [source processImage];
            }
        }
    }
    
    return self;
}

-(NSMutableArray*)map {
    return self.colors;
}

-(id)copyWithZone:(NSZone *)zone {
    UHMColorMap *colorMapCopy = [[UHMColorMap allocWithZone:zone] init];
    colorMapCopy.colors = [self.colors copyWithZone:zone];
    colorMapCopy.rows = self.rows;
    colorMapCopy.columns = self.columns;
    
    return colorMapCopy;
}

@end
