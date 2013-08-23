//
//  Wordset.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 22/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Word, WordsetCategory;

@interface Wordset : NSManagedObject

@property (nonatomic, retain) NSString * foreignName;
@property (nonatomic, retain) NSString * level;
@property (nonatomic, retain) NSString * nativeName;
@property (nonatomic, retain) NSString * wid;
@property (nonatomic, retain) NSString * about;
@property (nonatomic, retain) WordsetCategory *category;
@property (nonatomic, retain) NSSet *words;
@end

@interface Wordset (CoreDataGeneratedAccessors)

- (void)addWordsObject:(Word *)value;
- (void)removeWordsObject:(Word *)value;
- (void)addWords:(NSSet *)values;
- (void)removeWords:(NSSet *)values;

@end
