//
//  ProgressBarPopUpViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 25/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "ProgressBarPopUpViewController.h"

@interface ProgressBarPopUpViewController ()
@property (weak, nonatomic) IBOutlet UILabel *percentLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UIImageView *okImage;


@end

@implementation ProgressBarPopUpViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) setProgress: (CGFloat) progressInFloatPercent
{
    NSLog(@"Current progress = %g", progressInFloatPercent);
    NSLog(@"SetProgress Thread: %@", [NSThread currentThread]);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"SetProgress Main Thread: %@", [NSThread currentThread]);
        [self.progressBar setProgress:progressInFloatPercent animated:YES];
        NSNumber *number = [NSNumber numberWithFloat:100*progressInFloatPercent];
        NSString *percentString = [NSString stringWithFormat:@"%d %%", [number unsignedIntValue], nil];
        if ([number unsignedIntValue] == 100) [self.okImage setHidden:NO];
        self.percentLabel.text= percentString;
    });
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPercentLabel:nil];
    [self setProgressBar:nil];
    [self setOkImage:nil];
    [super viewDidUnload];
}
@end
