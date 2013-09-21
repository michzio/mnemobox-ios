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
     NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSNumber *flagAsNumber = [prefs objectForKey:@"prefereWordsViaWebServices"];
    
    return [flagAsNumber boolValue]; 
}

+  (BOOL) userWantsToMultiplayForgottenWords
{
    //should be implemented method to set this setting via Preferences View in app
    //now for testing purposes we return YES or NO depending on screnario
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSNumber *flagAsNumber = [prefs objectForKey:@"multiplayForgottenWords"];
    
    return [flagAsNumber boolValue];
}

+ (BOOL) recordingsAreSavedOnPhone
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSNumber *flagAsNumber = [prefs objectForKey:@"saveRecordingsOnPhone"];
    
    return [flagAsNumber boolValue];
}

+ (void) setPreferencesToUserWordsViaWebServices: (BOOL) flag {
    NSLog(@"Setting Preferences to use words via web services: %d", flag);
     NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSNumber *flagAsNumber = [NSNumber numberWithBool:flag]; 
    [prefs setObject: flagAsNumber forKey:@"prefereWordsViaWebServices"];
    
}

+ (void) setUserWantsToMultiplayForgottenWords: (BOOL) flag
{
    NSLog(@"Setting that user wants to multiplay forgotten words: %d", flag);
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSNumber *flagAsNumber = [NSNumber numberWithBool:flag];
    [prefs setObject: flagAsNumber forKey:@"multiplayForgottenWords"];
}

+ (void) setToSaveRecordingsOnPhone: (BOOL) flag
{
    NSLog(@"Setting to save recordings on user phone: %d", flag);
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSNumber *flagAsNumber = [NSNumber numberWithBool:flag];
    [prefs setObject: flagAsNumber forKey:@"saveRecordingsOnPhone"];
}
@end
