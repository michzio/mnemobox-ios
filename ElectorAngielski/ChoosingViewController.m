//
//  ChoosingViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 06/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "ChoosingViewController.h"
#import "NSMutableArray+Shuffle.h"

@interface ChoosingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *foreignWordLabel;
@property (weak, nonatomic) IBOutlet UILabel *nativeWordLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UIButton *recordingButton;
@property (weak, nonatomic) IBOutlet UILabel *transcriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *answerAButton;
@property (weak, nonatomic) IBOutlet UIButton *answerBButton;
@property (weak, nonatomic) IBOutlet UIButton *answerCButton;
@property (weak, nonatomic) IBOutlet UIButton *answerDButton;
@property (weak, nonatomic) IBOutlet UIImageView *wordImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIImageView *badAnswerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *goodAnswerImageView;
@property (strong, nonatomic) NSMutableArray *allIndexesArray;
@end

@implementation ChoosingViewController

@synthesize allIndexesArray = _allIndexesArray;

- (void) setUpActivityIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator startAnimating];
    });
    
}

-(void) displayFirstWord
{
    NSLog(@"Displaying first word question on the screen, currentWordIndex = %d", self.currentWordIndex);
    if(self.currentWordIndex >= 0) return;
    
    self.currentWordIndex = 0;
    if([self.words count] <= 0) { [self emptyWordsetAlert]; return; }
    
    [self loadCurrentWordObject];
    
    [self reloadView];
    
    //makeing strong randomization of resultant array
    srandom(time(NULL));
    [self createAllIndexesArray];
    [self reloadAnswers];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating];
        [self.loadingLabel setHidden:YES];
        
        [self.questionLabel setHidden: NO];
        [self.answerAButton setHidden: NO];
        [self.answerBButton setHidden: NO];
        [self.answerCButton setHidden: NO];
        [self.answerDButton setHidden: NO];
        
        
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

- (void) createAllIndexesArray
{
    //we need to choose 3 random wrong answers other then true answer to fill buttons between all words, so we need all indexes
    self.allIndexesArray = [NSMutableArray arrayWithCapacity:[self.words count]];
    
    for(NSUInteger idx = 0; idx < [self.words count]; idx++) {
        
        [self.allIndexesArray addObject: [NSNumber numberWithUnsignedInteger:idx]];
    };

}

- (void) reloadAnswers
{
    NSLog(@"Loading possible answers... with correct one.");
    
    //creating mutable array for answer's suggestion
    NSMutableArray *answers = [NSMutableArray arrayWithCapacity:4];
   
    //putting into this array correct suggestion (answer) i.e. current word foreing string preceeded by its article
    NSString *currentForeignWordWithArticle =
    [NSString stringWithFormat:@"%@ %@", self.currentWord.foreignArticle, self.currentWord.foreign]; 
    [answers addObject: currentForeignWordWithArticle];

    //we next shuffle array of all wrong indexes
    [self.allIndexesArray shuffle];
    
    //we get first three indexes from shuffled array of wrong indexes and put words for this indexes into answers NSMutableArray
    NSUInteger idx = 0;
    NSUInteger selected = 0; 
    while( selected < 3) {
        
        if(idx > [self.allIndexesArray count]) break;
       
        NSString *wrongArticle = [[self.words objectAtIndex: [[self.allIndexesArray objectAtIndex: idx] integerValue]] foreignArticle];
        NSString *wrongWord = [[self.words objectAtIndex: [[self.allIndexesArray objectAtIndex: idx] integerValue]] foreign];
        
        NSString *wrongWordWithArticle = [NSString stringWithFormat:@"%@ %@", wrongArticle, wrongWord,nil];
        
        if(![answers containsObject: wrongWordWithArticle]) {
            [answers addObject: wrongWordWithArticle];
            selected++;
        }
        
        idx++;
        
    }
    
    //we shuffle answers in order to proper answer wouldn't always as first suggestion (answer A button) 
    [answers shuffle];
    
    //next we display this suggestions on buttons
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if([answers count] > 0) {
            [self.answerAButton setTitle: [[answers objectAtIndex:0] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]]
                        forState:UIControlStateNormal];
        } else {
            [self.answerAButton setHidden: YES]; 
        }
  
        if([answers count] > 1) {
            [self.answerBButton setTitle:[[answers objectAtIndex:1]
                                          stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]]
                        forState:UIControlStateNormal];
        } else {
            [self.answerBButton setHidden: YES];
        }
 
        if([answers count] > 2) { 
            [self.answerCButton setTitle:[[answers objectAtIndex:2]
                                          stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]]
                        forState:UIControlStateNormal];
        } else {
            [self.answerCButton setHidden: YES];
        }
        if([answers count] > 3) { 
        [self.answerDButton setTitle:[[answers objectAtIndex:3]
                                      stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]]
                        forState:UIControlStateNormal];
        } else {
            [self.answerDButton setHidden:YES];
        }
    
    });
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

- (IBAction)playRecording:(UIButton *)sender {
    NSLog(@"Play recording button touched.");
    [self playCurrentWordAudio]; 
}

- (IBAction)nextButtonTouched:(UIButton *)sender {
    NSLog(@"Next button touched.");
    /* when the next button has been touched we need
     to displayNextWord view */
    self.title = nil;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 188.0/255
                                                                        green:0.0
                                                                         blue:38.0/255
                                                                        alpha:0.7];
    [self displayNextWord];

}

- (void) displayNextWord
{
    [self.transcriptionLabel setHidden: YES];
    [self.recordingButton setHidden:YES];
    [self.nativeWordLabel setHidden: YES];
    [self.foreignWordLabel setHidden:YES];
    [self.wordImageView setHidden: YES];
    [self.goodAnswerImageView setHidden:YES];
    [self.badAnswerImageView setHidden:YES];
    [self.nextButton setHidden:YES];
    
    self.currentWordIndex++;
    //if the index is out of bound, there is no more words in array so we must display ending view.
    if(self.currentWordIndex >= [self.words count]) { [self summarizeLearning]; [self displayEndView]; return; }
    NSLog(@"Displaying next word on the screen, currentWordIndex = %d", self.currentWordIndex);
    
    [self.questionLabel setHidden: NO];
    [self.answerAButton setHidden: NO];
    [self.answerBButton setHidden: NO];
    [self.answerCButton setHidden: NO];
    [self.answerDButton setHidden: NO];
    
    [self loadCurrentWordObject];
    
    [self reloadView];
    
    [self reloadAnswers]; 
}


- (IBAction)checkUserSelectedAnswer:(UIButton *)sender {
    NSLog(@"Method checking answer selected by user: %@", sender.titleLabel.text);
    [self checkUserAnswer: sender.titleLabel.text];
}

- (void) checkUserAnswer: (NSString *) answer
{
    dispatch_async(dispatch_get_main_queue(), ^{
    [self.questionLabel setHidden: YES];
    [self.answerAButton setHidden: YES];
    [self.answerBButton setHidden: YES];
    [self.answerCButton setHidden: YES];
    [self.answerDButton setHidden: YES];
    
    [self.transcriptionLabel setHidden: NO];
    [self.recordingButton setHidden:NO];
    [self.nativeWordLabel setHidden: NO];
    [self.foreignWordLabel setHidden:NO];
    [self.wordImageView setHidden: NO];
    [self.nextButton setHidden: NO];
        
    //adding user answer to pullUp in order to user can check it
    self.userAnswerLabel.text = answer;
    });
    
    NSString *lowercaseAnswer = answer.lowercaseString;
   
    NSString *foreign = self.currentWord.foreign.lowercaseString;
    NSString *foreignWithArticle = [NSString stringWithFormat:@"%@ %@",
                                    self.currentWord.foreignArticle.lowercaseString,
                                    foreign, nil];
    [self playCurrentWordAudio];
    
    if( [lowercaseAnswer isEqualToString:foreign] || [lowercaseAnswer isEqualToString:foreignWithArticle]) {
        NSLog(@"Answer: %@ is in accordance with: %@", lowercaseAnswer, foreignWithArticle);
        [self answerHasBeenGood];
    } else {
        NSLog(@"Answer: %@ is not correct. Should be: %@", lowercaseAnswer, foreignWithArticle);
        [self answerHasBeenBad];
    }
    
}

- (void) answerHasBeenGood
{
    [self.goodAnswerImageView setHidden:NO];
    [self.goodAns addObject:self.currentWord.wordId];
    self.title = @"GOOD";
    self.userAnswerLabel.textColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 9/255.0
                                                                        green:97/255.0
                                                                         blue:33/255.0
                                                                        alpha:0.7];
    
}

- (void) answerHasBeenBad
{
    [self.badAnswerImageView setHidden: NO];
    self.title = @"BAD";
    self.userAnswerLabel.textColor = [UIColor redColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 188.0/255
                                                                        green:0.0
                                                                         blue:38.0/255
                                                                        alpha:0.7];
    
    
    [self addCurrentWordToForgottenOne];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.learningMode = kLEARNING_MODE_CHOOSING;
}
- (void) viewWillDisappear:(BOOL)animated
{
    self.title = nil;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 188.0/255
                                                                        green:0.0
                                                                         blue:38.0/255
                                                                        alpha:0.7];
}


- (void) clearCurrentView
{
    [self.transcriptionLabel setHidden: YES];
    [self.recordingButton setHidden:YES];
    [self.nativeWordLabel setHidden: YES];
    [self.foreignWordLabel setHidden:YES];
    [self.wordImageView setHidden: YES];
    [self.goodAnswerImageView setHidden:YES];
    [self.nextButton setHidden:YES];
    [self.badAnswerImageView setHidden:YES];
    [self.questionLabel setHidden: YES];
    [self.answerAButton setHidden: YES];
    [self.answerBButton setHidden: YES];
    [self.answerCButton setHidden: YES];
    [self.answerDButton setHidden: YES];
    
    self.title = nil;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 188.0/255
                                                                        green:0.0
                                                                         blue:38.0/255
                                                                        alpha:0.7];
}



- (void)viewDidUnload {
    [self setForeignWordLabel:nil];
    [self setQuestionLabel:nil];
    [self setNativeWordLabel:nil];
    [self setRecordingButton:nil];
    [self setTranscriptionLabel:nil];
    [self setAnswerAButton:nil];
    [self setAnswerBButton:nil];
    [self setAnswerCButton:nil];
    [self setAnswerDButton:nil];
    [self setWordImageView:nil];
    [self setActivityIndicator:nil];
    [self setLoadingLabel:nil];
    [self setNextButton:nil];
    [self setBadAnswerImageView:nil];
    [self setGoodAnswerImageView:nil];
    [super viewDidUnload];
}
@end
