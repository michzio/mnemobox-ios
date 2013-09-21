//
//  Task.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 12/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Solution;

@interface Task : NSManagedObject

@property (nonatomic, retain) NSString * categoryId;
@property (nonatomic, retain) NSString * categoryName;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * creatorFirstName;
@property (nonatomic, retain) NSString * creatorId;
@property (nonatomic, retain) NSString * creatorImage;
@property (nonatomic, retain) NSString * creatorLastName;
@property (nonatomic, retain) NSNumber * isUserTask;
@property (nonatomic, retain) NSString * solutionCount;
@property (nonatomic, retain) NSString * taskId;
@property (nonatomic, retain) NSString * taskText;
@property (nonatomic, retain) NSSet *solutions;
@end

@interface Task (CoreDataGeneratedAccessors)

- (void)addSolutionsObject:(Solution *)value;
- (void)removeSolutionsObject:(Solution *)value;
- (void)addSolutions:(NSSet *)values;
- (void)removeSolutions:(NSSet *)values;

@end
