//
//  iPadMainMenuViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 08/10/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "iPadMainMenuViewController.h"
#import "MainContainerViewController.h"

#import "MenuViewController.h"


@interface iPadMainMenuViewController ()
@property (nonatomic, strong) MainContainerViewController *containerViewController;
@property (nonatomic, strong) MenuViewController *menuViewController;
@end

@implementation iPadMainMenuViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Detail Container Segue"]) {
        self.containerViewController = segue.destinationViewController;
    } else if([segue.identifier isEqualToString:@"Menu Container Segue"]) {
        [segue.destinationViewController setDelegate:self];
    }
}

- (void)buttonTouchedWithIdentifier:(NSString *)buttonIdentifier
{
    [self.containerViewController swapViewControllersWithSegueIdentifier:buttonIdentifier];
}

- (void) viewDidLoad  {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}

- (void)viewDidUnload {
    [self setDetailContainer:nil];
    [self setMenuContainer:nil];
    [super viewDidUnload];
}
@end
