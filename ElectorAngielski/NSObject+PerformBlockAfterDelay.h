//
//  NSObject+PerformBlockAfterDelay.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 04/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PerformBlockAfterDelay)

- (void)performBlock:(void (^)(void))block
          afterDelay:(NSTimeInterval)delay;
@end
