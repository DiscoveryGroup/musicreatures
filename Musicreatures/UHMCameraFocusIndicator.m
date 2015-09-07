//
//  UHMCameraFocusIndicator.m
//  Musicreatures
//
//  Created by Petri J Myllys on 31/07/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMCameraFocusIndicator.h"

@implementation UHMCameraFocusIndicator

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0.0;
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"adjustingFocus"]) {
        BOOL adjustingFocus = [[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1]];
        
        if (adjustingFocus) {
            [self animateIn];
        } else {
            [self animateOut];
        }
    }
}

-(void)animateIn {
    self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2, 2);
    
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                         self.alpha = 0.8;
                     } completion:NULL];
}

-(void)animateOut {
    [UIView animateWithDuration:0.6f
                          delay:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.alpha = 0.0;
                     } completion:NULL];
}

-(void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [UIColor orangeColor].CGColor);
    CGContextSetLineWidth(context, 1.0f);
    
    float horizontalCenter = self.frame.size.width / 2;
    float verticalCenter = self.frame.size.height / 2;
    float x, y;
    float lineLength = 40.0f;
    float openingLenght = 5.0f;
    
    x = horizontalCenter - openingLenght;
    y = verticalCenter - lineLength - openingLenght;
    CGContextMoveToPoint(context, x, y);
    x -= lineLength;
    CGContextAddLineToPoint(context, x, y);
    
    y += lineLength;
    CGContextAddLineToPoint(context, x, y);

    y = verticalCenter + openingLenght;
    CGContextMoveToPoint(context, x, y);
    y += lineLength;
    CGContextAddLineToPoint(context, x, y);
    
    x += lineLength;
    CGContextAddLineToPoint(context, x, y);

    x = horizontalCenter + openingLenght;
    CGContextMoveToPoint(context, x, y);
    x += lineLength;
    CGContextAddLineToPoint(context, x, y);

    y -= lineLength;
    CGContextAddLineToPoint(context, x, y);

    y = verticalCenter - openingLenght;
    CGContextMoveToPoint(context, x, y);
    y -= lineLength;
    CGContextAddLineToPoint(context, x, y);

    x -= lineLength;
    CGContextAddLineToPoint(context, x, y);
    
    CGContextStrokePath(context);
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return NO;
}

@end
