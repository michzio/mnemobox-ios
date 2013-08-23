//
//  WordsetViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 23/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "WordsetViewController.h"

@interface WordsetViewController ()
@property (weak, nonatomic) IBOutlet UILabel *foreignNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nativeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation WordsetViewController

@synthesize wordset = _wordset;

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
    self.foreignNameLabel.text = self.wordset.foreignName;
    self.nativeNameLabel.text = self.wordset.nativeName;
    self.levelLabel.text = self.wordset.level;
    self.descriptionLabel.text = self.wordset.about;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setForeignNameLabel:nil];
    [self setNativeNameLabel:nil];
    [self setLevelLabel:nil];
    [self setDescriptionLabel:nil];
    [super viewDidUnload];
}
@end
