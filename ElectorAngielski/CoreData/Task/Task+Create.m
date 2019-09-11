//
//  Task+Create.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 10/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "Task+Create.h"

@implementation Task (Create)

+ (Task *) taskWithTID: (NSString *) taskId
              taskText: (NSString *) taskText
            categoryId: (NSString *) categoryId
          categoryName: (NSString *) categoryName
          creationDate: (NSDate *) creationDate
             creatorId: (NSString *) creatorId
      creatorFirstName: (NSString *) firstName
       creatorLastName: (NSString *) lastName
          creatorImage: (NSString *) creatorImage
         solutionCount: (NSString *) solutionCount
            isUserTask: (BOOL) isUserTask
inManagedObjectContext: (NSManagedObjectContext *) context
{
    
    Task *task = nil;
    
    /* checking whether this Task object is already saved in the database, if so we need only to update it
       else we need to create new input in database */
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Task"];
    request.predicate = [NSPredicate predicateWithFormat: @"taskId = %@", taskId, nil];
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject: sortDesc];

    NSError *fetchError = nil;
    NSArray *tasks = [context executeFetchRequest:request error:&fetchError];

    if(!tasks || [tasks count] > 1) {
        // we suppose tasks to be unique -> taskId identifier
        NSLog(@"Error while checking for existance of task for given taskId in database.");
    } else if([tasks count] == 0) {
        task = [NSEntityDescription insertNewObjectForEntityForName: @"Task"
                                             inManagedObjectContext: context];
        task.taskId = taskId;
        task.taskText = taskText;
        task.categoryId = categoryId;
        task.categoryName = categoryName;
        task.creationDate = creationDate;
        task.creatorId = creatorId;
        task.creatorFirstName = firstName;
        task.creatorLastName = lastName;
        task.solutionCount = solutionCount;
        task.isUserTask = [NSNumber numberWithBool:isUserTask];
        task.creatorImage = creatorImage;
        
    } else {
        //task must have one element
        task = [tasks lastObject];
        task.taskId = taskId;
        task.taskText = taskText;
        task.categoryId = categoryId;
        task.categoryName = categoryName;
        task.creationDate = creationDate;
        task.creatorId = creatorId;
        task.creatorFirstName = firstName;
        task.creatorLastName = lastName;
        task.solutionCount = solutionCount;
        task.isUserTask = [NSNumber numberWithBool:isUserTask];
        task.creatorImage = creatorImage;
    }

    return task;

}

@end
