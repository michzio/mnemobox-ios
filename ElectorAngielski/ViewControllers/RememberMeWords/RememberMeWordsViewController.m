//
//  RememberMeWordsViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 17/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "RememberMeWordsViewController.h"
#import "ElectorWebServices.h"

//params: emailAddress, sha1Password,fromLang, toLang
#define kUSER_REMEMBERME_WORDS_SERVICE_URL @"http://www.mnemobox.com/webservices/userRememberMeWords.xml.php?email=%@&pass=%@&from=%@&to=%@"

//params: emailAddress, sha1Password, fromLang, toLang
#define kREMEMBERME_WORDS_SERVICE_URL @"http://www.mnemobox.com/webservices/getwordset.php?type=rememberme&email=%@&pass=%@&wordset=0&from=%@&to=%@"

//params: emailAddress, sha1Password, wordId, fromLang, toLang
#define kDELETE_REMEMBERME_WORD_SERVICE_URL @"http://mnemobox.com/webservices/deleteRemember.php?email=%@&pass=%@&translationId=%@&from=%@&to=%@"

@interface RememberMeWordsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *remembermeWordsTableView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation RememberMeWordsViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    if(self.internetReachable.isReachable) {
        //save locally stored forgotten words into web server database in order to synchronize it
        [ElectorWebServices synchronizeRememberMeWordsSavedInUserDefaults];
    }
}
- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear:animated];
    [self adjustToScreenOrientation];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    NSLog(@"Setting up TableView and FetchResultsController.");
    self.tableView = self.remembermeWordsTableView;
    //if Wordset with id: Forgotten hasn't been created yet we should creat such Wordset and we will put into it new forgotten words...
    self.title = @"Remember Me";
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self adjustToScreenOrientation];
    
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
        [self.backgroundImageView setImage:[UIImage imageNamed:@"london.png"]];
        CGFloat xOffset = 100;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            xOffset += 224;
        }
        [self setPullUpViewPosition:xOffset];
    }  else if (UIDeviceOrientationIsPortrait(deviceOrientation) &&
                deviceOrientation != UIDeviceOrientationPortraitUpsideDown)
    {
        [self.backgroundImageView setImage:[UIImage imageNamed:@"bigben.png"]];
        CGFloat xOffset = 0;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            xOffset = 224;
        }
        [self setPullUpViewPosition:xOffset];
    }  else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && deviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
        CGFloat xOffset = 0;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            xOffset = 224;
        }
        [self setPullUpViewPosition:xOffset];
    }

}



- (NSURL *) getWebServicesURL
{
    NSString *emailAddress = [ProfileServices emailAddressFromUserDefaults];
    NSString *sha1Password = [ProfileServices sha1PasswordFromUserDefaults];
    NSString *urlAsString = [NSString stringWithFormat:kREMEMBERME_WORDS_SERVICE_URL, emailAddress, sha1Password, kLANG_FROM, kLANG_TO, nil];
    NSLog(@"RememberMe Words URL: %@", urlAsString);
    
    return [NSURL URLWithString:urlAsString];
}

- (void) createOrUpdateGenericWordsetInCoreData
{
    //[self.database.managedObjectContext performBlock:^{
    
    NSLog(@"Creating or updating rememberme wordset in core data.");
    
    WordsetCategory *category = [WordsetCategory wordsetCategoryWithCID:@"USER"
                                                            foreignName:@"User Wordsets"
                                                             nativeName:@"Zestawy użytkownika"
                                                 inManagedObjectContext:self.database.managedObjectContext];
    
    self.genericWordset = [Wordset wordsetWithWID:@"REMEMBERME"
                                      foreignName:@"Remember Me Words"
                                       nativeName:@"Słówka Dodane Do Przypomnienia"
                                            level:nil
                                      description:@"This is wordset collecting words which user add to remember him while learning."
                                      forCategory:category
                           inManagedObjectContext:self.database.managedObjectContext];
    //}];
    
    
}

- (NSURL *) getDeletionRequestURLForWord: (Word *) word
{
    
    NSString *emailAddress = [ProfileServices emailAddressFromUserDefaults];
    NSString *sha1Password = [ProfileServices sha1PasswordFromUserDefaults];
    
    //params: emailAddress, sha1Password, forgottenId, fromLang, toLang
    NSString *urlAsString = [NSString stringWithFormat: kDELETE_REMEMBERME_WORD_SERVICE_URL,
                             emailAddress, sha1Password, word.wordId, kLANG_FROM, kLANG_TO, nil];
    
    NSLog(@"Delete RememberMe Word URL: %@", urlAsString);
    
    return [NSURL URLWithString:urlAsString];
    
}

- (void)viewDidUnload {
    [self setRemembermeWordsTableView:nil];
    [self setBackgroundImageView:nil];
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
