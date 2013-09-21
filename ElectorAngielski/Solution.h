//
//  Solution.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 12/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Task;

@interface Solution : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * solutionId;
@property (nonatomic, retain) NSString * teaser;
@property (nonatomic, retain) Task *forTask;

@end
