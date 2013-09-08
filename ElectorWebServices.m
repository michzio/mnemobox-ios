//
//  ElectorWebServices.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 01/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "ElectorWebServices.h"
#import "ProfileServices.h"

//params: emailAddress, sha1Password, wordid
#define kSAVE_TO_REMEMBERME_SERVICE_URL @"http://www.mnemobox.com/webservices/rememberWord.php?email=%@&pass=%@&wordid=%@&from=%@&to=%@"
#define kLANG_FROM @"pl"
#define kLANG_TO @"en"

@implementation ElectorWebServices

+ (void) saveWordToRememberMe: (NSString *) wordId
{
    NSLog(@"Saving word to remember me remotely via web services");
    
    NSString *emailAddress = [ProfileServices emailAddressFromUserDefaults];
    NSString *sha1Password = [ProfileServices sha1PasswordFromUserDefaults];
    
    NSString *urlAsString = [NSString stringWithFormat: kSAVE_TO_REMEMBERME_SERVICE_URL, emailAddress, sha1Password, wordId, kLANG_FROM, kLANG_TO, nil];
    
    NSLog(@"RememberMe URL: %@", urlAsString);
    
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL: url];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init]; 
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if([data length] > 0 && error == nil) {
                                   NSString *result = [[NSString alloc]
                                                       initWithData:data
                                                       encoding:NSUTF8StringEncoding];
                                   if([result isEqualToString:@"1"]) {
                                       NSLog(@"Successfully saved remember me word in remote web server");
                                   } else {
                                       NSLog(@"An error occured while saving remember me word to web server");
                                       
                                   }
                                   
                               } else if([data length] == 0 && error == nil) {
                                   NSLog(@"URL request return no data");
                               } else {
                                   NSLog(@"URL request end with error: %@", error); 
                               }
}];
    
}

+ (void) shareWordOnUserProfileWall: (WordObject *) word
{
    NSLog(@"Sharing Word with WID: %@, on User Profile Wall via web services", word.wordId); 
}

@end
