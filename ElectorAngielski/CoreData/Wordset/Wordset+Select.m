//
//  Wordset+Select.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 23/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "Wordset+Select.h"

@implementation Wordset (Select)

+ (Wordset *) selectWordsetWithWID: (NSString *) wid
managedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    Wordset *wordset = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Wordset"];
    request.predicate = [NSPredicate predicateWithFormat:@"wid = %@", wid, nil];
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"foreignName" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDesc];
    
    NSError *fetchError = nil;
    NSArray *wordsets = [managedObjectContext executeFetchRequest:request error:&fetchError];
    
    if(!wordsets || [wordsets count]> 1) {
        NSLog(@"Error while selecting wordset object for given Wordset ID");
    } else if([wordsets count] == 0) {
        NSLog(@"Wordset object for given Wordset ID hasn't been found in Core Data.");
    } else {
      //exactly one object found in Core Data
        wordset = [wordsets lastObject];
    }
    
    return wordset;
}

@end
