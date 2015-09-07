//
//  UHMBox.m
//  Musicreatures
//
//  Created by Petri J Myllys on 28/09/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "UHMBox.h"

@implementation UHMBox

-(id)init {
    self = [super init];
    
    if (self) {
        int sides = 4;
        
        for (int sideNumber = 1; sideNumber <= sides; sideNumber++) {
            SKSpriteNode *side = [[SKSpriteNode alloc] initWithImageNamed:@"box_side.png"];
            side.centerRect = CGRectMake(4.0 / 12.0, 4.0 / 12.0, 4.0 / 12.0, 4.0 / 12.0);
            
            switch (sideNumber) {
                case 1:
                    side.size = CGSizeMake(6.0, 30.0);
                    break;
                    
                case 2:
                    side.size = CGSizeMake(30.0, 6.0);
                    break;
                    
                case 3:
                    side.size = CGSizeMake(6.0, 30.0);
                    break;
                    
                case 4:
                    side.size = CGSizeMake(30.0, 6.0);
                    break;
                    
                default:
                    break;
            }
            
            
        }
        
    }
    
    return self;
}

@end
