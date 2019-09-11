//
//  Solution+Create.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 11/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "Solution.h"

@interface Solution (Create)

+ (Solution *) solutionWithSID: (NSString *) solutionId
                        teaser: (NSString *) teaser
                       content: (NSString *) content
                       created: (NSDate *) creationDate
                      byAuthor: (NSString *) author
                       forTask: (Task *) task
        inManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;

@end
