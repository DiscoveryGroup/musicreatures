//
//  UHMMenuScene.h
//  Musicreatures
//
//  Created by Petri J Myllys on 04/08/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "UHMAudioController.h"

@interface UHMMenuScene : SKScene <UHMAudioConversionProgressDelegate, UHMAudioConversionFileDelegate>

/// Background image for the menu.
@property (strong, nonatomic) SKSpriteNode *background;
@property (nonatomic, readonly) BOOL isConvertingAudio;

+(id)sceneWithSize:(CGSize)size;

@end
