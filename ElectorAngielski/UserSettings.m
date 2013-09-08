//
//  UserSettings.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 31/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "UserSettings.h"

@implementation UserSettings

+ (BOOL) prefereToUseWordsViaWebServices
{
    //should be implemented method to set this setting via Preferences View in app
    //now for testing purposes we return YES or NO depending on scenario
    return YES; 
}

+  (BOOL) userWantsToMultiplayForgottenWords
{
    //should be implemented method to set this setting via Preferences View in app
    //now for testing purposes we return YES or NO depending on screnario
    return YES;
}

@end
