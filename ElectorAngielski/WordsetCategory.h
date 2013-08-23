//
//  WordsetCategory.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 22/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Wordset;

@interface WordsetCategory : NSManagedObject

@property (nonatomic, retain) NSString * cid;
@property (nonatomic, retain) NSString * foreignName;
@property (nonatomic, retain) NSString * nativeName;
@property (nonatomic, retain) NSSet *wordsets;
@end

@interface WordsetCategory (CoreDataGeneratedAccessors)

- (void)addWordsetsObject:(Wordset *)value;
- (void)removeWordsetsObject:(Wordset *)value;
- (void)addWordsets:(NSSet *)values;
- (void)removeWordsets:(NSSet *)values;

@end
