//
//  NSManagedObjectContext+PermamentId.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 21/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "NSManagedObjectContext+PermamentId.h"

@implementation NSManagedObjectContext (PermamentId)

- (BOOL)obtainPermanentIDsForInsertedObjects:(NSError **)error
{
    NSSet * inserts = [self insertedObjects];
    
    if ([inserts count] == 0) return YES;
    
    return  [self obtainPermanentIDsForObjects:[inserts allObjects]
                                         error:error];
}

@end
