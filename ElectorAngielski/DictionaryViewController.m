//
//  DictionaryViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 07/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "DictionaryViewController.h"
#import "WordCell.h"
#import "Reachability.h"
#import "XMLParser.h"
#import "SuggestionObject.h"
#import "WordObject.h"
#import "Word+Create.h"
#import "UIImageView+AFNetworking.h"
#import "WordDetailsViewController.h"
#import "DictionaryWord+Create.h"
#import "DictionaryWordsViewController.h"
#import "ElectorWebServices.h"
#import "RememberMePopUpViewController.h"
#import "UIViewController+MJPopupViewController.h"

#define kLOOKUP_SERVICE_URL @"http://mnemobox.com/webservices/lookupWord.php?from=%@&to=%@&word=%@"
#define kLANG_FROM @"pl"
#define kLANG_TO @"en"
#define kNATIVE @"PL" //constant to pass to url into lang param if we want only native lang words
#define kFOREIGN @"EN" //like kNATIVE but if we want only foreign lang words
#define kWORD_DETAILS_SERVICE_URL @"http://www.mnemobox.com/webservices/getTranslationCollection.php?from=%@&to=%@&tids=%@"
#define kWORD_RECORDING_SERVICE_URL @"http://mnemobox.com/recordings/words/"


@interface DictionaryViewController ()
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (weak, nonatomic) IBOutlet UIButton *foreignButton;
@property (weak, nonatomic) IBOutlet UIButton *nativeButton;
@property (weak, nonatomic) IBOutlet UITextField *lookupTextField;
@property (weak, nonatomic) IBOutlet UIButton *lookupButton;
@property (weak, nonatomic) IBOutlet UITableView *suggestionsTableView;
@property (weak, nonatomic) IBOutlet UITableView *wordsTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *suggestionActivityIndicator;
@property (strong, nonatomic) RememberMePopUpViewController *rememberMePopUpViewController;

//data source - looked up words by the user via web services
//               for current search phrase in text field
@property (strong, nonatomic) NSArray *lookUpWords;
@property (strong, nonatomic) NSArray *lookUpSuggestions;

//timer to fire retrieving of suggestion through web services
//if user changes the value of textField befor 2 sec delay
//this timer prepered method invocation will be canceled
@property (strong, nonatomic) NSTimer *myTimer;
//this object enable to check internet access reachability
@property (strong, nonatomic) Reachability *internetReachable;
@property (strong, nonatomic) XMLElement *suggestionsXmlRoot;
@property (strong, nonatomic) XMLElement *wordDetailsXmlRoot;
//language filter - lookup words will be only searched in selected by the user language
@property (strong, nonatomic) NSString *languageFilter; 

@property (strong, nonatomic) NSIndexPath *accessoryButtonSelectedIndexPath;

@end

@implementation DictionaryViewController

@synthesize database = _database;

@synthesize lookUpWords = _lookUpWords;
@synthesize lookUpSuggestions = _lookUpSuggestions; 
@synthesize myTimer = _myTimer;
@synthesize languageFilter = _languageFilter;
@synthesize suggestionsXmlRoot = _suggestionsXmlRoot;
@synthesize accessoryButtonSelectedIndexPath = _accessoryButtonSelectedIndexPath;

- (IBAction)foreignButtonTouched:(UIButton *)sender {
    [sender setTitleColor: [UIColor redColor]
     forState: UIControlStateNormal];
    [self.nativeButton setTitleColor: [UIColor blackColor]
     forState:UIControlStateNormal];
    //now we set constraint on searching only in foreign words dictionary
    self.languageFilter = kFOREIGN; 
}

- (IBAction)nativeButtonTouched:(UIButton *)sender {
    [sender setTitleColor: [UIColor redColor]
                 forState:UIControlStateNormal];
    [self.foreignButton setTitleColor: [UIColor blackColor]
                             forState:UIControlStateNormal];
    //now we set constraint on searching only in native words dictionary
    self.languageFilter = kNATIVE;
}


- (IBAction)screenViewTouched:(UIControl *)sender {
    NSLog(@"Somewhere on the screen touched we close the suggestionTableView if opened.");
    [self.suggestionsTableView setHidden:YES]; 
}

- (IBAction)searchButtonTouched:(UIButton *)sender {
   
    NSLog(@"Search button touched.");
    [self.myTimer invalidate];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.suggestionsTableView setHidden:YES];
        [self.lookupTextField resignFirstResponder];
    });
    [self loadSuggestionsAsync: YES];

}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"Returning keyboard.");
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)textFieldEditingChanged:(UITextField *)sender {

    NSLog(@"TextField value changed... after 2 seconds if user hasn't edited textfield again we retrieve words suggestions.");
    [self.myTimer invalidate];
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(loadSuggestionsOnTextFieldChange) userInfo:nil repeats:NO];
}

- (void) loadSuggestionsOnTextFieldChange {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.suggestionActivityIndicator setHidden:NO];
        [self.suggestionActivityIndicator startAnimating];
    }); 
    [self loadSuggestionsAsync: NO];
}

- (void) loadSuggestionsAsync: (BOOL) searchButtonTouched
{
    NSLog(@"Loading suggestions asynchronously caused by search button: %d.", searchButtonTouched);
    
    if(self.internetReachable.isReachable) {
      //we have internet connection so we can get suggestions from web services
      
       NSString *word = self.lookupTextField.text;
       NSString *urlAsString = [NSString stringWithFormat:kLOOKUP_SERVICE_URL,
                                kLANG_FROM, kLANG_TO, word, nil];
        
        if(self.languageFilter != nil) {
            NSLog(@"User has selected language to filter word suggestions. We apply it to REST url"); 
            urlAsString = [urlAsString stringByAppendingFormat:@"&lang=%@", self.languageFilter, nil];
        }
        
        urlAsString = [urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //creating REST url
        NSURL *url = [NSURL URLWithString:urlAsString];
        
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setTimeoutInterval: 30.0f]; //after 30 seconds request will be cancelled
        [urlRequest setHTTPMethod:@"GET"];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        __weak DictionaryViewController *weakSelf = self;
        
        NSLog(@"Suggestion Lookup URL: %@", urlAsString); 
        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:queue
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   NSLog(@"Getting and Parsing XML with suggestions."); 
                                   XMLParser *xmlParser = [[XMLParser alloc] initWithData:data];
                                   self.suggestionsXmlRoot = [xmlParser parseAndGetRootElement];
                                   if(self.suggestionsXmlRoot != nil) { //if xml has been parsed properly i.e. without error
                                       [weakSelf traverseSuggestionsXMLStartingFromRootElement: searchButtonTouched];
                                   } else {
                                        [weakSelf.suggestionActivityIndicator stopAnimating];
                                   }
                               }];
        
    }
}

- (void) traverseSuggestionsXMLStartingFromRootElement: (BOOL) searchButtonTouched
{
  
    NSMutableArray *suggestionsArray = [[NSMutableArray alloc] init];
    
    NSLog(@"We are traversing all 'word suggestion' objects."); 
    [self.suggestionsXmlRoot.subElements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        XMLElement *wordSuggestionElement = (XMLElement *) obj;
        NSString *tids = [wordSuggestionElement.attributes valueForKey:@"tids"];
        //NSArray *tidsArray = [tids componentsSeparatedByString:@","];
        //we split it later when retrieving word details :)
        NSString *wordSuggestionText = wordSuggestionElement.text; //here we have word suggestion text to display as label
        SuggestionObject *suggestion = [SuggestionObject suggestionWithText:wordSuggestionText
                                                                andTidsList:tids];
        NSLog(@"Adding SuggestionObject to array: %@, %@.", wordSuggestionText, tids);
        [suggestionsArray addObject:suggestion];
    
    }];
  
    @synchronized(self.lookUpSuggestions) {
        self.lookUpSuggestions = suggestionsArray;
    }
    
    if([self.lookUpSuggestions count] > 0) { 
        if(searchButtonTouched) {
            
            //user instantiated suggestion loading
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.suggestionsTableView setHidden:YES];
                [self.lookupTextField resignFirstResponder];
            });
            [self reloadWordTableBasedOnCurrentSuggestions];
            
        } else {
            
           //automatic suggestion loading on textField edition 
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.suggestionsTableView setHidden: NO];
                [self.suggestionsTableView reloadData];
                [self.suggestionActivityIndicator stopAnimating];
            });
            
        }
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.lookupTextField.delegate = self;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    self.suggestionsTableView.layer.borderWidth = 1.0;
    self.suggestionsTableView.layer.borderColor = [UIColor grayColor].CGColor;
    
    UIBarButtonItem *saveWordBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemOrganize target:self action:@selector(saveWordBarButtonTouched:)];
    UIBarButtonItem *postItBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCompose target:self action:@selector(postItBarButtonTouched:)];
    UIBarButtonItem *rememberMeBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"barStar.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(rememberMeBarButtonTouched:)];
   UIBarButtonItem *shareBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAction target:self action:@selector(shareBarButtonTouched:)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: saveWordBarButton, postItBarButton, shareBarButton, rememberMeBarButton, nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /* if my database is nil we will create it */
    if(!self.database) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent: @"Wordset Database"];
        self.database = [[UIManagedDocument alloc] initWithFileURL:url];
    }
}

- (void) useDocument
{
    if(![[NSFileManager defaultManager] fileExistsAtPath: [self.database.fileURL path]]) {
        /* database not exists on disk so we need to creat it */
        [self.database saveToURL: self.database.fileURL forSaveOperation: UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            NSLog(@"database created on disk");
        }];
        
    } else if (self.database.documentState == UIDocumentStateClosed) {
        /* document is closed then we need to open the file */
        [self.database openWithCompletionHandler:^(BOOL success) {
            NSLog(@"wordsetDatabase was opened");
        }];
    } else if (self.database.documentState == UIDocumentStateNormal) {
        /* document exists for a given path and is opend */
        NSLog(@"database is in normal state (opened)");
    }
    
}

- (void) setDatabase:(UIManagedDocument *)database
{
    if( _database != database) {
        _database = database;
        [self useDocument];
    }
    
}


- (void) saveWordBarButtonTouched: (id) sender
{
    if([self.lookUpWords count] > 0) {
        NSInteger idx = [[self.wordsTableView indexPathForSelectedRow] row];
    
        NSLog(@"Save word bar button touched for word with idx: %d", idx);
   
        WordObject *wordObject = [self.lookUpWords objectAtIndex:idx];
    
        DictionaryWord *dictWord = [DictionaryWord dictionaryWordWithWID:wordObject.wordId
                              foreignName:wordObject.foreign
                               nativeName:wordObject.native
                                    image:wordObject.imagePath
                                audioPath:wordObject.recording
                            transcription:wordObject.transcription
                     managedObjectContext:self.database.managedObjectContext];
        NSLog(@"Saved Word into Dictionary Word with id: %@", dictWord.wordId);
    } else {
        NSLog(@"Couldn't select any row at table view, there are any word loaded.");
    }
}

- (void) rememberMeBarButtonTouched: (id) sender
{
    NSLog(@"Remember me word bar button touched");
    
    if([self.lookUpWords count] > 0) {
    
    NSInteger idx = [[self.wordsTableView indexPathForSelectedRow] row];
    WordObject *wordObject = [self.lookUpWords objectAtIndex: idx];
    
    if(self.internetReachable.isReachable) {
        // when we have internet connection we save this word to remember me section
        // directly to web server
        
        [ElectorWebServices saveWordToRememberMe: wordObject.wordId];
        
        [self showRememberMePopUp];
        [self.rememberMePopUpViewController.popUpLabel setText: @"Dodano do przypomnienia"];
    } else {
        // otherwise there is no internet connection and we stored this wordId in
        // userDefaults array
        NSLog(@"Saving current word to remember me locally in user defaults array");
        
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
        NSMutableSet *rememberMeWordIds = [[NSMutableSet alloc]
                                           initWithArray: [userDefaults valueForKey:@"rememberMeWordIdsArray"]];
        // add object uniquely
        [rememberMeWordIds addObject: wordObject.wordId];
        
        [userDefaults setObject: [rememberMeWordIds allObjects] forKey:@"rememberMeWordIdsArray"];
        
        [self showRememberMePopUp];
        [self.rememberMePopUpViewController.popUpLabel setText: @"Brak internetu. Zapisano lokalnie."];
        
        
        NSLog(@"%@", [userDefaults valueForKey:@"rememberMeWordIdsArray"]);
    }
    } else {
        NSLog(@"Couldn't select any row at table view, there are any word loaded.");
    }
    
}

- (void) showRememberMePopUp
{
    self.rememberMePopUpViewController = [[RememberMePopUpViewController alloc] initWithNibName:@"RememberMePopUpViewController" bundle:nil];
    [self presentPopupViewController:self.rememberMePopUpViewController animationType:MJPopupViewAnimationFade];
    [self.rememberMePopUpViewController.popUpImageView setHidden: NO];
    [self.rememberMePopUpViewController.popUpErrorImageView setHidden: YES];
}

- (void) postItBarButtonTouched: (id) sender
{
    NSLog(@"PostIt bar button touched");
    if([self.lookUpWords count] > 0) { 
        [self performSegueWithIdentifier:@"PostIt Segue" sender:self];
    } else {
         NSLog(@"Couldn't select any row at table view, there are any word loaded.");
    }
    
}

- (void) shareBarButtonTouched: (id) sender
{
    NSLog(@"Share bar button touched");
    
}

//TABLE VIEW DATA SOURCE AND DELEGATE METHODS
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch(tableView.tag) {
            
        case 1: {
            return [self.lookUpSuggestions count];
        }
        case 0:
        default: {
            return [self.lookUpWords count];
        }
    }
    
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (tableView.tag) {
     
        case 1: {
            return [self suggestionCellForTableView: tableView andRowAtIndexPath: indexPath];
        }
            
        case 0:
        default: {
            return [self wordCellForTableView: tableView andRowAtIndexPath: indexPath];
        }
            
    }
}

- (UITableViewCell *) suggestionCellForTableView: (UITableView *)tableView andRowAtIndexPath: (NSIndexPath *) indexPath
{
    static NSString *CellIdentifier = @"Suggestion Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Suggestion Cell"];
    }
    
    cell.textLabel.text = [[self.lookUpSuggestions objectAtIndex:[indexPath row]] text];
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
    
    return cell; 
}

- (UITableViewCell *) wordCellForTableView: (UITableView *)tableView andRowAtIndexPath: (NSIndexPath *) indexPath
{
    static NSString *CellIdentifier = @"Word Cell";
    WordCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[WordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Word Cell"];
    }
    
    if([indexPath row] < [self.lookUpWords count]) {
        NSLog(@"Reloading Word Cell at row: %d", [indexPath row]);
        __weak WordObject *word = [self.lookUpWords objectAtIndex:[indexPath row]];
        cell.wordLabel.text =  word.foreign;
        cell.transcriptionLabel.text = word.transcription;
        cell.translationLabel.text = word.native;
        cell.tag = [word.wordId integerValue];
    
        UIImageView * wordImageView = cell.wordImage;
        
        NSString *imageServer = kIMAGE_SERVER;
        NSString *imageFullPath = [imageServer stringByAppendingString: word.imagePath];
        NSURLRequest *imageURLRequst = [NSURLRequest requestWithURL:[NSURL URLWithString:imageFullPath]];
        
        [cell.wordImage setHidden:YES];
        [cell.activityIndicator setHidden: NO]; 
        [cell.activityIndicator startAnimating];
        __weak WordCell *weakCell = cell;
        [wordImageView setImageWithURLRequest:imageURLRequst placeholderImage: nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            [weakCell.wordImage setImage:image]; 
            [weakCell.wordImage setHidden:NO];
            [weakCell.activityIndicator stopAnimating];
            word.image = image;
            word.imageLoaded = YES;
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            [weakCell.activityIndicator stopAnimating];
            
        }];
        
        /*
        if(word.imageLoaded) {
            [wordImageView setImage: word.image];
        } else {
            [wordImageView setImage:nil]; 
            //[self loadAsyncImageForWord: word intoCell: wordImageView atIndexPath: indexPath];
        }*/
        
        UIImage *recordingImage = [UIImage imageNamed:@"detail_arrow.png"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = CGRectMake(44.0, 44.0, recordingImage.size.width/2, recordingImage.size.height/2);
        button.frame = frame;
        [button setBackgroundImage:recordingImage forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(accessoryButtonTapped:event:)
         forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor clearColor];
        cell.accessoryView = button;

        
    } else {
        NSLog(@"The index of Cell is out of words array. Reloading cell operation will be cancelled"); 
    }
    
    return cell; 
}
    
- (void) loadAsyncImageForWord: (WordObject *) word intoCell: (UIImageView *) wordImageView atIndexPath: (NSIndexPath *) indexPath {
    
      __weak DictionaryViewController *weakSelf = self;
       
     dispatch_async(dispatch_queue_create("com.company.app.imageQueue", NULL), ^{
            
            NSData *imageData = [Word imageDataWithImagePath: word.imagePath];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [UIImage imageWithData:imageData];
                [word setImage: image];
                [word setImageHeight:image.size.height];
                [word setImageLoaded: YES];
                
                //loading only whether user hasn't changed word in textField
                if([indexPath row] < [self.lookUpWords count]) {
                    NSLog(@"Reloading row: %d while image has been loaded.", [indexPath row]);
                    [weakSelf.wordsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
                
            });
        });
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch(tableView.tag) {
        case 1: {
            [self selectedSuggestionRowAtIndexPath: indexPath];
            break;
        }
        case 0:
        default: {
            [self selectedWordRowAtIndexPath: indexPath];
            break;
        }
    }
}

- (void) selectedSuggestionRowAtIndexPath: (NSIndexPath *) indexPath
{
    NSLog(@"Selected row at SuggestionTableView.");
    
    SuggestionObject *suggestion = [self.lookUpSuggestions objectAtIndex:[indexPath row]];
    
    [self.lookupTextField setText:suggestion.text];
    
    self.lookUpSuggestions = [NSMutableArray arrayWithObject:suggestion];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.suggestionsTableView setHidden:YES];
        [self.lookupTextField resignFirstResponder];
        [self.suggestionsTableView reloadData];
    }); 
    [self reloadWordTableBasedOnCurrentSuggestions];
}

- (void) selectedWordRowAtIndexPath: (NSIndexPath *) indexPath
{
    NSLog(@"Selected row at WordTableView.");
    
    NSString *audioPath = [[self.lookUpWords objectAtIndex:[indexPath row]] recording];
    
    NSString *urlAsString = kWORD_RECORDING_SERVICE_URL;
    urlAsString = [urlAsString stringByAppendingString: audioPath];
    NSLog(@"Audio Full Path: %@", urlAsString);
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    dispatch_async(dispatch_queue_create("com.company.app.audioQueue", NULL), ^{
        NSData *audioData = [NSData dataWithContentsOfURL: url];
        
        NSError *error = nil;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData: audioData error:&error];
        
        if(error) {
            NSLog(@"Error playing audio: %@",[error description]);
        } else {
            NSLog(@"Playing recording of word");
            self.audioPlayer.delegate = self;
            [self.audioPlayer prepareToPlay];
            [self.audioPlayer play];
        }
    });

    
}


- (void) reloadWordTableBasedOnCurrentSuggestions
{
    NSLog(@"Reloading Word Table based on current suggestions in self.lookupSuggestions array.");
    
    if(self.internetReachable.isReachable) {
    
    //we pass through array of SuggestionObjects and
    //based on wordIds (tidsList - translation ids list)
    //we create TIDs list concateneted by commas
    //we retrieve details of words and wrap it into
    //WordObject and next put into self.lookupWords array
    //at the end we refresh (reloadData) in Word TableView
    
    NSArray *lookUpSuggestions = [self.lookUpSuggestions copy];
        
    __block NSString *tidsList = @""; //we start with empty string which will grow up while enumerating all lookUp suggestions
        
    [lookUpSuggestions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        SuggestionObject *suggestion = (SuggestionObject *) obj;
        tidsList = [tidsList stringByAppendingFormat:@",%@",suggestion.tidsList, nil];
            
    }];
    
    if([tidsList length] > 1) { //we make request only if there are any translation ids, first character is comma!
        [self loadWordDetailsForTids: [tidsList substringFromIndex:1]]; //we start tidsList from index 1 to ommit first comma preceeding the string
    }
        
    } else {
        NSLog(@"Couldn't load the word details bacause of internet reachability problem.");
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet Connection Lost!" message:@"App couldn't search words because of internet connection problem..." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
            [alert show];
        });
    }
}

- (void) loadWordDetailsForTids: (NSString *)tidsList
{
    NSLog(@"Loading Word Details for TIDs: %@", tidsList);
    
    NSString *urlAsString = [NSString stringWithFormat:kWORD_DETAILS_SERVICE_URL, kLANG_FROM, kLANG_TO, tidsList, nil];
   
    //creating REST url
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval: 30.0f]; //after 30 seconds request will be cancelled
    [urlRequest setHTTPMethod:@"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
       
    NSLog(@"Word Details URL: %@", urlAsString);
    
    
    //we make this request asynchronously 
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                NSLog(@"Getting and Parsing XML with suggestions.");
                                XMLParser *xmlParser = [[XMLParser alloc] initWithData:data];
                                self.wordDetailsXmlRoot = [xmlParser parseAndGetRootElement];
                                [self traverseWordDetailsXMLStartingFromRootElement];
                           }];
    
}

- (void) traverseWordDetailsXMLStartingFromRootElement
{
    
    NSMutableArray *wordsArray = [[NSMutableArray alloc] init];
    //we are going through all downloaded words :)
    
    [self.wordDetailsXmlRoot.subElements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        XMLElement *wordElement = (XMLElement *) obj;
        
        NSString *wordId = [wordElement.attributes valueForKey:@"tid"];
        NSLog(@"Traversing Word Details with ID: %@", wordId);
        
        NSString *nativeWordText = [[wordElement.subElements objectAtIndex:0] text];
        NSString *foreignWordText = [[wordElement.subElements objectAtIndex:1] text];
        NSString *transcriptionText = [[wordElement.subElements objectAtIndex:2] text];
        NSString *audioPath = [[wordElement.subElements objectAtIndex:3] text];
        //we get only first from possible images set
        NSArray *imageElements = [[wordElement.subElements objectAtIndex:4] subElements];
        NSString *imagePath = @"";
        if([imageElements count] > 0) {
            imagePath = [[imageElements objectAtIndex:0] text];
        }
        //we doesn't get sentences.... it will be loaded only if user segues to WordDetailsViewController
        //by selecting suitable row in Word Table View....

        WordObject *wordObject = [[WordObject alloc] initWithWID:wordId
                                                     foreignName:foreignWordText
                                                      nativeName:nativeWordText
                                                       imagePath:imagePath
                                                       audioPath:audioPath
                                                   transcription:transcriptionText
                                                  foreignArticle:@""
                                                   nativeArticle:@""];
        
        [wordsArray addObject:wordObject];
    }];
    
    @synchronized(self.lookUpWords) {
        self.lookUpWords = wordsArray;
    }
    if([self.lookUpWords count] > 0) { 
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.wordsTableView reloadData];
        });
    }
}

- (void)accessoryButtonTapped:(id)sender event:(id)event
{
    
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.wordsTableView];
    NSIndexPath *indexPath = [self.wordsTableView indexPathForRowAtPoint: currentTouchPosition];
    if (indexPath != nil) {
        [self tableView: self.wordsTableView accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
}

- (void) tableView: (UITableView *) tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Accessory Button Tapped - Manual Word Details Segue");
    self.accessoryButtonSelectedIndexPath = indexPath;
    
    [self performSegueWithIdentifier:@"Word Details Segue" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //ListOfWordsViewController *viewcontroller
    if([segue.identifier isEqualToString:@"Word Details Segue"]) {
        NSLog(@"Prepare For Word Details Segue");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
                WordObject *wordObject = [self.lookUpWords objectAtIndex: [self.accessoryButtonSelectedIndexPath row]];
                [segue.destinationViewController setWordObject: wordObject];
            
        });
        
    } else if([segue.identifier isEqualToString:@"Dictionary Words Segue"]) {
       
        [segue.destinationViewController setDatabase: self.database];
        
    }  else if([segue.identifier isEqualToString:@"PostIt Segue"] &&
               [segue.destinationViewController respondsToSelector:@selector(setWordObject:)]) {
        
        
               NSInteger idx = [[self.wordsTableView indexPathForSelectedRow] row];
        
               WordObject *wordObject = [self.lookUpWords objectAtIndex: idx];
               [segue.destinationViewController setWordObject: wordObject];
    }

}

   // [self.wordsTableView indexPathForSelectedRow]


- (void)viewDidUnload {
    [self setForeignButton:nil];
    [self setNativeButton:nil];
    [self setLookupTextField:nil];
    [self setLookupButton:nil];
    [self setSuggestionsTableView:nil];
    [self setWordsTableView:nil];
    [self setSuggestionActivityIndicator:nil];
    [super viewDidUnload];
}
@end
