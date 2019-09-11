//
//  HistoryObject.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 18/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "HistoryObject.h"

@implementation HistoryObject

@synthesize wordsetTitle = _wordsetTitle;
@synthesize times = _times;
@synthesize effectiveness = _effectiveness;
@synthesize learningMethod = _learningMethod;
@synthesize lastAccessDate = _lastAccessDate;


+ (HistoryObject *) historyObjectWithID: (NSString *) learningHistoryId
                           wordsetTitle: (NSString *) wordsetTitle
                          learningTimes: (NSString *) times
                          effectiveness: (NSString *) effectiveness
                         learningMethod: (NSString *) learningMethod
                          lastAccessDate: (NSString *) lastAccessDate
{
    HistoryObject *result = nil;
    
    result = [[HistoryObject alloc] init];
    if(result) {
        result.learningHistoryId = learningHistoryId;
        result.wordsetTitle = wordsetTitle;
        result.times = times;
        result.effectiveness = effectiveness;
        result.learningMethod = learningMethod;
        result.lastAccessDate = lastAccessDate; 
    }
    
    return result; 
}

@end
