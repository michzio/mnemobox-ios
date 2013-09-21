//
//  ProfileViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 17/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "ProfileViewController.h"
#import "Reachability.h"
#import "UIImageView+AFNetworking.h"

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@property (strong, nonatomic) Reachability *internetReachable;


@end

@implementation ProfileViewController

@synthesize internetReachable = _internetReachable;

- (IBAction)aboutButtonTouched:(UIButton *)sender {
    NSLog(@"About Button Touched."); 
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden: NO animated: YES];
    [self.scrollView setContentSize: self.menuView.frame.size];
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
}

- (void)viewDidUnload {
   
    [self setScrollView:nil];
    [self setMenuView:nil];
    [self setNameLabel:nil];
    [self setEmailLabel:nil];
    [self setUserImageView:nil];
    [super viewDidUnload];
}
@end
