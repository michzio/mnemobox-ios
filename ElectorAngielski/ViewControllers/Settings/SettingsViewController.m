//
//  SettingsViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 20/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "SettingsViewController.h"
#import "ProfileServices.h"
#import "UserSettings.h"


#define IDIOM UI_USER_INTERFACE_IDIOM()
#define IPAD UIUserInterfaceIdiomPad
@interface SettingsViewController () {
    BOOL isShowingLandscapeView;
}

@property (weak, nonatomic) IBOutlet UISwitch *preferOnlineSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *saveRecordingsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *multiplayForgottenSwitch;

@end

@implementation SettingsViewController

@synthesize preferOnlineSwitch = _preferOnlineSwitch;
@synthesize saveRecordingsSwitch = _saveRecordingsSwitch;
@synthesize delegate = _delegate;

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self adjustToSreenOrientation];
}


- (void)awakeFromNib
{
    
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
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation) &&
        !isShowingLandscapeView)
    {
        if(IDIOM == IPAD) {
            isShowingLandscapeView = YES;
            NSLog(@"Ipad Landscape"); 
        } else {
            if(self.view.tag == 99) {
                ///do just nothing
                NSLog(@"Do nothing"); 
            } else {
                NSLog(@"Iphone Landscape"); 
                [self performSegueWithIdentifier:@"Landscape View Segue" sender:self];
                isShowingLandscapeView = YES;
            }
        }
    } else if (UIDeviceOrientationIsPortrait(deviceOrientation) &&
               isShowingLandscapeView && deviceOrientation != UIDeviceOrientationPortraitUpsideDown)
    {
        if(IDIOM == IPAD) {
            isShowingLandscapeView = NO;
            NSLog(@"Ipad Portrait."); 
        } else {
            NSLog(@"Dismissing Landscape View."); 
            [self dismissViewControllerAnimated:YES completion:nil];
            isShowingLandscapeView = NO;
        }
        
    }
    NSLog(@"Screen rotation"); 
    
}


- (void) viewDidAppear:(BOOL)animated
{
    self.preferOnlineSwitch.on = [UserSettings prefereToUseWordsViaWebServices];
    self.saveRecordingsSwitch.on = [UserSettings recordingsAreSavedOnPhone];
    self.multiplayForgottenSwitch.on = [UserSettings userWantsToMultiplayForgottenWords];
}

- (IBAction)preferOnlineWordsetsSwiched:(UISwitch *)sender {
    [UserSettings setPreferencesToUserWordsViaWebServices:sender.on];
}
- (IBAction)multiplayForgottenSwitched:(UISwitch *)sender {
    [UserSettings setUserWantsToMultiplayForgottenWords:sender.on];
}

- (IBAction)saveRecordingsOnPhoneSwiched:(UISwitch *)sender {
    
    [UserSettings setToSaveRecordingsOnPhone: sender.on];
}

- (IBAction)clearWordsData:(id)sender {
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent: @"Wordset Database"];
    UIManagedDocument *databaseDocument = [[UIManagedDocument alloc] initWithFileURL:url];
     if([[NSFileManager defaultManager] fileExistsAtPath: [databaseDocument.fileURL path]]) {
         /* document exists at path we can delete it */
         NSError *error;
         [[NSFileManager defaultManager] removeItemAtPath:[databaseDocument.fileURL path] error:&error];
         if(error == nil) {
             NSLog(@"Wordset Database has been deleted.");
             //!!!! WE COULD ALSO DELETE RECORDING IF THEY ARE STORED ON PHONE STORAGE !!!!!
         } else {
             NSLog(@"An error has occured while deleting database: %@", error); 
         }
     }
    
    //deleting audio recordings from Documents/audio folder on disk
    NSFileManager *fm = [NSFileManager defaultManager];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *audioFolderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"audio"];
    NSLog(@"Audio Folder Path: %@", audioFolderPath);
    
    NSError *error = nil;
    for (NSString *audioFile in [fm contentsOfDirectoryAtPath:audioFolderPath error:&error]) {
        BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", audioFolderPath, audioFile] error:&error];
        if (!success || error) {
            // it failed.
            NSLog(@"Deleted audio file: %@", audioFile); 
        }
    }
    
}

- (void)modalViewControllerDismissed:(SettingsViewController *)modalViewController
{
     [ProfileServices storeInUserDefaultsEmail:@"" andSHA1Password:@""];
    [self performSegueWithIdentifier:@"Sign Out Segue" sender:self];
}

- (IBAction)signOutButtonTouched:(id)sender {

    [ProfileServices storeInUserDefaultsEmail:@"" andSHA1Password:@""];
    if(self.view.tag == 99) {
        [self.delegate modalViewControllerDismissed:self];
        [self dismissModalViewControllerAnimated:NO]; 
    } else { 
        [self performSegueWithIdentifier:@"Sign Out Segue" sender:self];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Landscape View Segue"]) {
        [segue.destinationViewController setDelegate:self];
    }
}

- (void)viewDidUnload {
    [self setPreferOnlineSwitch:nil];
    [self setSaveRecordingsSwitch:nil];
    [self setMultiplayForgottenSwitch:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
