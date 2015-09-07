//
//  UHMProgressMeter.m
//  Musicreatures
//
//  Created by Petri J Myllys on 12/10/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMProgressMeter.h"

@interface UHMProgressMeter()

@property (strong, nonatomic) UIBezierPath *path;

@end

@implementation UHMProgressMeter

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

-(void)setProgress:(float)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect {
    UIBezierPath* bg = [UIBezierPath bezierPath];
    bg.lineWidth = 20;
    
    [bg addArcWithCenter:CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0)
                    radius:self.frame.size.width / 2.0 - bg.lineWidth / 2.0
                startAngle:-0.5 * M_PI
                  endAngle:2.0 * M_PI - 0.5 * M_PI
                 clockwise:YES];
    
    [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2] setStroke];
    [bg stroke];
    
    UIBezierPath* path = [UIBezierPath bezierPath];
    path.lineWidth = 20;
    path.lineCapStyle = kCGLineCapRound;
    
    [path addArcWithCenter:CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
                          radius:self.frame.size.width / 2.0 - path.lineWidth / 2.0
                      startAngle:-0.5 * M_PI
                        endAngle:2.0 * M_PI * self.progress - 0.5 * M_PI
                       clockwise:YES];
    
    [[UIColor colorWithRed:0.3843 green:0.6902 blue:0.8275 alpha:0.8] setStroke];
    [path stroke];
}

@end
