//
//  TracingHistoryAndStatistics.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 30/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kLEARNING_MODE_PRESENTATION @"prezentacja"
#define kLEARNING_MODE_REPETITION @"odpytywacz"
#define kLEARNING_MODE_SPEAKING @"odpytywacz"
#define kLEARNING_MODE_CARTONS @"kartoniki"
#define kLEARNING_MODE_LISTENING @"dyktando"
#define kLEARNING_MODE_CHOOSING @"wybieracz"


@interface TracingHistoryAndStatistics : NSObject

+ (void) traceLearningHistoryForWordsetWithId: (NSString *) wordsetId learningMode: (NSString *) mode goodAnswers: (NSInteger) goodAns badAnswers: (NSInteger) badAns;

+ (void) traceWordsForgottenTwoAns: (NSArray *) forgottenTwoAns forgottenOneAns: (NSArray *) forgottenOneAns
                           goodAns: (NSArray *) goodAns;

+ (NSString *) stringWithForgottenWordIdsBasedOnForgottenTwoAns: (NSArray *) forgottenTwoAns
                                                forgottenOneAns: (NSArray *) forgottenOneAns
                                                        goodAns: (NSArray *) goodAns;

+ (void) saveForgottenWordsToWebServerUsingSerialData: (NSString *) serialData;
+ (void) saveForgottenSerialDataLocallyInUserDefaults: (NSString *) forgottenSerialData;
+ (void) synchronizeForgottenWordsSavedInUserDefaults; 

@end
