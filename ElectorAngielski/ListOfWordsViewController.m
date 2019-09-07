//
//  ListOfWordsViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 24/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "ListOfWordsViewController.h"
#import "Word+Create.h"
#import "WordCell.h"
#import "WordObject.h"
#import "XMLParser.h"
#import "Reachability.h"
#import "WordDetailsViewController.h"
#import "ProfileServices.h"
#import "iOSVersion.h"

#define IDIOM UI_USER_INTERFACE_IDIOM()
#define IPAD UIUserInterfaceIdiomPad
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
#define kWORD_RECORDING_SERVICE_URL @"http://mnemobox.com/recordings/words/"

@interface ListOfWordsViewController ()
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) IBOutlet UITableView *listOfWordsTableView;
@property (nonatomic) BOOL wordsStoredInCoreData;
@property (nonatomic, strong) NSMutableArray *words;
@property (nonatomic, strong) XMLElement *xmlRoot;
@property (nonatomic, strong) Reachability *internetReachable;
@property (nonatomic, strong) UIBarButtonItem *barButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSIndexPath *accessoryButtonSelectedIndexPath;
@end

@implementation ListOfWordsViewController

@synthesize wordset = _wordset;
@synthesize wordsStoredInCoreData = _wordsStoredInCoreData;
@synthesize words = _words;
@synthesize accessoryButtonSelectedIndexPath = _accessoryButtonSelectedIndexPath;

- (void) setWordset:(Wordset *)wordset
{
    if(_wordset != wordset ) {
        _wordset = wordset;
        if([wordset.words count] > 0) {
            NSLog(@"Words are preloaded in Core Data, we can get it from there");
            self.wordsStoredInCoreData = YES;
            self.words = [[self.wordset.words allObjects] mutableCopy];
        } else {
            NSLog(@"Words should be retrieved from web services"); 
            self.wordsStoredInCoreData = NO;
            
            self.activityIndicator = [[UIActivityIndicatorView alloc]
                                          initWithFrame:CGRectMake(0, 0, 20, 20)];
            self.barButton = [[UIBarButtonItem alloc]
                                  initWithCustomView:self.activityIndicator];
            [self navigationItem].rightBarButtonItem = self.barButton;
            [self.activityIndicator startAnimating];
            
            __weak ListOfWordsViewController *weakSelf = self;
            
            self.internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
            
            // Internet is reachable
            self.internetReachable.reachableBlock = ^(Reachability*reach)
            {
                // Update the UI on the main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSLog(@"Yayyy, we have the interwebs!");
                 
                    [weakSelf getWordsInWordsetFromWebServices];
                    
                });
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
    }
  
}

- (void) getWordsInWordsetFromWebServices
{
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
    
    NSLog(@"Words in Wordset URL: %@", urlAsString);
    NSURL *url = [NSURL URLWithString: urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval: 30.0f];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    __weak ListOfWordsViewController *weakSelf = self;
    
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:queue
                           completionHandler:^(NSURLResponse * response, NSData *data, NSError *error) {
                               if([data length] > 0 && error == nil) {
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

- (void) traverseXMLStartingFromRootElement
{
     __weak ListOfWordsViewController *weakSelf = self;
    self.words = [[NSMutableArray alloc] init];
    
    
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
        XMLElement *postItElement = [wordElement.subElements objectAtIndex:6];
        
        NSLog(@"wid = %@, en = %@, pl = %@, img = %@, audio = %@", wid,
              foreignWordElement.text, nativeWordElement.text, imagePathElement.text, audioPathElement.text);
        
        
        /* creating word object */
        WordObject *word = [[WordObject alloc] initWithWID: wid
                  foreignName: foreignWordElement.text
                   nativeName: nativeWordElement.text
                    imagePath: imagePathElement.text
                    audioPath: audioPathElement.text
                transcription: transcriptionElement.text
               foreignArticle: [foreignWordElement.attributes valueForKey:@"article"]
                nativeArticle: [nativeWordElement.attributes valueForKey:@"article"]];
        NSLog(@"Loading WordObject: %@ from Web Services to words array", word.foreign);
        
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
               // [weakSelf.listOfWordsTableView reloadData];
               // [weakSelf.listOfWordsTableView beginUpdates];
                [weakSelf.words addObject: word];
                //[weakSelf.listOfWordsTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] //withRowAnimation:UITableViewRowAnimationAutomatic];
                //[weakSelf.listOfWordsTableView endUpdates];
                [weakSelf.listOfWordsTableView reloadData];
        });
        
        
        
    }];
                                
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bigben.png"]];
    tempImageView.contentMode = UIViewContentModeScaleAspectFill;
    [tempImageView setFrame:self.tableView.frame];
    self.tableView.backgroundView = tempImageView;
    [self adjustToScreenOrientation];
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
        UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"london.png"]];
        tempImageView.contentMode = UIViewContentModeScaleAspectFill;
        [tempImageView setFrame:self.tableView.frame];
        self.tableView.backgroundView = tempImageView;
        
        
    }  else if (UIDeviceOrientationIsPortrait(deviceOrientation) &&
                deviceOrientation != UIDeviceOrientationPortraitUpsideDown)
    {
        UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bigben.png"]];
        tempImageView.contentMode = UIViewContentModeScaleAspectFill;
        [tempImageView setFrame:self.tableView.frame];
        self.tableView.backgroundView = tempImageView;
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSLog(@"Number of rows in tableView: %d", [self.words count]);
    [self.activityIndicator startAnimating];
    [self performSelector:@selector(stopActivityIndicatorAnimation) withObject:nil afterDelay: 2.0f];
    
    
    return [self.words count];
}

- (void) stopActivityIndicatorAnimation {
    [self.activityIndicator stopAnimating];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Word Cell";
    WordCell *cell;
    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        NSLog(@"Creating TableViewCell for iOS version < 6.0");
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil) {
            cell = [[WordCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }
    // Configure the cell...
    if(self.wordsStoredInCoreData) {
        // we load word cell from core data storage -> NSMutableArray *words contains Word (NSManagedObject) objects 
        cell = [self usingCoreDataCreateWordCell:cell forRowAtIndexPath:indexPath];
    } else {
        // we load word cell directly from web services -> NSMutableArray *words contains WordObject
        cell.wordImage.image = nil;
        cell = [self usingWebServicesCreateWordCell:cell forRowAtIndexPath: indexPath];
    }
    
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

    return cell;
}

- (WordCell *)usingCoreDataCreateWordCell: (WordCell *) cell forRowAtIndexPath: (NSIndexPath *) indexPath
{
    Word *word = [self.words objectAtIndex: [indexPath row]];
    cell.wordLabel.text = [NSString stringWithFormat:@"%@ %@", word.foreignArticle,
                           word.foreign,nil];
    cell.translationLabel.text = [NSString stringWithFormat:@"%@ %@",  word.nativeArticle, word.native, nil];
    UIImageView * wordImageView = cell.wordImage;
    wordImageView.image = [UIImage imageWithData: word.image];
    cell.transcriptionLabel.text = word.transcription;
    
    return cell;
}

- (void)accessoryButtonTapped:(id)sender event:(id)event
{
    
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
    if (indexPath != nil) {
        [self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
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
        
        if(self.wordsStoredInCoreData) {
            /* we have Word object from Core Data database, we can pass it to next View Controller */
            Word *word = [self.words objectAtIndex: [self.accessoryButtonSelectedIndexPath row]];
            [segue.destinationViewController setWord: word];
        } else {
            /* we have WordObject object with data from web services, details e.g. sentences should be 
               retrieved additionaly from web services after segue */
            WordObject *wordObject = [self.words objectAtIndex: [self.accessoryButtonSelectedIndexPath row]];
             [segue.destinationViewController setWordObject: wordObject];
        }
        
    });
        
    }
}

- (WordCell *)usingWebServicesCreateWordCell: (WordCell *) cell forRowAtIndexPath: (NSIndexPath *) indexPath
{
   
    WordObject *word = [self.words objectAtIndex: [indexPath row]];
    cell.wordLabel.text = [NSString stringWithFormat:@"%@ %@", word.foreignArticle,
                           word.foreign,nil];
    cell.translationLabel.text = [NSString stringWithFormat:@"%@ %@",  word.nativeArticle, word.native, nil];
    UIImageView * wordImageView = cell.wordImage;
    if(word.imageLoaded) {
        [wordImageView setImage: word.image];
    } else { 
    __weak ListOfWordsViewController *weakSelf = self;
    dispatch_async(dispatch_queue_create("com.company.app.imageQueue", NULL), ^{
        NSData *imageData = [Word imageDataWithImagePath: word.imagePath];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithData:imageData];
            [word setImage: image];
            [word setImageHeight:image.size.height];
            [word setImageLoaded: YES]; 
            [weakSelf.listOfWordsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        });
    });
    }
    cell.transcriptionLabel.text = word.transcription;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0f;
    
    if(self.wordsStoredInCoreData) {
        Word *word = [self.words objectAtIndex: [indexPath row]];
        UIImage *image = [UIImage imageWithData: word.image];
        height = image.size.height;
    } else {
        WordObject *word = [self.words objectAtIndex: [indexPath row]];
        height = word.imageHeight;
    }
    
    if( IDIOM != IPAD && height > 80.0f) { height = 80.0f; }
    else if( IDIOM == IPAD) { height = 170.0f; }
    
    return 80.0f + height;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
    NSString *audioPath = nil; 
    if(self.wordsStoredInCoreData) {
        Word *word = [self.words objectAtIndex: [indexPath row]];
        audioPath = word.recording;
    } else {
        WordObject *word = [self.words objectAtIndex: [indexPath row]];
        audioPath = word.recording;
    }
    
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

- (void)viewDidUnload {
    [self setListOfWordsTableView:nil];
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
