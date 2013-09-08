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

#define kLOOKUP_SERVICE_URL @"http://mnemobox.com/webservices/lookupWord.php?from=%@&to=%@&word=%@"
#define kLANG_FROM @"pl"
#define kLANG_TO @"en"
#define kNATIVE @"PL" //constant to pass to url into lang param if we want only native lang words
#define kFOREIGN @"EN" //like kNATIVE but if we want only foreign lang words
#define kWORD_DETAILS_SERVICE_URL @"http://www.mnemobox.com/webservices/getTranslationCollection.php?from=%@&to=%@&tids=%@"

@interface DictionaryViewController ()
@property (weak, nonatomic) IBOutlet UIButton *foreignButton;
@property (weak, nonatomic) IBOutlet UIButton *nativeButton;
@property (weak, nonatomic) IBOutlet UITextField *lookupTextField;
@property (weak, nonatomic) IBOutlet UIButton *lookupButton;
@property (weak, nonatomic) IBOutlet UITableView *suggestionsTableView;
@property (weak, nonatomic) IBOutlet UITableView *wordsTableView;

//data source - looked up words by the user via web services
//               for current search phrase in text field
@property (strong, nonatomic) NSMutableArray *lookUpWords;
@property (strong, nonatomic) NSMutableArray *lookUpSuggestions;

//timer to fire retrieving of suggestion through web services
//if user changes the value of textField befor 2 sec delay
//this timer prepered method invocation will be canceled
@property (strong, nonatomic) NSTimer *myTimer;
@property (nonatomic) BOOL showLookUpTableView;
@property (nonatomic) BOOL searchButtonDidTouched;
//this object enable to check internet access reachability
@property (strong, nonatomic) Reachability *internetReachable;
@property (strong, nonatomic) XMLElement *suggestionsXmlRoot;
@property (strong, nonatomic) XMLElement *wordDetailsXmlRoot;
//language filter - lookup words will be only searched in selected by the user language
@property (strong, nonatomic) NSString *languageFilter; 

@end

@implementation DictionaryViewController


@synthesize lookUpWords = _lookUpWords;
@synthesize lookUpSuggestions = _lookUpSuggestions; 
@synthesize myTimer = _myTimer;
@synthesize languageFilter = _languageFilter;
@synthesize suggestionsXmlRoot = _suggestionsXmlRoot;
@synthesize showLookUpTableView = _showLookUpTableView;

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
    
    self.searchButtonDidTouched = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.suggestionsTableView setHidden:YES];
        [self.lookupTextField resignFirstResponder];
    });
    [self loadSuggestionsAsync];

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
    if(!self.searchButtonDidTouched) {
        self.myTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(loadSuggestionsAsync) userInfo:nil repeats:NO];
        self.showLookUpTableView = YES;
    }
}

- (void) loadSuggestionsAsync
{
    NSLog(@"Loading Suggestions Asynchronously."); 
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
        
        NSLog(@"Making URL asynchonous request to: %@", urlAsString); 
        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:queue
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   //....code here
                                   NSLog(@"Getting and Parsing XML with suggestions."); 
                                   XMLParser *xmlParser = [[XMLParser alloc] initWithData:data];
                                   self.suggestionsXmlRoot = [xmlParser parseAndGetRootElement];
                                   if(self.suggestionsXmlRoot != nil) { //if xml has been parsed properly i.e. without error
                                       [weakSelf traverseSuggestionsXMLStartingFromRootElement];
                                   } else { //error occured while parsing xml - do not travers it!
                                       //we are reseting flag variables 
                                       self.showLookUpTableView = NO;
                                       self.searchButtonDidTouched = NO;
                                   }
                               }];
        
    }
}

- (void) traverseSuggestionsXMLStartingFromRootElement
{
    //making self.lookupSuggestions an empty mutable array to which we will be adding new
    //suggestion objects
    self.lookUpSuggestions = [[NSMutableArray alloc] initWithCapacity:[self.suggestionsXmlRoot.subElements count]];
    
    NSLog(@"We are traversing all 'word suggestion' objects."); 
    [self.suggestionsXmlRoot.subElements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        //...
        XMLElement *wordSuggestionElement = (XMLElement *) obj;
        NSString *tids = [wordSuggestionElement.attributes valueForKey:@"tids"];
        //NSArray *tidsArray = [tids componentsSeparatedByString:@","];
        //we split it later when retrieving word details :)
        NSString *wordSuggestionText = wordSuggestionElement.text; //here we have word suggestion text to display as label
        SuggestionObject *suggestion = [SuggestionObject suggestionWithText:wordSuggestionText
                                                                andTidsList:tids];
        NSLog(@"Adding SuggestionObject to array: %@, %@.", wordSuggestionText, tids);
        [self.lookUpSuggestions addObject:suggestion]; 
    
    }];
    
    if([self.lookUpSuggestions count] > 0 && self.showLookUpTableView) {
        self.showLookUpTableView = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.suggestionsTableView setHidden: NO];
            [self.suggestionsTableView reloadData];
            
        });
        
    } else if(self.searchButtonDidTouched) {
        self.searchButtonDidTouched = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.suggestionsTableView setHidden:YES];
            [self.lookupTextField resignFirstResponder];
        });
        [self reloadWordTableBasedOnCurrentSuggestions];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.lookupTextField.delegate = self;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    self.showLookUpTableView = NO;
    self.searchButtonDidTouched = NO;
    self.suggestionsTableView.layer.borderWidth = 1.0;
    self.suggestionsTableView.layer.borderColor = [UIColor grayColor].CGColor;
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
        WordObject *word = [self.lookUpWords objectAtIndex:[indexPath row]];
        cell.wordLabel.text =  word.foreign;
        cell.transcriptionLabel.text = word.transcription;
        cell.translationLabel.text = word.native;
        cell.tag = [word.wordId integerValue];
    
        UIImageView * wordImageView = cell.wordImage;
        if(word.imageLoaded) {
            [wordImageView setImage: word.image];
        } else {
            [wordImageView setImage:nil]; 
            [self loadAsyncImageForWord: word intoCell: wordImageView atIndexPath: indexPath];
        }
        
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
                if(self.lookupTextField.text && ([word.foreign hasPrefix:self.lookupTextField.text] || [word.native hasPrefix: self.lookupTextField.text])) {
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
}


- (void) reloadWordTableBasedOnCurrentSuggestions
{
    NSLog(@"Reloading Word Table based on current suggestions in self.lookupSuggestions array.");
    
    if(self.internetReachable.isReachable) {
    
    //emptying NSMutableArray
    self.lookUpWords = [[NSMutableArray alloc] initWithCapacity:[self.lookUpSuggestions count]];

    //we pass through array of SuggestionObjects and
    //based on wordIds (tidsList - translation ids list)
    //we create TIDs list concateneted by commas
    //we retrieve details of words and wrap it into
    //WordObject and next put into self.lookupWords array
    //at the end we refresh (reloadData) in Word TableView
        
    __block NSString *tidsList = @""; //we start with empty string which will grow up while enumerating all lookUp suggestions
        
    [self.lookUpSuggestions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
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
        if(self.lookupTextField.text && ( [nativeWordText hasPrefix:self.lookupTextField.text] || [foreignWordText hasPrefix: self.lookupTextField.text] )) {
            [self.lookUpWords addObject:wordObject];
        }
    }];
    
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.wordsTableView reloadData];
        });
}

- (void)viewDidUnload {
    [self setForeignButton:nil];
    [self setNativeButton:nil];
    [self setLookupTextField:nil];
    [self setLookupButton:nil];
    [self setSuggestionsTableView:nil];
    [self setWordsTableView:nil];
    [super viewDidUnload];
}
@end
