//
//  ProfileServices.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 20/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CommonCrypto/CommonDigest.h>

@interface ProfileServices : NSObject

+ (BOOL) verifyUserWithEmailAddress: (NSString *) emailAddress andSHA1Passowrd: (NSString *) password;
+ (NSString *)passwordToSHA1: (NSString *)password;
+ (void) storeInUserDefaultsEmail: (NSString *) emailAddress andSHA1Password: (NSString *)sha1Password;
+ (NSString *) emailAddressFromUserDefaults;
+ (NSString *) sha1PasswordFromUserDefaults;

@end
