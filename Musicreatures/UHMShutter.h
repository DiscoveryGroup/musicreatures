//
//  UHMShutter.h
//  Musicreatures
//
//  Created by Petri J Myllys on 15/08/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^patternUpdateCompletion)(BOOL);

@interface UHMShutter : UIView

-(void)operate:(patternUpdateCompletion)completion;

@end
