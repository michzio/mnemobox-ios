//
//  UserwordsetWordsViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 22/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "UserwordsetWordsViewController.h"

#define IPAD UIUserInterfaceIdiomPad
#define IDIOM UI_USER_INTERFACE_IDIOM()
//params: wordsetId, type, langFrom, langTo
#define kWORDS_IN_WORDSET_SERVICE_URL @"http://www.mnemobox.com/webservices/getwordset.php?wordset=%@&type=%@&from=%@&to=%@"
#define kTYPE_USERWORDSET @"userwordset"
#define kLANG_FROM @"pl"
#define kLANG_TO @"en"

@interface UserwordsetWordsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *userwordsetWordsTableView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
 
@end

@implementation UserwordsetWordsViewController

@synthesize userWordset = _userWordset;
@synthesize userwordsetWordsTableView = _userwordsetWordsTableView;
@synthesize backgroundImageView = _backgroundImageView;

- (void) viewDidLoad
{
    [super viewDidLoad];
    //[self adjustToScreenOrientation];
}

- (void) setUserWordset:(Wordset *)userWordset
{
    NSLog(@"setUserWordset: executing....");
    if(_userWordset != userWordset) {
        NSLog(@"Setting user wordset with wid: %@", userWordset.wid);
        _userWordset = userWordset; 
    }
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
        
    } else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && deviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
        CGFloat xOffset = 0;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            xOffset = 224;
        }
        [self setPullUpViewPosition:xOffset];
    }
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];

    NSLog(@"Setting up Table View");
    self.tableView = self.userwordsetWordsTableView;
    self.title = self.userWordset.foreignName;
    if(IDIOM == IPAD) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addWordButtonTouched:)];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self adjustToScreenOrientation];
}

- (NSURL *) getWebServicesURL
{
    NSRange range = [self.userWordset.wid rangeOfString:@"USERWORDSET_"];
    NSString *idOfUserWordset;
    if (range.location != NSNotFound)
    {
        //range.location is start of substring
        //range.length is length of substring
        idOfUserWordset= [self.userWordset.wid substringFromIndex:range.location + range.length];
    }

    NSString *urlAsString = [NSString stringWithFormat:kWORDS_IN_WORDSET_SERVICE_URL, idOfUserWordset, kTYPE_USERWORDSET, kLANG_FROM, kLANG_TO, nil];
    NSLog(@"Userwordset Words URL: %@", urlAsString);
    
    return [NSURL URLWithString:urlAsString];
}

- (void) createOrUpdateGenericWordsetInCoreData
{
    WordsetCategory *category = [WordsetCategory wordsetCategoryWithCID:@"USER"
                                                            foreignName:@"User Wordsets"
                                                             nativeName:@"Zestawy użytkownika"
                                                 inManagedObjectContext:self.database.managedObjectContext];
    

    //we set up genericWordset with userWordset datas
    self.genericWordset = [Wordset wordsetWithWID:self.userWordset.wid
                                      foreignName:self.userWordset.foreignName
                                       nativeName:self.userWordset.nativeName
                                            level:nil
                                      description:self.userWordset.about
                                      forCategory:category
                           inManagedObjectContext:self.database.managedObjectContext];
    
}

- (NSURL *) getDeletionRequestURLForWord: (Word *) word
{
    NSLog(@"Method returning url for deletion selected word from user wordset.");
    NSString *urlAsString = @"";
    
    return [NSURL URLWithString:urlAsString];
}

- (IBAction)addWordButtonTouched:(UIBarButtonItem *)sender {
    NSLog(@"Add Word to User Wordset Button Touched.");
     
     [self performSegueWithIdentifier:@"Add Word Segue" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if([segue.destinationViewController respondsToSelector:@selector(setUserWordset:)])
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [segue.destinationViewController setUserWordset:self.userWordset]; 
    }
}


- (void)viewDidUnload {
    [self setUserwordsetWordsTableView:nil];
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
