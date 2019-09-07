//
//  RepetitionViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 30/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "RepetitionViewController.h"
#import "NSString+Utilities.h"

@interface RepetitionViewController ()
@property (weak, nonatomic) IBOutlet UILabel *foreignWordLabel;
@property (weak, nonatomic) IBOutlet UILabel *nativeWordLabel;
@property (weak, nonatomic) IBOutlet UILabel *transcriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *recordingButton;
@property (weak, nonatomic) IBOutlet UIImageView *wordImageView;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITextField *answerTextField;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;

@property (weak, nonatomic) IBOutlet UIImageView *goodAnswerImage;
@property (weak, nonatomic) IBOutlet UIImageView *badAnswerImage;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation RepetitionViewController

- (void) setUpActivityIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator startAnimating];
    });
}

- (void) setInBackgroundImageNamed: (NSString *) imageName
{
    [self.backgroundImageView setImage:[UIImage imageNamed:imageName]];
    
}

-(void) displayFirstWord
{
    NSLog(@"Displaying first word question on the screen, currentWordIndex = %d", self.currentWordIndex);
    if(self.currentWordIndex >= 0) return;
    
    self.currentWordIndex = 0;
    if([self.words count] <= 0) { [self emptyWordsetAlert]; return; }
    
    [self loadCurrentWordObject];
    
    [self reloadView];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating];
        [self.loadingLabel setHidden:YES];
        [self.questionLabel setHidden: NO];
        [self.answerTextField setHidden: NO];
        
        [self.answerTextField becomeFirstResponder];
        self.answerTextField.delegate = self;
        
        UILabel *answerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 100, 64)];
        answerTitleLabel.textAlignment = UITextAlignmentLeft;
        answerTitleLabel.backgroundColor = [UIColor clearColor];
        answerTitleLabel.textColor = [UIColor whiteColor];
        answerTitleLabel.text = @"Twoja Odpowiedź:";
        answerTitleLabel.adjustsFontSizeToFitWidth = YES;
        answerTitleLabel.font = [UIFont systemFontOfSize:15.0];
        
        [self.pullUpView addSubview:answerTitleLabel];
        
        self.userAnswerLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 5, 220, 64)];
        self.userAnswerLabel.textAlignment = UITextAlignmentLeft;
        self.userAnswerLabel.backgroundColor = [UIColor clearColor];
        self.userAnswerLabel.textColor = [UIColor whiteColor];
        self.userAnswerLabel.text = @"brak";
        self.userAnswerLabel.adjustsFontSizeToFitWidth = YES;
        self.userAnswerLabel.font = [UIFont boldSystemFontOfSize:15.0];
        
        [self.pullUpView addSubview:self.userAnswerLabel];
        
        
    });
}

- (void) displayNextWord
{
    [self.transcriptionLabel setHidden: YES];
    [self.recordingButton setHidden:YES];
    [self.nativeWordLabel setHidden: YES];
    [self.foreignWordLabel setHidden:YES];
    [self.wordImageView setHidden: YES];
    [self.goodAnswerImage setHidden:YES];
    [self.badAnswerImage setHidden:YES];
    [self.nextButton setHidden:YES];
    [self.questionLabel setHidden: NO];
    [self.answerTextField setHidden: NO];
    
    [self.answerTextField becomeFirstResponder];
    self.answerTextField.text = nil;
    
    
    self.currentWordIndex++;
    //if the index is out of bound, there is no more words in array so we must display ending view.
     if(self.currentWordIndex >= [self.words count]) { [self summarizeLearning]; [self displayEndView]; return; }
    NSLog(@"Displaying next word on the screen, currentWordIndex = %d", self.currentWordIndex);
    [self loadCurrentWordObject];
    
    [self reloadView];
    
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    //checking user answer against word question
    //and next displaying current word view
    NSLog(@"Checking user answer against word question on return key."); 
    [self checkUserAnswer];
    [textField resignFirstResponder];
    return YES;
}

- (void) checkUserAnswer
{
    [self.questionLabel setHidden: YES];
    [self.answerTextField setHidden: YES];
    
    [self.transcriptionLabel setHidden: NO];
    [self.recordingButton setHidden:NO];
    [self.nativeWordLabel setHidden: NO];
    [self.foreignWordLabel setHidden:NO];
    [self.wordImageView setHidden: NO];
    [self.nextButton setHidden: NO];
    
    NSString *answer = self.answerTextField.text.lowercaseString;
    NSString *foreign = self.currentWord.foreign.lowercaseString;
    NSString *foreignWithArticle = [NSString stringWithFormat:@"%@ %@",
                                    self.currentWord.foreignArticle.lowercaseString,
                                    foreign, nil]; 
    [self playCurrentWordAudio];
    
    if( [answer isEqualToString:foreign] || [answer isEqualToString:foreignWithArticle]) {
        NSLog(@"Answer: %@ is in accordance with: %@", answer, foreignWithArticle);
        [self answerHasBeenGood];
    } else {
        NSLog(@"Answer: %@ is not correct. Should be: %@", answer, foreignWithArticle);
        [self answerHasBeenBad]; 
    }
    
    /*
    [self.goodButton setHidden:NO];
    [self.badButton setHidden:NO];
     */
}

- (void) answerHasBeenGood
{
    [self.goodAnswerImage setHidden:NO];
    [self.goodAns addObject:self.currentWord.wordId];
    self.title = @"GOOD";
    self.userAnswerLabel.text = self.answerTextField.text;
    self.userAnswerLabel.textColor = [UIColor whiteColor];
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 9/255.0
                                                                        green:97/255.0
                                                                         blue:33/255.0
                                                                        alpha:0.7];

}

- (void) answerHasBeenBad
{
    [self.badAnswerImage setHidden: NO];
    self.title = @"BAD";
    self.userAnswerLabel.text = self.answerTextField.text;
    self.userAnswerLabel.textColor = [UIColor redColor]; 
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 188.0/255
                                                                        green:0.0
                                                                         blue:38.0/255
                                                                        alpha:0.7];
    

    [self addCurrentWordToForgottenOne];
}

- (IBAction)nextButtonTouched:(UIButton *)sender {
    /* when the next button has been touched we need 
     to displayNextWord view */
    self.title = nil; 
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 188.0/255
                                                                        green:0.0
                                                                         blue:38.0/255
                                                                        alpha:0.7];
    [self displayNextWord]; 
}

- (IBAction)playRecording:(UIButton *)sender {
    // button to play word recording has been touched
    NSLog(@"Play recording button touched.");
    [self playCurrentWordAudio];
}

- (void) reloadView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.questionLabel.text = [NSString stringWithFormat: @"%@ %@", self.currentWord.nativeArticle, self.currentWord.native];
        
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

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.learningMode = kLEARNING_MODE_REPETITION;
}

- (void) clearCurrentView
{
    [self.transcriptionLabel setHidden: YES];
    [self.recordingButton setHidden:YES];
    [self.nativeWordLabel setHidden: YES];
    [self.foreignWordLabel setHidden:YES];
    [self.wordImageView setHidden: YES];
    [self.goodAnswerImage setHidden:YES];
    [self.nextButton setHidden:YES];
    [self.badAnswerImage setHidden:YES];
    [self.questionLabel setHidden: YES];
    [self.answerTextField setHidden: YES];
    
    [self.answerTextField resignFirstResponder];
    self.answerTextField.text = nil;
    
    self.title = nil; 
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 188.0/255
                                                                        green:0.0
                                                                         blue:38.0/255
                                                                        alpha:0.7];
}

- (void) viewWillDisappear:(BOOL)animated
{
    self.title = nil;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 188.0/255
                                                                        green:0.0
                                                                         blue:38.0/255
                                                                        alpha:0.7];
}

- (void)viewDidUnload {
    [self setForeignWordLabel:nil];
    [self setNativeWordLabel:nil];
    [self setTranscriptionLabel:nil];
    [self setRecordingButton:nil];
    [self setWordImageView:nil];
    [self setLoadingLabel:nil];
    [self setActivityIndicator:nil];
    [self setAnswerTextField:nil];
    [self setQuestionLabel:nil];

    [self setGoodAnswerImage:nil];
    [self setBadAnswerImage:nil];
    [self setNextButton:nil];
    [self setBackgroundImageView:nil];
    [super viewDidUnload];
}
@end
