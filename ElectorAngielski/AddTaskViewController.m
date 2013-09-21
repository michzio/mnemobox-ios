//
//  AddTaskViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 11/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "AddTaskViewController.h"
#import "Reachability.h"
#import "ProfileServices.h"

//langFrom, langTo, emailAddress, sha1Password, categoryId, taskText
#define kADD_TASK_SERVICE_URL @"http://www.mnemobox.com/webservices/addTask.php?from=%@&to=%@&email=%@&pass=%@&category_id=%@&task_text=%@"
#define kLANG_FROM @"pl"
#define kLANG_TO @"en"

@interface AddTaskViewController ()

@property (weak, nonatomic) IBOutlet UITextView *taskTextView;
@property (strong, nonatomic) Reachability *internetReachable;

@end

@implementation AddTaskViewController

- (IBAction)addTaskButtonTouched:(UIButton *)sender {
    NSLog(@"Add Task Button Touched.");
    [self saveNewTaskToServer]; 
    [self dismissModalViewControllerAnimated:YES]; 
}


- (IBAction)endEditionOnTouchControl:(UIView *)sender {
    
    [[self view] endEditing:YES]; 
}

- (IBAction)cancelButtonTouched:(UIButton *)sender {
    NSLog(@"Cancel Button Touched."); 
    [self dismissModalViewControllerAnimated:YES]; 
}

- (void) saveNewTaskToServer
{
    self.internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    if(self.internetReachable.isReachable) {
    
        NSString *emailAddress = [ProfileServices emailAddressFromUserDefaults];
        NSString *sha1Passowrd = [ProfileServices sha1PasswordFromUserDefaults];
    
        NSString *categoryId = @"2"; //we add tasks from iOS app as "Ćwiczenia językowe"
        //this category could be modified by user selecting, proper category...
        //langFrom, langTo, emailAddress, sha1Password, categoryId, taskText
        NSString *urlAsString = [NSString stringWithFormat:kADD_TASK_SERVICE_URL, kLANG_FROM, kLANG_TO, emailAddress, sha1Passowrd, categoryId, self.taskTextView.text, nil ];
        NSString *urlAsPercentEncodedString = [urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
     
        NSLog(@"Add New Task URL: %@", urlAsPercentEncodedString);
        NSURL *url = [NSURL URLWithString: urlAsPercentEncodedString];
        
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL: url];
        [urlRequest setTimeoutInterval:30.0f];
        [urlRequest setHTTPMethod:@"GET"];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        
        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:queue
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   //verifying whether solution saved correctly to the server
                                   //in such situation the result of request is solution Id > 0
                                   //else if there was some error the return value is 0
                                   if([data length] > 0 && error == nil) {
                                       NSString *stringReturnCode = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];
                                       if([stringReturnCode integerValue] > 0) {
                                           NSLog(@"New Task saved properly in server database with ID: %d", [stringReturnCode integerValue]);
                                       } else {
                                           NSLog(@"An error occured while saving New Task to server database.");
                                       }
                                   } else if([data length] == 0 && error == nil) {
                                       NSLog(@"Nothing was downloaded.");
                                   } else if(error != nil) {
                                       NSLog(@"Error happened = %@", error);
                                   }
                                   
                               }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet connection lost!" message:@"Couldn't save new task to server database." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
            [alert show];
        });
    }

    
}

- (void)viewDidUnload {
    [self setTaskTextView:nil];
    [super viewDidUnload];
}
@end
