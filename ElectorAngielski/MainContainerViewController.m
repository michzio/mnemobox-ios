//
//  MainContainerViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 08/10/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "MainContainerViewController.h"
#import "WordsetCategoriesViewController.h"
#import "TasksViewController.h"
#import "ProfileViewController.h"
#import "RememberMeWordsViewController.h"
#import "ForgottenWordsViewController.h"
#import "ProfileServices.h"

@interface MainContainerViewController ()
@property (strong, nonatomic) NSString *currentSegueIdentifier;
@property (assign, nonatomic) BOOL transitionInProgress;
@property (strong, nonatomic) WordsetCategoriesViewController *wordsetCategoriesViewController;
@property (strong, nonatomic) DictionaryViewController *dictionaryViewController;
@property (strong, nonatomic) DictionaryWordsViewController *dictionaryWordsViewController;
@property (strong, nonatomic) TasksViewController *tasksViewController;
@property (strong, nonatomic) ProfileViewController *profileViewController;
@property (strong, nonatomic) RememberMeWordsViewController *rememberMeViewController;
@property (strong, nonatomic) ForgottenWordsViewController *forgottenViewController;
@end

@implementation MainContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.currentSegueIdentifier = SegueIdentifierWordsetCategories;
    [self performSegueWithIdentifier:self.currentSegueIdentifier sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    // Instead of creating new VCs on each seque we want to hang on to existing
    // instances if we have it. Remove the second condition of the following
    // two if statements to get new VC instances instead.
    if (([segue.identifier isEqualToString:SegueIdentifierWordsetCategories]) && !self.wordsetCategoriesViewController) {
        self.wordsetCategoriesViewController = segue.destinationViewController;
    }
    
    if (([segue.identifier isEqualToString:SegueIdentifierDictionary]) && !self.dictionaryViewController) {
        self.dictionaryViewController = segue.destinationViewController;
    }
    
    if (([segue.identifier isEqualToString:SegueIdentifierDictionaryWords]) && !self.dictionaryWordsViewController) {
        self.dictionaryWordsViewController = segue.destinationViewController;
    }
    
    if (([segue.identifier isEqualToString:SegueIdentifierTasks]) && !self.tasksViewController) {
        self.tasksViewController = segue.destinationViewController;
    }
    if (([segue.identifier isEqualToString:SegueIdentifierProfile]) && !self.profileViewController) {
        self.profileViewController = segue.destinationViewController;
    }
    
    if (([segue.identifier isEqualToString:SegueIdentifierForgotten]) && !self.forgottenViewController) {
        self.forgottenViewController = segue.destinationViewController;
    }
    if (([segue.identifier isEqualToString:SegueIdentifierRememberMe]) && !self.rememberMeViewController) {
        self.rememberMeViewController = segue.destinationViewController;
    }
    
    if ([segue.identifier isEqualToString:SegueIdentifierWordsetCategories])
    {
        // If this is not the first time we're loading this.
        if (self.childViewControllers.count > 0) {
            [self swapFromViewController:[self.childViewControllers objectAtIndex:0] toViewController:self.wordsetCategoriesViewController];
        }
        else {
            // If this is the very first time we're loading this we need to do
            // an initial load and not a swap.
            [self addChildViewController:segue.destinationViewController];
            ((UIViewController *)segue.destinationViewController).view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            [self.view addSubview:((UIViewController *)segue.destinationViewController).view];
            [segue.destinationViewController didMoveToParentViewController:self];
        }
    
    }
    else if ([segue.identifier isEqualToString:SegueIdentifierDictionary])
    {
        [self swapFromViewController:[self.childViewControllers objectAtIndex:0] toViewController:self.dictionaryViewController];
        [self.dictionaryViewController setDelegate:self];
        
    } else if ([segue.identifier isEqualToString:SegueIdentifierDictionaryWords])
    {
        [self swapFromViewController:[self.childViewControllers objectAtIndex:0] toViewController:self.dictionaryWordsViewController];
        [segue.destinationViewController setDatabase: self.dictionaryViewController.database];
        [self.dictionaryWordsViewController setDelegate:self];
        
    }  else if ([segue.identifier isEqualToString:SegueIdentifierTasks])
    {
        [self swapFromViewController:[self.childViewControllers objectAtIndex:0] toViewController:self.tasksViewController];
        
    }  else if ([segue.identifier isEqualToString:SegueIdentifierProfile])
    {
        [self swapFromViewController:[self.childViewControllers objectAtIndex:0] toViewController:self.profileViewController];
        
    }  else if ([segue.identifier isEqualToString:SegueIdentifierForgotten])
    {
        [self swapFromViewController:[self.childViewControllers objectAtIndex:0] toViewController:self.forgottenViewController];
        
    }  else if ([segue.identifier isEqualToString:SegueIdentifierRememberMe])
    {
        [self swapFromViewController:[self.childViewControllers objectAtIndex:0] toViewController:self.rememberMeViewController];
        
    }
}

- (void)swapFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
{
    toViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];
    
    [self transitionFromViewController:fromViewController toViewController:toViewController duration:1.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        [fromViewController removeFromParentViewController];
        [toViewController didMoveToParentViewController:self];
        self.transitionInProgress = NO;
    }];
}

- (void)swapViewControllersWithSegueIdentifier: (NSString *) SegueIdentifier
{
    if([ProfileServices isUserSignedIn] || [SegueIdentifier isEqualToString: SegueIdentifierDictionary] || [SegueIdentifier isEqualToString:SegueIdentifierWordsetCategories] || [SegueIdentifier isEqualToString: SegueIdentifierDictionaryWords]) {
        
    
        if (self.transitionInProgress) {
            return;
        }
    
        if( self.currentSegueIdentifier != SegueIdentifier) {
            self.transitionInProgress = YES;
            self.currentSegueIdentifier =  SegueIdentifier;
            [self performSegueWithIdentifier:self.currentSegueIdentifier sender:nil];
        }
        
    } else {
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

//DictionaryViewController - DELEGATE methods:

- (void) segueToDictionaryWordsView
{
    NSLog(@"Segue To Dictionary Words View");
    [self swapViewControllersWithSegueIdentifier:SegueIdentifierDictionaryWords];
}

- (void) segueToDictionaryView
{
    NSLog(@"Segue To Dictionary View");
    [self swapViewControllersWithSegueIdentifier:SegueIdentifierDictionary];
}

@end
