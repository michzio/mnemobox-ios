//
//  ListeningViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 05/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "ListeningViewController.h"

@interface ListeningViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *wordImageView;
@property (weak, nonatomic) IBOutlet UILabel *transcriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *foreignWordLabel;
@property (weak, nonatomic) IBOutlet UILabel *nativeWordLabel;
@property (weak, nonatomic) IBOutlet UITextField *foreignAnswerTextField;
@property (weak, nonatomic) IBOutlet UITextField *nativeAnswerTextField;
@property (weak, nonatomic) IBOutlet UIButton *listenRecordingButton;
@property (weak, nonatomic) IBOutlet UIButton *hintButton;
@property (weak, nonatomic) IBOutlet UIButton *recordingButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIImageView *badAnswerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *goodAnswerImageView;

@end

@implementation ListeningViewController

- (void) setUpActivityIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator startAnimating];
    });
}
- (IBAction)recordingButtonTouched:(UIButton *)sender {
    NSLog(@"Recording button touched.");
    [self playCurrentWordAudio]; 
}
- (IBAction)listenRecordingButtonTouched:(UIButton *)sender {
    NSLog(@"Listen recording button touched.");
    [self playCurrentWordAudio];
}
- (IBAction)hintButtonTouched:(UIButton *)sender {
    NSLog(@"Hint Button Touched");
    self.hintButton.enabled = NO;
    [self.hintButton setTitle:self.currentWord.transcription forState:UIControlStateDisabled];
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
        
        [self.foreignAnswerTextField setHidden: NO];
        [self.foreignAnswerTextField becomeFirstResponder];
        self.foreignAnswerTextField.delegate = self;
        
        [self.nativeAnswerTextField setHidden: NO];
        [self.nativeAnswerTextField becomeFirstResponder];
        self.nativeAnswerTextField.delegate = self;
        
        [self.listenRecordingButton setHidden:NO];
        [self.hintButton setHidden:NO];
        
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

- (void) reloadView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        /* self.questionLabel.text = [NSString stringWithFormat: @"%@ %@", self.currentWord.nativeArticle, self.currentWord.native]; */
        
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

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    //checking user answer against listening question
    //and next displaying current word view
    NSLog(@"Checking user answer against word question on return key.");
    if([self.foreignAnswerTextField.text length] > 0
       && [self.nativeAnswerTextField.text length] > 0) {
        [self checkUserAnswer];
        [textField resignFirstResponder];
        return YES;
    }
    return NO; 
}

- (void) checkUserAnswer
{
    NSLog(@"Checking user answer...");
    
    self.hintButton.enabled = YES;
    [self.hintButton setHidden:YES];
    
    [self.listenRecordingButton setHidden: YES];
    [self.foreignAnswerTextField setHidden: YES];
    [self.nativeAnswerTextField setHidden:YES];
    
    [self.foreignWordLabel setHidden:NO];
    [self.nativeWordLabel setHidden: NO];
    [self.transcriptionLabel setHidden: NO];
    [self.recordingButton setHidden:NO];
    [self.wordImageView setHidden: NO];
    [self.nextButton setHidden: NO];
    
    NSString *foreignAnswer = self.foreignAnswerTextField.text.lowercaseString;
    NSString *foreign = self.currentWord.foreign.lowercaseString;
    NSString *foreignWithArticle = [NSString stringWithFormat:@"%@ %@",
                                    self.currentWord.foreignArticle.lowercaseString,
                                    foreign, nil];
    
    NSString *nativeAnswer = self.nativeAnswerTextField.text.lowercaseString;
    NSString *native = self.currentWord.native.lowercaseString;
    NSString *nativeWithArticle = [NSString stringWithFormat:@"%@ %@",
                                    self.currentWord.nativeArticle.lowercaseString,
                                    native, nil];
    [self playCurrentWordAudio];
    
    if(([foreignAnswer isEqualToString:foreign] || [foreignAnswer isEqualToString:foreignWithArticle]) && ([nativeAnswer isEqualToString:native] || [nativeAnswer isEqualToString:nativeWithArticle]))
    {
        NSLog(@"Answer: %@ - %@ is in accordance with: %@ - %@", foreignAnswer, nativeAnswer, foreignWithArticle, nativeWithArticle);
        [self answerHasBeenGood];
    } else {
        NSLog(@"Answer: %@ = %@ is not correct. Should be: %@ - %@", foreignAnswer, nativeAnswer, foreignWithArticle, nativeWithArticle);
        [self answerHasBeenBad]; 
    }
    
    
}

- (void) answerHasBeenGood
{
    [self.goodAnswerImageView setHidden:NO];
    [self.goodAns addObject:self.currentWord.wordId];
    self.title = @"GOOD";
    self.userAnswerLabel.text = [NSString stringWithFormat:@"%@ - %@", self.foreignAnswerTextField.text, self.nativeAnswerTextField.text];
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
    self.userAnswerLabel.text = [NSString stringWithFormat:@"%@ - %@", self.foreignAnswerTextField.text, self.nativeAnswerTextField.text];
    self.userAnswerLabel.textColor = [UIColor redColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 188.0/255
                                                                        green:0.0
                                                                         blue:38.0/255
                                                                        alpha:0.7];
    
    
    [self addCurrentWordToForgottenOne];
    
}

- (IBAction)nextButtonTouched:(UIButton *)sender {
    NSLog(@"Next Button has been touched.");
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
    [self.listenRecordingButton setHidden: NO];
   
    [self.nativeAnswerTextField setHidden: NO];
    self.nativeAnswerTextField.text = nil;
    
    [self.foreignAnswerTextField setHidden: NO];
    [self.foreignAnswerTextField becomeFirstResponder];
    self.foreignAnswerTextField.text = nil;
    
    [self.hintButton setHidden: NO]; 
    
    
    self.currentWordIndex++;
    //if the index is out of bound, there is no more words in array so we must display ending view.
    if(self.currentWordIndex >= [self.words count]) { [self summarizeLearning]; [self displayEndView]; return; }
    NSLog(@"Displaying next word on the screen, currentWordIndex = %d", self.currentWordIndex);
    [self loadCurrentWordObject];
    
    [self reloadView];
    
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
    [self.listenRecordingButton setHidden: YES];
    [self.foreignAnswerTextField setHidden: YES];
    [self.nativeAnswerTextField setHidden: YES];
    [self.hintButton setHidden:YES];

    
    [self.foreignAnswerTextField resignFirstResponder];
    self.foreignAnswerTextField.text = nil;
    [self.nativeAnswerTextField resignFirstResponder];
    self.nativeAnswerTextField.text = nil;
    
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


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.learningMode = kLEARNING_MODE_LISTENING;
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
    [self setActivityIndicator:nil];
    [self setLoadingLabel:nil];
    [self setWordImageView:nil];
    [self setTranscriptionLabel:nil];
    [self setForeignWordLabel:nil];
    [self setNativeWordLabel:nil];
    [self setForeignAnswerTextField:nil];
    [self setNativeAnswerTextField:nil];
    [self setListenRecordingButton:nil];
    [self setHintButton:nil];
    [self setRecordingButton:nil];
    [self setNextButton:nil];
    [self setBadAnswerImageView:nil];
    [self setGoodAnswerImageView:nil];
    [super viewDidUnload];
}
@end
