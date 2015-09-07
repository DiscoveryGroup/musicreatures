//
//  NSMutableArray+Queue.h
//  Musicreatures
//
//  Created by Petri J Myllys on 02/10/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Queue)

-(void)enqueue:(id)obj;
-(id)dequeue;
-(id)peekHead;
-(id)peekLast;

@end
