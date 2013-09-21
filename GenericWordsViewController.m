//
//  GenericWordsViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 17/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "GenericWordsViewController.h"
#import "XMLParser.h"
#import "WordCell.h"
#import "UIViewController+MJPopupViewController.h"
#import "UIImageView+AFNetworking.h"
#import "WordDetailsViewController.h"
#import "GenericLearningViewController.h"

//recording URL
#define kWORD_RECORDING_SERVICE_URL @"http://mnemobox.com/recordings/words/"

@interface GenericWordsViewController ()

@property (strong, nonatomic) XMLElement *xmlRoot;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSIndexPath *accessoryButtonSelectedIndexPath;

@end

@implementation GenericWordsViewController

@synthesize database = _database;
@synthesize xmlRoot = _xmlRoot;
@synthesize accessoryButtonSelectedIndexPath = _accessoryButtonSelectedIndexPath;
@synthesize genericWordset = _genericWordset;

/************ PullUpView **************/
@synthesize pullUpView = _pullUpView;
@synthesize pullUpLabel = _pullUpLabel;
@synthesize presentationButton = _presentationButton;
@synthesize repetitionButton = _repetitionButton;
@synthesize speakingButton = _speakingButton;
@synthesize listeningButton = _listeningButton;
@synthesize choosingButton = _choosingButton;
@synthesize cartonsButton = _cartonsButton;
/**************************************/

- (void)pullableView:(PullableView *)pView didChangeState:(BOOL)opened
{
    NSLog(@"Pullable View Did Changed State Delegate Method.");
}

- (void) setDatabase:(UIManagedDocument *)database
{
    if(_database != database) {
        _database = database;
        [self useDocument];
    }
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden: NO animated: YES];
    self.internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    /* if my database is nil we will create it */
    NSLog(@"Creating UIManagedDocument for Core Data access in viewWillAppear.");
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent: @"Wordset Database"];
    self.database = [[UIManagedDocument alloc] initWithFileURL:url];

}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(!self.pullUpView)
        [self setUpPullUpView];
}

- (void) useDocument
{
    if(![[NSFileManager defaultManager] fileExistsAtPath: [self.database.fileURL path]]) {
        /* database not exists on disk so we need to creat it */
        [self.database saveToURL: self.database.fileURL forSaveOperation: UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            NSLog(@"database created on disk");
            [self createOrUpdateGenericWordsetInCoreData];
            [self loadGenericWordsFromWebServices];
            [self setupFetchedResultsController];
        }];
        
    } else if (self.database.documentState == UIDocumentStateClosed) {
        /* document is closed then we need to open the file */
        [self.database openWithCompletionHandler:^(BOOL success) {
            NSLog(@"wordsetDatabase was opened");
            [self createOrUpdateGenericWordsetInCoreData];
            [self loadGenericWordsFromWebServices];
            [self setupFetchedResultsController];
        }];
    } else if (self.database.documentState == UIDocumentStateNormal) {
        /* document exists for a given path and is opend */
        NSLog(@"database is in normal state (opened)");
        [self createOrUpdateGenericWordsetInCoreData];
        [self loadGenericWordsFromWebServices];
        [self setupFetchedResultsController];
    }
    
}

- (void) setupFetchedResultsController {
    //self.fetchedResultsControlle = ...
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
    //[cd] meand case insensitive (c) and diacritic insensitive (d) it is many-to-many predicate
    request.predicate = [NSPredicate predicateWithFormat:@"ANY inWordsets.wid =[cd] %@", self.genericWordset.wid];
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"foreign" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDesc];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.database.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}


- (void) loadGenericWordsFromWebServices
{
    NSLog(@"Loading generic words from web services into Core Data database...");
    
    
    __weak GenericWordsViewController *weakSelf = self;
    
    //Internet is reachable
    self.internetReachable.reachableBlock = ^(Reachability *reach) {
        
        //Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Yayyy, we have the interwebs!");
        });
        
        [weakSelf getGenericWordsFromWebServices];
    };
    
    //Internet is not reachable.
    self.internetReachable.unreachableBlock = ^(Reachability *reach)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Someone broke the internet :(");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet connection lost!"
                                                            message:@"Check whether you have internet access."
                                                           delegate: weakSelf
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            
            [weakSelf.internetReachable stopNotifier];
        });
    };
    
    [self.internetReachable startNotifier];
    
}


- (void) getGenericWordsFromWebServices
{
    NSLog(@"Quering Web Services for Generic Words as XML.");
    
    NSURL *url = [self getWebServicesURL];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    __weak GenericWordsViewController *weakSelf = self;
    
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
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
    //__weak ForgottenWordsViewController *weakSelf = self;
    
    //we collect words actually finden in Forgotten into NSSet (with Word objects) and next we override actual
    //generic (ex. forgotten, userwordset, rememberme) wordset words property with this set :)
    __block NSMutableSet *genericWords = [[NSMutableSet alloc] init];
    
    [self.xmlRoot.subElements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //we enumerate through each words in current i.e. forgotten words wordset and insert them or update it in Core Data Model
        
        XMLElement *wordElement = (XMLElement *) obj;
        NSString *wid = [wordElement.attributes valueForKey:@"wid"];
        XMLElement *foreignWordElement = [wordElement.subElements objectAtIndex:0];
        XMLElement *nativeWordElement = [wordElement.subElements objectAtIndex:1];
        XMLElement *transcriptionElement = [wordElement.subElements objectAtIndex:2];
        XMLElement *imagePathElement = [wordElement.subElements objectAtIndex:3];
        XMLElement *audioPathElement = [wordElement.subElements objectAtIndex:4];
        //XMLElement *sentencesElement = [wordElement.subElements objectAtIndex: 5];
        //XMLElement *postItElement = [wordElement.subElements objectAtIndex:6];
        
        NSLog(@"wid = %@, en = %@, pl = %@, img = %@, audio = %@", wid,
              foreignWordElement.text, nativeWordElement.text, imagePathElement.text, audioPathElement.text);
        
        
        /*creating Word object */
        [self.database.managedObjectContext performBlock:^{
            Word *word = [Word wordWithWID: wid
                               foreignName: foreignWordElement.text
                                nativeName: nativeWordElement.text
                                 imagePath: imagePathElement.text
                             loadImageData:NO
                                 audioPath: audioPathElement.text
                             transcription: transcriptionElement.text
                            foreignArticle: [foreignWordElement.attributes valueForKey:@"article"]
                             nativeArticle: [nativeWordElement.attributes valueForKey:@"article"]
                                 inWordset: self.genericWordset
                      managedObjectContext: self.database.managedObjectContext];
            
            if(word != nil) {
                [genericWords addObject:word];
            }
        }];
    }];
    
    //we are updating Generic (ex.Forgotten, UserWordset, RememberMe) Wordset Words
    [self.database.managedObjectContext performBlock:^{
        self.genericWordset.words = (NSSet *) genericWords;
    }]; 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Word Cell";
    
    WordCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil) {
        cell = [[WordCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:
                CellIdentifier];
    }
    
    Word *word = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if(word.foreignArticle) {
        [cell.wordLabel setText: [NSString stringWithFormat:@"%@ %@",
                                  word.foreignArticle, word.foreign]];
    } else {
        [cell.wordLabel setText: word.foreign];
    }
    if(word.nativeArticle) {
        [cell.translationLabel setText: [NSString stringWithFormat:@"%@ %@",
                                         word.nativeArticle, word.native]];
    } else {
        [cell.translationLabel setText: word.native];
    }
    [cell.transcriptionLabel setText: word.transcription];
    
    [cell.wordImage setHidden:YES];
    if(word.image != nil) {
        [cell.wordImage setImage: [UIImage imageWithData: word.image]];
        [cell.wordImage setHidden:NO];
    } else if( word.imagePath != nil) {
        NSString *imageServer = kIMAGE_SERVER;
        NSString *imageFullPath = [imageServer stringByAppendingString: word.imagePath];
        NSURLRequest *imageURLRequst = [NSURLRequest requestWithURL:[NSURL URLWithString:imageFullPath]];
        
        [cell.activityIndicator setHidden: NO];
        [cell.activityIndicator startAnimating];
        __weak WordCell *weakCell = cell;
        [cell.wordImage setImageWithURLRequest:imageURLRequst
                              placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                  
                                  [weakCell.wordImage setImage: image];
                                  [weakCell.wordImage setHidden:NO];
                                  [weakCell.activityIndicator stopAnimating];
                                  NSData *imageData = UIImagePNGRepresentation(image);
                                  word.image = imageData;
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [self.tableView reloadRowsAtIndexPaths: [NSArray arrayWithObject:indexPath] withRowAnimation:NO];
                                  });
                                  
                                  
                              } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                  NSLog(@"Error while loading image: %@", error);
                                  [weakCell.activityIndicator stopAnimating];
                              }];
    }
    
    
    
    //adding accesory button
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

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected row at Generic Word Table.");
    
    NSString *audioPath = [[self.fetchedResultsController objectAtIndexPath: indexPath] recording];
    NSString *urlAsString = kWORD_RECORDING_SERVICE_URL;
    urlAsString = [urlAsString stringByAppendingString: audioPath];
    NSLog(@"Audio Full Path: %@", urlAsString);
    NSURL *url = [NSURL URLWithString: urlAsString];
    
    dispatch_async(dispatch_queue_create("com.company.app.audioQueue", NULL), ^{
        
        NSData *audioData = [NSData dataWithContentsOfURL: url];
        NSError *error = nil;
        
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData: audioData error:&error];
        if(error) {
            NSLog(@"Error playing audio: %@", [error description]);
        } else {
            NSLog(@"Playing recording of word.");
            self.audioPlayer.delegate = self;
            [self.audioPlayer prepareToPlay];
            [self.audioPlayer play];
        }
        
    });
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

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Word Details Segue"]) {
        
        NSLog(@"Prepare For Word Details Segue");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            Word *word = [self.fetchedResultsController objectAtIndexPath: self.accessoryButtonSelectedIndexPath];
            
            [segue.destinationViewController setWord: word];
        });
        
    } else if([segue.destinationViewController respondsToSelector:@selector(setWordset:)]) {
        
        NSLog(@"Number of words in this wordset in Core Data: %d", [self.genericWordset.words count]);
        [segue.destinationViewController setWordset: self.genericWordset];
        
    }
    
}

- (void) setUpPullUpView {
    
    CGFloat xOffset = 0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        xOffset = 224;
    }
    self.pullUpView = [[PullableView alloc] initWithFrame:CGRectMake(xOffset, 0, 320, 460)];
    self.pullUpView.openedCenter = CGPointMake(160 + xOffset,self.view.frame.size.height);
    self.pullUpView.closedCenter = CGPointMake(160 + xOffset, self.view.frame.size.height + 220);
    self.pullUpView.center = self.pullUpView.closedCenter;
    self.pullUpView.handleView.frame = CGRectMake(0, 0, 320, 10);
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
    
    
    
    self.pullUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 95)];
    self.pullUpLabel.textAlignment = UITextAlignmentLeft;
    self.pullUpLabel.backgroundColor = [UIColor clearColor];
    self.pullUpLabel.textColor = [UIColor whiteColor];
    self.pullUpLabel.text = @"Wybierz metodę nauki słówek:";
    self.pullUpLabel.adjustsFontSizeToFitWidth = YES;
    self.pullUpLabel.minimumFontSize = 8.0f;
    self.pullUpLabel.numberOfLines = 4;
    self.pullUpLabel.font = [UIFont systemFontOfSize:15.0];
    
    [self.pullUpView addSubview:self.pullUpLabel];
    
    
    self.presentationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.presentationButton.frame = CGRectMake(30,70, 50,50);
    [self.presentationButton setBackgroundImage: [UIImage imageNamed:@"presentation_round.png"] forState:UIControlStateNormal];
    [self.presentationButton addTarget:self action:@selector(presentationButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.presentationButton setTitle: @"Prezentacja" forState:UIControlStateNormal];
    self.presentationButton.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    self.presentationButton.titleLabel.adjustsFontSizeToFitWidth  = YES;
    self.presentationButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, -18.0f, 0);
    [self.pullUpView addSubview:self.presentationButton];
    
    self.repetitionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.repetitionButton.frame = CGRectMake(30,150, 50,50);
    [self.repetitionButton setBackgroundImage: [UIImage imageNamed:@"repetition_round.png"] forState:UIControlStateNormal];
    [self.repetitionButton addTarget:self action:@selector(repetitionButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.repetitionButton setTitle: @"Odpytywanie" forState:UIControlStateNormal];
    self.repetitionButton.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    self.repetitionButton.titleLabel.adjustsFontSizeToFitWidth  = YES;
    self.repetitionButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, -18.0f, 0);
    [self.pullUpView addSubview:self.repetitionButton];
    
    self.speakingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.speakingButton.frame = CGRectMake(130,70, 50,50);
    [self.speakingButton setBackgroundImage: [UIImage imageNamed:@"speaking_grey.png"] forState:UIControlStateNormal];
    [self.speakingButton addTarget:self action:@selector(speakingButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.speakingButton setTitle: @"Mówienie" forState:UIControlStateNormal];
    self.speakingButton.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    self.speakingButton.titleLabel.adjustsFontSizeToFitWidth  = YES;
    self.speakingButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, -18.0f, 0);
    [self.pullUpView addSubview:self.speakingButton];
    
    self.listeningButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.listeningButton.frame = CGRectMake(130,150, 50,50);
    [self.listeningButton setBackgroundImage: [UIImage imageNamed:@"listening_round.png"] forState:UIControlStateNormal];
    [self.listeningButton addTarget:self action:@selector(listeningButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.listeningButton setTitle: @"Dyktando" forState:UIControlStateNormal];
    self.listeningButton.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    self.listeningButton.titleLabel.adjustsFontSizeToFitWidth  = YES;
    self.listeningButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, -18.0f, 0);
    [self.pullUpView addSubview:self.listeningButton];
    
    self.choosingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.choosingButton.frame = CGRectMake(230,70, 50,50);
    [self.choosingButton setBackgroundImage: [UIImage imageNamed:@"choosing_round.png"] forState:UIControlStateNormal];
    [self.choosingButton addTarget:self action:@selector(choosingButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.choosingButton setTitle: @"Wybieranie" forState:UIControlStateNormal];
    self.choosingButton.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    self.choosingButton.titleLabel.adjustsFontSizeToFitWidth  = YES;
    self.choosingButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, -18.0f, 0);
    [self.pullUpView addSubview:self.choosingButton];
    
    self.cartonsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cartonsButton.frame = CGRectMake(230,150, 50,50);
    [self.cartonsButton setBackgroundImage: [UIImage imageNamed:@"cartons_round.png"] forState:UIControlStateNormal];
    [self.cartonsButton addTarget:self action:@selector(cartonsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.cartonsButton setTitle: @"Kartoniki" forState:UIControlStateNormal];
    self.cartonsButton.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    self.cartonsButton.titleLabel.adjustsFontSizeToFitWidth  = YES;
    self.cartonsButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, -18.0f, 0);
    [self.pullUpView addSubview:self.cartonsButton];
    
    
}

- (void) presentationButtonTouched: (UIButton *) sender
{
    NSLog(@"Presentation Button Touched.");
    NSLog(@"Presentation Segue");
    [self performSegueWithIdentifier: @"Presentation Segue" sender:self];
}

- (void) repetitionButtonTouched: (UIButton *) sender
{
    NSLog(@"Presentation Button Touched.");
    NSLog(@"Repetition Segue");
    [self performSegueWithIdentifier: @"Repetition Segue" sender:self];
}

- (void) speakingButtonTouched: (UIButton *) sender
{
    NSLog(@"Speaking Button Touched.");
    NSLog(@"Speaking Segue");
    [self performSegueWithIdentifier: @"Speaking Segue" sender:self];
    
}

- (void) listeningButtonTouched: (UIButton *) sender
{
    NSLog(@"Listening Button Touched.");
    NSLog(@"Listening Segue");
    [self performSegueWithIdentifier: @"Listening Segue" sender:self];
}

- (void) choosingButtonTouched: (UIButton *) sender
{
    NSLog(@"Choosing Button Touched.");
    NSLog(@"Choosing Segue");
    [self performSegueWithIdentifier: @"Choosing Segue" sender:self];
}

- (void) cartonsButtonTouched: (UIButton *) sender
{
    NSLog(@"Cartons Button Touched.");
    NSLog(@"Cartons Segue");
    [self performSegueWithIdentifier: @"Cartons Segue" sender:self];
}

// enable deleting of words from list of forgotten words
// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        NSLog(@"Swipe-to-Delete, Delete button touched.");
        [self.database.managedObjectContext performBlock:^{
            [self deleteWordAtIndexPath:indexPath];
        }];
    }
}

- (void) deleteWordAtIndexPath: (NSIndexPath *) indexPath
{
    NSLog(@"DictionaryWord deleted in data source.");
    
    Word *word = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSMutableSet *genericWords = [self.genericWordset.words mutableCopy];
    [genericWords removeObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    self.genericWordset.words = genericWords;
    
    NSURL *url = [self getDeletionRequestURLForWord: word];
    
    if(url != nil) {
        
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setTimeoutInterval:30.0f];
        [urlRequest setHTTPMethod: @"GET"];
    
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
        [NSURLConnection sendAsynchronousRequest: urlRequest
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if([data length] > 0 && error == nil) {
                                   NSString *resultString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   if([resultString isEqualToString: @"1"]) {
                                       
                                       NSLog(@"Generic word correctly deleted from web database.");
                                       
                                   } else {
                                       
                                       NSLog(@"An error encountered while trying to delete word from web database.");
                                   }
                               } else if([data length] == 0 && error == nil) {
                                   NSLog(@"Nothing was downloaded.");
                               } else if(error != nil) {
                                   NSLog(@"Error happened = %@", error);
                               }
                           }];
    }

}


/* virtual methods which should be implemented in subclass */

- (void) createOrUpdateGenericWordsetInCoreData
{
    NSException *methodNotImplemented = [NSException
                                         exceptionWithName:@"MethodNotImplementedException"
                                         reason:@"Method createOrUpdateGenericWordsetInCoreData hasn't been overriden in subclass."
                                         userInfo:nil];
    @throw methodNotImplemented;
}

- (NSURL *) getWebServicesURL
{
    NSException *methodNotImplemented = [NSException
                                         exceptionWithName:@"MethodNotImplementedException"
                                         reason:@"Method getWebServicesURL setInCoreData hasn't been overriden in subclass."
                                         userInfo:nil];
    @throw methodNotImplemented;
}

- (NSURL *) getDeletionRequestURLForWord: (Word *) word
{
    NSException *methodNotImplemented = [NSException
                                         exceptionWithName:@"MethodNotImplementedException"
                                         reason:@"Method getDeletionRequestURLForWord: setInCoreData hasn't been overriden in subclass."
                                         userInfo:nil];
    @throw methodNotImplemented;
    
}


@end
