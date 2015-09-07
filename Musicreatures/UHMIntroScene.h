//
//  UHMIntroScene.h
//  Musicreatures
//
//  Created by Petri J Myllys on 22/08/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

/**
 An introduction to Musicreatures, displayed on first app startup.
 */
@interface UHMIntroScene : SKScene

-(id)initWithSize:(CGSize)size initialPage:(int)page;

@end
