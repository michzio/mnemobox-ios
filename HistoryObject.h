//
//  HistoryObject.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 18/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HistoryObject : NSObject

@property (strong, nonatomic) NSString *learningHistoryId;
@property (strong, nonatomic) NSString *wordsetTitle;
@property (strong, nonatomic) NSString *times;
@property (strong, nonatomic) NSString *effectiveness;
@property (strong, nonatomic) NSString *learningMethod;
@property (strong, nonatomic) NSString *lastAccessDate;

+ (HistoryObject *) historyObjectWithID: (NSString *) learningHistoryId
                         wordsetTitle: (NSString *) wordsetTitle
                          learningTimes: (NSString *) times
                          effectiveness: (NSString *) effectiveness
                         learningMethod: (NSString *) learningMethod
                          lastAccessDate: (NSString *) lastAccessDate;
@end
