//
//  ElectorWebServices.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 01/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "ElectorWebServices.h"
#import "ProfileServices.h"
#import "UserSettings.h"
#import "AFHTTPRequestOperation.h"

//params: emailAddress, sha1Password, wordid
#define kSAVE_TO_REMEMBERME_SERVICE_URL @"http://www.mnemobox.com/webservices/rememberWord.php?email=%@&pass=%@&wordid=%@&from=%@&to=%@"
#define kLANG_FROM @"pl"
#define kLANG_TO @"en"
#define kAUDIO_PATH_SERVICE_URL @"http://mnemobox.com/recordings/words/%@"

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

+ (void) saveWordToRememberMeLocallyInUserDefaults: (NSString *) wordId
{
    // otherwise there is no internet connection and we stored this wordId in
    // userDefaults array
    NSLog(@"Saving current word to remember me locally in user defaults array");
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    NSMutableSet *rememberMeWordIds = [[NSMutableSet alloc]
                                       initWithArray: [userDefaults valueForKey:@"rememberMeWordIdsArray"]];
    // add object uniquely
    [rememberMeWordIds addObject: wordId];
    
    [userDefaults setObject: [rememberMeWordIds allObjects] forKey:@"rememberMeWordIdsArray"];
    
    NSLog(@"%@", [userDefaults valueForKey:@"rememberMeWordIdsArray"]);
}

+ (void) synchronizeRememberMeWordsSavedInUserDefaults
{
    NSLog(@"Synchronizing RememberMe Words In User Defaults wth Web Server.");
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    NSArray *rememberMeWordIds = [userDefaults valueForKey:@"rememberMeWordIdsArray"];
    
    [rememberMeWordIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSString *rememberMeWordId = (NSString *) obj;
        
        [self saveWordToRememberMe:rememberMeWordId]; 
        
    }];
    
    [userDefaults setObject: [[NSArray alloc] init] forKey:@"rememberMeWordIdsArray"];
    
}


+ (void) downloadAudioFileAndStoreOnDisk: (NSString *) audioPath {
    
    if([UserSettings recordingsAreSavedOnPhone]) { 
        NSLog(@"Downloading audio file and saving on disk: %@", audioPath);
        
        NSString *urlAsString = [NSString stringWithFormat:kAUDIO_PATH_SERVICE_URL, audioPath, nil]; 
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlAsString]];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *audioFolderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"audio"];
        
        // create audio directory in Documents directory if it doesn't exists 
        [[NSFileManager defaultManager] createDirectoryAtPath: audioFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        NSString *audioFilePath = [audioFolderPath stringByAppendingPathComponent:audioPath];
        
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:audioFilePath append:NO];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"Successfully downloaded file to %@", audioFilePath);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        
        [operation start];
    } else {
        NSLog(@"User doesn't select to download audio files on phone!"); 
    }
}
@end
