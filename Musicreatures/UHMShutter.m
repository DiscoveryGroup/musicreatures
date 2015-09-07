//
//  UHMShutter.m
//  Musicreatures
//
//  Created by Petri J Myllys on 15/08/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMShutter.h"

@implementation UHMShutter

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)operate:(patternUpdateCompletion)completion {
    [UIView animateWithDuration:0.2f animations:^{
        [self setBackgroundColor:[UIColor blackColor]];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2f animations:^{
            self.backgroundColor = [UIColor clearColor];
        } completion:^(BOOL finished){
            completion(YES);
        }];
    }];
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return NO;
}

@end
