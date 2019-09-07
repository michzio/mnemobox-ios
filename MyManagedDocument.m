//
//  MyManagedDocument.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 21/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "MyManagedDocument.h"
#import <CoreData/CoreData.h>

@implementation MyManagedDocument

- (id)contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    NSLog(@"Auto-Saving Document");
    return [super contentsForType:typeName error:outError];
}

- (void)handleError:(NSError *)error userInteractionPermitted:(BOOL)userInteractionPermitted
{
    NSLog(@"UIManagedDocument error: %@", error.localizedDescription);
    NSArray* errors = [[error userInfo] objectForKey: NSDetailedErrorsKey];
    if(errors != nil && errors.count > 0) {
        for (NSError *error in errors) {
            NSLog(@"  Error: %@", error.userInfo);
        }
    } else {
        NSLog(@"  %@", error.userInfo);
    }
}

@end
