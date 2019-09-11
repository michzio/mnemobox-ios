//
//  AddUserWordsetViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 22/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "AddUserWordsetViewController.h"
#import "ProfileServices.h"

#define IDIOM UI_USER_INTERFACE_IDIOM()
#define IPAD UIUserInterfaceIdiomPad
#define kCREATE_NEW_USERWORDSET_SERVICE_URL @"http://www.mnemobox.com/webservices/createNewUserWordset.php?email=%@&pass=%@&plName=%@&enName=%@&description=%@&from=%@&to=%@"
#define kLANG_FROM @"pl"
#define kLANG_TO @"en"

@interface AddUserWordsetViewController () {
    BOOL isShowingLandscapeView;
}

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property CGFloat currentTextFieldPositionY;
@property CGFloat currentTextFieldHeight; 

@end

@implementation AddUserWordsetViewController

@synthesize delegate = _delegate;
@synthesize currentTextFieldPositionY = _currentTextFieldPositionY;

- (IBAction)cancelButtonTouched:(id)sender {
     if(self.view.tag == 99) {
         [self.delegate cancelButtonTouchedOnView: self];
     } else {
         [self dismissModalViewControllerAnimated:YES];
     }
}
- (IBAction)viewTouched:(id)sender {
    [[self view] endEditing:YES];
}

- (IBAction)addWordsetButtonTouched:(id)sender {
    
   [self saveNewUserWordsetToWebServer];

}

- (IBAction) foreignTitleValueChanged:(UITextField *)sender {
    if(self.view.tag == 99) { 
        [self.delegate foreignTextFieldValueChangedOnView:self];
    }
}

- (IBAction) nativeTitleValueChanged:(UITextField *)sender {
    NSLog(@"Native Title Value Changed."); 
    if(self.view.tag == 99) {
        [self.delegate nativeTextFieldValueChangedOnView:self];
    }
}


- (void) saveNewUserWordsetToWebServer
{
    NSLog(@"Saving new user wordset to web server.");
    
    NSString *emailAddress = [ProfileServices emailAddressFromUserDefaults];
    NSString *sha1Password = [ProfileServices sha1PasswordFromUserDefaults];
    
    NSString *foreignTitle = self.foreignTitleTextField.text;
    NSString *nativeTitle = self.nativeTitleTextField.text;
    NSString *description = self.descriptionTextView.text;
    
    NSString *urlAsString = [NSString stringWithFormat:kCREATE_NEW_USERWORDSET_SERVICE_URL, emailAddress, sha1Password, nativeTitle, foreignTitle, description, kLANG_FROM, kLANG_TO];
    urlAsString = [urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue: queue
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               
                               if([data length] > 0 && error == nil) {
                                   NSString *resultString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   
                                   if([resultString isEqualToString:@"1"]) {
                                       NSLog(@"New user wordset has been created.");
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [self.errorLabel setHidden:YES];
                                           if(self.view.tag == 99) {
                                               [self.delegate addedUserWordsetOnView: self];
                                           } else {
                                               [self dismissViewControllerAnimated:YES completion:nil];
                                           }
                                       });
                                       
                                   } else {
                                       NSLog(@"The request end with error.");
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [self.errorLabel setHidden: NO];
                                       });
                                   }
                                   
                               } else if([data length] == 0 && error == nil) {
                                   NSLog(@"Nothing has beend downloaded.");
                               } else {
                                   NSLog(@"An error has occured: %@", error);
                               }
                               
                           }];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(self.view.tag == 0) { 
        [self adjustToSreenOrientation];
    } else {
        //if we have screen in landscape mode we must set text fields approprietly
        AddUserWordsetViewController *parent = (AddUserWordsetViewController *) self.presentingViewController;
        [self.foreignTitleTextField setText: parent.foreignTitleTextField.text];
        [self.nativeTitleTextField setText: parent.nativeTitleTextField.text];
        [self.descriptionTextView setText: parent.descriptionTextView.text];
        self.descriptionTextView.delegate = self;
        
    }
    
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

- (void)awakeFromNib
{
 
    NSLog(@"Awake From Nib executed...");
    isShowingLandscapeView = NO;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)orientationChanged:(NSNotification *)notification
{
    [self adjustToSreenOrientation];
}


- (void) adjustToSreenOrientation {
    NSLog(@"Adjust To Screen Orientation executed..."); 
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation) &&
        !isShowingLandscapeView)
    {
        if(IDIOM == IPAD) {
            isShowingLandscapeView = YES;
            
        } else {
            if(self.view.tag == 99) {
                ///do just nothing
            } else {
                [self performSegueWithIdentifier:@"Landscape View Segue" sender:self];
                isShowingLandscapeView = YES;
            }
        }
    }
    
    else if (UIDeviceOrientationIsPortrait(deviceOrientation) &&
             isShowingLandscapeView && deviceOrientation != UIDeviceOrientationPortraitUpsideDown )
    {
        if(IDIOM == IPAD) {
            isShowingLandscapeView = NO;
            
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
            isShowingLandscapeView = NO;
        }
    }
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Landscape View Segue"]) {
        [segue.destinationViewController setDelegate:self];
        [[segue.destinationViewController foreignTitleTextField] setText:self.foreignTitleTextField.text];
    }
}

- (void)viewDidUnload {
    [self setForeignTitleTextField:nil];
    [self setNativeTitleTextField:nil];
    [self setDescriptionTextView:nil];
    [self setErrorLabel:nil];
    [super viewDidUnload];
}

- (void) cancelButtonTouchedOnView: (AddUserWordsetViewController *) sender
{
    NSLog(@"Cancel Button Touched On View.");
    __weak AddUserWordsetViewController *weakSelf = self;
    [self dismissViewControllerAnimated:NO completion:^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void) addedUserWordsetOnView: (AddUserWordsetViewController *) sender
{
    NSLog(@"Added User Wordset On View.");
    __weak AddUserWordsetViewController *weakSelf = self;
    [self dismissViewControllerAnimated:NO completion:^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    
}

- (void) foreignTextFieldValueChangedOnView: (AddUserWordsetViewController *) sender
{
    [self.foreignTitleTextField setText:sender.foreignTitleTextField.text];
}

- (void) nativeTextFieldValueChangedOnView: (AddUserWordsetViewController *) sender
{
   [self.nativeTitleTextField setText: sender.nativeTitleTextField.text];
}

- (void) descriptionTextViewValueChangedOnView: (AddUserWordsetViewController *) sender
{
    [self.descriptionTextView setText: sender.descriptionTextView.text];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self.delegate descriptionTextViewValueChangedOnView: self];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"Did become first responder");
    self.currentTextFieldPositionY = textView.frame.origin.y;
    self.currentTextFieldHeight = textView.frame.size.height;
    NSLog(@"Y position of txt field: %f", self.currentTextFieldPositionY);
    NSLog(@"Text Field height: %f", self.currentTextFieldHeight);
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
}
- (void) keyboardWillShow: (NSNotification *) notification
{
    [self performSelector:@selector(keyboardWillShowAdjustment:) withObject:notification afterDelay:0.1];
}

-(void)keyboardWillShowAdjustment: (NSNotification *)notification{
    
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
    
    if(self.currentTextFieldPositionY + self.currentTextFieldHeight >= bottomInset) {
        //textField is obstructed by keyboard
        CGRect rect = self.view.frame;
        
        UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
        if(deviceOrientation == UIDeviceOrientationLandscapeLeft) {
            rect.origin.x += self.currentTextFieldPositionY - bottomInset + self.currentTextFieldHeight*2;
        } else if(deviceOrientation == UIDeviceOrientationLandscapeRight) {
            rect.origin.x -= self.currentTextFieldPositionY - bottomInset + self.currentTextFieldHeight*2;
        } else if(deviceOrientation == UIDeviceOrientationPortrait) {
           rect.origin.y -= self.currentTextFieldPositionY - bottomInset + self.currentTextFieldHeight*2;
        } else if(deviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
            rect.origin.y += self.currentTextFieldPositionY - bottomInset + self.currentTextFieldHeight*2;
        }
        
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
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    CGRect rect = self.view.frame;
    if(deviceOrientation == UIDeviceOrientationLandscapeLeft) {
        rect.origin.x = 0;
    } else if(deviceOrientation == UIDeviceOrientationLandscapeRight) {
        rect.origin.x = 20;
    } else if(deviceOrientation == UIDeviceOrientationPortrait) {
        rect.origin.y = 20;
    } else if(deviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
        rect.origin.y = 0;
    }
    self.view.frame = rect;
    [UIView commitAnimations];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"Did become first responder");
    self.currentTextFieldPositionY = textField.frame.origin.y;
    self.currentTextFieldHeight = textField.frame.size.height;
    NSLog(@"Y position of txt field: %f", self.currentTextFieldPositionY);
    NSLog(@"Text Field height: %f", self.currentTextFieldHeight);
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"Did end be first responder");
}

-(BOOL) shouldAutorotate{
    return YES;
}

-(NSUInteger) supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskAll;
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
