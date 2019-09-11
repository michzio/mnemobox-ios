//
//  ProfileServices.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 20/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "ProfileServices.h"
#import "XMLParser.h"
#import "XMLElement.h"

#define kLOGIN_SERVICE_URL @"http://www.mnemobox.com/webservices/loginService.php?email=%@&pass=%@"
#define kPROFILE_INFO_SERVICE_URL @"http://www.mnemobox.com/webservices/userProfile.xml.php?email=%@&pass=%@"


@interface ProfileServices ()

@property (strong, nonatomic) XMLElement *xmlRoot;

@end

@implementation ProfileServices

@synthesize xmlRoot = _xmlRoot;

+ (BOOL) verifyUserWithEmailAddress: (NSString *) emailAddress andSHA1Passowrd: (NSString *) sha1Password {
    
    BOOL result = NO;
    
    NSString *urlAsString = [NSString stringWithFormat: kLOGIN_SERVICE_URL, emailAddress, sha1Password];
    NSLog(@"%@", urlAsString);
    
    NSURL *url = [NSURL URLWithString: urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL: url];
    [urlRequest setTimeoutInterval: 30.0f];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSError *error = nil;
    NSURLResponse *response = nil;
    
    NSData *data = [NSURLConnection
     sendSynchronousRequest: urlRequest
     returningResponse: &response
     error:&error];
     
      
    if([data length] > 0 && error == nil) {
                        
            NSString *html = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];
            NSLog(@"%@", html);
            if([html intValue] > 0) {
                    NSLog(@"Correct email and password");
                    result = YES;
            } else if([html isEqualToString:@"0"]){
                    NSLog(@"Password or Email is invalid, could not sign in.");
            }
                        
    } else if([data length] == 0 && error == nil) {
                NSLog(@"Nothing was downloaded"); 
                        
    } else if(error != nil)  {
                NSLog(@"Error happened = %@", error);
    }
                        
    return result;
}

/***********************************************************************************
 * This is utility class method that calculates SHA1 encrypthed version of password*
 ***********************************************************************************/
+ (NSString *)passwordToSHA1: (NSString *)password {
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    NSData *stringBytes = [password dataUsingEncoding: NSUTF8StringEncoding]; /* or some other encoding */
    if (CC_SHA1([stringBytes bytes], [stringBytes length], digest)) {
        /* SHA-1 hash has been calculated and stored in 'digest'. */
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
        
        for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        {
            [output appendFormat:@"%02x", digest[i]];
        }
        
        return output;
    }
    return nil; 
}

+ (void) storeInUserDefaultsEmail: (NSString *) emailAddress andSHA1Password: (NSString *)sha1Password {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject: emailAddress forKey: @"profileEmailAddress"];
    [prefs setObject: sha1Password forKey: @"profileSHA1Password"];
    
    NSNumber *signedIn = [NSNumber numberWithInt: 1];
    [prefs setObject: signedIn forKey: @"profileNotSignedIn"];
}

+ (BOOL) isUserSignedIn
{
    BOOL result = NO;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSNumber *signedIn = [prefs valueForKey:@"profileNotSignedIn"];
    
    //checking whether user is sign in
    if([signedIn isEqualToNumber: [NSNumber numberWithInt: 1]]) {
        result = YES;
    }
    
    return result;
    
}

+ (NSString *) emailAddressFromUserDefaults
{
    NSString *emailAddress = nil;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    emailAddress = [prefs valueForKey:@"profileEmailAddress"];
    
    return emailAddress; 
}

+ (NSString *) sha1PasswordFromUserDefaults
{
    NSString *sha1Password = nil;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    sha1Password = [prefs valueForKey:@"profileSHA1Password"];

    return sha1Password;
}

+ (void) storeUserImageInUserDefaults: (NSString *) userImage
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject: userImage forKey: @"profileUserImage"];
}

+ (void) storeFirstNameInUserDefaults: (NSString *) firstName
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject: firstName forKey: @"profileFirstName"];
}

+ (void) storeLastNameInUserDefaults: (NSString *) lastName
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject: lastName forKey: @"profileLastName"];
}

+ (void) storeUserAgeInUserDefaults: (NSString *) userAge
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject: userAge forKey: @"profileUserAge"];
}
+ (void) storeGaduGaduInUserDefaults: (NSString *) gaduGadu
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject: gaduGadu forKey: @"profileGaduGadu"];
}

+ (void) storeSkypeInUserDefaults: (NSString *) skype
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject: skype forKey: @"profileSkype"];
}

+ (void) storePhoneInUserDefaults: (NSString *) phone
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject: phone forKey: @"profilePhone"];
}

+ (void) storeCityInUserDefaults: (NSString *) city
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject: city forKey: @"profileCity"];
}

+ (void) storeIsPaidUpAccountInUserDefaults: (NSString *) isPaidUpAccount
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject: isPaidUpAccount forKey: @"profileIsPaidUpAccount"];
}

+ (void) storeUserLevelInUserDefaults: (NSString *) userLevel
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject: userLevel forKey: @"profileUserLevel"];
}

+ (void) storeUserMoneyInUserDefaults: (NSString *) userMoney
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject: userMoney forKey: @"profileUserMoney"];
}

+ (void) storeLastWordsetIdInUserDefaults: (NSString *) lastWordsetId
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject: lastWordsetId forKey: @"profileLastWordsetId"];
}

+ (void) storeLastWordsetLabelInUserDefaults: (NSString *) lastWordsetLabel
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject: lastWordsetLabel forKey: @"profileLastWordset"];
}

+ (NSString *) userImageFromUserDefaults
{
    return [self stringFromUserDefaultsForKey: @"profileUserImage"];
}

+ (NSString *) firstNameFromUserDefaults
{

    return [self stringFromUserDefaultsForKey:  @"profileFirstName"];
}

+ (NSString *) lastNameFromUserDefaults
{
    return [self stringFromUserDefaultsForKey:  @"profileLastName"];
}

+ (NSString *) userAgeFromUserDefaults
{
    return [self stringFromUserDefaultsForKey:  @"profileUserAge"];
}

+ (NSString *) gaduGaduFromUserDefaults
{
    return [self stringFromUserDefaultsForKey:  @"profileGaduGadu"];
}

+ (NSString *) skypeFromUserDefaults
{
    return [self stringFromUserDefaultsForKey:  @"profileSkype"];
}

+ (NSString *) phoneFromUserDefaults
{
    return [self stringFromUserDefaultsForKey:  @"profilePhone"];
}

+ (NSString *) cityFromUserDefaults
{
    return [self stringFromUserDefaultsForKey:  @"profileCity"];
}

+ (NSString *) isPaidUpAccountFromUserDefaults
{
    return [self stringFromUserDefaultsForKey:  @"profileIsPaidUpAccount"];
}

+ (NSString *) userLevelFromUserDefaults
{
    return [self stringFromUserDefaultsForKey:  @"profileUserLevel"];
}

+ (NSString *) userMoneyFromUserDefaults
{
    return [self stringFromUserDefaultsForKey:  @"profileUserMoney"];
}

+ (NSString *) lastWordsetIdFromUserDefaults
{
    return [self stringFromUserDefaultsForKey:  @"profileLastWordsetId"];
}

+ (NSString *) lastWordsetLabelFromUserDefaults
{
    return [self stringFromUserDefaultsForKey:  @"profileLastWordset"];
}

+ (NSString *) stringFromUserDefaultsForKey: (NSString *) key 
{
    NSString *value = nil;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    value = [prefs valueForKey: key];
    
    return value;
}

- (void) synchronizeProfileInfoWithWebServer
{
    //Load data from web server
    NSString *emailAddress = [ProfileServices emailAddressFromUserDefaults];
    NSString *sha1Password = [ProfileServices sha1PasswordFromUserDefaults];
    
    NSString *urlAsString = [NSString stringWithFormat: kPROFILE_INFO_SERVICE_URL, emailAddress, sha1Password, nil];
    NSLog(@"Profile Info URL: %@", urlAsString);
    
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod: @"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    ProfileServices *weakSelf = self;
    
    [NSURLConnection sendAsynchronousRequest: urlRequest
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               if([data length] > 0 && error == nil) {
                                   XMLParser *xmlParser = [[XMLParser alloc] initWithData: data];
                                    weakSelf.xmlRoot = [xmlParser parseAndGetRootElement];
                                   [weakSelf traverseXMLStartingFromRootElement];
                               } else if([data length] == 0 && error == nil) {
                                   NSLog(@"Nothing has been downloaded.");
                               } else {
                                   NSLog(@"Error happened: %@", error);
                               }
                           }];
}

- (void) traverseXMLStartingFromRootElement
{
    NSLog(@"Traversing XML starting from root element.");
    
    XMLElement *profileElement = self.xmlRoot;
    
    NSString *emailAddress = [[profileElement.subElements objectAtIndex:0] text];
    NSLog(@"Email Address: %@", emailAddress);
    
    NSString *userImage = [[profileElement.subElements objectAtIndex:1] text];
    NSLog(@"User Image: %@", userImage);
    [ProfileServices storeUserImageInUserDefaults:userImage];
    
    NSString *firstName = [[profileElement.subElements objectAtIndex:2] text];
    NSLog(@"First Name: %@", firstName);
    [ProfileServices storeFirstNameInUserDefaults:firstName];
    
    NSString *lastName = [[profileElement.subElements objectAtIndex: 3] text];
    NSLog(@"Last Name: %@", lastName);
    [ProfileServices storeLastNameInUserDefaults:lastName];
    
    NSString *userAge = [[profileElement.subElements objectAtIndex:4] text];
    NSLog(@"User Age: %@", userAge);
    [ProfileServices storeUserAgeInUserDefaults:userAge];
    
    NSString *gaduGadu = [[profileElement.subElements objectAtIndex:5] text];
    NSLog(@"Gadu Gadu: %@", gaduGadu);
    [ProfileServices storeGaduGaduInUserDefaults:gaduGadu];
    
    NSString *skype = [[profileElement.subElements objectAtIndex:6] text];
    NSLog(@"Skype: %@", skype);
    [ProfileServices storeSkypeInUserDefaults:skype];
    
    NSString *phone = [[profileElement.subElements objectAtIndex:7] text];
    NSLog(@"Phone: %@", phone);
    [ProfileServices storePhoneInUserDefaults:phone];
    
    NSString *city = [[profileElement.subElements objectAtIndex:8] text];
    NSLog(@"City: %@", city);
    [ProfileServices storeCityInUserDefaults:city];
    
    NSString *paidupAccount = [[profileElement.subElements objectAtIndex:9] text];
    NSLog(@"Paid Up Account: %@", paidupAccount);
    [ProfileServices storeIsPaidUpAccountInUserDefaults:paidupAccount];
    
    NSString *userLevel = [[profileElement.subElements objectAtIndex:10] text];
    NSLog(@"User Level: %@", userLevel);
    [ProfileServices storeUserLevelInUserDefaults:userLevel];
    
    NSString *userMoney = [[profileElement.subElements objectAtIndex:11] text];
    NSLog(@"User Money: %@", userMoney);
    [ProfileServices storeUserMoneyInUserDefaults:userMoney];
    
    NSString *lastWordsetId = [[[profileElement.subElements objectAtIndex:12] attributes] valueForKey:@"wid"];
    NSLog(@"Last Wordset Id: %@", lastWordsetId);
    [ProfileServices storeLastWordsetIdInUserDefaults:lastWordsetId];
    
    NSString *lastWordsetLabel = [[profileElement.subElements objectAtIndex:12] text];
    NSLog(@"Last Wordset: %@", lastWordsetLabel);
    [ProfileServices storeLastWordsetLabelInUserDefaults:lastWordsetLabel];
    
    [self.delegate profileInfoDidSynchronized]; 
}


@end

