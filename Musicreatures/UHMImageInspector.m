//
//  UHMImageInspector.m
//  Musicreatures
//
//  Created by Petri J Myllys on 02/12/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMImageInspector.h"
#import "GPUImage.h"
#import "UHMChord.h"

@implementation UHMImageInspector

+(NSDictionary*)extractMusicalPropertiesFromImage:(UIImage*)image {
    GPUImagePicture *source = [[GPUImagePicture alloc] initWithImage:image];
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    
    UIColor *color = [UHMImageInspector averageColorFromImage:source];
    NSString *tonality = [UHMImageInspector evaluateTonalityFromColor:color];
    CGFloat tempo = [UHMImageInspector evaluateTempoFromColor:color];
    int transposition = [UHMImageInspector evaluateTranspositionFromColor:color];
    int polyphony = [UHMImageInspector evaluatePolyphonyFromColor:color];

//    NSLog(@"%@", tonality);
    [properties setValue:tonality forKey:@"tonality"];
    
//    NSLog(@"%f", tempo);
    [properties setValue:[NSNumber numberWithFloat:tempo] forKey:@"tempo"];
    
//    NSLog(@"%d", transposition);
    [properties setValue:[NSNumber numberWithInt:transposition] forKey:@"transposition"];
    
//    NSLog(@"%d", polyphony);
    [properties setValue:[NSNumber numberWithInt:polyphony] forKey:@"polyphony"];
    
    return properties;
}

+(NSString*)evaluateTonalityFromColor:(UIColor*)color {
    CGFloat h, s, b;
    [color getHue:&h saturation:&s brightness:&b alpha:nil];
    
//    NSLog(@"%f %f %f", h, s, b);
//    
//    if (h < 0.05) NSLog(@"red");
//    else if (h < 0.1) NSLog(@"orange");
//    else if (h < 0.2) NSLog(@"yellow");
//    else if (h < 0.42) NSLog(@"green");
//    else if (h < 0.5) NSLog(@"turquoise");
//    else if (h < 0.71) NSLog(@"blue");
//    else if (h < 0.83) NSLog(@"purple");
//    else if (h < 0.91) NSLog(@"fuchsia");
//    else NSLog(@"red");
    
    if (((h >= 0.05 && h < 0.42) || (h >= 0.83 && h < 0.91)) && (s > 0.35 && b > 0.35)) return @"major";
    else if ((h >= 0.71 && h < 0.83) || (s > 0.35 && b <= 0.35)) return @"harmonicMinor";
    else return @"naturalMinor";
}

+(CGFloat)evaluateTempoFromColor:(UIColor*)color {
    CGFloat s, b;
    CGFloat tempo = 110.0;
    [color getHue:nil saturation:&s brightness:&b alpha:nil];
    
    tempo = 110.0 + ((s+b) / 2.0 - 0.5) * 20.0;
    return tempo;
}

+(int)evaluateTranspositionFromColor:(UIColor*)color {
    CGFloat s;
    int transposition = 0;
    [color getHue:nil saturation:&s brightness:nil alpha:nil];
    
    if (s < 0.25) transposition = -1;
    else if (s > 0.8) transposition = +1;
    
    return transposition;
}

+(int)evaluatePolyphonyFromColor:(UIColor*)color {
    CGFloat r, g, b, s;
    int polyphony = 4;
    [color getRed:&r green:&g blue:&b alpha:nil];
    [color getHue:nil saturation:&s brightness:nil alpha:nil];
    
    if (((r > (2.0*g) && r > (2.0*b)) ||
        (g > (2.0*b) && g > (2.0*r)) ||
        (b > (2.0*r) && b > (2.0*g))) &&
        (s > 0.5))
    {
        polyphony = 3;
    }
    
    return polyphony;
}

+(UIColor*)averageColorFromImage:(GPUImagePicture*)image {
    GPUImageCropFilter *crop = [[GPUImageCropFilter alloc] init];
    GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
    GPUImageAverageColor *averageColor = [[GPUImageAverageColor alloc] init];
    
    __block UIColor *color;
    
    crop.cropRegion = CGRectMake(0.2f, 0.2f, 0.6f, 0.6f);
    saturation.saturation = 2.0;
    
    dispatch_group_t colorAveraging = dispatch_group_create();
    dispatch_group_enter(colorAveraging);
    
    [averageColor setColorAverageProcessingFinishedBlock:^(CGFloat red,
                                                           CGFloat green,
                                                           CGFloat blue,
                                                           CGFloat alpha,
                                                           CMTime frameTime)
     {
         color = [[UIColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
         dispatch_group_leave(colorAveraging);
     }];
    
    [image addTarget:crop];
    [crop addTarget:saturation];
    [saturation addTarget:averageColor];
    [image processImage];
    
    dispatch_group_wait(colorAveraging, DISPATCH_TIME_FOREVER);
    
    return color;
}

@end
