//
//  GenericLearningViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 29/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "GenericLearningViewController.h"
#import "XMLParser.h"
#import "Reachability.h"
#import "NSMutableArray+Shuffle.h"
#import "Word+Create.h"
#import "UserSettings.h"
#import "ProfileServices.h"
#import "Sentence.h"
#import "SentenceObject.h"
#import "WordDetailsViewController.h"
#import "ElectorWebServices.h"
#import "UIViewController+MJPopupViewController.h"
#import "RememberMePopUpViewController.h"

#define IPAD UIUserInterfaceIdiomPad
#define IDIOM UI_USER_INTERFACE_IDIOM()

#define kWORDS_IN_WORDSET_SERVICE_URL @"http://www.mnemobox.com/webservices/getwordset.php?wordset=%@&type=systemwordset&from=%@&to=%@"
#define kFORGOTTEN_WORDS_SERVICE_URL @"http://www.mnemobox.com/webservices/getwordset.php?email=%@&pass=%@&wordset=0&type=forgotten&from=%@&to=%@"
#define kREMEMBERME_WORDS_SERVICE_URL @"http://www.mnemobox.com/webservices/getwordset.php?email=%@&pass=%@&wordset=0&type=rememberme&from=%@&to=%@"
#define kWORDS_IN_USERWORDSET_SERVICE_URL @"http://www.mnemobox.com/webservices/getwordset.php?wordset=%@&type=userwordset&from=%@&to=%@"
#define kLANG_FROM @"pl"
#define kLANG_TO @"en"
#define kWORD_RECORDING_SERVICE_URL @"http://mnemobox.com/recordings/words/"
#define kWORD_SERVICE_URL @"http://mnemobox.com/webservices/getTranslation.php?translation_id=%@&from=%@&to=%@"

@interface GenericLearningViewController ()

@property (nonatomic, strong) XMLElement *xmlRoot;
@property (nonatomic, strong) Reachability *internetReachable;
@property (nonatomic, strong) RememberMePopUpViewController *rememberMePopUpViewController;

@end

@implementation GenericLearningViewController

@synthesize wordset = _wordset;
@synthesize wordsStoredInCoreData = _wordsStoredInCoreData;
@synthesize words = _words;
@synthesize currentWord = _currentWord;
@synthesize currentWordIndex = _currentWordIndex;
@synthesize forgottenTwoAns = _forgottenTwoAns;
@synthesize forgottenOneAns = _forgottenOneAns;
@synthesize goodAns = _goodAns;
@synthesize learningMode = _learningMode;

/************ PullUpView **************/
@synthesize pullUpView = _pullUpView;
@synthesize pullUpLabel = _pullUpLabel;
@synthesize infoButton = _infoButton;
@synthesize shareButton = _shareButton;
@synthesize remembermeButton = _remembermeButton;
@synthesize postitButton = _postitButton;
@synthesize rememberMePopUpViewController = _rememberMePopUpViewController;
/**************************************/

- (void) setWordset: (Wordset *)wordset
{
    if(_wordset != wordset) {
        _wordset = wordset;
        
        [self initializeLearning]; 
        self.internetReachable = [Reachability reachabilityWithHostname: @"www.google.com"];
        
        if([wordset.words count] > 0) {
            NSLog(@"Words are preloaded in Core Data, we can get it from there");
            //we check user settings to verify whether he want to get wordset from web services
            //instead of Core Data if internet connection is available
            if(self.internetReachable.isReachable && [UserSettings prefereToUseWordsViaWebServices]) {
                NSLog(@"User preferes to use word from web services instead of Core Data");
                self.wordsStoredInCoreData = NO;
                [self loadWordsInWordsetFromWebServices];
            } else { 
                self.wordsStoredInCoreData = YES;
                self.words = [[self.wordset.words allObjects] mutableCopy];
                [self.words shuffle];
                [self displayFirstWord];
            }
        } else {
            NSLog(@"Couldn't find words in Core Data, we should retrieved it from web services");
            self.wordsStoredInCoreData = NO;
            [self loadWordsInWordsetFromWebServices];
        }
    }
}

- (void) initializeLearning
{
    //initialiation of wordset learning progress
    self.currentWordIndex = -1;
    self.currentWord = nil;
    [self setUpActivityIndicator];
    self.goodAns = [[NSMutableArray alloc] init];
    self.forgottenOneAns = [[NSMutableArray alloc] init];
    self.forgottenTwoAns = [[NSMutableArray alloc] init];
    srandom(time(NULL));
}


- (void) setUpActivityIndicator
{
    NSException *methodNotImplemented = [NSException
                                exceptionWithName:@"MethodNotImplementedException"
                                reason:@"Method setUpActivityIndicator hasn't been overriden in subclass."
                                userInfo:nil];
    @throw methodNotImplemented; 
}

- (void) displayFirstWord
{
  NSException *methodNotImplemented = [NSException
                                       exceptionWithName:@"MethodNotImplementedException"
                                       reason:@"Method displayFirstWord hasn't been overriden in subclass." userInfo:nil];
    @throw methodNotImplemented;
}

- (void) clearCurrentView
{
  NSException *methodNotImplemented = [NSException
                                       exceptionWithName: @"MethodNotImplementedException"
                                       reason: @"Method clearCurrentView hasn't been overriden in subclass." userInfo:nil];
    @throw methodNotImplemented;
}

- (void) displayEndView
{
    [self clearCurrentView];
    
    [self  addButtonWithLabel: @"Wróć do zestawu" action: @selector(comeBackToWordsetView:) centerYOffset: -20];
    [self  addButtonWithLabel: @"Przelosuj zestaw" action: @selector(reloadWordset:) centerYOffset: 40];
    
}

- (void) addButtonWithLabel: (NSString *) label action: (SEL) actionSelector centerYOffset: (CGFloat) yOffset
{
   
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectZero;
    button.backgroundColor = [UIColor colorWithRed:172/255.0f green:0.0f blue:29/255.0f alpha:1];
    [button setTitle:label forState:UIControlStateNormal];
    button.titleLabel.textColor = [UIColor whiteColor];
    button.titleLabel.textAlignment = UITextAlignmentCenter;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [button setTranslatesAutoresizingMaskIntoConstraints:NO];
    [button addTarget:self action: actionSelector forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: button];
    button.tag = 9;
    
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"|-20-[button]-20-|"
                               options:0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(button)]];
    
    NSLayoutConstraint *cn = [NSLayoutConstraint constraintWithItem:button
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:yOffset];
    
    [self.view addConstraint:cn];
    
    cn = [NSLayoutConstraint constraintWithItem:button
                                      attribute:NSLayoutAttributeHeight
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                     multiplier:1
                                       constant:40];
    [button addConstraint:cn];

}

- (void) comeBackToWordsetView: (UIButton *) sender
{
    NSLog(@"Come back to wordset button clicked"); 
    [self.navigationController popViewControllerAnimated:YES]; 
}

- (void) reloadWordset: (UIButton *) sender
{
    NSLog(@"Reloading Wordset");
    
    for(UIView *subview in self.view.subviews) {
        if(subview.tag == 9) {
            [subview removeFromSuperview];
        }
    }
    //initialize learning progress
    [self initializeLearning];
    //shuffle words in wordset
    [self.words shuffle];
    //display first word from shuffled word's array
    [self displayFirstWord]; 
    
}

- (void) summarizeLearning
{
    //counting and logging good/bad answers
    NSLog(@"There's no more words in this wordset.");
    NSInteger badAns = [self.forgottenTwoAns count] + [self.forgottenOneAns count];
    NSInteger goodAns = [self.goodAns count];
    NSLog(@"Stats, goodAns = %d, badAns = %d", goodAns, badAns);
    
    //saving traced bad/good answers in the server
    // if there isn't internet connection? - should be stored in Core Data and synchronized
    // later? - this functionality not implemented, should be added later!!!!
    [TracingHistoryAndStatistics traceLearningHistoryForWordsetWithId:self.wordset.wid
                                                         learningMode:self.learningMode
                                                          goodAnswers:goodAns
                                                           badAnswers:badAns];
    if(self.internetReachable.isReachable) {
        [TracingHistoryAndStatistics traceWordsForgottenTwoAns: self.forgottenTwoAns
                                           forgottenOneAns: self.forgottenOneAns
                                                   goodAns: self.goodAns];
    } else {
        // otherwise there is no internet connection and we stored this forgotten words wordIds 
        // as serialData string in userDefaults array

        NSString *forgottenSerialData =  [TracingHistoryAndStatistics
                                          stringWithForgottenWordIdsBasedOnForgottenTwoAns: self.forgottenTwoAns
                                          forgottenOneAns: self.forgottenOneAns
                                          goodAns: self.goodAns];
        
        [TracingHistoryAndStatistics saveForgottenSerialDataLocallyInUserDefaults: forgottenSerialData];
        
    }
}

- (void) loadCurrentWordObject
{
    if(self.wordsStoredInCoreData) {
        //we use Word object and wrap it into WordObject
        WordObject *wordObject = [WordObject wordObjectWithWord: [self.words objectAtIndex:
                                                                  self.currentWordIndex]];
        self.currentWord = wordObject;
    } else {
        self.currentWord = [self.words objectAtIndex:self.currentWordIndex];
    }
}

- (void) loadWordsInWordsetFromWebServices
{
    __weak GenericLearningViewController *weakSelf = self;
    
   
    //Internet is reachable
    self.internetReachable.reachableBlock = ^(Reachability *reach)
    {
        //Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Yayyy, we have the interwebs!");
            [weakSelf getWordsInWordsetFromWebServices];
        });
        
    };
    
    //Internet is not reachable
    self.internetReachable.unreachableBlock = ^(Reachability *reach)
    {
        //Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Someone broke the internet :(");
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet connection lost!" message:@"Could not synchronize words in wordset with mnemobox.com" delegate:weakSelf cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
            [alert show];
        });
        
    };
    
    [self.internetReachable startNotifier];
}


- (void) getWordsInWordsetFromWebServices
{
    NSString *wid = self.wordset.wid;
    NSString *urlAsString;
    
    if([wid isEqualToString:@"FORGOTTEN"]) {
        NSString *emailAddress = [ProfileServices emailAddressFromUserDefaults];
        NSString *sha1Password = [ProfileServices sha1PasswordFromUserDefaults];
        urlAsString = [NSString stringWithFormat: kFORGOTTEN_WORDS_SERVICE_URL,
                        emailAddress, sha1Password, kLANG_FROM, kLANG_TO, nil];
    } else if([wid isEqualToString:@"REMEMBERME"]) {
        NSString *emailAddress = [ProfileServices emailAddressFromUserDefaults];
        NSString *sha1Password = [ProfileServices sha1PasswordFromUserDefaults];
        urlAsString = [NSString stringWithFormat: kREMEMBERME_WORDS_SERVICE_URL,
                       emailAddress, sha1Password, kLANG_FROM, kLANG_TO, nil];
    } else if([wid hasPrefix:@"USERWORDSET"]) {
        NSRange range = [wid rangeOfString:@"USERWORDSET_"];
        NSString *idOfUserWordset;
        if (range.location != NSNotFound)
        {
            //range.location is start of substring
            //range.length is length of substring
             idOfUserWordset= [wid substringFromIndex:range.location + range.length];
        }
        urlAsString = [NSString stringWithFormat: kWORDS_IN_USERWORDSET_SERVICE_URL,
                       idOfUserWordset, kLANG_FROM, kLANG_TO, nil];
    } else {
        urlAsString = [NSString stringWithFormat: kWORDS_IN_WORDSET_SERVICE_URL,
                             wid, kLANG_FROM, kLANG_TO, nil];
    }
    
    //we are checking user settings to verify whether user wants to multiply occurances of forgotten words
    if([UserSettings userWantsToMultiplayForgottenWords]) {
        
        urlAsString = [urlAsString stringByAppendingFormat:@"&email=%@", [ProfileServices emailAddressFromUserDefaults]];
        urlAsString = [urlAsString stringByAppendingFormat:@"&pass=%@", [ProfileServices sha1PasswordFromUserDefaults]];
    }
    
    NSLog(@"Words in Wordset URL: %@", urlAsString);
    NSURL *url = [NSURL URLWithString: urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval: 30.0f];
    [urlRequest setHTTPMethod: @"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    __weak GenericLearningViewController *weakSelf = self;
    
    
    [NSURLConnection sendAsynchronousRequest: urlRequest
                                       queue: queue
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               
                               if([data length] > 0 && error == nil) {
                                   XMLParser *xmlParser = [[XMLParser alloc] initWithData: data];
                                   self.xmlRoot = [xmlParser parseAndGetRootElement];
                                   [weakSelf traverseXMLStartingFromRootElement];
                                   [weakSelf.internetReachable stopNotifier];
                               } else if([data length] == 0 && error == nil) {
                                   NSLog(@"Nothing was downloaded");
                               } else if(error != nil) {
                                   NSLog(@"Error happened = %@", error);
                               }
                           }];
     
    /* synchronous version 
    NSURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    if([data length] > 0 && error == nil) {
        XMLParser *xmlParser = [[XMLParser alloc] initWithData: data];
        self.xmlRoot = [xmlParser parseAndGetRootElement];
        [weakSelf traverseXMLStartingFromRootElement];
    } else if([data length] == 0 && error == nil) {
        NSLog(@"Nothing was downloaded");
    } else if(error != nil) {
        NSLog(@"Error happened = %@", error);
    }
     */

}

- (void) traverseXMLStartingFromRootElement
{
    __weak GenericLearningViewController *weakSelf = self;
    self.words = [[NSMutableArray alloc] init];
    
    [self.xmlRoot.subElements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        XMLElement *wordElement = (XMLElement *)obj;
        NSString *wid = [wordElement.attributes valueForKey: @"wid"];
        XMLElement *foreignWordElement = [wordElement.subElements objectAtIndex:0];
        XMLElement *nativeWordElement = [wordElement.subElements objectAtIndex:1];
        XMLElement *transcriptionElement = [wordElement.subElements objectAtIndex:2];
        XMLElement *imagePathElement = [wordElement.subElements objectAtIndex: 3];
        XMLElement *audioPathElement = [wordElement.subElements objectAtIndex:4];
        //XMLElement *sentencesElement = [wordElement.subElements objectAtIndex:5];
        //XMLElement *postItElement = [wordElement.subElements objectAtIndex:6];
        
        NSLog(@"wid = %@, en= %@, pl = %@, img = %@, audio = %@",
              wid, foreignWordElement.text, nativeWordElement.text, imagePathElement.text,
              audioPathElement.text);
        
        /* creating WordObject */
        WordObject *word = [[WordObject alloc] initWithWID:wid
                                               foreignName:foreignWordElement.text
                                                nativeName:nativeWordElement.text
                                                 imagePath:imagePathElement.text
                                                 audioPath:audioPathElement.text
                                             transcription:transcriptionElement.text
                                            foreignArticle: [foreignWordElement.attributes valueForKey:@"article"]
                                             nativeArticle:[nativeWordElement.attributes valueForKey:@"article"]];
        NSLog(@"Loading WordObject: %@ from web services to words array", word.foreign);
        
        [weakSelf.words addObject: word];
    }];
    NSLog(@"Number of loaded words: %d", [self.words count]);
    [self.words shuffle]; 
    [self displayFirstWord];
    
}

- (void) loadImageOfWord: (WordObject *) word toImageView: (UIImageView *) imageView
{
    [imageView setImage:nil]; 
    dispatch_async(dispatch_queue_create("com.company.app.imageQueue", nil), ^{
        
            NSData *imageData = [Word imageDataWithImagePath: word.imagePath];
        
            UIImage *image = [UIImage imageWithData:imageData];
            [word setImage: image];
            [word setImageHeight:image.size.height];
            [word setImageLoaded: YES];
       
            // before we display word on the screen we check whether user doesn't preceed in learning by touching to next words
            if(self.currentWord == word) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [imageView setImage: word.image];
                });
            }
        
    });

}

- (void) playCurrentWordAudio
{
    if(self.currentWord == nil) return;
    
    if(self.wordsStoredInCoreData && self.wordset.isAudioStoredLocally) {
        [self playAudioFromDisk: self.currentWord.recording];
    } else { //play audio remotely from web server
        /* concatenating full string path to sentence recording on the server */
        NSString *urlAsString = kWORD_RECORDING_SERVICE_URL;
        urlAsString = [urlAsString stringByAppendingString: self.currentWord.recording];
        
        NSLog(@"Word Audio Full Path: %@", urlAsString);
        NSURL *url = [NSURL URLWithString:urlAsString];
    
        [self playAudioFromURL:url];
    }
}

- (void) playAudioFromURL: (NSURL *) url {
    
    dispatch_async(dispatch_queue_create("com.company.app.audioQueue", NULL), ^{
        NSData *audioData = [NSData dataWithContentsOfURL: url];
        
        NSError *error = nil;
        
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData: audioData error:&error];
        
        if(error) {
            NSLog(@"Error playing audio: %@",[error description]);
        } else {
            NSLog(@"Playing recording");
            self.audioPlayer.delegate = self;
            [self.audioPlayer prepareToPlay];
            [self.audioPlayer play];
        }
    });
}

- (void) playAudioFromDisk: (NSString *) audioFile
{
    NSLog(@"Playing audio stored locally: %@", audioFile); 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *audioDirectory = [documentsDirectory stringByAppendingPathComponent:@"audio"];
    
    NSString *fullAudioPath = [audioDirectory stringByAppendingPathComponent:audioFile];
    NSLog(@"Full locale audio path: %@", fullAudioPath);
    NSURL *url= [NSURL fileURLWithPath: fullAudioPath];
    [self playAudioFromURL:url];
}

- (void) addCurrentWordToForgottenOne
{
    NSString *currentWordId = self.currentWord.wordId;
    
    //we check wheather word hasn't been currently added to forgottenOneAns if no we add it to this array
    BOOL isInForgottenOne = NO;
    
    for(NSString *wid in self.forgottenOneAns)
    {
        if([wid isEqualToString:currentWordId]) {
            isInForgottenOne = YES;
            break;
        }
    }
    
    if(isInForgottenOne) {
        //if current wordId is in forgottenOneAns we need to check it for existance in forgottenTwoAns
        [self addCurrentWordToForgottenTwo];
    } else {
        BOOL isInForgottenTwo = NO;
        for(NSString *wid in self.forgottenTwoAns) {
            if([wid isEqualToString:currentWordId]) {
                isInForgottenTwo = YES;
                break;
            }
        }
        if(!isInForgottenTwo) {
            [self.forgottenOneAns addObject:currentWordId];
        }
    }
    
}

- (void) addCurrentWordToForgottenTwo
{
    // we need to check it for existance in forgottenTwoAns befor we add it here
    NSString *currentWordId = self.currentWord.wordId;
    
    BOOL isInForgottenTwo = NO;
    
    for(NSString *wid in self.forgottenTwoAns) {
        if([wid isEqualToString:currentWordId]) {
            isInForgottenTwo = YES;
            break;
        }
    }
    
    if(!isInForgottenTwo) {
        [self.forgottenOneAns removeObject:currentWordId];
        [self.forgottenTwoAns addObject:currentWordId];
    }
    
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
    [self.navigationController setNavigationBarHidden:NO];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(!self.pullUpView)
        [self setUpPullUpView];
     [self adjustToScreenOrientation];
}

- (void) setPullUpViewPosition: (CGFloat) xOffset
{
    self.pullUpView.openedCenter = CGPointMake(160 + xOffset,self.view.frame.size.height);
    self.pullUpView.closedCenter = CGPointMake(160 + xOffset, self.view.frame.size.height + 220);
    self.pullUpView.center = self.pullUpView.closedCenter;
    self.pullUpView.handleView.frame = CGRectMake(0, 0, 320, 10);
}

- (void) setUpPullUpView {
    
    CGFloat xOffset = 0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        xOffset = 224;
    }
    self.pullUpView = [[PullableView alloc] initWithFrame:CGRectMake(xOffset, 0, 320, 460)];
   [self setPullUpViewPosition:xOffset];
    self.pullUpView.backgroundColor =  [UIColor colorWithRed:89/255.0f green:89/255.0f blue:91/255.0f alpha:1];
    self.pullUpView.handleView.backgroundColor = [UIColor whiteColor];
    self.pullUpView.delegate = self;
    
    
    [self.view addSubview:self.pullUpView];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    imgView.frame = CGRectMake(0, 0, 320, 460);
    [self.pullUpView addSubview: imgView];
    
    UIImageView *pullUpImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pullUpButton.png"]];
    pullUpImage.frame = CGRectMake(135,0,50,20); 
    [self.pullUpView addSubview:pullUpImage];
    
    
    
    self.pullUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 300, 95)];
    self.pullUpLabel.textAlignment = UITextAlignmentLeft;
    self.pullUpLabel.backgroundColor = [UIColor clearColor];
    self.pullUpLabel.textColor = [UIColor whiteColor];
    self.pullUpLabel.text = @"Wczytuje przykładowe zdanie...";
    self.pullUpLabel.adjustsFontSizeToFitWidth = YES;
    self.pullUpLabel.minimumFontSize = 8.0f;
    self.pullUpLabel.numberOfLines = 4;
    self.pullUpLabel.font = [UIFont systemFontOfSize:15.0];
    
   [self.pullUpView addSubview:self.pullUpLabel];
    
    
    self.infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.infoButton.frame = CGRectMake(20,145, 60,60);
    [self.infoButton setBackgroundImage: [UIImage imageNamed:@"info.png"] forState:UIControlStateNormal];
    [self.infoButton addTarget:self action:@selector(infoButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.infoButton setTitle: @"Szczegóły" forState:UIControlStateNormal];
    self.infoButton.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    self.infoButton.titleLabel.adjustsFontSizeToFitWidth  = YES;
    self.infoButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, -15.0f, 0); 
    [self.pullUpView addSubview:self.infoButton];
    
    self.remembermeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.remembermeButton.frame = CGRectMake(90,145, 60,60);
    [self.remembermeButton setBackgroundImage: [UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
    [self.remembermeButton addTarget:self action:@selector(remembermeButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.remembermeButton setTitle: @"Przypomnij" forState:UIControlStateNormal];
    self.remembermeButton.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    self.remembermeButton.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    self.remembermeButton.titleLabel.adjustsFontSizeToFitWidth  = YES;
    self.remembermeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, -15.0f, 0);
    [self.pullUpView addSubview:self.remembermeButton];
    
    self.postitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.postitButton.frame = CGRectMake(160,145, 60,60);
    [self.postitButton setBackgroundImage: [UIImage imageNamed:@"comment.png"] forState:UIControlStateNormal];
    [self.postitButton addTarget:self action:@selector(postitButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.postitButton setTitle: @"Skojarzenia" forState:UIControlStateNormal];
    self.postitButton.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    self.postitButton.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    self.postitButton.titleLabel.adjustsFontSizeToFitWidth  = YES;
    self.postitButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, -15.0f, 0);
    [self.pullUpView addSubview:self.postitButton];
    
    self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.shareButton.frame = CGRectMake(230,145, 60,60);
    [self.shareButton setBackgroundImage: [UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
    [self.shareButton addTarget:self action:@selector(shareButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton setTitle: @"Podziel się" forState:UIControlStateNormal];
    self.shareButton.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    self.shareButton.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    self.shareButton.titleLabel.adjustsFontSizeToFitWidth  = YES;
    self.shareButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, -15.0f, 0);
    [self.pullUpView addSubview:self.shareButton];

}

- (void) infoButtonTouched: (UIButton *) sender
{
    NSLog(@"Info Button Touched.");
    
    [self performSegueWithIdentifier:@"Word Details Segue" sender:self]; 
}

- (void) remembermeButtonTouched: (UIButton *) sender
{
    NSLog(@"Remember Me Button Touched.");
    
    if(self.internetReachable.isReachable) {
        // when we have internet connection we save this word to remember me section
        // directly to web server
        [ElectorWebServices saveWordToRememberMe:self.currentWord.wordId];
        
        [self showRememberMePopUp];
        [self.rememberMePopUpViewController.popUpLabel setText: @"Dodano do przypomnienia"];
    } else {
        
        [ElectorWebServices saveWordToRememberMeLocallyInUserDefaults: self.currentWord.wordId];
        
        [self showRememberMePopUp];
        [self.rememberMePopUpViewController.popUpLabel setText: @"Brak internetu. Zapisano lokalnie."];
    }
}

- (void) postitButtonTouched: (UIButton *) sender
{
    NSLog(@"Post It Button Touched.");
    [self performSegueWithIdentifier:@"PostIt Segue" sender:self];

}

- (void) shareButtonTouched: (UIButton *) sender
{
    NSLog(@"Share Buttn Touched.");
    if(self.internetReachable.isReachable) {
        //we have internect connection and can share our word
        //on profile wall
        [ElectorWebServices shareWordOnUserProfileWall: self.currentWord];
        //we reuse rememberMePopUp to display confirmation message
        [self showRememberMePopUp];
        [self.rememberMePopUpViewController.popUpLabel setText:@"Umieszczono słówko na twoim profilu"];
    } else {
        [self showRememberMePopUp];
        [self.rememberMePopUpViewController.popUpLabel setText:@"Brak Internetu. Nie udało się przesłać słowka na twój profil w serwisie Elector.pl"];
        [self.rememberMePopUpViewController.popUpImageView setHidden: YES];
        [self.rememberMePopUpViewController.popUpErrorImageView setHidden: NO];
        
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Word Details Segue"]) {
        
        NSLog(@"Prepare For Word Details Segue");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(self.wordsStoredInCoreData) {
                /* we have Word object from Core Data database, we can pass it to next View Controller */
                Word *word = [self.words objectAtIndex:self.currentWordIndex];
                [segue.destinationViewController setWord: word];
            } else {
                /* we have WordObject object with data from web services, details e.g. sentences should be
                 retrieved additionaly from web services after segue */
                [segue.destinationViewController setWordObject: self.currentWord];
            }
            
        });

    } else if([segue.identifier isEqualToString:@"PostIt Segue"] &&
              [segue.destinationViewController respondsToSelector:@selector(setWordObject:)]) {
        
        [segue.destinationViewController setWordObject: self.currentWord];
    }

}

- (void)pullableView:(PullableView *)pView didChangeState:(BOOL)opened {
    
    self.pullUpLabel.text = @"Wczytuje przykładowe zdanie...";
    if (opened) {
        
        [self putSentenceExampleInPullUpView];
        
        
    } else {
        //self.pullUpLabel.text = @"Now I'm closed, pull me up again!";
    }
}

- (void) putSentenceExampleInPullUpView
{
    //self.pullUpLabel.text = @"Now I'm open!";
    if(self.wordsStoredInCoreData) {
        // we have Word object stored in Data Core, it also means user don't want loading from web services
        
        Sentence *anySentence = [[[self.words objectAtIndex: self.currentWordIndex] sentences] anyObject];
        
        self.pullUpLabel.text = [NSString stringWithFormat:@"e.g. %@", anySentence.foreign, nil];
        
    } else {
        // we have WordObject object because data hasn't been loaded to Core Data or user want explicitly to load them
        __weak GenericLearningViewController *weakSelf = self;
        
        self.internetReachable.reachableBlock = ^(Reachability *reach) {
            //Update the UI on the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Yayyy, we have the interwebs!");
                
                [weakSelf getSentenceForCurrentWordFromWebServices];
                
            });
        };
        
        //Internet is not reachable
        self.internetReachable.unreachableBlock = ^(Reachability *reach)
        {
            //Update the UI on the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Someone broke the internet :(");
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet connection lost!" message:@"Could not synchronize sentences in wordset with mnemobox.com" delegate:weakSelf cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
                [alert show];
            });
            
        };
        
        [self.internetReachable startNotifier];
        
    }
    
}


- (void) getSentenceForCurrentWordFromWebServices
{
    NSString *wid = self.currentWord.wordId;
    NSString *urlAsString = [NSString stringWithFormat: kWORD_SERVICE_URL, wid, kLANG_FROM, kLANG_TO, nil];
    
    NSLog(@"Getting Sentence for Word URL: %@", urlAsString); 
    NSURL *url = [NSURL URLWithString: urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL: url];
    [urlRequest setTimeoutInterval: 30.0f];
    [urlRequest setHTTPMethod: @"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    __weak GenericLearningViewController *weakSelf = self;
    
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:queue
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               
                               if([data length] > 0 && error == nil) {
                                   XMLParser *xmlParser = [[XMLParser alloc] initWithData: data];
                                   self.xmlRoot = [xmlParser parseAndGetRootElement];
                                   [weakSelf traverseXMLStartingFromRootToGetSentence];
                                   [self.internetReachable stopNotifier]; 
                               } else if([data length] == 0 && error == nil) {
                                   NSLog(@"Nothing was downloaded.");
                               } else if(error != nil) {
                                   NSLog(@"Error happened = %@", error);
                               }
                           }];

}

- (void) traverseXMLStartingFromRootToGetSentence
{
    //__weak GenericLearningViewController *weakSelf = self;
    
    NSMutableSet *sentences = [[NSMutableSet alloc] init];
    
    XMLElement *sentencesElement = [self.xmlRoot.subElements objectAtIndex:5];
    
    [sentencesElement.subElements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XMLElement *sentenceElement = (XMLElement *) obj;
        
        NSString *sid = [sentenceElement.attributes valueForKey: @"sid"];
        
        XMLElement *foreignSentenceElement = [sentenceElement.subElements objectAtIndex:0];
        NSString *sentenceRecording = [foreignSentenceElement.attributes valueForKey:@"recording"];
        XMLElement *nativeSentenceElement = [sentenceElement.subElements objectAtIndex:1];
        
        NSLog(@"Sentence sid: %@, %@ - retrieved from XML", sid, foreignSentenceElement.text);
        
        SentenceObject *sentence = [[SentenceObject alloc] initWithSID: sid
                                                       foreignSentence: foreignSentenceElement.text
                                                        nativeSentence: nativeSentenceElement.text
                                                             recording: sentenceRecording];
        
        [sentences addObject: sentence];
        SentenceObject * anySentence = [sentences anyObject];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.pullUpLabel.text = [NSString stringWithFormat:@"e.g. %@", anySentence.foreign, nil];
            
        });
        
    }];

}

- (void) showRememberMePopUp
{
    self.rememberMePopUpViewController = [[RememberMePopUpViewController alloc] initWithNibName:@"RememberMePopUpViewController" bundle:nil];
    [self presentPopupViewController:self.rememberMePopUpViewController animationType:MJPopupViewAnimationFade];
    [self.rememberMePopUpViewController.popUpImageView setHidden: NO];
    [self.rememberMePopUpViewController.popUpErrorImageView setHidden: YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//adjusting view to portrait and landscape mode methods
- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear:animated];
    [self adjustToScreenOrientation];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}
- (void)awakeFromNib
{
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
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
        [self setInBackgroundImageNamed: @"london.png"];
        CGFloat xOffset = 100;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            xOffset += 224;
        }
        [self setPullUpViewPosition:xOffset];
        
    }  else if (UIDeviceOrientationIsPortrait(deviceOrientation) &&
                deviceOrientation != UIDeviceOrientationPortraitUpsideDown)
    {
        [self setInBackgroundImageNamed: @"bigben.png"];
        CGFloat xOffset = 0;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            xOffset = 224;
        }
        [self setPullUpViewPosition:xOffset];
    } else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && deviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
        CGFloat xOffset = 0;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            xOffset = 224;
        }
        [self setPullUpViewPosition:xOffset];
    }

}

- (void) setInBackgroundImageNamed: (NSString *) imageName
{
    NSException *methodNotImplemented = [NSException
                                         exceptionWithName:@"MethodNotImplementedException"
                                         reason:@"Method setInBackgroundImageNamed hasn't been overriden in subclass."
                                         userInfo:nil];
    @throw methodNotImplemented;
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
