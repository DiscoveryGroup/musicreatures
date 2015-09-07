//
//  UHMShadowedLabel.m
//  Musicreatures
//
//  Created by Petri J Myllys on 20/12/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMShadowedLabel.h"

@implementation UHMShadowedLabel

-(id)init {
    return [self initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    CGSize shadowOffset = CGSizeMake(0, -1);
    CGFloat colorValues[] = {0.0f, 0.0f, 0.0f, 0.4f};

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef color = CGColorCreate(colorSpace, colorValues);
    CGContextSetShadowWithColor(context, shadowOffset, 5.0f, color);
    
    [super drawTextInRect:rect];
    
    CGColorRelease(color);
    CGColorSpaceRelease(colorSpace);
    
    CGContextRestoreGState(context);
}

@end
