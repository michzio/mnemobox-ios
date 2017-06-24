//
//  UserWordsetsViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 21/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "UserWordsetsViewController.h"
#import "Reachability.h"
#import "XMLParser.h"
#import "WordsetCategory+Create.h"
#import "ProfileServices.h"
#import "Wordset+Create.h"
#import "WordsetViewController.h"
#import "UserwordsetWordsViewController.h"

#define kUSERWORDSETS_SERVICE_URL @"http://www.mnemobox.com/webservices/userWordsets.xml.php?email=%@&pass=%@&from=%@&to=%@"
#define kLANG_FROM @"pl"
#define kLANG_TO @"en"
//params: userWordsetId, langFrom, langTo
#define kDELETE_USERWORDSET_SERVICE_URL @"http://mnemobox.com/webservices/deleteUserWordset.php?email=%@&pass=%@&uwid=%@&from=%@&to=%@"

@interface UserWordsetsViewController ()

@property (strong, nonatomic) UIManagedDocument *database;
@property (strong, nonatomic) Reachability *internetReachable;
@property (weak, nonatomic) IBOutlet UITableView *userWordsetsTableView;

@property (strong, nonatomic) XMLElement *xmlRoot;
@property (strong, nonatomic) WordsetCategory *category;
@property (strong, nonatomic) NSIndexPath *accessoryButtonSelectedIndexPath;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation UserWordsetsViewController

@synthesize database = _database;
@synthesize internetReachable = _internetReachable;
@synthesize userWordsetsTableView = _userWordsetsTableView;
@synthesize xmlRoot = _xmlRoot;
@synthesize accessoryButtonSelectedIndexPath = _accessoryButtonSelectedIndexPath;
@synthesize backgroundImageView = _backgroundImageView;

- (void) setDatabase:(UIManagedDocument *)database
{
    if(_database != database) {
        _database = database;
        [self useDocument];
    }
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
        NSLog(@"Adjusting view to landscape mode"); 
        [self.backgroundImageView setImage:[UIImage imageNamed:@"london.png"]];
        
    }  else if (UIDeviceOrientationIsPortrait(deviceOrientation) &&
                 deviceOrientation != UIDeviceOrientationPortraitUpsideDown)
    {
        NSLog(@"Adjusting view to portrait mode");
        [self.backgroundImageView setImage:[UIImage imageNamed:@"bigben.png"]];
    }
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

- (void) useDocument
{
    if(![[NSFileManager defaultManager] fileExistsAtPath: [self.database.fileURL path]]) {
        /* database not exists on disk so we need to creat it */
        [self.database saveToURL: self.database.fileURL forSaveOperation: UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            NSLog(@"database created on disk");
            [self createOrUpdateUserCategoryInCoreData];
            [self loadUserWordsetsFromWebServices];
            [self setupFetchedResultsController];
        }];
        
    } else if (self.database.documentState == UIDocumentStateClosed) {
        /* document is closed then we need to open the file */
        [self.database openWithCompletionHandler:^(BOOL success) {
            NSLog(@"wordsetDatabase was opened");
            [self createOrUpdateUserCategoryInCoreData];
            [self loadUserWordsetsFromWebServices];
            [self setupFetchedResultsController];
        }];
    } else if (self.database.documentState == UIDocumentStateNormal) {
        /* document exists for a given path and is opend */
        NSLog(@"database is in normal state (opened)");
        [self createOrUpdateUserCategoryInCoreData];
        [self loadUserWordsetsFromWebServices];
        [self setupFetchedResultsController];
    }
    
}

- (void) createOrUpdateUserCategoryInCoreData
{
    NSLog(@"Creating or updating USER Wordset Category in Core Data.");
   
    self.category = [WordsetCategory wordsetCategoryWithCID:@"USER"
                                                            foreignName:@"User Wordsets"
                                                             nativeName:@"Zestawy użytkownika"
                                                 inManagedObjectContext:self.database.managedObjectContext];
}

- (void) loadUserWordsetsFromWebServices
{
    NSLog(@"Loading user wordsets from web services.");
    
    __weak UserWordsetsViewController *weakSelf = self;
    
    //Internet is reachable
    self.internetReachable.reachableBlock = ^(Reachability *reach) {
        
        //Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Yayyy, we have the interwebs!");
        });
        
        [weakSelf getUserWordsetsFromWebServices];
    };
    
    //Internet is not reachable
    self.internetReachable.unreachableBlock = ^(Reachability *reach) {
      
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Someone broke the internet :(");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Internet connection lost!"
                                                            message:@"Check whether you have internet access."
                                                           delegate:weakSelf
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            
            [weakSelf.internetReachable stopNotifier];
        });
        
    };
    
    [self.internetReachable startNotifier];
}

- (void) getUserWordsetsFromWebServices
{
    NSLog(@"Quering web services for User Wordsets as XML.");
    
    NSString *emailAddress = [ProfileServices emailAddressFromUserDefaults];
    NSString *sha1Password = [ProfileServices sha1PasswordFromUserDefaults];
    
    NSString *urlAsString = [NSString stringWithFormat:kUSERWORDSETS_SERVICE_URL, emailAddress, sha1Password, kLANG_FROM, kLANG_TO, nil]; 
    
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    __weak UserWordsetsViewController *weakSelf = self;
    
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
    [self.xmlRoot.subElements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XMLElement *userwordsetElement = (XMLElement *) obj;
        NSString *uwid = [userwordsetElement.attributes valueForKey:@"uwid"];
        NSString *wordsetTitle = [[userwordsetElement.subElements objectAtIndex: 0] text];
        NSArray *titleComponents = [wordsetTitle componentsSeparatedByString:@" - "];
        NSString *foreignName = [titleComponents objectAtIndex:0];
        NSString *nativeName = [titleComponents objectAtIndex:1];
        NSString *description = [[userwordsetElement.subElements objectAtIndex: 1] text];
        
        NSLog(@"UWID = %@, EN = %@, PL = %@, LVL = %@", uwid, foreignName, nativeName, @"-");
        
        /* we use this because managedObjectContext is not thread-safe, must be on the thread on which it was created */
        [self.database.managedObjectContext performBlock: ^(void) {
            /* creating objects in our data model */
            [Wordset wordsetWithWID: [NSString stringWithFormat:@"USERWORDSET_%@", uwid, nil]
                        foreignName: foreignName
                         nativeName: nativeName
                              level: nil
                        description: description
                        forCategory: self.category
             inManagedObjectContext: self.category.managedObjectContext];
            
        }];
    }];
    
    [self.database saveToURL: self.database.fileURL forSaveOperation: UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
    }];


}

- (void) setupFetchedResultsController {
    //self.fetchedResultsControlle = ...
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Wordset"];
    //[cd] meand case insensitive (c) and diacritic insensitive (d) it is many-to-many predicate
    request.predicate = [NSPredicate predicateWithFormat:@"(category.cid = %@) AND (wid != %@) AND (wid != %@)", self.category.cid, @"FORGOTTEN", @"REMEMBERME", nil];
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"foreignName" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDesc];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.database.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    self.tableView = self.userWordsetsTableView;
    self.title = @"User Wordsets";
    [self adjustToScreenOrientation];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Userwordset Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:
                CellIdentifier];
    }
    Wordset *userwordset = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell.textLabel setText: [NSString stringWithFormat: @"%@ - %@", userwordset.foreignName, userwordset.nativeName, nil]];
    [cell.detailTextLabel setText: userwordset.about];
    
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
    NSLog(@"Selected row at UserWordset Table.");
    
    //we reuse property for accessory button to transfer information about selected cell's indexPath 
    self.accessoryButtonSelectedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"Userwordset Words Segue" sender:self];
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
    NSLog(@"Accessory Button Tapped - Manual Wordset Segue");
    
    self.accessoryButtonSelectedIndexPath = indexPath;
    
    [self performSegueWithIdentifier:@"Wordset Segue" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Wordset Segue"] && [segue.destinationViewController respondsToSelector:@selector(setWordset:)]) {
        
        NSLog(@"Prepare For Wordset Segue");
        
        [segue.destinationViewController setWordset: [self.fetchedResultsController objectAtIndexPath:self.accessoryButtonSelectedIndexPath]];
        
    } else if([segue.identifier isEqualToString:@"Userwordset Words Segue"] && [segue.destinationViewController respondsToSelector:@selector(setUserWordset:)]) {
        
        NSLog(@"Prepare For Userwordset Words Segue");
        
        [segue.destinationViewController setUserWordset: [self.fetchedResultsController objectAtIndexPath:self.accessoryButtonSelectedIndexPath]];
    }
    
}

- (IBAction)addUserwordsetButtonTouched:(UIBarButtonItem *)sender {
    NSLog(@"Add user wordset button touched.");
    

    [self performSegueWithIdentifier:@"Add User Wordset Segue" sender:self];
   
   
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
            [self deleteUserWordsetAtIndexPath:indexPath];
        }];
    }
}

- (void) deleteUserWordsetAtIndexPath: (NSIndexPath *) indexPath
{
    NSLog(@"UserWordset deleted in data source.");
    
    Wordset *currentUserWordset = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSMutableSet *userWordsets = [self.category.wordsets mutableCopy];
    [userWordsets removeObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    self.category.wordsets = userWordsets;
    
    NSURL *url = [self getDeletionRequestURLForUserWordset: currentUserWordset];
    
    if(url != nil) {
        
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setTimeoutInterval:30.0f];
        [urlRequest setHTTPMethod: @"GET"];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        __weak UserWordsetsViewController *weakSelf = self;
        [NSURLConnection sendAsynchronousRequest: urlRequest
                                           queue:queue
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if([data length] > 0 && error == nil) {
                                       NSString *resultString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                       if([resultString isEqualToString: @"1"]) {
                                           
                                           NSLog(@"UserWordset correctly deleted from web database.");
                                           [weakSelf.database saveToURL: weakSelf.database.fileURL forSaveOperation: UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
                                           }];

                                       } else {
                                           
                                           NSLog(@"An error encountered while trying to delete userwordset from web database.");
                                       }
                                   } else if([data length] == 0 && error == nil) {
                                       NSLog(@"Nothing was downloaded.");
                                   } else if(error != nil) {
                                       NSLog(@"Error happened = %@", error);
                                   }
                               }];
    }
    
}

- (NSURL *) getDeletionRequestURLForUserWordset: (Wordset *) userWordset
{
    NSString *emailAddress = [ProfileServices emailAddressFromUserDefaults];
    NSString *sha1Password = [ProfileServices sha1PasswordFromUserDefaults];
    
    NSRange range = [userWordset.wid rangeOfString:@"USERWORDSET_"];
    NSString *idOfUserWordset;
    if (range.location != NSNotFound)
    {
        //range.location is start of substring
        //range.length is length of substring
        idOfUserWordset= [userWordset.wid substringFromIndex:range.location + range.length];
    }
    NSString *urlAsString = [NSString stringWithFormat:kDELETE_USERWORDSET_SERVICE_URL, emailAddress, sha1Password, idOfUserWordset, kLANG_FROM,kLANG_TO, nil];
    NSLog(@"Delete userwordset URL: %@", urlAsString);
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    return url;
}

-(BOOL) shouldAutorotate{
    return YES;
}

-(NSUInteger) supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskAll;
}

- (void)viewDidUnload {
    [self setUserWordsetsTableView:nil];
    [self setBackgroundImageView:nil];
    [super viewDidUnload];
}
@end
