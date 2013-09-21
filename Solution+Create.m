//
//  Solution+Create.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 11/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "Solution+Create.h"

@implementation Solution (Create)


+ (Solution *) solutionWithSID: (NSString *) solutionId
                        teaser: (NSString *) teaser
                       content: (NSString *) content
                       created: (NSDate *) creationDate
                      byAuthor: (NSString *) author
                       forTask: (Task *) task
        inManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    
    
    Solution *solution = nil;
    
    /* checking whether this solution is already saved in the database, if so we need only to update it, else we need to create new input in database */
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"Solution"];
    request.predicate = [NSPredicate predicateWithFormat:@"solutionId = %@", solutionId, nil];
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sortDesc];
    
    NSError *fetchError = nil;
    NSArray *solutions = [managedObjectContext executeFetchRequest:request
                                                             error:&fetchError];
    
    if(!solutions || [solutions count] > 1) {
        NSLog(@"Error while checking for existance of solution for given solutionId in Core Data."); 
    } else if([solutions count] == 0) {
        NSLog(@"Creating new Solution object in database.");
        solution = [NSEntityDescription insertNewObjectForEntityForName:@"Solution" inManagedObjectContext:managedObjectContext];
        solution.solutionId = solutionId;
        solution.teaser = teaser;
        solution.content = content;
        solution.creationDate = creationDate;
        solution.author = author;
        solution.forTask = task;
        
    } else {
        solution = [solutions lastObject];
        NSLog(@"Updating existing Solution object = %@ in database", solution.solutionId);
        solution.solutionId = solutionId;
        solution.teaser = teaser;
        solution.content = content;
        solution.creationDate = creationDate;
        solution.author = author;
        solution.forTask = task;
        
    }
    
    return solution; 
}

@end
