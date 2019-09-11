//
//  SolutionViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 11/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "SolutionViewController.h"
#import "Task+Create.h"
#import "UIImageView+AFNetworking.h"

@interface SolutionViewController ()
@property (weak, nonatomic) IBOutlet UILabel *taskLabel;
@property (weak, nonatomic) IBOutlet UIImageView *creatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *creatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *solutionCreationDate;
@property (weak, nonatomic) IBOutlet UILabel *solutionAuthorLabel;
@property (weak, nonatomic) IBOutlet UILabel *solutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *creationDate;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation SolutionViewController

@synthesize solution = _solution;

- (void) setSolution:(Solution *)solution
{
    NSLog(@"Setting Solution object: %@", solution.solutionId);
    
    if(_solution != solution) {
        _solution = solution;
    }
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self adjustToScreenOrientation];
}

- (void)awakeFromNib
{
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
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
        
    }  else if (UIDeviceOrientationIsPortrait(deviceOrientation) &&
                deviceOrientation != UIDeviceOrientationPortraitUpsideDown)
    {
        [self.backgroundImageView setImage:[UIImage imageNamed:@"bigben.png"]];
    }
}



- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self displayTask];
    [self displaySolution];
    
}

- (void) displayTask
{
    Task *task = self.solution.forTask;
    
    dispatch_async(dispatch_get_main_queue(), ^{
    //UI main thread!
   
    [self.taskLabel setText:task.taskText];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *stringFromDate = [formatter stringFromDate:
                                 task.creationDate];
    [self.creationDate setText: stringFromDate];
    [self.creatorLabel setText:[NSString stringWithFormat:@"~@%@ %@", task.creatorFirstName, task.creatorLastName, nil]];
    NSURL *creatorImageUrl = [NSURL URLWithString:[NSString stringWithFormat:kUSER_AVATAR_SERVICE_URL, task.creatorImage, nil]];
    [self.creatorImageView setImageWithURL:creatorImageUrl
                          placeholderImage:[UIImage imageNamed:@"blank.png"]];
        
    });
}

- (void) displaySolution
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //UI main thread!
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *stringFromDate = [formatter stringFromDate:
                                self.solution.creationDate];
    [self.solutionCreationDate setText: [NSString stringWithFormat:@"Utworzone: %@", stringFromDate, nil]];
    [self.solutionAuthorLabel setText:[NSString stringWithFormat:@"~@%@", self.solution.author, nil]];
    [self.solutionLabel setText: self.solution.content];
    [self.solutionLabel sizeToFit];
    
    }); 
    
}

- (void)viewDidUnload {
    [self setTaskLabel:nil];
    [self setCreatorImageView:nil];
    [self setCreatorLabel:nil];
    [self setSolutionCreationDate:nil];
    [self setSolutionAuthorLabel:nil];
    [self setSolutionLabel:nil];
    [self setCreationDate:nil];
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
