//
//  WordsetCategoriesViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 21/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "WordsetCategoriesViewController.h"
#import "WordsetCategory+Create.h"
#import "WordsetsTableViewController.h"
#import "iOSVersion.h"

#define kWORDSET_CATEGORIES_SERVICE_URL @"http://www.mnemobox.com/webservices/getCategories.php?from=pl&to=en"


@interface WordsetCategoriesViewController ()

@property (nonatomic, strong) XMLElement *xmlRoot;
@property (nonatomic, strong) Reachability *internetReachable;

@end

@implementation WordsetCategoriesViewController

@synthesize wordsetsDatabase = _wordsetsDatabase; 

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
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"WordsetCategory"];
    /* we want all categories, we don't specify predicate */
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"foreignName" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDesc];
   
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.wordsetsDatabase.managedObjectContext sectionNameKeyPath:nil cacheName:nil]; 
    
}

- (void) useDocument
{
    if(![[NSFileManager defaultManager] fileExistsAtPath: [self.wordsetsDatabase.fileURL path]]) {
        /* wordsetDatabase not exists on disk so we need to creat it */
        [self.wordsetsDatabase saveToURL: self.wordsetsDatabase.fileURL forSaveOperation: UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            NSLog(@"wordsetDatabase created on disk");
            [self setupFetchedResultsController];
            /* after wordsetDatabase has been created we fetch into it categories objects */
            [self fetchCategoriesFromWebServicesIntoDocument: self.wordsetsDatabase]; 
        }];
        
    } else if (self.wordsetsDatabase.documentState == UIDocumentStateClosed) {
        /* document is closed then we need to open the file */
        [self.wordsetsDatabase openWithCompletionHandler:^(BOOL success) {
            NSLog(@"wordsetDatabase was opened");
            [self setupFetchedResultsController];
            /* after wordsetDatabase has been opened we fetch into it categories objects in order to update entries */
            [self fetchCategoriesFromWebServicesIntoDocument: self.wordsetsDatabase];

            
        }];
    } else if (self.wordsetsDatabase.documentState == UIDocumentStateNormal) {
       /* document exists for a given path and is opend */
        NSLog(@"wordsetDatabase is in normal state (opened)");
        [self setupFetchedResultsController];
    }

}

- (void) setWordsetsDatabase:(UIManagedDocument *)wordsetsDatabase
{
    if( _wordsetsDatabase != wordsetsDatabase) {
        _wordsetsDatabase = wordsetsDatabase;
        self.title = @"Categories"; 
        [self useDocument];
    }
    
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    
}

- (void) fetchCategoriesFromWebServicesIntoDocument: (UIManagedDocument *) document
{
    __weak WordsetCategoriesViewController *weakSelf = self;
    
    self.internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Internet is reachable
    self.internetReachable.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"Yayyy, we have the interwebs!");
            
        });
        [weakSelf getWordsetCategoriesFromWebServices];
    };
    
    // Internet is not reachable
    self.internetReachable.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Someone broke the internet :(");
           /*
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet connection lost!" message:@"Check whether you have internet access." delegate:weakSelf cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
            [alert show];
            */
            
        });
    };
    
    [self.internetReachable startNotifier];
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    WordsetCategory * wordsetCategory = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if([segue.destinationViewController respondsToSelector:@selector(setWordsetCategory:)]) {
        [segue.destinationViewController setWordsetCategory: wordsetCategory];
        
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
}
 */

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Wordset Category Cell";
    UITableViewCell *cell;
    
    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        NSLog(@"Creating TableViewCell for iOS version < 6.0"); 
       cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        NSLog(@"Creating TableViewCell for iOS version >= 6.0"); 
         cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }
   
    
    // Configure the cell...
    WordsetCategory *category = [self.fetchedResultsController objectAtIndexPath:indexPath]; 
    cell.textLabel.text = category.foreignName;
    cell.detailTextLabel.text = category.nativeName;
    cell.tag = [category.cid integerValue];
    
    return cell;
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

- (void) getWordsetCategoriesFromWebServices
{
    NSString *urlAsString = kWORDSET_CATEGORIES_SERVICE_URL;
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL: url];
    [urlRequest setTimeoutInterval: 30.0f];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    __weak WordsetCategoriesViewController *weakSelf = self;
    
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
                                   [weakSelf.internetReachable stopNotifier];
                               } else if ([data length] == 0 && error == nil) {
                                   NSLog(@"Nothing was downloaded.");
                               } else if(error != nil) {
                                   NSLog(@"Error happened = %@", error); 
                               }
                           }]; 
}

- (void) traverseXMLStartingFromRootElement {
   
    [self.xmlRoot.subElements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XMLElement *categoryElement = (XMLElement *) obj;
        NSString *cid = [categoryElement.attributes valueForKey:@"cid"];
        XMLElement *angnameElement = [categoryElement.subElements objectAtIndex: 0];
        XMLElement *plnameElement = [categoryElement.subElements objectAtIndex: 1];
        NSLog(@"CID = %@, EN = %@, PL = %@", cid, angnameElement.text, plnameElement.text);
        
        /* we use this because managedObjectContext is not thread-safe, must be on the thread on which it was created */
        [self.wordsetsDatabase.managedObjectContext performBlock: ^(void) {
            /* creating objects in our data model */
            [WordsetCategory wordsetCategoryWithCID: cid foreignName: angnameElement.text nativeName: plnameElement.text inManagedObjectContext:self.wordsetsDatabase.managedObjectContext];
            
        }];
    }];

}


@end
