//
//  Task+Create.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 10/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "Task.h"

#define kUSER_AVATAR_SERVICE_URL @"http://mnemobox.com/uploads/avatars/%@"

@interface Task (Create)

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
inManagedObjectContext: (NSManagedObjectContext *) context;

@end
