//
//  TaskViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 10/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "TaskViewController.h"
#import "ProfileServices.h"
#import "XMLParser.h"
#import "Reachability.h"
#import "Solution+Create.h"
#import "UIImageView+AFNetworking.h"
#import "SolutionCell.h"
#import "SolutionViewController.h"

#define IDIOM UI_USER_INTERFACE_IDIOM()
#define IPAD UIUserInterfaceIdiomPad

//params: fromLang, toLang, emailAddress, sha1Password, taskId
#define kTASK_SERVICE_URL @"http://www.mnemobox.com/webservices/task.xml.php?from=%@&to=%@&email=%@&pass=%@&task_id=%@"
#define kLANG_FROM @"pl"
#define kLANG_TO @"en"

@interface TaskViewController ()

@property (weak, nonatomic) IBOutlet UILabel *taskLabel;
@property (weak, nonatomic) IBOutlet UIImageView *creatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *creatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *creationDate;
@property (weak, nonatomic) IBOutlet UITableView *solutionsTableView;
@property (weak, nonatomic) IBOutlet UILabel *createdDateLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;

@property (strong, nonatomic) XMLElement *xmlRoot;
@property (strong, nonatomic) Reachability *internetReachable;
@property (strong, nonatomic) Solution *selectedSolutionObject;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;


@end

@implementation TaskViewController

@synthesize task = _task;
@synthesize selectedSolutionObject = _selectedSolutionObject; 

- (void) setTask:(Task *)task
{
    NSLog(@"Setting Task object: %@", task.taskId);
    if(_task != task) {
        _task = task;
    }
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self adjustToScreenOrientation];
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
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




- (void) displayTask
{
    NSLog(@"Displaying tasks basic information."); 
    self.taskLabel.text = self.task.taskText;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *stringFromDate = [formatter stringFromDate:self.task.creationDate];
    [self.creationDate setText:stringFromDate];
    [self.taskLabel setHidden: NO];
    [self.creationDate setHidden: NO];
    [self.createdDateLabel setHidden:NO]; 
    
}

- (void) reloadTaskDisplay
{
    [self displayTask];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
    self.creatorLabel.text = [NSString stringWithFormat:@"~@%@ %@", self.task.creatorFirstName, self.task.creatorLastName, nil];
    [self.creatorLabel setHidden: NO]; 
    //load creator image into image view asynchronously
    NSURL *creatorImageURL = [NSURL URLWithString:
                              [NSString stringWithFormat:kUSER_AVATAR_SERVICE_URL, self.task.creatorImage, nil]];
    [self.creatorImageView setImageWithURL:creatorImageURL placeholderImage:[UIImage imageNamed:@"blank.png"]];
        
    });
    
}

- (void) loadTaskDetailsAndSolutions
{
    //loading taks's  additional info and solutions
    NSLog(@"Loading task's additional info and solutions.");
    
    NSString *urlAsString = [NSString stringWithFormat:kTASK_SERVICE_URL, kLANG_FROM, kLANG_TO,
                             [ProfileServices emailAddressFromUserDefaults],
                             [ProfileServices sha1PasswordFromUserDefaults],
                             self.task.taskId, nil];
    NSLog(@"Task Details URL: %@", urlAsString);
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"GET"];
    
    __weak TaskViewController *weakSelf = self;
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue: queue
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
    NSLog(@"Traversing XML of Task...");
    
    XMLElement *taskElement = self.xmlRoot;
    NSString *taskId = [taskElement.attributes valueForKey:@"taskId"];
    NSString *categoryId = [taskElement.attributes valueForKey:@"categoryId"];
    NSString *creatorId = [taskElement.attributes valueForKey:@"creatorId"];
    BOOL isUserTask = [[taskElement.attributes valueForKey:@"isUserTask"] boolValue];
    
    NSString *taskText = [[taskElement.subElements objectAtIndex:0] text];
    NSString *taskCategory = [[taskElement.subElements objectAtIndex:1] text];
    NSString *strCreationDate = [[taskElement.subElements objectAtIndex:2] text];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSDate *creationDate = [df dateFromString: strCreationDate];
    
    NSLog(@"Task: %@, %@, %@", taskId, taskText, strCreationDate);

    NSString *creatorFirstName = [[taskElement.subElements objectAtIndex:3] text];
    NSString *creatorLastName = [[taskElement.subElements objectAtIndex:4] text];
    NSString *creatorImage = [[taskElement.subElements objectAtIndex:5] text];
    
    XMLElement *solutionsElement = [taskElement.subElements objectAtIndex: 6];
    
    NSString *solutionCount = [taskElement.attributes valueForKey:@"solutionCount"];
    
    //we use performBlock method of managedObjectContext because of
    //managedObject context is not thread-safe and must be executed on thread
    //which it was created
    if([self.task.taskId isEqualToString: taskId]) {
        
        /* updating Task object */
        self.task.taskText = taskText;
        self.task.categoryId = categoryId;
        self.task.categoryName = taskCategory;
        self.task.creationDate = creationDate;
        self.task.creatorId = creatorId;
        self.task.creatorFirstName = creatorFirstName;
        self.task.creatorLastName = creatorLastName;
        self.task.creatorImage = creatorImage;
        self.task.solutionCount = solutionCount;
        self.task.isUserTask = [NSNumber numberWithBool:isUserTask];
        
    }
    
    [self reloadTaskDisplay];
    
    //Loading solutions for this task into Core Data database
    [solutionsElement.subElements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        XMLElement *solutionElement = (XMLElement *) obj;
        NSString *solutionId = [solutionElement.attributes valueForKey:@"solutionId"];
        NSString *teaser = [[solutionElement.subElements objectAtIndex:0] text];
        NSString *content = [[solutionElement.subElements objectAtIndex:1] text];
        NSString *author = [[solutionElement.subElements objectAtIndex:2] text];
        NSString *strCreationDate = [[solutionElement.subElements objectAtIndex:3] text];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        NSDate *creationDate = [df dateFromString: strCreationDate];
        
        [Solution solutionWithSID:solutionId
                           teaser:teaser
                          content:content
                          created:creationDate
                         byAuthor:author
                          forTask:self.task
           inManagedObjectContext:self.task.managedObjectContext];
        
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating];
    });
    
    //if there is zero solutions we place add solution button ;/
    if([self.task.solutions count]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView setHidden:NO];
            [self.loadingLabel setHidden: YES];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingLabel setText:@"Brak rozwiązań..."];
        });
    }

    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected Solution at row: %d", [indexPath row]);
    
    self.selectedSolutionObject = [self.fetchedResultsController objectAtIndexPath:indexPath]; 
    [self performSegueWithIdentifier:@"Solution Segue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Solution Segue"])
    {
        [segue.destinationViewController setSolution: self.selectedSolutionObject]; 
    } else if([segue.identifier isEqualToString:@"Add Solution Segue"])
    {
        [segue.destinationViewController setTask: self.task]; 
        
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tableView = self.solutionsTableView;
    self.title = @"Task Details";
    
    [self displayTask];
    [self setupFetchedResultsController];
    self.internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    __weak TaskViewController *weakSelf = self;
    //Internet is reachable.
    self.internetReachable.reachableBlock = ^(Reachability *reach)
    {
        //Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Yayyy, we have the interwebs!");
        });
        
        [weakSelf loadTaskDetailsAndSolutions];
    };
    
    //Internet is not reachable.
    self.internetReachable.unreachableBlock = ^(Reachability *reach)
    {
        NSLog(@"Someone broke the internet :(");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet connection lost!" message:@"Check whether you have internet access." delegate: weakSelf cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
        [weakSelf.internetReachable stopNotifier];
    };
    
    [self.internetReachable startNotifier]; 
    
}

- (void) setupFetchedResultsController {
    //self.fetchedResultsControlle = ...
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Solution"];
    request.predicate = [NSPredicate predicateWithFormat:@"forTask.taskId = %@", self.task.taskId, nil];
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sortDesc];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.task.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

- (void)viewDidUnload {
    [self setTaskLabel:nil];
    [self setCreatorImageView:nil];
    [self setCreatorLabel:nil];
    [self setCreationDate:nil];
    [self setSolutionsTableView:nil];
    [self setCreatedDateLabel:nil];
    [self setActivityIndicator:nil];
    [self setLoadingLabel:nil];
    [self setBackgroundImageView:nil];
    [super viewDidUnload];
}

#pragma mark - Table View Data Source and Delegate Methods

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Solution Cell";
    SolutionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[SolutionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Solution *solution = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.solutionTeaserLabel.text = solution.teaser;
   
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *stringFromDate = [formatter stringFromDate: solution.creationDate];
    
    cell.creationDateLabel.text = [NSString stringWithFormat:@"Utworzono: %@", stringFromDate, nil];
    cell.authorLabel.text = [NSString stringWithFormat:@"~@%@", solution.author, nil];
    
    return cell;
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
