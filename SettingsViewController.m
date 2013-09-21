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

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *preferOnlineSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *saveRecordingsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *multiplayForgottenSwitch;

@end

@implementation SettingsViewController

@synthesize preferOnlineSwitch = _preferOnlineSwitch;
@synthesize saveRecordingsSwitch = _saveRecordingsSwitch;

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
    
}

- (IBAction)signOutButtonTouched:(id)sender {

    [self performSegueWithIdentifier:@"Sign Out Segue" sender:self];
    [ProfileServices storeInUserDefaultsEmail:@"" andSHA1Password:@""];
}

- (void)viewDidUnload {
    [self setPreferOnlineSwitch:nil];
    [self setSaveRecordingsSwitch:nil];
    [self setMultiplayForgottenSwitch:nil];
    [super viewDidUnload];
}
@end
