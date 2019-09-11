//
//  SignInViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 20/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "SignUpViewController.h"

#define IDIOM UI_USER_INTERFACE_IDIOM()
#define IPAD UIUserInterfaceIdiomPad

#define kREGISTRATION_URL_SERVICE @"http://mnemobox.com/webservices/registerUser.php?email=%@&pass=%@&fn=%@&ln=%@"

@interface SignUpViewController () 
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property CGFloat currentTextFieldPositionY;
@property CGFloat currentTextFieldHeight;

@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UILabel *confirmPasswordLabel;

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
    if (UIDeviceOrientationIsLandscape(deviceOrientation) && IDIOM != IPAD)
    {
        [self.firstNameLabel setHidden:YES];
        [self.lastNameLabel setHidden:YES];
        [self.emailLabel setHidden:YES];
        [self.passwordLabel setHidden:YES];
        [self.confirmPasswordLabel setHidden:YES];
        
        
    }  else if (UIDeviceOrientationIsPortrait(deviceOrientation) &&
                deviceOrientation != UIDeviceOrientationPortraitUpsideDown)
    {
        [self.firstNameLabel setHidden:NO];
        [self.lastNameLabel setHidden:NO];
        [self.emailLabel setHidden:NO];
        [self.passwordLabel setHidden:NO];
        [self.confirmPasswordLabel setHidden:NO];
    }
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
    [self adjustToScreenOrientation];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
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
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name: UIDeviceOrientationDidChangeNotification
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
- (IBAction)signUpNewUser:(id)sender {
    NSLog(@"Signing Up New User.");
    
    NSString *emailAddress = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    NSString *confirmPassword = self.confirmPasswordTextField.text;
    NSString *firstName = self.firstNameTextField.text;
    NSString *lastName = self.lastNameTextField.text;
    if(![password isEqualToString:confirmPassword]) {
        
        NSLog(@"Podane hasła nie pasują do siebie.");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Błędne Hasło" message:@"Podane hasła nie pasują do siebie" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if(![self NSStringIsValidEmail:emailAddress]) {
        NSLog(@"Podany adres email jest niepoprawny!");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Błędny Adres Email" message:@"Podany adres email nie jest poprawny." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    NSString *urlAsString = [NSString stringWithFormat:kREGISTRATION_URL_SERVICE, emailAddress, password, firstName, lastName, nil];
    NSLog(@"Registration New User URL: %@", urlAsString); 
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if(error == nil || [result isEqualToString:@"1"]) {
            NSLog(@"Successfully register new user.");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Utworzono Konto Poprawnie!" message:@"Zostałeś użytkownikiem systemu e-learningowego elector.pl, przejdź do ekranu logowania i zaloguj się do aplikacji." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
           
        } else {
            NSLog(@"Error: %@", result);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Błąd podczas tworzenia konta." message:@"Zmień dane i spróbuj ponownie. Być może użyłeś adresu email na który zostało już utworzone konto w systemie. W takim przypadku na elector.pl możesz wygenerować nowe hasło." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES;
    // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (void)viewDidUnload {
    [self setFirstNameTextField:nil];
    [self setLastNameTextField:nil];
    [self setEmailTextField:nil];
    [self setPasswordTextField:nil];
    [self setConfirmPasswordTextField:nil];
    [self setFirstNameLabel:nil];
    [self setLastNameLabel:nil];
    [self setEmailLabel:nil];
    [self setPasswordLabel:nil];
    [self setConfirmPasswordLabel:nil];
    [super viewDidUnload];
}
@end
