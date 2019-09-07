//
//  SpeakingViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 02/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "SpeakingViewController.h"
#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OEAcousticModel.h>
#import <OpenEars/OEPocketsphinxController.h>
#import <Slt/Slt.h>
#import <OpenEars/OEFliteController.h>
#import <OpenEars/OELogging.h>
#import "NSObject+PerformBlockAfterDelay.h"

@interface SpeakingViewController ()
{
    OEPocketsphinxController *pocketsphinxController;
    OEFliteController *fliteController;
    Slt *slt;
    NSString *lmPath;
    NSString *dicPath;
    BOOL detectingSpeech;
    NSTimer *myTimer;
}
@property (strong, nonatomic) OEPocketsphinxController *pocketsphinxController;
@property (strong, nonatomic) OEFliteController *fliteController;
@property (strong, nonatomic) Slt *slt;

//User Interface Element Outlets
@property (weak, nonatomic) IBOutlet UILabel *foreignLabel;
@property (weak, nonatomic) IBOutlet UILabel *nativeLabel;
@property (weak, nonatomic) IBOutlet UILabel *transcriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *wordImageView;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *goodAnswerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *badAnswerImageView;
@property (weak, nonatomic) IBOutlet UIButton *recordingOffButton;

@property (weak, nonatomic) IBOutlet UIImageView *recordingOnImageView;
@property (weak, nonatomic) IBOutlet UIButton *audioButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation SpeakingViewController

@synthesize fliteController;
@synthesize slt;
@synthesize pocketsphinxController;
@synthesize openEarsEventsObserver;

- (void) setInBackgroundImageNamed: (NSString *) imageName
{
    [self.backgroundImageView setImage:[UIImage imageNamed:imageName]];
    
}

//lazy accessor for confident memory management of the object
- (OEPocketsphinxController *) pocketsphinxController {
	if (pocketsphinxController == nil) {
        pocketsphinxController = [OEPocketsphinxController sharedInstance];
        [pocketsphinxController setActive:TRUE error:nil];
	}
	return pocketsphinxController;
}
- (OEEventsObserver *)openEarsEventsObserver {
	if (openEarsEventsObserver == nil) {
        openEarsEventsObserver = [[OEEventsObserver alloc] init];
	}
	return openEarsEventsObserver;
}
- (OEFliteController *)fliteController {
	if (fliteController == nil) {
		fliteController = [[OEFliteController alloc] init];
	}
	return fliteController;
}

- (Slt *)slt {
	if (slt == nil) {
		slt = [[Slt alloc] init];
	}
	return slt;
}

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
    
    //set delegate for OpenEarsEventsObserver'a 
    [self.openEarsEventsObserver setDelegate:self];
    
    //to test text-to-speech?
    //[self.fliteController say:@"A short statement" withVoice:self.slt];
    [OELogging startOpenEarsLogging];
}

- (void) setUpLanguageModel
{
    
    //lmPath = [[NSBundle mainBundle] pathForResource:@"WordsetLanguageModelFile" ofType:@"arpa"];
    //dicPath = [[NSBundle mainBundle] pathForResource:@"WordsetLanguageModelFile" ofType:@"dic"];
    
    OELanguageModelGenerator *lmGenerator = [[OELanguageModelGenerator alloc] init];
    //List of words we want to recognize using speech recognition api, for offline speech recognition
    //it is adviced to use between 3 to 300 words -> so we add to this array all words in given wordset
    // ex. NSArray *words = [NSArray arrayWithObjects:@"WORD", @"STATEMENT", @"OTHER WORD", @"A PHRASE", nil];
    __block NSMutableArray *wordsArrayForModel = [[NSMutableArray alloc] init];
   
    [self.words enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSString *foreignWordWithArticle = nil;
        
        if(self.wordsStoredInCoreData) {
            //we have Word objects saved in Core Data in self.words array
            Word *wordObject = (Word *) obj;
            foreignWordWithArticle = [NSString stringWithFormat:@"%@ %@", wordObject.foreignArticle, wordObject.foreign, nil]; 
        } else {
            //we have WordObject objects retrieved remotly from web services
            WordObject *wordObject = (WordObject *) obj;
            foreignWordWithArticle = [NSString stringWithFormat:@"%@ %@", wordObject.foreignArticle, wordObject.foreign, nil];
        }
        //we remove any white spaces from left or right but not from the middle
        //this white spaces could happen possibly if word hasn't have article?
        //it's not sure we do this to ensure such possibilities
        NSString *trimmedWord = [foreignWordWithArticle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *uppercaseWord = [trimmedWord uppercaseString];
        
        [wordsArrayForModel addObject: uppercaseWord];
    }];
    

    //Name I want for my language model files
    NSString *name = [NSString stringWithFormat: @"WordsetLanguageModel%@", self.wordset.wid, nil];
    
    // Change "AcousticModelEnglish" to "AcousticModelSpanish" to create a Spanish language model instead of an English one.
    NSError *err = [lmGenerator generateLanguageModelFromArray:wordsArrayForModel withFilesNamed:name forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]];

    
    NSDictionary *languageGeneratorResults = nil;
    
    if([err code] == noErr) {
        
        languageGeneratorResults = [err userInfo];
		
        lmPath = [languageGeneratorResults objectForKey:@"LMPath"];
        dicPath = [languageGeneratorResults objectForKey:@"DictionaryPath"];
		
    } else {
        NSLog(@"Error: %@",[err localizedDescription]);
    }
 
    
    // Change "AcousticModelEnglish" to "AcousticModelSpanish" to perform Spanish recognition instead of English.
    [self.pocketsphinxController startListeningWithLanguageModelAtPath:lmPath dictionaryAtPath:dicPath acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO];
    self.pocketsphinxController.verbosePocketSphinx = YES;
    //we use BOOL variable to test whether system is now in speech detecting mode or not because pocketsphinxController calibration takes too much time
    detectingSpeech = NO;
   
}

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    if(detectingSpeech) {
        [myTimer invalidate];
        detectingSpeech = NO;
        [self.pocketsphinxController suspendRecognition];
        NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
        NSString *upercaseWord = [self.currentWord.foreign uppercaseString];
        NSString *upercaseWordWithArticle = [[NSString stringWithFormat:@"%@ %@", self.currentWord.foreignArticle, self.currentWord.foreign, nil] uppercaseString];
        if([hypothesis isEqualToString: upercaseWord] || [hypothesis isEqualToString: upercaseWordWithArticle] ) {
            NSLog(@"User speak correctly current word");
            [self answerHasBeenGood];
        } else {
            NSLog(@"User speak incorreclty current word");
            [self answerHasBeenBad];
        }
        [self displayAnswerView]; 
    }
}

- (void) answerHasBeenGood
{
    [self.goodAnswerImageView setHidden:NO];
    [self.goodAns addObject:self.currentWord.wordId];
    self.title = @"GOOD";
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 9/255.0
                                                                        green:97/255.0
                                                                         blue:33/255.0
                                                                        alpha:0.7];
}

- (void) answerHasBeenBad
{
    [self.badAnswerImageView setHidden: NO];
    self.title = @"BAD";
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 188.0/255
                                                                        green:0.0
                                                                         blue:38.0/255
                                                                        alpha:0.7];
    
    
    [self addCurrentWordToForgottenOne];
}

- (void) displayAnswerView
{
    [self.recordingOnImageView setHidden:YES];
    [self.recordingOffButton setHidden: YES]; 
    [self.nativeLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
    [self.transcriptionLabel setHidden: NO];
    [self.audioButton setHidden:NO];
    [self.nativeLabel setHidden: NO];
    [self.foreignLabel setHidden:NO];
    [self.wordImageView setHidden: NO];
    [self.nextButton setHidden: NO];
    [self.pullUpView setHidden: NO]; 
    
    [self playCurrentWordAudio];
    
}

- (void) pocketsphinxDidStartCalibration {
	NSLog(@"Pocketsphinx calibration has started.");
}

- (void) pocketsphinxDidCompleteCalibration {
	NSLog(@"Pocketsphinx calibration is complete.");
}

- (void) pocketsphinxDidStartListening {
	NSLog(@"Pocketsphinx is now listening.");
  
}

- (void) pocketsphinxDidDetectSpeech {
	NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
	NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
	NSLog(@"Pocketsphinx has stopped listening.");
    
}

- (void) pocketsphinxDidSuspendRecognition {
	NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
	NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
	NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFail {
    // This can let you know that something went wrong with the recognition loop startup. Turn on OPENEARSLOGGING to learn why.
	NSLog(@"Setting up the continuous recognition loop has failed for some reason, please turn on OpenEarsLogging to learn more.");
}
- (void) testRecognitionCompleted {
	NSLog(@"A test file that was submitted for recognition is now complete.");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setUpActivityIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator startAnimating];
    });
}

- (void) displayFirstWord {
    
    NSLog(@"Displaying first word question on the sreen with microphone button. currentWordIndex = %d", self.currentWordIndex);
    if(self.currentWordIndex >= 0) return;
    
    self.currentWordIndex = 0;
    if([self.words count] <= 0) { [self emptyWordsetAlert]; return;}
    
    [self loadCurrentWordObject];
    //set up Language Model to recognize array of words provided in this wordset
    //in currently learning language i.e. AcousticModelEnglish
    [self setUpLanguageModel];
    //[self.pocketsphinxController suspendRecognition];
    [self reloadView];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating];
        [self.loadingLabel setHidden: YES];
        [self.recordingOffButton setHidden:NO];
        [self.nativeLabel setHidden:NO];
        [self.nativeLabel setFont:[UIFont boldSystemFontOfSize:20.0f]];
        [self.wordImageView setHidden:NO];
        [self.pullUpView setHidden:YES]; 
    });
}

- (void) reloadView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.foreignLabel.text = [NSString stringWithFormat: @"%@ %@", self.currentWord.foreignArticle, self.currentWord.foreign];
        
        
        self.nativeLabel.text = [NSString stringWithFormat:@"%@ %@", self.currentWord.nativeArticle, self.currentWord.native];
        
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

- (IBAction)recordingButtonTouched:(UIButton *)sender {
    
    NSLog(@"Recording Button Touched. We start listening for user speech.");
    
   
    detectingSpeech = YES;
    [self performBlock:^{
        [self.pocketsphinxController resumeRecognition];
    } afterDelay:0.5f];
    
    //Change User Interface to reflect that we are recording user speech
    
    [self.recordingOffButton setHidden:YES];
    [self.recordingOnImageView setHidden:NO];
    
    [self.audioPlayer stop];
    
     myTimer = [NSTimer scheduledTimerWithTimeInterval:6.0f target:self selector:@selector(stopRecordingUserSpeech) userInfo:nil repeats:NO];
    

    //[self performSelector: withObject:nil afterDelay:5.0f];
}

- (void) stopRecordingUserSpeech
{
    NSLog(@"Stopping listening to user speech after 5 sec delay");
    
    detectingSpeech = NO;
    [self.pocketsphinxController suspendRecognition];
    //Change User Interface to reflect that we have stopped recording user speech
    [self.recordingOffButton setHidden:NO];
    [self.recordingOnImageView setHidden:YES];
    
}

- (IBAction)playRecording:(UIButton *)sender {
    NSLog(@"Play current word recording.");
    [self playCurrentWordAudio];
}

- (IBAction)nextButtonTouched:(UIButton *)sender {
    NSLog(@"Next button has been touched.");
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
    [self.audioButton setHidden:YES];
    [self.nativeLabel setFont: [UIFont boldSystemFontOfSize:20.0f]];
    [self.foreignLabel setHidden:YES];
    [self.goodAnswerImageView setHidden:YES];
    [self.badAnswerImageView setHidden:YES];
    [self.recordingOffButton setHidden: NO];
    [self.nextButton setHidden: YES];
    
    self.currentWordIndex++;
    //if the index is out of bound, there is no more words in array so we must display ending view.
    if(self.currentWordIndex >= [self.words count]) { [self summarizeLearning]; [self displayEndView]; return; }
    NSLog(@"Displaying next word on the screen, currentWordIndex = %d", self.currentWordIndex);
    [self loadCurrentWordObject];
    
    [self reloadView];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.learningMode = kLEARNING_MODE_SPEAKING;
}

- (void) clearCurrentView
{
    [self.transcriptionLabel setHidden: YES];
    [self.audioButton setHidden:YES];
    [self.nativeLabel setHidden: YES];
    [self.foreignLabel setHidden:YES];
    [self.wordImageView setHidden: YES];
    [self.goodAnswerImageView setHidden:YES];
    [self.nextButton setHidden:YES];
    [self.badAnswerImageView setHidden:YES];
    [self.recordingOffButton setHidden:YES];
    [self.recordingOnImageView setHidden: YES]; 
    [self.pullUpView setHidden: YES];
    
    detectingSpeech = NO;
    myTimer = nil;
    lmPath = nil;
    dicPath = nil;
    
    [self.pocketsphinxController stopListening];
    
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
    [self.pocketsphinxController stopListening];
}



- (void)viewDidUnload {
    [self setForeignLabel:nil];
    [self setNativeLabel:nil];
    [self setTranscriptionLabel:nil];
    [self setWordImageView:nil];
    [self setLoadingLabel:nil];
    [self setActivityIndicator:nil];
    [self setGoodAnswerImageView:nil];
    [self setRecordingOffButton:nil];
    [self setRecordingOnImageView:nil];
    [self setBadAnswerImageView:nil];
    [self setAudioButton:nil];
    [self setNextButton:nil];
    [self setPocketsphinxController:nil];
    [self setFliteController:nil];
    [self setSlt:nil];
    [self setBackgroundImageView:nil];
    [super viewDidUnload];
}
@end
