//
//  UHMActivityIndicator.m
//  Musicreatures
//
//  Created by Petri J Myllys on 19/12/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMActivityIndicator.h"
#import "UHMShadowedLabel.h"

@interface UHMActivityIndicator()

@property (strong, nonatomic) UILabel *loadingText;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;

@end

@implementation UHMActivityIndicator

-(id)init {
    return [self initWithTextColor:[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.8f]
                            shadow:NO
                              font:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:22]
                              text:NSLocalizedString(@"Getting things ready", nil)];
}

-(id)initWithTextColor:(UIColor*)color shadow:(BOOL)shadow font:(UIFont*)font text:(NSString*)text {
    self = [super init];
    
    if (self) {
        if (shadow) self.loadingText = [[UHMShadowedLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 50.0f)];
        else self.loadingText = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 50.0f)];
        
        self.loadingText.text = text;
        self.loadingText.textAlignment = NSTextAlignmentCenter;
        self.loadingText.font = font;
        self.loadingText.textColor = color;
        
        self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.indicator.center = CGPointMake(self.loadingText.center.x, self.loadingText.center.y - 50.0f);
        self.indicator.color = color;
        [self.indicator startAnimating];
        
        [self addSubview:self.loadingText];
        [self addSubview:self.indicator];
        
        self.backgroundColor = [UIColor blackColor];

        [UIView animateWithDuration:0.8
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut | UIViewKeyframeAnimationOptionAutoreverse | UIViewKeyframeAnimationOptionRepeat
                         animations:^{
                             self.loadingText.transform = CGAffineTransformScale(self.loadingText.transform, 0.9, 0.9);
                         } completion:nil];
    }
    
    return self;
}

-(void)setCenter:(CGPoint)center {
    self.loadingText.center = CGPointMake(center.x, center.y + 25.0f);
    self.indicator.center = CGPointMake(center.x, center.y - 25.0f);
}

-(void)finishActivityIndicationWithCompletion:(ActivityCompletion)complete {
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.loadingText.transform = CGAffineTransformScale(self.loadingText.transform, 1.2, 1.2);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.3 animations:^{
                             self.alpha = 0.0;
                             self.loadingText.transform = CGAffineTransformScale(self.loadingText.transform, 0.8, 0.8);
                         } completion:^(BOOL finished) {
                             complete();
                         }];
                     }];
}

@end
