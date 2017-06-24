//
//  MainMenuViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 21/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "MainMenuViewController.h"

@interface MainMenuViewController () {
    BOOL isShowingLandscapeView;
}

@end

@implementation MainMenuViewController

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

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    isShowingLandscapeView = NO;
    [self adjustToSreenOrientation];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
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
        if(self.view.tag == 99) {
            ///do just nothing
        } else {
            [self performSegueWithIdentifier:@"Main Menu Landscape View Segue" sender:self];
            isShowingLandscapeView = YES;
        }
    }
    
    else if (UIDeviceOrientationIsPortrait(deviceOrientation) &&
             isShowingLandscapeView && deviceOrientation != UIDeviceOrientationPortraitUpsideDown)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        isShowingLandscapeView = NO;
    }
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Main Menu Landscape View Segue"]) {
        [segue.destinationViewController setDelegate:self];
        
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - Landscape View Button Actions

- (IBAction)vocabularyButtonTouched:(UIButton *)sender {
    [self dismissModalViewControllerAnimated:YES];
    [self.delegate segueWithIdentifier:@"Wordset Categories Segue"];
}

- (IBAction)taskButtonTouched:(UIButton *)sender {
    [self dismissModalViewControllerAnimated:YES];
    [self.delegate segueWithIdentifier:@"Tasks Segue"];
}

- (IBAction)dictionaryButtonTouched:(UIButton *)sender {
    [self dismissModalViewControllerAnimated:YES];
    [self.delegate segueWithIdentifier:@"Dictionary Segue"];
}

- (IBAction)profileButtonTouched:(UIButton *)sender {
    [self dismissModalViewControllerAnimated:YES];
    [self.delegate segueWithIdentifier:@"Profile Segue"];
}

- (IBAction)forgottenButtonTouched:(UIButton *)sender {
    [self dismissModalViewControllerAnimated:YES];
    [self.delegate segueWithIdentifier:@"Forgotten Words Segue"];
}

- (IBAction)rememberMeButtonTouched:(UIButton *)sender {
    [self dismissModalViewControllerAnimated:YES];
    [self.delegate segueWithIdentifier:@"RememberMe Words Segue"];
}

- (void) segueWithIdentifier: (NSString *) identifier
{
    [self performSegueWithIdentifier:identifier sender:self];
}

@end
