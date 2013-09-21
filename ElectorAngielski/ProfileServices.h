//
//  ProfileServices.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 20/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CommonCrypto/CommonDigest.h>

#define kUSER_AVATAR_SERVICE_URL @"http://mnemobox.com/uploads/avatars/%@"

@protocol ProfileInfoUpdateDelegate;

@interface ProfileServices : NSObject

@property (weak, nonatomic) id <ProfileInfoUpdateDelegate> delegate;

+ (BOOL) verifyUserWithEmailAddress: (NSString *) emailAddress andSHA1Passowrd: (NSString *) password;
+ (NSString *)passwordToSHA1: (NSString *)password;
+ (void) storeInUserDefaultsEmail: (NSString *) emailAddress andSHA1Password: (NSString *)sha1Password;
+ (NSString *) emailAddressFromUserDefaults;
+ (NSString *) sha1PasswordFromUserDefaults;
+ (void) storeUserImageInUserDefaults: (NSString *) userImage;
+ (void) storeFirstNameInUserDefaults: (NSString *) firstName;
+ (void) storeLastNameInUserDefaults: (NSString *) lastName;
+ (void) storeUserAgeInUserDefaults: (NSString *) userAge;
+ (void) storeGaduGaduInUserDefaults: (NSString *) gaduGadu;
+ (void) storeSkypeInUserDefaults: (NSString *) skype;
+ (void) storePhoneInUserDefaults: (NSString *) phone;
+ (void) storeCityInUserDefaults: (NSString *) city;
+ (void) storeIsPaidUpAccountInUserDefaults: (NSString *) isPaidUpAccount;
+ (void) storeUserLevelInUserDefaults: (NSString *) userLevel;
+ (void) storeUserMoneyInUserDefaults: (NSString *) userMoney;
+ (void) storeLastWordsetIdInUserDefaults: (NSString *) lastWordsetId;
+ (void) storeLastWordsetLabelInUserDefaults: (NSString *) lastWordsetLabel;

+ (NSString *) userImageFromUserDefaults;
+ (NSString *) firstNameFromUserDefaults;
+ (NSString *) lastNameFromUserDefaults;
+ (NSString *) userAgeFromUserDefaults;
+ (NSString *) gaduGaduFromUserDefaults;
+ (NSString *) skypeFromUserDefaults;
+ (NSString *) phoneFromUserDefaults;
+ (NSString *) cityFromUserDefaults;
+ (NSString *) isPaidUpAccountFromUserDefaults;
+ (NSString *) userLevelFromUserDefaults;
+ (NSString *) userMoneyFromUserDefaults;
+ (NSString *) lastWordsetIdFromUserDefaults;
+ (NSString *) lastWordsetLabelFromUserDefaults;

- (void) synchronizeProfileInfoWithWebServer;

@end

@protocol ProfileInfoUpdateDelegate <NSObject>

- (void) profileInfoDidSynchronized;

@end
