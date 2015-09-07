//
//  UIButton+MusicreaturesButton.m
//  Musicreatures
//
//  Created by Petri J Myllys on 10/09/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UIButton+MusicreaturesButton.h"

@implementation UIButton (MusicreaturesButton)

+(UIButton*)buttonWithMusicreaturesStyle {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:26];
    [button setTitleColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.55f] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.15f] forState:UIControlStateHighlighted];
    [button setBackgroundColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.2f]];
    button.layer.cornerRadius = 25;
    button.clipsToBounds = YES;
    
    return button;
}

+(void)matchSizesForButtons:(NSArray*)buttonsArray {
    CGFloat width = k_buttonWidth;
    
    for (UIButton *button in buttonsArray)
        width = fmaxf(width, button.frame.size.width);
    
    for (UIButton *button in buttonsArray)
        button.frame = CGRectMake(button.frame.origin.x - (width - button.frame.size.width) / 2.0f,
                                  button.frame.origin.y,
                                  width,
                                  button.frame.size.height);
}

-(void)setTitle:(NSString*)titleText {
    [self setTitle:titleText forState:UIControlStateNormal];
    [self autosize];
}

-(void)autosize {
    CGSize size = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName : self.titleLabel.font}];
    CGFloat width = size.width + 20.0f;
    if (width <= self.frame.size.width) return;
    self.frame = CGRectMake(self.frame.origin.x - (width - self.frame.size.width) / 2.0f,
                            self.frame.origin.y,
                            width,
                            self.frame.size.height);
}

@end
