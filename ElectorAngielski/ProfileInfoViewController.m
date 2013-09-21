//
//  ProfileInfoViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 18/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "ProfileInfoViewController.h"
#import "Reachability.h"
#import "UIImageView+AFNetworking.h"

@interface ProfileInfoViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *ggLabel;
@property (weak, nonatomic) IBOutlet UILabel *skypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *userLevel;
@property (weak, nonatomic) IBOutlet UILabel *mnemoneyLabel;

@property (strong, nonatomic) Reachability *internetReachable;

@end

@implementation ProfileInfoViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"]; 
    [self loadProfileInformation];
}

- (void) loadProfileInformation
{
    [self.emailLabel setText:[ProfileServices emailAddressFromUserDefaults]];
    
    [self reloadingProfileView];
    
    if(self.internetReachable.isReachable) {
        ProfileServices *profile = [[ProfileServices alloc] init];
        profile.delegate = self;
        [profile synchronizeProfileInfoWithWebServer];
    } else {
        NSLog(@"There is no internet connection.");
    }

}

- (void) profileInfoDidSynchronized
{
    [self reloadingProfileView]; 
}

- (void) reloadingProfileView
{
    if([ProfileServices firstNameFromUserDefaults] && [ProfileServices lastNameFromUserDefaults])
    {
        [self.nameLabel setText: [NSString stringWithFormat:@"%@ %@", [ProfileServices firstNameFromUserDefaults], [ProfileServices lastNameFromUserDefaults], nil]];
    }
    if([ProfileServices userImageFromUserDefaults]) {
        NSString *imageURLAsString = [NSString stringWithFormat:kUSER_AVATAR_SERVICE_URL,
                                      [ProfileServices userImageFromUserDefaults], nil];
        [self.userImageView setImageWithURL:[NSURL URLWithString:imageURLAsString] placeholderImage:[UIImage imageNamed:@"blank.png"]];
    }
    
    if([ProfileServices userAgeFromUserDefaults]) {
        [self.ageLabel setText:[NSString stringWithFormat:@"Age: %@", [ProfileServices userAgeFromUserDefaults]]];
    }
    
    if([ProfileServices cityFromUserDefaults]) {
        [self.cityLabel setText:[NSString stringWithFormat:@"City: %@", [ProfileServices cityFromUserDefaults]]];
    }
    
    if([ProfileServices gaduGaduFromUserDefaults]){
        [self.ggLabel setText: [NSString stringWithFormat:@"Gadu Gadu: %@", [ProfileServices gaduGaduFromUserDefaults]]];
    }
    
    if([ProfileServices skypeFromUserDefaults]) {
        [self.skypeLabel setText:[NSString stringWithFormat:@"Skype: %@", [ProfileServices skypeFromUserDefaults]]];
    }
    
    if([ProfileServices phoneFromUserDefaults]) {
        [self.phoneLabel setText:[NSString stringWithFormat:@"Phone: %@", [ProfileServices phoneFromUserDefaults]]];
    }
    
    if([ProfileServices isPaidUpAccountFromUserDefaults]) {
        if([[ProfileServices isPaidUpAccountFromUserDefaults] isEqualToString: @"1"]) {
            [self.accountTypeLabel setText:@"Account Type: Full Access"];
        } else {
            [self.accountTypeLabel setText:@"Account Type: Basic Access"]; 
        }
    }
    
    if([ProfileServices userLevelFromUserDefaults]) {
        [self.userLevel setText: [NSString stringWithFormat:@"User Level: %@", [ProfileServices userLevelFromUserDefaults] ]];
    }
    
    if([ProfileServices userMoneyFromUserDefaults]) {
        [self.mnemoneyLabel setText: [NSString stringWithFormat:@"Your mnemoney amount: %@", [ProfileServices userMoneyFromUserDefaults]]];
    }
}

- (void)viewDidUnload {
    [self setNameLabel:nil];
    [self setEmailLabel:nil];
    [self setUserImageView:nil];
    [self setAgeLabel:nil];
    [self setCityLabel:nil];
    [self setGgLabel:nil];
    [self setSkypeLabel:nil];
    [self setPhoneLabel:nil];
    [self setAccountTypeLabel:nil];
    [self setUserLevel:nil];
    [self setMnemoneyLabel:nil];
    [super viewDidUnload];
}
@end
