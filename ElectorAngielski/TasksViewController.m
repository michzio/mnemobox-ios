//
//  TasksViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 10/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "TasksViewController.h"
#import "Reachability.h"
#import "XMLParser.h"
#import "ProfileServices.h"
#import "Task+Create.h"
#import "TaskViewController.h"

#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad

#define kTASKS_SERVICE_URL @"http://www.mnemobox.com/webservices/tasks.xml.php?from=%@&to=%@&email=%@&pass=%@&category_id=%@"
#define kLANG_FROM @"pl"
#define kLANG_TO @"en"

@interface TasksViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tasksTableView;
@property (nonatomic, strong) UIManagedDocument *database;
@property (nonatomic, strong) Reachability *internetReachable;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (nonatomic, strong) XMLElement *xmlRoot;
@property (nonatomic, strong) Task *currentTask;
@end

@implementation TasksViewController

@synthesize database = _database;
@synthesize internetReachable = _internetReachable;
@synthesize currentTask = _currentTask;

- (void) setDatabase:(UIManagedDocument *)database
{
    if( _database != database) {
        _database = database;
        [self useDocument];
    }
    
}
- (void) viewDidLoad
{
    [super viewDidLoad];
     [self.navigationController setNavigationBarHidden:NO animated:YES];
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
        [self.backgroundImageView setImage:[UIImage imageNamed:@"london.png"]];
        
    }  else if (UIDeviceOrientationIsPortrait(deviceOrientation) &&
                deviceOrientation != UIDeviceOrientationPortraitUpsideDown)
    {
        [self.backgroundImageView setImage:[UIImage imageNamed:@"bigben.png"]];
    }
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /* if my database is nil we will create it */
    NSLog(@"Creating UIManagedDocument for Core Data access in ViewWillAppear."); 
    if(!self.database) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent: @"Wordset Database"];
        self.database = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    NSLog(@"Setting up TableView and FetchResultsController."); 
    self.tableView = self.tasksTableView;
    [self setupFetchedResultsController];
    [self loadTasksFromWebServices];
    self.title = @"Tasks";
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(IDIOM == IPAD) {
         UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd target:self action:@selector(addBarButtonTouched:)];
        
        self.parentViewController.parentViewController.navigationItem.rightBarButtonItem = addBarButton;
    }
}

- (void) addBarButtonTouched: (id) sender
{
    [self performSegueWithIdentifier:@"Add Task Segue" sender:sender];
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

- (void) setupFetchedResultsController {
    //self.fetchedResultsControlle = ...
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Task"];
    /* we want all tasks, we don't specify predicate */
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sortDesc];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.database.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

- (void) loadTasksFromWebServices
{
    NSLog(@"Loading tasks from web services into Core Data database...");
    
    self.internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    __weak TasksViewController *weakSelf = self;
    //Internet is reachable.
    self.internetReachable.reachableBlock = ^(Reachability *reach)
    {
        //Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Yayyy, we have the interwebs!");
        });
        
        [weakSelf getTasksFromWebServices]; 
        
    };
    
    //Internet is not reachable.
    self.internetReachable.unreachableBlock = ^(Reachability *reach)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Someone broke the internet :(");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet connection lost!" message:@"Check whether you have internet access." delegate:weakSelf cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
            [alert show];
        });
        
    };
    
    [self.internetReachable startNotifier];
}

- (void) getTasksFromWebServices
{
    NSLog(@"Quering Web Services for Tasks collection as XML.");
    
    NSString *urlAsString = [NSString stringWithFormat: kTASKS_SERVICE_URL,
                             kLANG_FROM, kLANG_TO,
                             [ProfileServices emailAddressFromUserDefaults],
                             [ProfileServices sha1PasswordFromUserDefaults],
                             @"0", //category_id = 0 means all tasks from any category
                             nil];
    NSLog(@"Tasks URL: %@", urlAsString);
    
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod: @"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    __weak TasksViewController *weakSelf = self;
    
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
    NSLog(@"Traversing XML of Tasks...");
    [self.xmlRoot.subElements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        XMLElement *taskElement = (XMLElement *) obj;
        NSString *taskId = [taskElement.attributes valueForKey:@"taskId"];
        NSString *categoryId = [taskElement.attributes valueForKey:@"categoryId"];
        NSString *solutionCount = [taskElement.attributes valueForKey:@"solutionCount"];
        NSString *creatorId = [taskElement.attributes valueForKey:@"creatorId"];
        BOOL isUserTask = [[taskElement.attributes valueForKey:@"isUserTask"] boolValue];
        
        NSString *taskText = [[taskElement.subElements objectAtIndex:0] text];
        NSString *taskCategory = [[taskElement.subElements objectAtIndex:1] text];
        NSString *strCreationDate = [[taskElement.subElements objectAtIndex:2] text];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        NSDate *creationDate = [df dateFromString: strCreationDate];
        
        NSLog(@"Task: %@, %@, %@", taskId, taskText, strCreationDate);
        //we use performBlock method of managedObjectContext because of
        //managedObject context is not thread-safe and must be executed on thread
        //which it was created
        [self.database.managedObjectContext performBlock:^{
            /*creating Task object in our data model */
            [Task taskWithTID:taskId
                     taskText:taskText
                   categoryId:categoryId
                 categoryName: taskCategory
                 creationDate: creationDate
                    creatorId:creatorId
             creatorFirstName:nil
              creatorLastName:nil
                 creatorImage:nil
                solutionCount:solutionCount
                   isUserTask:isUserTask
       inManagedObjectContext:self.database.managedObjectContext];
            
        }];
        
    }];
    
    [self.database saveToURL: self.database.fileURL forSaveOperation: UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
    }];
}

- (void)viewDidUnload {
    [self setTasksTableView:nil];
    [self setBackgroundImageView:nil];
    [super viewDidUnload];
}

#pragma mark - Table view data dource
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Task Cell";
    TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[TaskCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Task *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSLog(@"Configure cell with task: %@", task.taskText); 
    cell.taskTextLabel.text = task.taskText;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    //Optionally for time zone converstions
    //[formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    NSString *stringFromDate = [formatter stringFromDate:task.creationDate];
    
    cell.dateLabel.text = stringFromDate;
    [cell.solutionButton setTitle: [NSString stringWithFormat:@"Rozwiązania (%@)", task.solutionCount] forState: UIControlStateNormal];
        
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
    
    cell.delegate = self;
    
    return cell;
}

- (void) accessoryButtonTapped: (id) sender event: (id) event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
    if (indexPath != nil) {
        self.currentTask = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"Task Segue" sender:self];
        
    }
}

- (void) solutionButtonTouchedOnTaskCell: (TaskCell *) taskCell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell: taskCell];
    NSLog(@"Solution Button Touched for Cell at Row: %d",
          [indexPath row]);
    self.currentTask = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"Task Segue" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Task Segue"])
    {
        [segue.destinationViewController setTask: self.currentTask];
    }
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
