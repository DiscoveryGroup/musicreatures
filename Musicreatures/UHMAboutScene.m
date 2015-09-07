//
//  UHMAboutScene.m
//  Musicreatures
//
//  Created by Petri J Myllys on 27/10/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMAboutScene.h"
#import "UIButton+MusicreaturesButton.h"
#import "UHMMainMenuScene.h"

@interface UHMAboutScene()

@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UILabel *info;
@property (strong, nonatomic) UIButton *readMoreButton;

@end

@implementation UHMAboutScene

-(id)init {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

-(void)didMoveToView:(SKView *)view {
    self.info = [[UILabel alloc] initWithFrame:CGRectMake(10.0,
                                                          50.0,
                                                          self.view.frame.size.width - 20.0,
                                                          self.view.frame.size.height - 200.0)];
    self.info.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    self.info.textColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
    self.info.alpha = 0.8;
    self.info.textAlignment = NSTextAlignmentCenter;
    self.info.numberOfLines = 0;
    
    self.info.text = NSLocalizedString(@"Discovery", nil);
    self.info.alpha = 0.0;
    
    [self.view addSubview:self.info];
    
    self.backButton = [UIButton buttonWithMusicreaturesStyle];
    self.backButton.frame = CGRectMake(CGRectGetMidX(self.view.frame) - k_buttonWidth / 2,
                                       self.view.frame.size.height,
                                       k_buttonWidth,
                                       k_buttonHeight);
    [self.backButton setTitle:NSLocalizedString(@"Back", nil)];
    [self.backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
    
    self.readMoreButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0 - 125.0,
                                                                     self.view.frame.size.height - 165.0,
                                                                     250.0,
                                                                     50.0)];
    [self.readMoreButton addTarget:self action:@selector(readMore) forControlEvents:UIControlEventTouchUpInside];
    [self.readMoreButton setTitle:NSLocalizedString(@"Website", nil) forState:UIControlStateNormal];
    self.readMoreButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    self.readMoreButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self.readMoreButton setTitleColor:[SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8] forState:UIControlStateNormal];
    [self.readMoreButton setTitleColor:[SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5] forState:UIControlStateHighlighted];
    self.readMoreButton.alpha = 0.0;
    [self.view addSubview:self.readMoreButton];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.backButton.center = CGPointMake(self.backButton.center.x, self.view.frame.size.height - k_buttonHeight);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            self.info.alpha = 1.0;
            self.readMoreButton.alpha = 1.0;
        }];
    }];
}

-(void)readMore {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"Link", nil)]];
}

-(void)back {
    [self.view presentScene:self.presenter transition:[SKTransition crossFadeWithDuration:0.5]];
    UHMMainMenuScene *menuScene = (UHMMainMenuScene*)self.presenter;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.backButton.alpha = 0.0;
        self.backButton.center = CGPointMake(self.backButton.center.x, self.view.frame.size.height);
        menuScene.aboutButton.alpha = 0.0;
        self.info.alpha = 0.0;
        self.readMoreButton.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.backButton removeFromSuperview];
        [self.info removeFromSuperview];
        [self.readMoreButton removeFromSuperview];
        [menuScene.aboutButton removeFromSuperview];
    }];
}

@end