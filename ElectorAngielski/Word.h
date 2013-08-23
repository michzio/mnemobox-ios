//
//  Word.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 22/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Wordset;

@interface Word : NSManagedObject

@property (nonatomic, retain) NSString * foreign;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * native;
@property (nonatomic, retain) NSString * recording;
@property (nonatomic, retain) NSString * transcription;
@property (nonatomic, retain) NSString * wordId;
@property (nonatomic, retain) NSSet *inWordsets;
@end

@interface Word (CoreDataGeneratedAccessors)

- (void)addInWordsetsObject:(Wordset *)value;
- (void)removeInWordsetsObject:(Wordset *)value;
- (void)addInWordsets:(NSSet *)values;
- (void)removeInWordsets:(NSSet *)values;

@end
