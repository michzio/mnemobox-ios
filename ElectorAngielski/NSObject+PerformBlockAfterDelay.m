//
//  NSObject+PerformBlockAfterDelay.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 04/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "NSObject+PerformBlockAfterDelay.h"

@implementation NSObject (PerformBlockAfterDelay)

- (void)performBlock:(void (^)(void))block
          afterDelay:(NSTimeInterval)delay
{
    block = [block copy];
    [self performSelector:@selector(fireBlockAfterDelay:)
               withObject:block
               afterDelay:delay];
}

- (void)fireBlockAfterDelay:(void (^)(void))block {
    block();
}

@end
