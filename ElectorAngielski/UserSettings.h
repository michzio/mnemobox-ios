//
//  UserSettings.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 31/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserSettings : NSObject

+ (BOOL) prefereToUseWordsViaWebServices;
+ (BOOL) userWantsToMultiplayForgottenWords;
+ (BOOL) recordingsAreSavedOnPhone; 
+ (void) setPreferencesToUserWordsViaWebServices: (BOOL) flag;
+ (void) setUserWantsToMultiplayForgottenWords: (BOOL) flag;
+ (void) setToSaveRecordingsOnPhone: (BOOL) flag; 
@end
