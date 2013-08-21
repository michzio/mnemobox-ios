//
//  ElectorViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 20/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "ElectorViewController.h"
#import "ProfileServices.h"

@interface ElectorViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UILabel *incorrectPasswordLabel;

@end

@implementation ElectorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 188.0/255
                                                                        green:0.0
                                                                         blue:38.0/255
                                                                        alpha:0.7];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
     
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES; 
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString: @"Sign Up Segue"]) {
        NSLog(@"Sign Up Segue"); 
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
       [self performSegueWithIdentifier: @"Sign In Segue" sender:self.view];

    } else {
        [UIView beginAnimations: @"incorrectEmailOrPassowrd" context:NULL];
        [UIView setAnimationDuration:1.0f];
        [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromLeft forView:self.incorrectPasswordLabel cache:YES];
        self.incorrectPasswordLabel.hidden = NO;
        [UIView commitAnimations];
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
    [super viewDidUnload];
}
@end
