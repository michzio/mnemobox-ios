//
//  TracingHistoryAndStatistics.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 30/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "TracingHistoryAndStatistics.h"
#import "ProfileServices.h"

//params: emailAddress, sha1Password, goodAnsCounter, basAnsCounter, mode, wordsetId, fromLang, toLang
#define kTRACE_LEARNING_HISTORY_SERVICE_URL @"http://www.mnemobox.com/webservices/traceHistory.php?email=%@&pass=%@&good=%@&bad=%@&mode=%@&wordset_id=%@&from=%@&to=%@"
#define kLANG_FROM @"pl"
#define kLANG_TO @"en"
//params: emailAddress, sha1Password, fromLang, toLang, serialData (format: 3,0;4,2;5,1; (wid,weight; wid, weight;))
#define kTRACE_FORGOTTEN_WORDS_SERVICE_URL @"http://www.mnemobox.com/webservices/forgottenWords.php?email=%@&pass=%@&from=%@&to=%@&serialData=%@"


@implementation TracingHistoryAndStatistics

+ (void) traceLearningHistoryForWordsetWithId: (NSString *) wordsetId
                                 learningMode: (NSString *) mode
                                  goodAnswers: (NSInteger) goodAns
                                   badAnswers: (NSInteger) badAns
{
    NSString *emailAddress = [ProfileServices emailAddressFromUserDefaults];
    NSString *sha1Password = [ProfileServices sha1PasswordFromUserDefaults];
    NSString *strGoodAns = [NSString stringWithFormat:@"%d", goodAns, nil];
    NSString *strBadAns = [NSString stringWithFormat:@"%d", badAns, nil]; 
   
    
    NSString *urlAsString = [NSString stringWithFormat: kTRACE_LEARNING_HISTORY_SERVICE_URL, emailAddress, sha1Password,
                             strGoodAns, strBadAns, mode, wordsetId, kLANG_FROM, kLANG_TO, nil];
    
    
    NSLog(@"Tracing Learning History URL: %@", urlAsString);
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod: @"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest: urlRequest
                                        queue: queue
                            completionHandler:^(NSURLResponse *response,
                                                NSData *data,
                                                NSError *error) {
                                
            //request should return 1 if successfully saved learning history on the server
                                if([data length] > 0 && error == nil) {
                                    NSString *strResponse = [[NSString alloc] initWithData:data
                                                                                  encoding:NSUTF8StringEncoding];
                                    if( [strResponse isEqualToString:@"1"]) {
                                        NSLog(@"Successfully saved learning history on the web server.");
                                    } else {
                                        NSLog(@"An error occured while saving learning history on the server"); 
                                    }
                                } else if([data length] == 0 && error == nil) {
                                    NSLog(@"Nothing was downloaded");
                                } else if(error != nil) {
                                    NSLog(@"Error happened = %@", error);
                                }
      }];

}

/******************************************************************************
 * This mathod is saving traced forgotten words to server database. It takes  *
 * into 3 arguments of type NSArray i.e. forgottenTwoAns - array of very      *
 * forgotten words which have weight 2, forgottenOneAns - array of medium     *
 * forgotten words which have weight 1, goodAns - remembered words we put them*
 * into web server database with weight 0                                     *
 ******************************************************************************/
+ (void) traceWordsForgottenTwoAns: (NSArray *) forgottenTwoAns
                   forgottenOneAns: (NSArray *) forgottenOneAns
                           goodAns: (NSArray *) goodAns
{
    NSString *serialData = [[NSString alloc] init];
    
    for(NSString *wid in goodAns) {
        serialData =[serialData stringByAppendingFormat:@"%@,0;", wid, nil];
    }
    for(NSString *wid in forgottenOneAns) {
        serialData = [serialData stringByAppendingFormat:@"%@,1;", wid, nil];
    }
    for(NSString *wid in forgottenTwoAns) {
        serialData = [serialData stringByAppendingFormat:@"%@,2;", wid, nil];
    }
    
    NSString *emailAddress = [ProfileServices emailAddressFromUserDefaults];
    NSString *sha1Password = [ProfileServices sha1PasswordFromUserDefaults]; 
    
    NSString *urlAsString = [NSString stringWithFormat:kTRACE_FORGOTTEN_WORDS_SERVICE_URL,
                             emailAddress, sha1Password, kLANG_FROM, kLANG_TO, serialData, nil];
    NSString *urlAsPercentEncodedString = [urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Tracing Forgotten Words URL: %@", urlAsPercentEncodedString);
    NSURL *url = [NSURL URLWithString:urlAsPercentEncodedString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init]; 
    
    [NSURLConnection sendAsynchronousRequest: urlRequest
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
            //request should return 1 if successfully saved forgotten on the server
                            if([data length] > 0 && error == nil) {
                                   NSString *strResponse = [[NSString alloc] initWithData:data
                                                                                 encoding:NSUTF8StringEncoding];
                                   if( [strResponse isEqualToString:@"1"]) {
                                       NSLog(@"Successfully saved forgotten words on the web server.");
                                   } else {
                                       NSLog(@"An error occured while saving forgotten words on the server");
                                   }
                               } else if([data length] == 0 && error == nil) {
                                   NSLog(@"Nothing was downloaded");
                               } else if(error != nil) {
                                   NSLog(@"Error happened = %@", error);
                               }
                   
    }];
    
    
}

@end
