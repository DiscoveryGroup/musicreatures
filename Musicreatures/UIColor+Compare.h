//
//  UIColor+Compare.h
//  Musicreatures
//
//  Created by Petri J Myllys on 29/07/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Compare)

-(BOOL)isEqualToColor:(UIColor*)color tolerance:(CGFloat)tolerance ignoreAlpha:(BOOL)ignoreAlpha;

@end
