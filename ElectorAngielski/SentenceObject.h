//
//  SentenceObject.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 27/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SentenceObject : NSObject

@property (nonatomic, retain) NSString * sentenceId;
@property (nonatomic, retain) NSString * foreign;
@property (nonatomic, retain) NSString * native;
@property (nonatomic, retain) NSString * recording;

- (id) initWithSID: (NSString *) sentenceId
   foreignSentence: (NSString *) foreign
    nativeSentence: (NSString *) native
         recording: (NSString *) recording;

@end
