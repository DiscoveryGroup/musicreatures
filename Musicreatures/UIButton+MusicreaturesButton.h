//
//  UIButton+MusicreaturesButton.h
//  Musicreatures
//
//  Created by Petri J Myllys on 10/09/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>

static CGFloat k_buttonWidth = 100.0f;
static CGFloat k_buttonHeight = 60.0f;
static CGFloat k_buttonPaddingBottom = 30.0f;

@interface UIButton (MusicreaturesButton)

+(UIButton*)buttonWithMusicreaturesStyle;
+(void)matchSizesForButtons:(NSArray*)buttonsArray;
-(void)setTitle:(NSString*)titleText;
-(void)autosize;

@end
