//
//  SignInViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 20/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController () 
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property CGFloat currentTextFieldPositionY;
@property CGFloat currentTextFieldHeight; 
@end

@implementation SignUpViewController

@synthesize currentTextFieldPositionY = _currentTextFieldPositionY;

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
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self setTextFieldsDelegate];
}

- (void) setTextFieldsDelegate
{
    self.firstNameTextField.delegate = self;
    self.lastNameTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.confirmPasswordTextField.delegate = self;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void) viewWillAppear:(BOOL)animated
{
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
}

-(void)keyboardWillShow: (NSNotification *)notification{
    
   // Get the size of the keyboard.
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationCurveObject = [userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey];
    NSValue *animationDurationObject = [userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSValue *keyboardEndRectObject = [userInfo valueForKey: UIKeyboardFrameEndUserInfoKey];
    NSUInteger animationCurve = 0;
    double animationDuration = 0.0f;
    CGRect keyboardEndRect = CGRectMake(0,0,0,0);
    
    [animationCurveObject getValue: &animationCurve];
    [animationDurationObject getValue: &animationDuration];
    [keyboardEndRectObject getValue: &keyboardEndRect];
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    keyboardEndRect = [self.view convertRect:keyboardEndRect fromView:window];
    
    [UIView beginAnimations:@"moveViewObstructedByKeyboard" context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve: (UIViewAnimationCurve) animationCurve];
    
    CGRect intersectionOfKeyboardRectAndWindowRect =
    CGRectIntersection(window.frame, keyboardEndRect);
    CGFloat bottomInset = intersectionOfKeyboardRectAndWindowRect.size.height;
    NSLog(@" %f", bottomInset);
    
    if(self.currentTextFieldPositionY > bottomInset) {
        //textField is obstructed by keyboard
        CGRect rect = self.view.frame;
        rect.origin.y -= self.currentTextFieldPositionY - bottomInset + self.currentTextFieldHeight*2;
        self.view.frame = rect;
    }
    
    [UIView commitAnimations]; 

}

- (void)keyboardWillHide: (NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationCurveObject = [userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey];
    NSValue *animationDurationObject = [userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSValue *keyboardEndRectObject = [userInfo valueForKey: UIKeyboardFrameEndUserInfoKey];
    NSUInteger animationCurve = 0;
    double animationDuration = 0.0f;
    CGRect keyboardEndRect = CGRectMake(0,0,0,0);
    
    [animationCurveObject getValue: &animationCurve];
    [animationDurationObject getValue: &animationDuration];
    [keyboardEndRectObject getValue: &keyboardEndRect];
    
    [UIView beginAnimations: @"moveViewObstructedByKeyboard" context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:(UIViewAnimationCurve)animationCurve];
    CGRect rect = self.view.frame;
    rect.origin.y = 0;
    self.view.frame = rect;
    [UIView commitAnimations]; 
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"Did become first responder");
    self.currentTextFieldPositionY = textField.frame.origin.y;
    self.currentTextFieldHeight = textField.frame.size.height;
    NSLog(@"Y position of txt field: %f", self.currentTextFieldPositionY);
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"Did end be first responder"); 
}
/*
#define kOFFSET_FOR_KEYBOARD 100.0
//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp byOffest: (CGFloat) keyboardHeight
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}
*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setFirstNameTextField:nil];
    [self setLastNameTextField:nil];
    [self setEmailTextField:nil];
    [self setPasswordTextField:nil];
    [self setConfirmPasswordTextField:nil];
    [super viewDidUnload];
}
@end
