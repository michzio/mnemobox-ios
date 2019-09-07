//
//  PresentationViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 29/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "PresentationViewController.h"

@interface PresentationViewController ()

@property (weak, nonatomic) IBOutlet UILabel *foreignWordLabel;
@property (weak, nonatomic) IBOutlet UILabel *nativeWordLabel;
@property (weak, nonatomic) IBOutlet UILabel *transcriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *wordImageView;
@property (weak, nonatomic) IBOutlet UIButton *recordingButton;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIButton *badButton;
@property (weak, nonatomic) IBOutlet UIButton *normalButton;
@property (weak, nonatomic) IBOutlet UIButton *goodButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation PresentationViewController

- (void) setUpActivityIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator startAnimating];
    });
}

-(void) displayFirstWord
{
    NSLog(@"Displaying first word on the screen, currentWordIndex = %d", self.currentWordIndex); 
    if(self.currentWordIndex >= 0) return;
   
    self.currentWordIndex = 0;
    if([self.words count] <= 0) { [self emptyWordsetAlert]; return; }
    
    [self loadCurrentWordObject];
    
    [self reloadView];
     dispatch_async(dispatch_get_main_queue(), ^{
         [self.activityIndicator stopAnimating];
         [self.loadingLabel setHidden:YES]; 
         [self.transcriptionLabel setHidden: NO];
         [self.recordingButton setHidden:NO];
         [self.nativeWordLabel setHidden: NO];
         [self.foreignWordLabel setHidden:NO];
         [self.wordImageView setHidden: NO];
         [self.goodButton setHidden:NO];
         [self.normalButton setHidden:NO];
         [self.badButton setHidden:NO];
         
     });
}

- (void) reloadView
{
    dispatch_async(dispatch_get_main_queue(), ^{
         
        self.foreignWordLabel.text = [NSString stringWithFormat: @"%@ %@", self.currentWord.foreignArticle, self.currentWord.foreign];
        
        
        self.nativeWordLabel.text = [NSString stringWithFormat:@"%@ %@", self.currentWord.nativeArticle, self.currentWord.native];
       
        self.transcriptionLabel.text = self.currentWord.transcription;
        
        if(self.wordsStoredInCoreData || self.currentWord.imageLoaded) {
            [self.wordImageView setImage:self.currentWord.image];
        } else {
            [self loadImageOfWord: self.currentWord toImageView: self.wordImageView]; 
        }
        
    }); 
}

- (void) emptyWordsetAlert
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Empty Wordset" message:@"Could not find any words in wordset." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        
        [alert show];
    });
}

- (IBAction)playRecording:(UIButton *)sender {
    // button to play word recording has been touched
    NSLog(@"Play recording button touched."); 
    [self playCurrentWordAudio];
}

- (IBAction)goodButtonTouched:(UIButton *)sender {
    NSLog(@"Good Smile Button Touched.");
    [self.goodAns addObject: self.currentWord.wordId];
    [self displayNextWord]; 
}

- (IBAction)normalButtonTouched:(UIButton *)sender {
    NSLog(@"Normal Smile Button Touched.");
    [self addCurrentWordToForgottenOne];
    [self displayNextWord];
}

- (IBAction)badButtonTouched:(UIButton *)sender {
    NSLog(@"Bad Smile Button Touched.");
    [self addCurrentWordToForgottenTwo];
    [self displayNextWord];
}

- (void) displayNextWord
{
    self.currentWordIndex++;
    //if the index is out of bound, there is no more words in array so we must display ending view.
    if(self.currentWordIndex >= [self.words count]) { [self summarizeLearning]; [self displayEndView]; return; }
    
    NSLog(@"Displaying next word on the screen, currentWordIndex = %d", self.currentWordIndex);
    
    [self loadCurrentWordObject];
    
    [self reloadView];
    
}

- (void) setInBackgroundImageNamed: (NSString *) imageName
{
    [self.backgroundImageView setImage:[UIImage imageNamed:imageName]];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.learningMode = kLEARNING_MODE_PRESENTATION;
}

- (void) clearCurrentView
{
    [self.transcriptionLabel setHidden: YES];
    [self.recordingButton setHidden:YES];
    [self.nativeWordLabel setHidden: YES];
    [self.foreignWordLabel setHidden:YES];
    [self.wordImageView setHidden: YES];
    [self.goodButton setHidden:YES];
    [self.normalButton setHidden:YES];
    [self.badButton setHidden:YES];
}


- (void)viewDidUnload {
    [self setForeignWordLabel:nil];
    [self setNativeWordLabel:nil];
    [self setTranscriptionLabel:nil];
    [self setWordImageView:nil];
    [self setRecordingButton:nil];
    [self setBadButton:nil];
    [self setNormalButton:nil];
    [self setGoodButton:nil];
    [self setActivityIndicator:nil];
    [self setLoadingLabel:nil];
    [self setBackgroundImageView:nil];
    [super viewDidUnload];
}

@end
