//
//  UIColor+Compare.m
//  Musicreatures
//
//  Created by Petri J Myllys on 29/07/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UIColor+Compare.h"

@implementation UIColor (Compare)

-(BOOL)isEqualToColor:(UIColor*)color tolerance:(CGFloat)tolerance ignoreAlpha:(BOOL)ignoreAlpha {
    CGFloat r1, g1, b1, a1, r2, g2, b2, a2;
    [self getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [color getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    
    if (ignoreAlpha) {
        return
        
        fabs(r1 - r2) <= tolerance &&
        fabs(g1 - g2) <= tolerance &&
        fabs(b1 - b2) <= tolerance;
    }
    
    else {
        return
        
        fabs(r1 - r2) <= tolerance &&
        fabs(g1 - g2) <= tolerance &&
        fabs(b1 - b2) <= tolerance &&
        fabs(a1 - a2) <= tolerance;
    }
}

@end
