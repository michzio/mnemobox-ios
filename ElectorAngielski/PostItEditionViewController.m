//
//  PostItEditionViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 27/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "PostItEditionViewController.h"
#import "Reachability.h"
#import "ProfileServices.h"
#import "XMLParser.h"
#import "XMLElement.h"

#define kPOST_ITS_SERVICE_URL @"http://mnemobox.com/webservices/getContextPostIts.xml.php?contextId=%@&from=%@&to=%@&email=%@&pass=%@"
#define kLANG_FROM @"pl"
#define kLANG_TO @"en"
//params: emailAddress, sha1Password, fromLang, toLang, wordId, postItText
#define kPOST_IT_SAVING_SERVICE_URL @"http://www.mnemobox.com/webservices/savePostIts.php?email=%@&pass=%@&from=%@&to=%@&serialData=%@,%@;"

@interface PostItEditionViewController ()
@property (weak, nonatomic) IBOutlet UITextView *postItTextView;
@property (strong, nonatomic) Reachability *internetReachable;
@property (strong, nonatomic) XMLElement *xmlRoot;

@end

@implementation PostItEditionViewController

@synthesize wordObject = _wordObject;
@synthesize postItObject = _postItObject;
@synthesize xmlRoot = _xmlRoot;

- (void) setWordObject:(WordObject *)wordObject
{
    
    if(_wordObject != wordObject) {
        _wordObject = wordObject; 
    }
}

- (void) setPostItObject: (PostItObject *) postItObject {
 
    if(postItObject != nil) {
        NSLog(@"Setting Post It Text View"); 
        if(_postItObject != postItObject) {
            _postItObject = postItObject;
            NSLog(@"PostItText is: %@", postItObject.postItText);
            //execute UI-code on the main queue
            dispatch_async(dispatch_get_main_queue(), ^{
                self.postItTextView.text = postItObject.postItText;
            });
        }
    } else if(self.wordObject != nil && postItObject == nil) {
        [self loadUserPostItFromWebServices];
    } else {
        NSLog(@"WordObject and PosItObject are equal to nil, cannot edit user postIt."); 
    }
}

- (void) loadUserPostItFromWebServices {
    __weak PostItEditionViewController *weakSelf = self;
    
    self.internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Internet is reachable
    self.internetReachable.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"Yayyy, we have the interwebs!");
            
            [weakSelf getUserPostItFromWebServices];
            
        });
    };
    
    // Internet is not reachable
    self.internetReachable.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Someone broke the internet :(");
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet connection lost!" message:@"Could not synchronize user post with mnemobox.com." delegate:weakSelf cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
            [alert show];
            
            
        });
    };
    
    [self.internetReachable startNotifier];

}

- (void) getUserPostItFromWebServices {
    
    NSString *email = [ProfileServices emailAddressFromUserDefaults];
    NSString *pass = [ProfileServices sha1PasswordFromUserDefaults];
    
    NSString *urlAsString = [NSString stringWithFormat: kPOST_ITS_SERVICE_URL,
                             self.wordObject.wordId, kLANG_FROM, kLANG_TO, email, pass];
    
    NSLog(@"PostIts URL: %@", urlAsString);
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL: url];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod: @"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    __weak PostItEditionViewController *weakSelf = self;
    
    [NSURLConnection sendAsynchronousRequest: urlRequest
                                       queue: queue
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               
                               if([data length] > 0 && error == nil) {
                                   ///...
                                   XMLParser *xmlParser = [[XMLParser alloc] initWithData: data];
                                   self.xmlRoot = [xmlParser parseAndGetRootElement];
                                   [weakSelf traverseXMLStartingFromRootElement];
                               } else if([data length] == 0 && error == nil) {
                                   NSLog(@"Nothing was downloaded.");
                               } else if(error != nil) {
                                   NSLog(@"Error happened = %@", error); 
                               }
                           }];

}

- (void) traverseXMLStartingFromRootElement
{
    __weak PostItEditionViewController *weakSelf = self;
    
    [self.xmlRoot.subElements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
       
        XMLElement *postItElement = (XMLElement *) obj;
        BOOL isCreatedByYou =
        [[postItElement.attributes valueForKey:@"createdByYou"] isEqualToString: @"1"] ? YES : NO;
        
        if(isCreatedByYou) { 
            NSString *postItID = [postItElement.attributes valueForKey:@"pid"];
            XMLElement *postItTextElement = [postItElement.subElements objectAtIndex: 0];
            XMLElement *authorFirstName = [postItElement.subElements objectAtIndex:1];
            XMLElement *authorLastName = [postItElement.subElements objectAtIndex:2];
            XMLElement *authorID = [postItElement.subElements objectAtIndex:3];
        
            PostItObject *postIt = [[PostItObject alloc] initWithPID: postItID
                                                            text:postItTextElement.text
                                                    createdByYou:isCreatedByYou
                                                        authorID: authorID.text
                                                       firstName: authorFirstName.text
                                                        lastName: authorLastName.text];
        
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.postItObject = postIt;
                weakSelf.postItTextView.text = postIt.postItText;
            });
        }
    }];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.postItTextView.delegate = self; 
}

- (IBAction)cancelPostItsEdition:(UIButton *)sender {
    
    NSLog(@"Canceled PostIt Edition.");
    [self dismissModalViewControllerAnimated:YES]; 
}
- (IBAction)savePostIt:(UIButton *)sender {
    
    //now we can save edited postIt into web server
     NSLog(@"Saving PostIt throught web services to server");
    [self savePostItToServer]; 
    [self dismissModalViewControllerAnimated:YES];
}

-(void) savePostItToServer {
  
    NSString *emailAddress = [ProfileServices emailAddressFromUserDefaults];
    NSString *sha1Password = [ProfileServices sha1PasswordFromUserDefaults];
    
    
    //params: emailAddress, sha1Password, fromLang, toLang, wordId, postItText
    NSString *urlAsString = [NSString stringWithFormat: kPOST_IT_SAVING_SERVICE_URL,
                             emailAddress, sha1Password, kLANG_FROM, kLANG_TO, self.wordObject.wordId, self.postItTextView.text, nil];
    NSString *urlAsPercentEncodedString = [urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Saving PostIt URL: %@", urlAsPercentEncodedString);
    NSURL *url = [NSURL URLWithString: urlAsPercentEncodedString];
   
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval: 30.0f];
    [urlRequest setHTTPMethod: @"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest: urlRequest
                                       queue: queue
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
         
                               if([data length] > 0 && error == nil) {
                                   NSString *stringReturnCode = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];
                                   if([stringReturnCode isEqualToString: @"1"]) {
                                       NSLog(@"PostIt saved properly in server database.");
                                   } else {
                                       NSLog(@"An error occured while saving postIt to server database."); 
                                   }
                               } else if([data length] == 0 && error == nil) {
                                   NSLog(@"Nothing was downloaded."); 
                               } else if(error != nil) {
                                   NSLog(@"Error happened = %@", error); 
                               }
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPostItTextView:nil];
    [super viewDidUnload];
}

- (IBAction)dismissKeyboardOnTap:(id)sender {
    
    //....
    [[self view] endEditing:YES];
}
@end
