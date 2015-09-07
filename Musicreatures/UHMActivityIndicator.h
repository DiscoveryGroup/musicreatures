//
//  UHMActivityIndicator.h
//  Musicreatures
//
//  Created by Petri J Myllys on 19/12/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ActivityCompletion)(void);

@interface UHMActivityIndicator : UIView

-(id)initWithTextColor:(UIColor*)color shadow:(BOOL)shadow font:(UIFont*)font text:(NSString*)text;
-(void)finishActivityIndicationWithCompletion:(ActivityCompletion)complete;

@end
