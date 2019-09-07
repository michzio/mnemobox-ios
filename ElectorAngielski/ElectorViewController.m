//
//  ElectorViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 20/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "ElectorViewController.h"
#import "ProfileServices.h"
#import "Wordset+Create.h"
#import "GenericLearningViewController.h"

#define IDIOM UI_USER_INTERFACE_IDIOM()
#define IPAD UIUserInterfaceIdiomPad
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface ElectorViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UILabel *incorrectPasswordLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (strong, nonatomic) UIManagedDocument *database;
@property (strong,nonatomic) Wordset *testWordset;

@property (weak, nonatomic) IBOutlet UIButton *withoutSignInButton;

@end


@implementation ElectorViewController

@synthesize testWordset = _testWordset;
@synthesize database = _database;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView setContentSize: CGSizeMake(8*self.view.frame.size.width + 40.0f, self.contentView.frame.size.height)];
	// Do any additional setup after loading the view, typically from a nib.
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 188.0/255
                                                                        green:0.0
                                                                         blue:38.0/255
                                                                        alpha:0.7];
    
    if([ProfileServices emailAddressFromUserDefaults] != nil && [ProfileServices sha1PasswordFromUserDefaults] != nil ) {
        NSLog(@"Email: %@, Pass: %@", [ProfileServices emailAddressFromUserDefaults], [ProfileServices sha1PasswordFromUserDefaults]  );
        
        if(IDIOM == IPAD /*&& SYSTEM_VERSION_LESS_THAN(@"6.0")*/) {
            [self performSegueWithIdentifier:  @"Sign In iOS5 Segue" sender:self];
        } else {
            [self performSegueWithIdentifier: @"Sign In Segue" sender:self];
        }
    }
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
     
}

- (void)awakeFromNib
{
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
}

- (void)orientationChanged:(NSNotification *)notification
{
    [self adjustToScreenOrientation];
}

- (void) adjustToScreenOrientation
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {
        [self.emailLabel setHidden:YES];
        [self.passwordLabel setHidden:YES];
        [self.scrollView setContentSize: CGSizeMake(8*self.view.frame.size.height + 40.0f, self.contentView.frame.size.height)];
       
        
    }  else if (UIDeviceOrientationIsPortrait(deviceOrientation) &&
                deviceOrientation != UIDeviceOrientationPortraitUpsideDown)
    {
        [self.emailLabel setHidden:NO];
        [self.passwordLabel setHidden:NO];
        [self.scrollView setContentSize: CGSizeMake(8*self.view.frame.size.width + 40.0f, self.contentView.frame.size.height)];
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES; 
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString: @"Sign Up Segue"]) {
        NSLog(@"Sign Up Segue"); 
    } else if([segue.destinationViewController respondsToSelector:@selector(setWordset:)]) {
        [segue.destinationViewController setWordset: [self testWordset]];
    }
}

- (IBAction)useWithoutSignIn:(UIButton *)sender {
    //użycie aplikacji bez zakładania konta i logowania
    
    NSLog(@"Running application without signing in...");
    self.incorrectPasswordLabel.hidden = YES;
    
    NSNumber *signedIn = [NSNumber numberWithInt:0];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject: signedIn forKey: @"profileNotSignedIn"];
    
    /* execute signing in operation */
    if(IDIOM == IPAD /*&& SYSTEM_VERSION_LESS_THAN(@"6.0")*/) {
        [self performSegueWithIdentifier:  @"Sign In iOS5 Segue" sender:self];
    } else {
        [self performSegueWithIdentifier: @"Sign In Segue" sender:self];
    }
}

- (IBAction)trySignIn:(UIButton *)sender {
    
    NSString *sha1Password = [ProfileServices passwordToSHA1: self.passwordTextField.text];
    BOOL verifiedWithSuccess = [ProfileServices verifyUserWithEmailAddress: self.emailTextField.text
                                                           andSHA1Passowrd: sha1Password];
    if(verifiedWithSuccess) {
        NSLog(@"Email and password will be stored in user defaults"); 
        self.incorrectPasswordLabel.hidden = YES;
        [ProfileServices storeInUserDefaultsEmail: self.emailTextField.text
                                                           andSHA1Password: sha1Password];
        /* execute signing in operation */
        if(IDIOM == IPAD /*&& SYSTEM_VERSION_LESS_THAN(@"6.0")*/) {
            [self performSegueWithIdentifier:  @"Sign In iOS5 Segue" sender:self];
        } else {
            [self performSegueWithIdentifier: @"Sign In Segue" sender:self];
        }
    

    } else {
        [UIView beginAnimations: @"incorrectEmailOrPassowrd" context:NULL];
        [UIView setAnimationDuration:1.0f];
        [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromLeft forView:self.incorrectPasswordLabel cache:YES];
        self.incorrectPasswordLabel.hidden = NO;
        [UIView commitAnimations];
    }
}

- (IBAction)tryPresentationLearning:(id)sender {
    NSLog(@"Try Presentation Learning Segue");
    [self performSegueWithIdentifier:@"Try Presentation Learning" sender:self];
}
- (IBAction)tryRepetitionLearning:(id)sender {
     [self performSegueWithIdentifier:@"Try Repetition Learning" sender:self];
}
- (IBAction)trySpeakingLearning:(id)sender {
     [self performSegueWithIdentifier:@"Try Speaking Learning" sender:self];
}
- (IBAction)tryChoosingLearning:(id)sender {
     [self performSegueWithIdentifier:@"Try Choosing Learning" sender:self];
}
- (IBAction)tryListeningLearning:(id)sender {
     [self performSegueWithIdentifier:@"Try Listening Learning" sender:self];
}
- (IBAction)tryCartonsLearning:(id)sender {
     [self performSegueWithIdentifier:@"Try Cartons Learning" sender:self];
}

- (Wordset *) testWordset
{
    if(_testWordset == nil) {
        //lazy instantiation
        _testWordset = [Wordset wordsetWithWID:@"14"
                                   foreignName:@"Fruits and Vegetables"
                                    nativeName:@"Owoce i Warzywa"
                                         level:@"A1"
                                   description:@"Nazwy warzyw, owoców i orzechów, np. apple, carrot, nut..."
                                   forCategory:nil
                        inManagedObjectContext: self.database.managedObjectContext];
    }
    
    return _testWordset;
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [self adjustToScreenOrientation];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    /* if my database is nil we will create it */
    if(!self.database) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent: @"Wordset Database"];
        self.database = [[UIManagedDocument alloc] initWithFileURL:url];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setDatabase:(UIManagedDocument *)database
{
    if( _database != database) {
        _database = database;
        [self useDocument];
    }
    
}

- (void) useDocument
{
    if(![[NSFileManager defaultManager] fileExistsAtPath: [self.database.fileURL path]]) {
        /* database not exists on disk so we need to creat it */
        [self.database saveToURL: self.database.fileURL forSaveOperation: UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            NSLog(@"database created on disk");
        }];
        
    } else if (self.database.documentState == UIDocumentStateClosed) {
        /* document is closed then we need to open the file */
        [self.database openWithCompletionHandler:^(BOOL success) {
            NSLog(@"wordsetDatabase was opened");
        }];
    } else if (self.database.documentState == UIDocumentStateNormal) {
        /* document exists for a given path and is opend */
        NSLog(@"database is in normal state (opened)");
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setEmailTextField:nil];
    [self setPasswordTextField:nil];
    [self setSignupButton:nil];
    [self setIncorrectPasswordLabel:nil];
    [self setScrollView:nil];
    [self setContentView:nil];
    [self setEmailLabel:nil];
    [self setPasswordLabel:nil];
    [super viewDidUnload];
}
@end
