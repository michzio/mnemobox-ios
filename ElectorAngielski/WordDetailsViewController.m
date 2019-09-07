//
//  WordDetailsViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 26/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "WordDetailsViewController.h"
#import "Reachability.h"
#import "SentenceCell.h"
#import "Sentence+Create.h"
#import "SentenceObject.h"
#import "XMLParser.h"
#import "UIImageView+AFNetworking.h"
#import "Word+Create.h"
#import "iOSVersion.h"


#define kWORD_SERVICE_URL @"http://mnemobox.com/webservices/getTranslation.php?translation_id=%@&from=%@&to=%@"
#define kLANG_FROM @"pl"
#define kLANG_TO @"en"
#define kSENTENCE_RECORDING_SERVICE_URL @"http://mnemobox.com/recordings/sentences/"
#define kWORD_RECORDING_SERVICE_URL @"http://mnemobox.com/recordings/words/"

@interface WordDetailsViewController ()

@property (strong, nonatomic) NSMutableArray *sentences;
@property (nonatomic) BOOL isWordPreloaded;

@property (strong, nonatomic) Reachability *internetReachable;
@property (strong, nonatomic) XMLElement *xmlRoot;

@property (weak, nonatomic) IBOutlet UILabel *foreignLabel;
@property (weak, nonatomic) IBOutlet UILabel *nativeLabel;
@property (weak, nonatomic) IBOutlet UILabel *transcriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *wordImageView;
@property (weak, nonatomic) IBOutlet UITableView *sentenceTableView;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation WordDetailsViewController

@synthesize word = _word;
@synthesize wordObject = _wordObject;
@synthesize isWordPreloaded = _isWordPreloaded;


- (void) setWord:(Word *)word {
  
    if(_word != word) {
        NSLog(@"Setting Word object in WordDetailsViewController");
        
        _word = word;
        _wordObject = nil;
        /* we have word object from Core Data we can now get sentences from Core Data! */
        self.sentences = [[word.sentences allObjects] mutableCopy];
        self.isWordPreloaded = YES;
        if([self.sentences count] == 0) {
            /* if there isn't sentences in Core Data we try to load it through internet from web services */
            [self startSentencesLoadingFromWebServices];
        }
        [self displayWordBasicInfo];
        [self.sentenceTableView reloadData]; 
        
    }
    
}

- (void) setWordObject:(WordObject *)wordObject
{
    if(_wordObject != wordObject) {
        NSLog(@"Setting WordObject in WordDetailsViewController");
        
        _wordObject = wordObject;
        _word = nil;
        
        self.isWordPreloaded = NO;
        [self displayWordBasicInfo];
        /* we have wordObject with data from web services we must load sentences and other datas */ 
        
        [self startSentencesLoadingFromWebServices]; 
    }
    
}

- (void) startSentencesLoadingFromWebServices
{
    __weak WordDetailsViewController *weakSelf = self;
    
    self.internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Internet is reachable
    self.internetReachable.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"Yayyy, we have the interwebs!");
            
            [weakSelf getSentencesFromWebServices];
            
        });
    };
    
    // Internet is not reachable
    self.internetReachable.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Someone broke the internet :(");
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet connection lost!" message:@"Could not synchronize word details with mnemobox.com." delegate:weakSelf cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
            [alert show];
            
            
        });
    };
    
    [self.internetReachable startNotifier];
}


- (void) getSentencesFromWebServices {
    
    // called when we haven't stored word details in Core Data, and must retrieved it from web services
    // if we have Word object (Core Data) then sentences must have been also loaded to core data
    // so we synchrnize sentences only if we got WordObject, we have in WordObject *wordObject property
    // wordId for which we get list of accessible sentences
    
    NSString *wid = nil;
    if(self.isWordPreloaded) {
        wid = self.word.wordId;
    } else { 
       wid = self.wordObject.wordId;
    }
    
    NSString *urlAsString = [NSString stringWithFormat: kWORD_SERVICE_URL, wid, kLANG_FROM, kLANG_TO, nil];
    
    NSLog(@"Word Detils URL: %@", urlAsString); 
    NSURL *url = [NSURL URLWithString: urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL: url];
    [urlRequest setTimeoutInterval: 30.0f];
    [urlRequest setHTTPMethod: @"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    __weak WordDetailsViewController *weakSelf = self;
    
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:queue
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               
                 if([data length] > 0 && error == nil) { 
                       XMLParser *xmlParser = [[XMLParser alloc] initWithData: data];
                       self.xmlRoot = [xmlParser parseAndGetRootElement];
                       [weakSelf traverseXMLStartingFromRootElement];
                  } else if([data length] == 0 && error == nil) {
                       NSLog(@"Nothing was downloaded.");
                  } else if(error != nil) {
                       NSLog(@"Error happened = %@", error); 
                  }
     }];
}

- (void) traverseXMLStartingFromRootElement {
 
    __weak WordDetailsViewController *weakSelf = self;
    self.sentences = [[NSMutableArray alloc] init];
    
    XMLElement *sentencesElement = [self.xmlRoot.subElements objectAtIndex:5];
    
    [sentencesElement.subElements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XMLElement *sentenceElement = (XMLElement *) obj;
        
        NSString *sid = [sentenceElement.attributes valueForKey: @"sid"];
    
        XMLElement *foreignSentenceElement = [sentenceElement.subElements objectAtIndex:0];
        NSString *sentenceRecording = [foreignSentenceElement.attributes valueForKey:@"recording"];
        XMLElement *nativeSentenceElement = [sentenceElement.subElements objectAtIndex:1];
        
        NSLog(@"Sentence sid: %@, %@ - retrieved from XML", sid, foreignSentenceElement.text); 
        
        if(weakSelf.isWordPreloaded) {
            //if word is preloaded into Core Data database we store this sentences
            //into Core Data also!
            Sentence *sentence = [Sentence sentenceWithSID:sid
                                               foreignText:foreignSentenceElement.text
                                                nativeText:nativeSentenceElement.text
                                                 recording:sentenceRecording
                                                    inWord:weakSelf.word manageObjectContext:weakSelf.word.managedObjectContext];
            [weakSelf.sentences addObject: sentence];
        } else {
            
            SentenceObject *sentence = [[SentenceObject alloc] initWithSID: sid
                                                       foreignSentence: foreignSentenceElement.text
                                                        nativeSentence: nativeSentenceElement.text
                                                             recording: sentenceRecording];
            [weakSelf.sentences addObject: sentence];
        }
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf.sentenceTableView reloadData];
            
        });
        
    }];
}


- (void) displayWordBasicInfo
{
    
    
    if(self.isWordPreloaded) {
      /* we use preloaded Word object to set labels */
        NSLog(@"Displaying word basic info for word with wid: %@", self.word.wordId);
        
       self.foreignLabel.text = [[NSString stringWithFormat: @"%@ %@", self.word.foreignArticle,
                                                            self.word.foreign, nil] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        self.nativeLabel.text = [[NSString stringWithFormat: @"%@ %@", self.word.nativeArticle,
                                                                      self.word.native, nil] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
       self.transcriptionLabel.text = self.word.transcription;

       [self.wordImageView setImage:[UIImage imageWithData:self.word.image]];
       
    } else {
      /* we use preloaded WordObject to set labels */
        NSLog(@"Displaying word basic info for word with wid: %@", self.wordObject.wordId);
        NSLog(@"Word Details: %@", self.wordObject.foreign);
        [self.foreignLabel setText: [NSString stringWithFormat: @"%@ %@",
                                  self.wordObject.foreignArticle, self.wordObject.foreign, nil]];
        self.nativeLabel.text = [NSString stringWithFormat: @"%@ %@",
                                 self.wordObject.nativeArticle, self.wordObject.native, nil];
        self.transcriptionLabel.text = self.wordObject.transcription;
        if(self.wordObject.imageLoaded) { 
            self.wordImageView.image =  self.wordObject.image;
        } else {
            NSString *imageFullURL = [NSString stringWithFormat:@"%@%@",kIMAGE_SERVER, self.wordObject.imagePath, nil];
            [self.wordImageView setImageWithURL:[NSURL URLWithString:imageFullURL]]; 
        }
    }
    
    
    
}
- (IBAction)playRecording:(UIButton *)sender {
    /* click recordingButton to play pronanciation */
    
    NSString *audioPath = @"";
    
    if(self.isWordPreloaded) {
        /* if word was preloaded we use the Word *word object stored in Core Data to access (.recording) property */
        if(self.word.recording)
            audioPath = self.word.recording;
    } else {
        /* if word hadn't been preloaded the word recording has been retrieved from web services into WordObject *wordObject */
        if(self.wordObject.recording)
            audioPath = self.wordObject.recording;        
    }
    
    
    /* concatenating full string path to sentence recording on the server */
    NSString *urlAsString = kWORD_RECORDING_SERVICE_URL;
    urlAsString = [urlAsString stringByAppendingString: audioPath];
    
    NSLog(@"Word Audio Full Path: %@", urlAsString);
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    [self playAudioFromURL:url]; 

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self adjustToScreenOrientation];
    [self displayWordBasicInfo];
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1; 
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    NSLog(@"Number of sentence rows in tableView: %d", [self.sentences count]);
    
    return [self.sentences count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Sentence Cell";
    SentenceCell *cell;
    
    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        NSLog(@"Creating TableViewCell for iOS version < 6.0");
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil) {
            cell = [[SentenceCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }
    // Configure the cell...
    
    NSLog(@"Loading sentence into cell"); 
    
    if(self.isWordPreloaded) {
        Sentence *sentence = [self.sentences objectAtIndex: [indexPath row]];
        cell.sentenceLabel.text = sentence.foreign;
        
    } else {
        SentenceObject *sentence = [self.sentences objectAtIndex: [indexPath row]];
        cell.sentenceLabel.text = sentence.foreign;
    }
    
    cell.tag = [indexPath row];
    
    UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(cellWasSwipedLeft:)];
    swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [cell addGestureRecognizer: swipeLeftRecognizer];
    
    UISwipeGestureRecognizer *swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget: self
                                                                                               action: @selector(cellWasSwipedRight:)];
    swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [cell addGestureRecognizer: swipeRightRecognizer];
    
    return cell;
}

- (void)cellWasSwipedLeft:(UIGestureRecognizer *) swipeRecognizer {
    
    NSLog(@"Swiped Left on row: %d", swipeRecognizer.view.tag);
    
    SentenceCell *cell = (SentenceCell *)swipeRecognizer.view;
    
    if(self.isWordPreloaded) { 
        Sentence * sentence = [self.sentences objectAtIndex: swipeRecognizer.view.tag];
        cell.sentenceLabel.text = sentence.native;
    } else {
        SentenceObject *sentence = [self.sentences objectAtIndex: swipeRecognizer.view.tag];
        cell.sentenceLabel.text = sentence.native;
    }
    
    /* recognizing indexPath from swipe doesn't wark in thid case
    CGPoint point = [swipeRecognizer locationInView: self.sentenceTableView];
    NSLog(@"%f %f", point.x, point.y);
    NSIndexPath *indexPath = [self.sentenceTableView indexPathForRowAtPoint:point];
    if (indexPath == nil) {
        //Not on a cell
         NSLog(@"Swiped Left on a cell: %d", [indexPath row]);
        
    } else {
        //On a cell, use indexPath to do something.
        NSLog(@"Swiped Left not on a cell"); 
    }
     */
    
   
}

- (void)cellWasSwipedRight:(UIGestureRecognizer *) swipeRecognizer {
    
   
    NSLog(@"Swiped Right on row: %d", swipeRecognizer.view.tag);
    
    SentenceCell *cell = (SentenceCell *)swipeRecognizer.view;
    if(self.isWordPreloaded) { 
        Sentence *sentence = [self.sentences objectAtIndex: swipeRecognizer.view.tag];
        cell.sentenceLabel.text = sentence.foreign;
    } else {
        SentenceObject *sentence = [self.sentences objectAtIndex: swipeRecognizer.view.tag];
        cell.sentenceLabel.text = sentence.foreign;
    }
    
    /* recognizing indexPath from swipe doesn't wark in thid case
    CGPoint point = [swipeRecognizer locationInView: self.sentenceTableView];
    NSIndexPath *indexPath = [self.sentenceTableView indexPathForRowAtPoint:point];
    if (indexPath == nil) {
        //Not on a cell
        NSLog(@"Swiped Right on a cell: %d", [indexPath row]);
        
    } else {
        //On a cell, use indexPath to do something.
        NSLog(@"Swiped Right not on a cell");
    }
    */
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   /* when row is selected by the user we play (if exists) this sentence's recording */
    NSString *audioPath = @"";
    
    if(self.isWordPreloaded) {
        /* if word was preloaded the sentence recording is then stored in Core Data object Sentence *sentence */
        Sentence *sentence = [self.sentences objectAtIndex: [indexPath row]];
        if(sentence.recording)
            audioPath = sentence.recording;
    } else {
        /* if word hadn't been preloaded the sentence recording has been retrieved from web services into SentenceObject *sentence */
        SentenceObject *sentence = [self.sentences objectAtIndex: [indexPath row]];
        if(sentence.recording)
            audioPath = sentence.recording;
    }
    
    //test purposes only
    //audioPath = @"sent_apple1.mp3";
    
    /* concatenating full string path to sentence recording on the server */ 
    NSString *urlAsString = kSENTENCE_RECORDING_SERVICE_URL;
    urlAsString = [urlAsString stringByAppendingString: audioPath];
    
    NSLog(@"Sentence Audio Full Path: %@", urlAsString);
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    [self playAudioFromURL:url]; 

    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"PostIt Segue"] && [segue.destinationViewController respondsToSelector:@selector(setWordObject:)]) {
        WordObject * wordObject = self.wordObject;
        if( wordObject == nil && self.word) {
            /* if we have Word *word object from Core Data database we wrap 
              it into WordObject object in order to
              provide consistancy in further view controller */
            wordObject = [[WordObject alloc] initWithWID: self.word.wordId
                                             foreignName: self.word.foreign
                                              nativeName:self.word.native
                                               imagePath: nil
                                               audioPath: self.word.recording
                                           transcription: self.word.transcription
                                          foreignArticle:self.word.foreignArticle
                                           nativeArticle:self.word.nativeArticle];
            [wordObject setImage: [UIImage imageWithData: self.word.image]];
        }
        [segue.destinationViewController setWordObject: wordObject];
    }
}

- (void) playAudioFromURL: (NSURL *) url {
    
    dispatch_async(dispatch_queue_create("com.company.app.audioQueue", NULL), ^{
        NSData *audioData = [NSData dataWithContentsOfURL: url];
        
        NSError *error = nil;
        
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData: audioData error:&error];
        
        if(error) {
            NSLog(@"Error playing sentence audio: %@",[error description]);
        } else {
            NSLog(@"Playing sentence recording");
            self.audioPlayer.delegate = self;
            [self.audioPlayer prepareToPlay];
            [self.audioPlayer play];
        }
    });
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setForeignLabel:nil];
    [self setNativeLabel:nil];
    [self setTranscriptionLabel:nil];
    [self setWordImageView:nil];
    [self setSentenceTableView:nil];
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
