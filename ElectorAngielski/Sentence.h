//
//  Sentence.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 12/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Word;

@interface Sentence : NSManagedObject

@property (nonatomic, retain) NSString * foreign;
@property (nonatomic, retain) NSString * native;
@property (nonatomic, retain) NSString * recording;
@property (nonatomic, retain) NSString * sentenceId;
@property (nonatomic, retain) Word *forWord;

@end
