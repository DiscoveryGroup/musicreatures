//
//  UHMMainMenuScene.h
//  Musicreatures
//
//  Created by Petri J Myllys on 02/07/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface UHMMainMenuScene : SKScene

@property (strong, nonatomic) UIButton *aboutButton;

-(void)startTutorial;

@end
