//
//  iPadiOS5MainMenuViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 16/10/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "iPadiOS5MainMenuViewController.h"
#import "MainContainerViewController.h"

#import "MenuViewController.h"

@interface iPadiOS5MainMenuViewController () {
    BOOL isShowingLandscape;
}
@property (nonatomic, strong) MainContainerViewController *containerViewController;
@property (nonatomic, strong) MenuViewController *menuViewController;
@end

@implementation iPadiOS5MainMenuViewController

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
    NSLog(@"iOS5 Main View");
    
     [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    
    self.containerViewController = [storyBoard instantiateViewControllerWithIdentifier:@"MainContainerViewController"];
    
    self.menuViewController = [storyBoard instantiateViewControllerWithIdentifier:@"MenuViewController"];
    [self.menuViewController setDelegate:self];
        
        [self addChildViewController:self.containerViewController];
        [self addChildViewController:self.menuViewController];
        
        [self.detailContainer addSubview:self.containerViewController.view];
        [self.menuContainer addSubview:self.menuViewController.view];
        
        self.containerViewController.view.frame = self.detailContainer.bounds;
        self.menuViewController.view.frame = self.menuContainer.bounds;
        
}

- (void)buttonTouchedWithIdentifier:(NSString *)buttonIdentifier
{
    [self.containerViewController swapViewControllersWithSegueIdentifier:buttonIdentifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setDetailContainer:nil];
    [self setMenuContainer:nil];
    [super viewDidUnload];
}

- (void)awakeFromNib
{
    isShowingLandscape = NO;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self adjustToScreenOrientation];
}

- (void)orientationChanged:(NSNotification *)notification
{
    [self adjustToScreenOrientation];
}

- (void) adjustToScreenOrientation
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation) && !isShowingLandscape) {
       
        self.containerViewController.view.frame = self.detailContainer.bounds;
        self.menuViewController.view.frame = self.menuContainer.bounds;
        isShowingLandscape = YES;
        
    } else if (UIDeviceOrientationIsPortrait(deviceOrientation) && isShowingLandscape) {
        
        self.containerViewController.view.frame = self.detailContainer.bounds;
        self.menuViewController.view.frame = self.menuContainer.bounds;
        isShowingLandscape = NO;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return ((toInterfaceOrientation == UIInterfaceOrientationPortrait) || (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

@end
