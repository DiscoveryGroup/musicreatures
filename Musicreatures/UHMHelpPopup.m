//
//  UHMHelpPopup.m
//  Musicreatures
//
//  Created by Petri J Myllys on 01/12/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMHelpPopup.h"
#import "UIButton+MusicreaturesButton.h"

#define HORIZONTAL_PADDING 10.0
#define VERTICAL_PADDING 10.0

@interface UHMHelpPopup()

@property (strong, nonatomic, readwrite) UHMShadowedLabel *info;
@property (nonatomic) CGRect hiddenFrame;
@property (nonatomic) CGRect visibleFrame;
@property (strong, nonatomic) UIButton *okButton;
@property (nonatomic) BOOL isHidden;

@end

@implementation UHMHelpPopup

-(id)initWithFrame:(CGRect)frame containerFrame:(CGRect)container helpText:(NSString *)text helpIdentifier:(HelpIdentifier)identifier {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.allowToBeDismissed = NO;
        self.identifier = identifier;
        
        self.info = [[UHMShadowedLabel alloc] initWithFrame:CGRectMake(HORIZONTAL_PADDING,
                                                              VERTICAL_PADDING + self.verticalOffset,
                                                              self.frame.size.width - 2 * HORIZONTAL_PADDING,
                                                              self.frame.size.height)];
        self.info.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:18];
        self.info.textColor = [UIColor colorWithWhite:1.0 alpha:0.75];
        self.info.textAlignment = NSTextAlignmentCenter;
        self.info.numberOfLines = 0;
        self.info.text = text;
        self.info.alpha = 1.0;
        
        [self.info sizeToFit];
        
        self.info.frame = CGRectMake(self.info.frame.origin.x,
                                     self.info.frame.origin.y,
                                     self.frame.size.width - 2 * HORIZONTAL_PADDING,
                                     self.info.frame.size.height);
        
        self.frame = CGRectMake(0.0f,
                                -self.info.frame.size.height - 2 * VERTICAL_PADDING,
                                self.frame.size.width,
                                self.info.frame.size.height + 2 * VERTICAL_PADDING);
        
        self.hiddenFrame = self.frame;
        
        [self addSubview:self.info];
        
        self.visibleFrame = CGRectMake(0.0f,
                                       0.0f + self.verticalOffset,
                                       self.frame.size.width,
                                       self.info.frame.size.height + 2 * VERTICAL_PADDING);
        
        self.buttonTitle = NSLocalizedString(@"Got it!", nil);
        self.buttonWidth = k_buttonWidth;
        self.isHidden = YES;
    }
    
    return self;
}

-(void)setHidden:(BOOL)hidden {
    _hidden = hidden;

    if (self.useFade) {
        if (!hidden) {
            self.alpha = 0.0f;
            self.frame = self.visibleFrame;
        }
        
        CGFloat time = hidden ? 0.3 : 1.0;
        
        [UIView animateWithDuration:time
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             self.frame = self.visibleFrame;
                             self.alpha = hidden ? 0.0f : 1.0f;
                         } completion:^(BOOL finished) {
                             self.isHidden = hidden;
                         }];
        
    }
    
    else {
        CGRect newFrame = hidden ? self.hiddenFrame : self.visibleFrame;
        
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.frame = newFrame;
                         } completion:^(BOOL finished) {
                             self.isHidden = hidden;
                         }];
    }
}

-(void)setButtonTitle:(NSString *)buttonTitle {
    _buttonTitle = buttonTitle;
    [self.okButton setTitle:buttonTitle forState:UIControlStateNormal];
}

-(void)setButtonWidth:(CGFloat)buttonWidth {
    _buttonWidth = buttonWidth;
    self.okButton.frame = CGRectMake(self.okButton.frame.origin.x - (self.buttonWidth-self.okButton.frame.size.width) / 2.0,
                                     self.okButton.frame.origin.y,
                                     self.buttonWidth,
                                     self.okButton.frame.size.height);
}

-(void)setUseFade:(BOOL)useFade {
    _useFade = useFade;
    if (self.hidden) self.alpha = 0.0;
    else self.alpha = 1.0;
}

-(void)hide {
    self.hidden = YES;
}

-(void)setAllowToBeDismissed:(BOOL)allowToBeDismissed {
    if (_allowToBeDismissed == allowToBeDismissed) return;
    _allowToBeDismissed = allowToBeDismissed;
    
    if (allowToBeDismissed) {
        CGRect newFrame = CGRectMake(0.0f,
                                     0.0f,
                                     self.frame.size.width,
                                     self.frame.size.height + k_buttonHeight + k_buttonPaddingBottom);
        
        self.hiddenFrame = CGRectMake(0.0f,
                                      -self.hiddenFrame.size.height - k_buttonHeight - k_buttonPaddingBottom,
                                      self.hiddenFrame.size.width,
                                      self.hiddenFrame.size.height + k_buttonHeight + k_buttonPaddingBottom);
        
        self.okButton = [UIButton buttonWithMusicreaturesStyle];
        self.okButton.frame = CGRectMake(newFrame.size.width / 2.0 -  self.buttonWidth / 2.0,
                                         self.info.frame.origin.y + self.info.frame.size.height + 10.0,
                                         self.buttonWidth,
                                         k_buttonHeight);
        [self.okButton setTitle:self.buttonTitle forState:UIControlStateNormal];
        [self.okButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        self.okButton.alpha = 0.0;
        [self addSubview:self.okButton];
        [self.okButton autosize];
        
        if (self.hidden) {
            self.frame = self.hiddenFrame;
            self.okButton.alpha = 1.0;
        }
        
        else {
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.frame = newFrame;
                                 self.okButton.alpha = 1.0;
                             } completion:nil];
        }
    }
    
    else {
        [self.okButton removeFromSuperview];
        self.okButton = nil;
        
        CGRect newFrame = CGRectMake(0.0f,
                                     0.0f,
                                     self.frame.size.width,
                                     self.frame.size.height - k_buttonHeight - k_buttonPaddingBottom);
        
        self.hiddenFrame = CGRectMake(0.0f,
                                      -self.hiddenFrame.size.height + k_buttonHeight + k_buttonPaddingBottom,
                                      self.hiddenFrame.size.width,
                                      self.hiddenFrame.size.height - k_buttonHeight - k_buttonPaddingBottom);
        
        if (self.hidden)
            self.frame = self.hiddenFrame;
        else
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.frame = newFrame;
                             } completion:nil];
    }
}

-(void)replaceTextWithString:(NSString *)text {
    self.info.text = text;
    [self updateFrames];
}

-(void)updateFrames {
    [self.info sizeToFit];
    CGFloat buttonPadding = self.allowToBeDismissed ? k_buttonHeight + k_buttonPaddingBottom : 0.0f;
    
    self.info.frame = CGRectMake(self.info.frame.origin.x,
                                 self.info.frame.origin.y,
                                 self.frame.size.width - 2 * HORIZONTAL_PADDING,
                                 self.info.frame.size.height);
    
    self.hiddenFrame = CGRectMake(0.0f,
                                  -self.info.frame.size.height - 2 * VERTICAL_PADDING - buttonPadding,
                                  self.frame.size.width,
                                  self.info.frame.size.height + 2 * VERTICAL_PADDING + buttonPadding);
    
    self.visibleFrame = CGRectMake(0.0f,
                                   0.0f + self.verticalOffset,
                                   self.frame.size.width,
                                   self.info.frame.size.height + 2 * VERTICAL_PADDING + buttonPadding);
    
    self.okButton.frame = CGRectMake(self.okButton.frame.origin.x,
                                     self.info.frame.origin.y + self.info.frame.size.height + VERTICAL_PADDING,
                                     self.okButton.frame.size.width,
                                     self.okButton.frame.size.height);
}

-(void)remove {
    [self setUserInteractionEnabled:NO];
    if ([self isHidden]) [self removeFromSuperview];
    
    else {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.frame = self.hiddenFrame;
                         } completion:^(BOOL finished) {
                             [self removeFromSuperview];
                         }];
    }
}

@end
