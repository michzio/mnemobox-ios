//
//  Word.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 21/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Sentence, Wordset;

@interface Word : NSManagedObject

@property (nonatomic, retain) NSString * foreign;
@property (nonatomic, retain) NSString * foreignArticle;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * native;
@property (nonatomic, retain) NSString * nativeArticle;
@property (nonatomic, retain) NSString * recording;
@property (nonatomic, retain) NSString * transcription;
@property (nonatomic, retain) NSString * wordId;
@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic, retain) NSSet *inWordsets;
@property (nonatomic, retain) NSSet *sentences;
@end

@interface Word (CoreDataGeneratedAccessors)

- (void)addInWordsetsObject:(Wordset *)value;
- (void)removeInWordsetsObject:(Wordset *)value;
- (void)addInWordsets:(NSSet *)values;
- (void)removeInWordsets:(NSSet *)values;

- (void)addSentencesObject:(Sentence *)value;
- (void)removeSentencesObject:(Sentence *)value;
- (void)addSentences:(NSSet *)values;
- (void)removeSentences:(NSSet *)values;

@end
