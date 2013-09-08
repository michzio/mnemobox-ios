//
//  ProfileServices.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 20/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "ProfileServices.h"

@implementation ProfileServices

#define kLOGIN_SERVICE_URL @"http://www.mnemobox.com/webservices/loginService.php?email=%@&pass=%@"

+ (BOOL) verifyUserWithEmailAddress: (NSString *) emailAddress andSHA1Passowrd: (NSString *) sha1Password {
    
    BOOL result = NO;
    
    NSString *urlAsString = [NSString stringWithFormat: kLOGIN_SERVICE_URL, emailAddress, sha1Password];
    NSLog(@"%@", urlAsString);
    
    NSURL *url = [NSURL URLWithString: urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL: url];
    [urlRequest setTimeoutInterval: 30.0f];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSError *error = nil;
    NSURLResponse *response = nil;
    
    NSData *data = [NSURLConnection
     sendSynchronousRequest: urlRequest
     returningResponse: &response
     error:&error];
     
      
    if([data length] > 0 && error == nil) {
                        
            NSString *html = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];
            NSLog(@"%@", html);
            if([html isEqualToString:@"1"]) {
                    NSLog(@"Correct email and password");
                    result = YES;
            } else if([html isEqualToString:@"0"]){
                    NSLog(@"Password or Email is invalid, could not sign in.");
            }
                        
    } else if([data length] == 0 && error == nil) {
                NSLog(@"Nothing was downloaded"); 
                        
    } else if(error != nil)  {
                NSLog(@"Error happened = %@", error);
    }
                        
    return result;
}

/***********************************************************************************
 * This is utility class method that calculates SHA1 encrypthed version of password*
 ***********************************************************************************/
+ (NSString *)passwordToSHA1: (NSString *)password {
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    NSData *stringBytes = [password dataUsingEncoding: NSUTF8StringEncoding]; /* or some other encoding */
    if (CC_SHA1([stringBytes bytes], [stringBytes length], digest)) {
        /* SHA-1 hash has been calculated and stored in 'digest'. */
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
        
        for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        {
            [output appendFormat:@"%02x", digest[i]];
        }
        
        return output;
    }
    return nil; 
}

+ (void) storeInUserDefaultsEmail: (NSString *) emailAddress andSHA1Password: (NSString *)sha1Password {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject: emailAddress forKey: @"profileEmailAddress"];
    [prefs setObject: sha1Password forKey: @"profileSHA1Password"];
}

+ (NSString *) emailAddressFromUserDefaults
{
    NSString *emailAddress = nil;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    emailAddress = [prefs valueForKey:@"profileEmailAddress"];
    
    return emailAddress; 
}

+ (NSString *) sha1PasswordFromUserDefaults
{
    NSString *sha1Password = nil;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    sha1Password = [prefs valueForKey:@"profileSHA1Password"];

    return sha1Password;
}

@end

