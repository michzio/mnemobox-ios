//
//  SentenceObject.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 27/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "SentenceObject.h"

@implementation SentenceObject

@synthesize sentenceId = _sentenceId;
@synthesize foreign = _foreign;
@synthesize native = _native;
@synthesize recording = _recording;

- (id) initWithSID: (NSString *) sentenceId
   foreignSentence: (NSString *) foreign
    nativeSentence: (NSString *) native
         recording: (NSString *) recording
{
 
    self = [super init];
    if(self) {
        
        self.sentenceId = sentenceId;
        self.foreign = foreign;
        self.native = native;
        self.recording = recording;
        
    }
    return self;
    
}

@end
