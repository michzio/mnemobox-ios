//
//  PostItsViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 27/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "PostItsViewController.h"
#import "Reachability.h"
#import "ProfileServices.h"
#import "XMLParser.h"
#import "PostItObject.h"
#import "PostItCell.h"
#import "PostItEditionViewController.h"
#import "iOSVersion.h"

#define kPOST_ITS_SERVICE_URL @"http://mnemobox.com/webservices/getContextPostIts.xml.php?contextId=%@&from=%@&to=%@&email=%@&pass=%@"
#define kLANG_FROM @"pl"
#define kLANG_TO @"en"

@interface PostItsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *foreignWordLabel;

@property (strong, nonatomic) NSMutableArray *postIts;
@property (strong, nonatomic) Reachability *internetReachable;
@property (strong, nonatomic) XMLElement *xmlRoot;

@property (nonatomic) BOOL isDragging;
@property (nonatomic) BOOL isLoading; 

@end

@implementation PostItsViewController

@synthesize wordObject = _wordObject;

- (void)setWordObject:(WordObject *)wordObject
{

    if(_wordObject != wordObject ) {
        NSLog(@"Setting WordObject in PostItViewController"); 
        _wordObject = wordObject;
        [self displayWordInfo];
        
        [self loadPostItsFromWebServices];
    }
}

- (void) loadPostItsFromWebServices {
    __weak PostItsViewController *weakSelf = self;
    
    self.internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Internet is reachable
    self.internetReachable.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"Yayyy, we have the interwebs!");
            
            [weakSelf getPostItsFromWebServices];
            
        });
    };
    
    // Internet is not reachable
    self.internetReachable.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Someone broke the internet :(");
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet connection lost!" message:@"Could not synchronize posts with mnemobox.com." delegate:weakSelf cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
            [alert show];
            
            
        });
    };
    
    [self.internetReachable startNotifier];
}

- (void) displayWordInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.foreignWordLabel.text =
        [NSString stringWithFormat:@"%@ %@",
         self.wordObject.foreignArticle,
         self.wordObject.foreign, nil];
    });
   
}



- (void) tableViewWasDragedDown: (UIGestureRecognizer *) gestureRecognizer
{
    NSLog(@"Drag Down to Refresh Gesture Recognized");
    [self.tableView reloadData]; 
}

- (void) getPostItsFromWebServices {
    
    NSString *email = [ProfileServices emailAddressFromUserDefaults];
    NSString *pass = [ProfileServices sha1PasswordFromUserDefaults];
    
    NSString *urlAsString = [NSString stringWithFormat: kPOST_ITS_SERVICE_URL,
                             self.wordObject.wordId, kLANG_FROM, kLANG_TO, email, pass];
    
    NSLog(@"PostIts URL: %@", urlAsString);
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL: url];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod: @"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    __weak PostItsViewController *weakSelf = self;
    
    [NSURLConnection sendAsynchronousRequest: urlRequest
                                       queue: queue
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error) {
         
         if([data length] > 0 && error == nil) {
             ///...
             XMLParser *xmlParser = [[XMLParser alloc] initWithData: data];
             self.xmlRoot = [xmlParser parseAndGetRootElement];
             [weakSelf traverseXMLStartingFromRootElement];
         } else if([data length] == 0 && error == nil) {
             NSLog(@"Nothing was downloaded.");
         } else if(error != nil) {
             NSLog(@"Error happened = %@", error); 
         }
     }];
}

- (void) traverseXMLStartingFromRootElement
{
    __weak PostItsViewController *weakSelf = self;
    self.postIts = [[NSMutableArray alloc] init];
    
    [self.xmlRoot.subElements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        XMLElement *postItElement = (XMLElement *) obj;
        NSString *postItID = [postItElement.attributes valueForKey:@"pid"];
        BOOL isCreatedByYou =
        [[postItElement.attributes valueForKey:@"createdByYou"] isEqualToString: @"1"] ? YES : NO;
        XMLElement *postItTextElement = [postItElement.subElements objectAtIndex: 0];
        XMLElement *authorFirstName = [postItElement.subElements objectAtIndex:1];
        XMLElement *authorLastName = [postItElement.subElements objectAtIndex:2];
        XMLElement *authorID = [postItElement.subElements objectAtIndex:3];
        
        PostItObject *postIt = [[PostItObject alloc] initWithPID: postItID
                                                            text:postItTextElement.text
                                                    createdByYou:isCreatedByYou
                                                        authorID: authorID.text
                                                       firstName: authorFirstName.text
                                                        lastName: authorLastName.text];
                                
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.postIts addObject: postIt];
            [weakSelf.tableView reloadData]; 
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
    [self displayWordInfo]; 

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

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.isLoading) return;
    self.isDragging = YES;
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.isLoading) return;
    self.isDragging = NO;
    if (self.tableView.contentOffset.y <= -50.0f) {
        // Released above the header
        [self startLoading];
    }
}

- (void)startLoading {
    self.isLoading = YES;
    
    // Reload PostIts from Web Services
    
    [self loadPostItsFromWebServices]; 
    
    // Refresh action!
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0];

}

- (void)stopLoading {
    self.isLoading = NO;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.postIts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PostItObject *postItObject =  [self.postIts objectAtIndex:[indexPath row]];
    
   if(tableView.editing && postItObject.isCreatedByYou) {
    NSLog(@"Editing Cell"); 
    static NSString *CellIdentifier = @"PostIt Edit Cell";
    PostItEditCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Configure the edit cell...
   
    cell.postItLabel.text = postItObject.postItText;
    cell.tag = [postItObject.postItID integerValue];
    cell.postItAuthorLabel.text =
    [NSString stringWithFormat:@"~@%@ %@", postItObject.authorFirstName, postItObject.authorLastName, nil];
      
       UISwipeGestureRecognizer *swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget: self
                                                                                                  action: @selector(cellWasSwipedRight:)];
       swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
       [cell addGestureRecognizer: swipeRightRecognizer];
       cell.delegate = self;
             return cell;
       
   } else {
    NSLog(@"Normal Cell"); 
    static NSString *CellIdentifier = @"PostIt Cell";
    PostItCell *cell;
    
       if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
           NSLog(@"Creating TableViewCell for iOS version < 6.0");
           cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
           if(cell == nil) {
               cell = [[PostItCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
           }
    }
       
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
     cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }
    // Configure the cell...
    cell.postItLabel.text = postItObject.postItText;
    cell.tag = [postItObject.postItID integerValue];
    cell.postItAuthorLabel.text =
    [NSString stringWithFormat:@"~@%@ %@", postItObject.authorFirstName, postItObject.authorLastName, nil];
       
    //if(postItObject.isCreatedByYou) {
    //    NSLog(@"This postIt it created by you.");
    //}
       UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(cellWasSwipedLeft:)];
       swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
       
       [cell addGestureRecognizer: swipeLeftRecognizer];
       
       
    return cell;
   }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    PostItObject *postItObject =  [self.postIts objectAtIndex:[indexPath row]];
    // Return NO if you do not want the specified item to be editable.
    NSLog(@"Called a method canEditRow..."); 
    if(postItObject.isCreatedByYou) {
        NSLog(@"This cell can be edited"); 
        return YES;
    }
    NSLog(@"This cell cannot be edited"); 
    return NO;
}

- (void)cellWasSwipedLeft:(UIGestureRecognizer *) swipeRecognizer {
    
    NSLog(@"Swiped Left on row: %d", swipeRecognizer.view.tag);
    
    [self.tableView setEditing:YES];
    [self.tableView reloadData];
    
    /* recognizing indexPath from swipe doesn't wark in thid case
     CGPoint point = [swipeRecognizer locationInView: self.sentenceTableView];
     NSLog(@"%f %f", point.x, point.y);
     NSIndexPath *indexPath = [self.sentenceTableView indexPathForRowAtPoint:point];
     if (indexPath == nil) {
     //Not on a cell
     NSLog(@"Swiped Left on a cell: %d", [indexPath row]);
     
     } else {
     //On a cell, use indexPath to do something.
     NSLog(@"Swiped Left not on a cell");
     }
     */
    
    
}

- (void)cellWasSwipedRight:(UIGestureRecognizer *) swipeRecognizer {
    
    
    NSLog(@"Swiped Right on row: %d", swipeRecognizer.view.tag);
    
    [self.tableView setEditing:NO];
    [self.tableView reloadData];
    /* recognizing indexPath from swipe doesn't wark in thid case
     CGPoint point = [swipeRecognizer locationInView: self.sentenceTableView];
     NSIndexPath *indexPath = [self.sentenceTableView indexPathForRowAtPoint:point];
     if (indexPath == nil) {
     //Not on a cell
     NSLog(@"Swiped Right on a cell: %d", [indexPath row]);
     
     } else {
     //On a cell, use indexPath to do something.
     NSLog(@"Swiped Right not on a cell");
     }
     */
    
}
- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
     return UITableViewCellEditingStyleNone;
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [self.postIts removeObjectAtIndex: [indexPath row]];
        
    }  
    
}*/

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

- (void) viewDidAppear:(BOOL)animated
{
    [self.tableView setEditing:NO];
    [self.tableView reloadData];
}

- (void) performPostItEdition
{
    [self performSegueWithIdentifier: @"PostIt Edition Segue" sender:self];
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([segue.destinationViewController respondsToSelector:@selector(setWordObject:)]
        && [segue.destinationViewController respondsToSelector:@selector(setPostItObject:)]) {
        NSLog(@"Post It Editon Segue"); 
        [segue.destinationViewController setWordObject: self.wordObject];
        PostItObject *postItObject = nil;
        for(PostItObject *pObj in self.postIts) {
            if(pObj.isCreatedByYou)
                postItObject = pObj;
        }
        [segue.destinationViewController setPostItObject:postItObject]; 
    }
}

- (void)viewDidUnload {
    [self setForeignWordLabel:nil];
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
