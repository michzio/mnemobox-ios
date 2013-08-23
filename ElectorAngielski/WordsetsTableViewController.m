//
//  WordsetsTableViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 22/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "WordsetsTableViewController.h"
#import "Wordset+Create.h"
#import "WordsetViewController.h"

#define kWORDSETS_LIST_SERVICE_URL @"http://www.mnemobox.com/webservices/getWordsetsList.php?cid=%@&from=%@&to=%@"
#define kFROM_LANG @"pl"
#define kTO_LANG @"en"

@interface WordsetsTableViewController ()

@property (nonatomic, strong) XMLElement *xmlRoot;
@property (nonatomic, strong) Reachability *internetReachable;

@end

@implementation WordsetsTableViewController

@synthesize wordsetCategory = _wordsetCategory;
@synthesize wordsetsDatabase = _wordsetsDatabase;

- (void) setWordsetsDatabase:(UIManagedDocument *)wordsetsDatabase
{
    if( _wordsetsDatabase != wordsetsDatabase) {
        _wordsetsDatabase = wordsetsDatabase;
        [self useDocument];
    }
}

- (void) setWordsetCategory:(WordsetCategory *) wordsetCategory
{
    _wordsetCategory = wordsetCategory;
    self.title = wordsetCategory.foreignName;
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    /* if my wordsetsDatabase is nil we will create it */
    if(!self.wordsetsDatabase) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent: @"Wordset Database"];
        self.wordsetsDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
        
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) setupFetchedResultsController {
    //self.fetchedResultsControlle = ...
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Wordset"];
    /* we want all categories, we don't specify predicate */
    NSLog(@"CID -> %@", self.wordsetCategory.cid);
    request.predicate  = [NSPredicate predicateWithFormat: @"category.cid = %@", self.wordsetCategory.cid, nil];
    NSSortDescriptor *sortDesc1 = [NSSortDescriptor sortDescriptorWithKey:@"level" ascending:YES];
    NSSortDescriptor *sortDesc2 = [NSSortDescriptor sortDescriptorWithKey:@"foreignName" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObjects:sortDesc1, sortDesc2,nil];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.wordsetCategory.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
}


- (void) useDocument
{
    if(![[NSFileManager defaultManager] fileExistsAtPath: [self.wordsetsDatabase.fileURL path]]) {
        // wordsetDatabase not exists on disk so we need to creat it 
        [self.wordsetsDatabase saveToURL: self.wordsetsDatabase.fileURL forSaveOperation: UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            NSLog(@"wordsetDatabase created on disk");
            [self setupFetchedResultsController];
            // after wordsetDatabase has been created we fetch into it categories objects
            [self fetchWordsetsInCategoryFromWebServicesIntoDocument: self.wordsetsDatabase];
        }];
        
    } else if (self.wordsetsDatabase.documentState == UIDocumentStateClosed) {
        // document is closed then we need to open the file 
        [self.wordsetsDatabase openWithCompletionHandler:^(BOOL success) {
            NSLog(@"wordsetDatabase was opened");
            [self setupFetchedResultsController];
            // after wordsetDatabase has been opened we fetch into it categories objects in order to update entries 
            [self fetchWordsetsInCategoryFromWebServicesIntoDocument: self.wordsetsDatabase];
            
            
        }];
    } else if (self.wordsetsDatabase.documentState == UIDocumentStateNormal) {
        // document exists for a given path and is opend 
        NSLog(@"wordsetDatabase is in normal state (opened)");
            }
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) fetchWordsetsInCategoryFromWebServicesIntoDocument: (UIManagedDocument *) document
{
    __weak WordsetsTableViewController *weakSelf = self;
    
    self.internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Internet is reachable
    self.internetReachable.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"Yayyy, we have the interwebs!");
            [weakSelf getWordsetsInCategoryFromWebServices];
            
        });
    };
    
    // Internet is not reachable
    self.internetReachable.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Someone broke the internet :(");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet connection lost!" message:@"Check whether you have internet access." delegate:weakSelf cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
            [alert show];
            
        });
    };
    
    [self.internetReachable startNotifier];
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Wordset *wordset = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if([segue.destinationViewController respondsToSelector: @selector(setWordset:)])
    {
        [segue.destinationViewController setWordset: wordset];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Wordset Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Wordset *wordset = [self.fetchedResultsController objectAtIndexPath:indexPath];

    cell.textLabel.text = wordset.foreignName;
    cell.detailTextLabel.text = wordset.nativeName;
    [self setImageViewOfTableViewCell: cell withLevel: wordset.level];
    
    return cell;
}

- (void) setImageViewOfTableViewCell: (UITableViewCell *) cell withLevel: (NSString *) level
{
    UIImageView * cellImageView = cell.imageView;
    if([level isEqualToString: @"A1"]) {
        cellImageView.image = [UIImage imageNamed:@"level_a1.png"];
    } else if([level isEqualToString: @"A2"]) {
        cellImageView.image = [UIImage imageNamed:@"level_a2.png"];
    } else if([level isEqualToString: @"B1"]) {
        cellImageView.image = [UIImage imageNamed:@"level_b1.png"];
    } else if([level isEqualToString: @"B2"]) {
        cellImageView.image = [UIImage imageNamed:@"level_b2.png"];
    } else if([level isEqualToString: @"C1"]) {
        cellImageView.image = [UIImage imageNamed:@"level_c1.png"];
    } else if([level isEqualToString: @"C2"]) {
        cellImageView.image = [UIImage imageNamed:@"level_c2.png"];
    } else {
        cellImageView.image = [UIImage imageNamed:@"level_a1.png"];
    }
    
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
}

- (void) getWordsetsInCategoryFromWebServices
{
    NSString *urlAsString = [NSString stringWithFormat: kWORDSETS_LIST_SERVICE_URL, self.wordsetCategory.cid, kFROM_LANG, kTO_LANG];
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL: url];
    [urlRequest setTimeoutInterval: 30.0f];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    __weak WordsetsTableViewController *weakSelf = self;
    
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:queue
                           completionHandler:^(NSURLResponse * response,
                                               NSData * data,
                                               NSError * error) {
                               
                               if([data length] > 0 && error == nil) {
                                   //NSString *xml = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];
                                   XMLParser *xmlParser = [[XMLParser alloc] initWithData: data];
                                   self.xmlRoot = [xmlParser parseAndGetRootElement];
                                   [weakSelf traverseXMLStartingFromRootElement];
                               } else if ([data length] == 0 && error == nil) {
                                   NSLog(@"Nothing was downloaded.");
                               } else if(error != nil) {
                                   NSLog(@"Error happened = %@", error);
                               }
                           }];
}

- (void) traverseXMLStartingFromRootElement {
    
    [self.xmlRoot.subElements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XMLElement *wordsetElement = (XMLElement *) obj;
        NSString *wid = [wordsetElement.attributes valueForKey:@"wid"];
        XMLElement *angnameElement = [wordsetElement.subElements objectAtIndex: 0];
        XMLElement *plnameElement = [wordsetElement.subElements objectAtIndex: 1];
        XMLElement *levelElement = [wordsetElement.subElements objectAtIndex: 3];
        XMLElement *descriptionElement = [wordsetElement.subElements objectAtIndex: 4];
        NSLog(@"WID = %@, EN = %@, PL = %@, LVL = %@", wid, angnameElement.text, plnameElement.text, levelElement.text);
        
        /* we use this because managedObjectContext is not thread-safe, must be on the thread on which it was created */
        [self.wordsetsDatabase.managedObjectContext performBlock: ^(void) {
            /* creating objects in our data model */
            [Wordset wordsetWithWID: wid
                        foreignName: angnameElement.text
                         nativeName: plnameElement.text
                              level: levelElement.text
                        description: descriptionElement.text
                        forCategory: self.wordsetCategory
             inManagedObjectContext:self.wordsetCategory.managedObjectContext];
            
        }];
    }];
    
}



@end
