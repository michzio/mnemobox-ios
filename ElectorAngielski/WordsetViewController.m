//
//  WordsetViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 23/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "WordsetViewController.h"
#import "LearningMethodsMenu.h"
#import "LearningMethodCell.h"
#import "XMLParser.h"
#import "XMLElement.h"
#import "Reachability.h"
#import "Word+Create.h"
#import "Wordset+Select.h"
#import "Sentence+Create.h"
// only for Progress Bar Pop Up View
#import "ProgressBarPopUpViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "iOSVersion.h"
#import "ElectorWebServices.h"
#import "UserSettings.h"
#import "ProfileServices.h"

//params: wordsetId, type, langFrom, langTo
#define kWORDS_IN_WORDSET_SERVICE_URL @"http://www.mnemobox.com/webservices/getwordset.php?wordset=%@&type=%@&from=%@&to=%@"
//params: emailAddress, sha1Password, langFrom, langTo
#define kFORGOTTEN_WORDSET_SERVICE_URL @"http://www.mnemobox.com/webservices/getwordset.php?type=forgotten&email=%@&pass=%@&wordset=0&from=%@&to=%@"
//params: emailAddress, sha1Password, langFrom, langTo
#define kREMEMBERME_WORDSET_SERVICE_URL @"http://www.mnemobox.com/webservices/getwordset.php?type=rememberme&email=%@&pass=%@&wordset=0&from=%@&to=%@"
#define kLANG_FROM @"pl"
#define kLANG_TO @"en"
#define kTYPE_SYSTEMWORDSET @"systemwordset"
#define kTYPE_USERWORDSET @"userwordset"

@interface WordsetViewController ()

@property (weak, nonatomic) IBOutlet UILabel *foreignNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nativeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *syncBarButtonItem;
@property (strong, nonatomic) ProgressBarPopUpViewController *progressBarPopUpViewController;

@property (nonatomic, strong) XMLElement *xmlRoot;
@property (nonatomic, strong) Reachability *internetReachable;

@property NSArray *learningMethodsInfo;

@end

@implementation WordsetViewController

@synthesize progressDelegate = _progressDelegate;
@synthesize wordset = _wordset;
@synthesize learningMethodsInfo = _learningMethodsInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) showPopUpProgressBar
{
    self.progressBarPopUpViewController = [[ProgressBarPopUpViewController alloc] initWithNibName:@"ProgressBarPopUpViewController" bundle:nil];
    self.progressDelegate = self.progressBarPopUpViewController;
    [self presentPopupViewController:self.progressBarPopUpViewController animationType:MJPopupViewAnimationFade];
}

/* method called when "Sync" button is touched in order to synchronize (download/update) words to database in Core Data */

- (IBAction)synchronize:(UIBarButtonItem *)sender {
    
    NSLog(@"Synchronization of wordset words");
    
    [self showPopUpProgressBar];
    
    __weak WordsetViewController *weakSelf = self;
    
    self.internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Internet is reachable
    self.internetReachable.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
         dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"Yayyy, we have the interwebs!");
            
        });
        [weakSelf getWordsInWordsetFromWebServices];
    };
    
    // Internet is not reachable
    self.internetReachable.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Someone broke the internet :(");
            
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet connection lost!" message:@"Could not synchronize words in wordset with mnemobox.com." delegate:weakSelf cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
             [alert show];
             
            
        });
    };
    
    [self.internetReachable startNotifier];
   
}

-(void) loadLearningMethodsInfoDictionary
{
    NSLog(@"Loading Learning Methods Info Array Of Dictionaries");
    NSArray *learningMethodsInfo = @[ @{ @"name" : @"Lista Słówek",
                                         @"imgURL" : @"listofwords.png"
                                         },
                                      @{ @"name" : @"Prezentacja",
                                         @"imgURL" : @"presentation.png"
                                         },
                                      @{ @"name" : @"Odpytywanie",
                                         @"imgURL" : @"repetition.png"
                                         },
                                      @{ @"name" : @"Mówienie",
                                         @"imgURL" : @"speaking.png"
                                         },
                                      @{ @"name" : @"Dyktando",
                                         @"imgURL" : @"listening.png"
                                         },
                                      @{ @"name" : @"Wybieranie",
                                         @"imgURL" : @"choosing.png"
                                         },
                                      @{ @"name" : @"Kartoniki",
                                         @"imgURL" : @"cartons.png"
                                         }
                                      
                                      ];
    self.learningMethodsInfo = learningMethodsInfo;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.learningMethodsInfo)
        return [self.learningMethodsInfo count];
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Learning Method Cell";
   // LearningMethodCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    LearningMethodCell *cell;
    
    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        NSLog(@"Creating TableViewCell for iOS version < 6.0");
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil) {
            cell = [[LearningMethodCell alloc] init];
        }
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        NSLog(@"Creating TableViewCell for iOS version >= 6.0");
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }
    
    // Configure the cell...
    cell.nameLabel.text = [[self.learningMethodsInfo objectAtIndex:[indexPath row]] objectForKey: @"name"];
    cell.thumbnail.image = [UIImage imageNamed: [[self.learningMethodsInfo objectAtIndex:[indexPath row]] objectForKey: @"imgURL"]];
   

    
    /*UIImage *image =     cellImageView.image = image;
    cellImageView.frame = CGRectMake(cellImageView.frame.origin.x,
                                     cellImageView.frame.origin.y,
                                     25.0f, 25.0f);*/
    
    
    return cell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.foreignNameLabel.text = self.wordset.foreignName;
    self.nativeNameLabel.text = self.wordset.nativeName;
    self.levelLabel.text = self.wordset.level;
    self.descriptionLabel.text = self.wordset.about;
    
    
    [self loadLearningMethodsInfoDictionary];
    
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
    UIDeviceOrientation deviceOrientation = (UIDeviceOrientation) [UIApplication sharedApplication].statusBarOrientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {
        [self.backgroundImageView setImage:[UIImage imageNamed:@"london.png"]];
        
    }  else if (UIDeviceOrientationIsPortrait(deviceOrientation) &&
                deviceOrientation != UIDeviceOrientationPortraitUpsideDown)
    {
        [self.backgroundImageView setImage:[UIImage imageNamed:@"bigben.png"]];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    
    switch([indexPath row]) {
    
        case 0: { //List Of Words
            NSLog(@"List Of Words Segue");
            [self performSegueWithIdentifier: @"List Of Words Segue" sender:self];
            break;
        }
        case 1: { //Presentation
            NSLog(@"Presentation Segue");
            [self performSegueWithIdentifier: @"Presentation Segue" sender:self];
            break;
        }
        
        case 2: { //Repetition
            NSLog(@"Repetition Segue");
            [self performSegueWithIdentifier: @"Repetition Segue" sender:self];
            break;
        }
        case 3: { //Speaking
            NSLog(@"Speaking Segue");
            [self performSegueWithIdentifier: @"Speaking Segue" sender:self];
            break;
        }
        case 4: { //Listening
            NSLog(@"Listening Segue");
            [self performSegueWithIdentifier: @"Listening Segue" sender:self];
            break;
        }
        case 5: { //Choosing
            NSLog(@"Choosing Segue");
            [self performSegueWithIdentifier: @"Choosing Segue" sender:self];
            break;
        }
    
        case 6: { //Cartons
            NSLog(@"Cartons Segue");
            [self performSegueWithIdentifier: @"Cartons Segue" sender:self];
            break;
        }
    
        }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //self.wordset = [Wordset selectWordsetWithWID:self.wordset.wid managedObjectContext:self.wordset.managedObjectContext];
    NSLog(@"Number of words in this wordset in Core Data: %d", [self.wordset.words count]); 
    if([segue.destinationViewController respondsToSelector:@selector(setWordset:)]) {
       
        [segue.destinationViewController setWordset: self.wordset]; 
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void) getWordsInWordsetFromWebServices
{
    NSLog(@"Getting Words From Service Thread: %@", [NSThread currentThread]);
    NSString *wid = self.wordset.wid;
    
    NSString *urlAsString = nil;
    
    if([self.wordset.wid isEqualToString:@"FORGOTTEN"]) {
        NSString *emailAddress = [ProfileServices emailAddressFromUserDefaults];
        NSString *sha1Password = [ProfileServices sha1PasswordFromUserDefaults];
        urlAsString = [NSString stringWithFormat:kFORGOTTEN_WORDSET_SERVICE_URL, emailAddress, sha1Password, kLANG_FROM, kLANG_TO, nil];
    } else if([self.wordset.wid isEqualToString:@"REMEMBERME"]) {
        NSString *emailAddress = [ProfileServices emailAddressFromUserDefaults];
        NSString *sha1Password = [ProfileServices sha1PasswordFromUserDefaults];
        urlAsString = [NSString stringWithFormat:kREMEMBERME_WORDSET_SERVICE_URL, emailAddress, sha1Password, kLANG_FROM, kLANG_TO, nil];
        
    } else if([self.wordset.wid hasPrefix:@"USERWORDSET"]) {
        NSRange range = [wid rangeOfString:@"USERWORDSET_"];
        NSString *idOfUserWordset;
        if (range.location != NSNotFound)
        {
            //range.location is start of substring
            //range.length is length of substring
            idOfUserWordset= [wid substringFromIndex:range.location + range.length];
        }
        NSLog(@"User wordset id: %@", idOfUserWordset);
        urlAsString = [NSString stringWithFormat:kWORDS_IN_WORDSET_SERVICE_URL, idOfUserWordset, kTYPE_USERWORDSET, kLANG_FROM, kLANG_TO, nil];
    } else {
        //default wordset with wid as wordset identifier
       urlAsString = [NSString stringWithFormat: kWORDS_IN_WORDSET_SERVICE_URL,
                             wid, kTYPE_SYSTEMWORDSET, kLANG_FROM, kLANG_TO, nil];
    }
    
    NSURL *url = [NSURL URLWithString: urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval: 30.0f];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    
    __weak WordsetViewController *weakSelf = self;
    
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:queue
                           completionHandler:^(NSURLResponse * response, NSData *data, NSError *error) {
                               if([data length] > 0 && error == nil) {
                                   NSLog(@"URL Async Request Thread: %@", [NSThread currentThread]);
                                   XMLParser *xmlParser = [[XMLParser alloc] initWithData:data];
                                   self.xmlRoot = [xmlParser parseAndGetRootElement];
                                   [weakSelf traverseXMLStartingFromRootElement];
                                   [weakSelf.internetReachable stopNotifier];
                               } else if([data length] == 0 && error == nil) {
                                   NSLog(@"Nothing was downloaded.");
                               } else if(error != nil) {
                                   NSLog(@"Error happened = %@", error); 
                               }
                           }];

}

- (void) traverseXMLStartingFromRootElement {
    
    NSInteger numOfWords = [self.xmlRoot.subElements count];
    __block NSInteger currentWordCount = 0;
    __weak WordsetViewController *weakSelf = self;
    
    NSManagedObjectContext *temporaryContext =
    [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext = self.wordset.managedObjectContext;
   
    NSString *wordsetId = self.wordset.wid;
    __block Wordset *wordsetWithTempContext = nil;
    //we select Wordset object for temporary managed object contex
    [temporaryContext performBlock:^{
       wordsetWithTempContext = [Wordset selectWordsetWithWID:wordsetId managedObjectContext:temporaryContext];
    }];
    if([UserSettings recordingsAreSavedOnPhone]) {
        //setting that we will be downloading audio files for this wordset
        wordsetWithTempContext.isAudioStoredLocally = [NSNumber numberWithBool:YES];
    } else {
        //settig that audio should be played remotely from web server
        wordsetWithTempContext.isAudioStoredLocally = [NSNumber numberWithBool:NO];
    }
 
    [self.xmlRoot.subElements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        // we enumerate through each words in current wordset and insert them or update it in Core Data Model
        XMLElement *wordElement = (XMLElement *) obj;
        NSString *wid = [wordElement.attributes valueForKey:@"wid"];
        XMLElement *foreignWordElement = [wordElement.subElements objectAtIndex:0];
        XMLElement *nativeWordElement = [wordElement.subElements objectAtIndex:1];
        XMLElement *transcriptionElement = [wordElement.subElements objectAtIndex:2];
        XMLElement *imagePathElement = [wordElement.subElements objectAtIndex:3];
        XMLElement *audioPathElement = [wordElement.subElements objectAtIndex:4];
        XMLElement *sentencesElement = [wordElement.subElements objectAtIndex: 5];
        //XMLElement *postItElement = [wordElement.subElements objectAtIndex:6];
        
        NSLog(@"wid = %@, en = %@, pl = %@, img = %@, audio = %@", wid,
              foreignWordElement.text, nativeWordElement.text, imagePathElement.text, audioPathElement.text);
        
        NSLog(@"Traversing XML Thread: %@", [NSThread currentThread]);
        
        // we use this because managedObjectContext is not thread-safe, must be on the thread on which it was created
        
        //Increment number of downloaded word objects
        currentWordCount++;
        CGFloat progressInFloatPercent = ((CGFloat) currentWordCount)/numOfWords;
        
        [temporaryContext performBlock:^{
            // creating objects in our data model
            NSLog(@"Inserting Word to Core Data Thread: %@", [NSThread currentThread]);
            Word *word = [Word
                  wordWithWID: wid
                  foreignName: foreignWordElement.text
                   nativeName: nativeWordElement.text
                    imagePath: imagePathElement.text
                loadImageData: YES
                    audioPath: audioPathElement.text
                transcription: transcriptionElement.text
               foreignArticle: [foreignWordElement.attributes valueForKey:@"article"]
                nativeArticle: [nativeWordElement.attributes valueForKey:@"article"]
                    inWordset: wordsetWithTempContext
         managedObjectContext: temporaryContext];
            
            [self traverseSentences: sentencesElement forWord: word andSaveThemInCoreData: temporaryContext];
            // Calling save on the background context will push the changes up to the document.
            NSError *error = nil;
            [temporaryContext save:&error];
            
            // Now, the changes will have been pushed into the MOC of the document, but
            // the auto-save will not have fired.  You must make this call to tell the document
            // that it can save recent changes.
            //[self. updateChangeCount:UIDocumentChangeDone];
            [ElectorWebServices downloadAudioFileAndStoreOnDisk: audioPathElement.text];
            [weakSelf.progressDelegate setProgress: progressInFloatPercent];
        }];
        
        /*[self.wordset.managedObjectContext performBlock: ^(void) {
            NSLog(@"Inserting Word to Core Data Thread: %@", [NSThread currentThread]);
         
        }];*/
       
    }];
}

- (void) traverseSentences: (XMLElement *) sentencesElement forWord: (Word *) word andSaveThemInCoreData: (NSManagedObjectContext *) managedObjectContext
{
    
    [sentencesElement.subElements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        /* each subelement is sentence element */
        XMLElement *sentenceElement = (XMLElement *) obj;
        NSString *sentenceId = [sentenceElement.attributes valueForKey:@"sid"];
        XMLElement *foreignSentenceElement = [sentenceElement.subElements objectAtIndex:0];
        XMLElement *nativeSentenceElement = [sentenceElement.subElements objectAtIndex:1];
        XMLElement *recordingElement = [sentenceElement.subElements objectAtIndex:2];
        
        NSLog(@"Adding sentence to word: %@ with SID = %@ .", word.wordId, sentenceId);
        [Sentence sentenceWithSID:sentenceId
                      foreignText:foreignSentenceElement.text
                       nativeText:nativeSentenceElement.text
                        recording:recordingElement.text
                           inWord:word
              manageObjectContext:managedObjectContext];
        
    }];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self adjustToScreenOrientation];
}

- (void)viewDidUnload {
    [self setForeignNameLabel:nil];
    [self setNativeNameLabel:nil];
    [self setLevelLabel:nil];
    [self setDescriptionLabel:nil];
    [self setSyncBarButtonItem:nil];
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
