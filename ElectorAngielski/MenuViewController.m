//
//  MenuViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 08/10/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "MenuViewController.h"
#import "MainContainerViewController.h"

#define LANDSCAPE_OFFSET 120.0f

@interface MenuViewController () {
    BOOL isShowingLandscape; 
}
@property (weak, nonatomic) IBOutlet UIButton *vocabularyButton;
@property (weak, nonatomic) IBOutlet UIButton *dictionaryButton;
@property (weak, nonatomic) IBOutlet UIButton *taskButton;
@property (weak, nonatomic) IBOutlet UIButton *profileButton;
@property (weak, nonatomic) IBOutlet UIButton *forgottenButton;
@property (weak, nonatomic) IBOutlet UIButton *rememberMeButton;

@end

@implementation MenuViewController

- (IBAction)vocabularyButtonTouched:(id)sender {
    [self.delegate buttonTouchedWithIdentifier: SegueIdentifierWordsetCategories];
}
- (IBAction)dictionaryButtonTouched:(id)sender {
    [self.delegate buttonTouchedWithIdentifier: SegueIdentifierDictionary];
}

- (IBAction)tasksButtonTouched:(id)sender {
    [self.delegate buttonTouchedWithIdentifier:SegueIdentifierTasks];
}
- (IBAction)profileButtonTouched:(id)sender {
     [self.delegate buttonTouchedWithIdentifier:SegueIdentifierProfile];
}
- (IBAction)forgottenButtonTouched:(id)sender {
     [self.delegate buttonTouchedWithIdentifier:SegueIdentifierForgotten];
}
- (IBAction)remembermeButtonTouched:(id)sender {
     [self.delegate buttonTouchedWithIdentifier:SegueIdentifierRememberMe];
}

- (void)awakeFromNib
{
    isShowingLandscape = NO;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
}

- (void)orientationChanged:(NSNotification *)notification
{
    [self adjustToScreenOrientation];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];

}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self adjustToScreenOrientation]; 
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
}

- (void) adjustToScreenOrientation
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation) && !isShowingLandscape) {
        
        [self moveButtonToLandscape:self.vocabularyButton];
        [self moveButtonToLandscape:self.dictionaryButton];
        [self moveButtonToLandscape:self.taskButton];
        [self moveButtonToLandscape:self.profileButton];
        [self moveButtonToLandscape:self.forgottenButton];
        [self moveButtonToLandscape:self.rememberMeButton];
        
        isShowingLandscape = YES;
        
    } else if (UIDeviceOrientationIsPortrait(deviceOrientation) && isShowingLandscape) {
        [self moveButtonToPortrait:self.vocabularyButton];
        [self moveButtonToPortrait:self.dictionaryButton];
        [self moveButtonToPortrait:self.taskButton];
        [self moveButtonToPortrait:self.profileButton];
        [self moveButtonToPortrait:self.forgottenButton];
        [self moveButtonToPortrait:self.rememberMeButton];
        
        isShowingLandscape = NO;
    }
}

- (void) moveButtonToLandscape: (UIButton*) button {
    CGRect frame;
    frame = button.frame;
    frame.origin.x += LANDSCAPE_OFFSET;
    button.frame = frame;
    NSLog(@"Adding landscape offset"); 
}

- (void) moveButtonToPortrait: (UIButton*) button {
    CGRect frame;
    frame = button.frame;
    frame.origin.x -= LANDSCAPE_OFFSET;
    button.frame = frame;
    NSLog(@"Removing landscape offset"); 
}

- (void)viewDidUnload {
        [self setVocabularyButton:nil];
        [self setDictionaryButton:nil];
        [self setTaskButton:nil];
        [self setProfileButton:nil];
        [self setForgottenButton:nil];
        [self setRememberMeButton:nil];
        [super viewDidUnload];
}

@end
