//
//  RememberMePopUpViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 02/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "RememberMePopUpViewController.h"

@interface RememberMePopUpViewController ()


@end

@implementation RememberMePopUpViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPopUpLabel:nil];
    [self setPopUpImageView:nil];
    [self setPopUpErrorImageView:nil];
    [super viewDidUnload];
}
@end
