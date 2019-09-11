//
//  AddSolutionViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 11/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "AddSolutionViewController.h"
#import "ProfileServices.h"
#import "Reachability.h"

//params: fromLang, toLang, emailAddress, sha1Password, taskId, solutionText
#define kADD_SOLUTION_SERVICE_URL @"http://www.mnemobox.com/webservices/addTaskSolution.php?from=%@&to=%@&email=%@&pass=%@&task_id=%@&solution_text=%@"
#define kLANG_FROM @"pl"
#define kLANG_TO @"en"

@interface AddSolutionViewController ()

@property (weak, nonatomic) IBOutlet UITextView *solutionTextView;
@property (strong, nonatomic) Reachability *internetReachable;

@end

@implementation AddSolutionViewController

@synthesize task = _task;

- (void) setTask:(Task *)task
{
    if(_task != task) {
        _task = task; 
    }
}

- (IBAction)addSolutionButtonTouched:(UIButton *)sender {
    NSLog(@"Add Solution Button Touched.");
    [self saveSolutionToServer];
    [self dismissModalViewControllerAnimated:YES]; 
    
}

- (IBAction)cancelButtonTouched:(UIButton *)sender {
    NSLog(@"Cancel Button Touched.");
    [self dismissModalViewControllerAnimated:YES]; 
}

- (void) saveSolutionToServer
{
    self.internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    if(self.internetReachable.isReachable && self.task.taskId) {
        NSString *emailAddress = [ProfileServices emailAddressFromUserDefaults];
        NSString *sha1Password = [ProfileServices sha1PasswordFromUserDefaults];
        
        //params: fromLang, toLang, emailAddress, sha1Password, taskId, solutionText
        NSString *urlAsString = [NSString stringWithFormat:kADD_SOLUTION_SERVICE_URL, kLANG_FROM,
                                 kLANG_TO, emailAddress, sha1Password, self.task.taskId, self.solutionTextView.text, nil];
        NSString *urlAsPercentEncodedString = [urlAsString
                                               stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"Add Solution URL: %@", urlAsPercentEncodedString);
        NSURL *url = [NSURL URLWithString: urlAsPercentEncodedString];
        
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
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
                                            NSLog(@"Solution saved properly in server database with ID: %d", [stringReturnCode integerValue]);
                                        } else {
                                            NSLog(@"An error occured while saving Solution to server database.");
                                        }
                                    } else if([data length] == 0 && error == nil) {
                                        NSLog(@"Nothing was downloaded.");
                                    } else if(error != nil) {
                                        NSLog(@"Error happened = %@", error);
                                    }
                                    
                                }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet connection lost!" message:@"Couldn't save solution to server database." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
            [alert show]; 
        });
    }
}

- (IBAction)endEditionOnTouchControl:(UIControl *)sender {
    [[self view] endEditing:YES]; 
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.solutionTextView.delegate = self;
}
- (void)viewDidUnload {
    [self setSolutionTextView:nil];
    [super viewDidUnload];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return ((toInterfaceOrientation == UIInterfaceOrientationPortrait) || (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight));
    } else {
        
        return ((toInterfaceOrientation == UIInterfaceOrientationPortrait) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight));
        
    }
}
@end
