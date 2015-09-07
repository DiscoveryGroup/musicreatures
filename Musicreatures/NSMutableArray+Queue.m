//
//  NSMutableArray+Queue.m
//  Musicreatures
//
//  Created by Petri J Myllys on 02/10/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#import "NSMutableArray+Queue.h"

@implementation NSMutableArray (Queue)

-(id)dequeue {
    id headObject = [self firstObject];
    if (headObject) [self removeObjectAtIndex:0];
    return headObject;
}

-(void)enqueue:(id)anObject {
    [self addObject:anObject];
}

-(id)peekHead {
    id headObject = [self firstObject];
    return headObject;
}

-(id)peekLast {
    return [self lastObject];
}

@end
