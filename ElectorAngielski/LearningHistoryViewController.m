//
//  LearningHistoryViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 18/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "LearningHistoryViewController.h"
#import "HistoryCell.h"
#import "XMLParser.h"
#import "XMLElement.h"
#import "Reachability.h"
#import "ProfileServices.h"
#import "HistoryObject.h"

#define kLEARNING_HISTORY_SERVICE_URL @"http://www.mnemobox.com/webservices/userHistory.xml.php?email=%@&pass=%@&from=%@&to=%@"
#define kLANG_FROM @"pl"
#define kLANG_TO @"en"

@interface LearningHistoryViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *learningHistoryArray;
@property (strong, nonatomic) Reachability *internetReachable;
@property (strong, nonatomic) XMLElement *xmlRoot;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation LearningHistoryViewController

@synthesize learningHistoryArray = _learningHistoryArray;
@synthesize internetReachable = _internetReachable;
@synthesize xmlRoot = _xmlRoot; 

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    //we need to remotely load Learning History from web services
    //and display it into table view HistoryCells
    [self loadLearningHistoryFromWebServices];
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
        
    }  else if (UIDeviceOrientationIsPortrait(deviceOrientation)  && deviceOrientation != UIDeviceOrientationPortraitUpsideDown)
    {
        [self.backgroundImageView setImage:[UIImage imageNamed:@"bigben.png"]];
    }
}

- (void) loadLearningHistoryFromWebServices
{
    NSLog(@"Loading Learning History From Web Services.");
    
    self.internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    __weak LearningHistoryViewController *weakSelf = self; 
    self.internetReachable.reachableBlock = ^(Reachability *reach)
    {
        //update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Yayyy, we have the interwebs!");
        });
        
        [weakSelf getLearningHistoryFromWebServices];
        
    };
    
    self.internetReachable.unreachableBlock = ^(Reachability *reach)
    {
        NSLog(@"Someone broke the internet :(");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet connection lost!" message:@"Check whether you have internet access." delegate: weakSelf cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
        [weakSelf.internetReachable stopNotifier];
    };
    
    [self.internetReachable startNotifier];
}

- (void) getLearningHistoryFromWebServices
{
    NSString *emailAddress = [ProfileServices emailAddressFromUserDefaults];
    NSString *sha1Password = [ProfileServices sha1PasswordFromUserDefaults];
    
    NSString *urlAsString = [NSString stringWithFormat:kLEARNING_HISTORY_SERVICE_URL,
                             emailAddress, sha1Password, kLANG_FROM, kLANG_TO, nil];
    NSLog(@"Learning History URL: %@", urlAsString);
    
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL: url];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    __weak LearningHistoryViewController *weakSelf = self;
    
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if([data length] > 0 && error == nil) {
                                   XMLParser *xmlParser = [[XMLParser alloc] initWithData:data];
                                   weakSelf.xmlRoot = [xmlParser parseAndGetRootElement];
                                   [weakSelf traverseXMLStartingFromRootElement]; 
                                   [weakSelf.internetReachable stopNotifier];
                                   
                               } else if([data length] == 0 && error == nil) {
                                   NSLog(@"Nothing has been downloaded."); 
                               } else {
                                   NSLog(@"Error happened: %@", error);
                               }
                           }];
    
}

- (void) traverseXMLStartingFromRootElement
{
    NSLog(@"Traversing XML starting from root element.");
    
    __block NSMutableArray *historyObjects = [NSMutableArray arrayWithCapacity: [self.xmlRoot.subElements count]];
    
    [self.xmlRoot.subElements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        XMLElement *historyElement = (XMLElement *) obj;
        NSString *wordsetId = [historyElement.attributes valueForKey:@"wid"];
        NSString *learningHistoryId = [historyElement.attributes valueForKey: @"lhid"];
        NSString *wordsetTitle = [[historyElement.subElements objectAtIndex:0] text];
        NSString *modeId = [[historyElement.subElements objectAtIndex:1] text]; 
        NSString *modeTitle = [[historyElement.subElements objectAtIndex:2] text];
        NSString *badAnswer = [[historyElement.subElements objectAtIndex:3] text];
        NSString *effectiveness = [[historyElement.subElements objectAtIndex:4] text];
        NSString *improvement = [[historyElement.subElements objectAtIndex:5] text];
        NSString *hits = [[historyElement.subElements objectAtIndex:6] text]; 
        NSString *lastAccess = [[historyElement.subElements objectAtIndex:7] text];
        
        NSLog(@"Learning History object: %@. WordsetId: %@, Wordset Title: %@, Mode Title: %@, Bad Answers: %@, Effectiveness: %@, Improvement: %@, Hits: %@, Last Access: %@.", learningHistoryId,
               wordsetId, wordsetTitle, modeTitle, badAnswer, effectiveness, improvement, hits
               , lastAccess);
        
       HistoryObject *historyObject = [HistoryObject historyObjectWithID: learningHistoryId
                                                            wordsetTitle:wordsetTitle learningTimes: hits
                                                           effectiveness: effectiveness learningMethod: modeTitle lastAccessDate: lastAccess ];
        [historyObjects addObject:historyObject]; 
        
    }];
    
    self.learningHistoryArray = historyObjects;
    dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
    });
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.learningHistoryArray count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"History Cell";
    
    HistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[HistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]; 
    }
    
    HistoryObject *historyObject = [self.learningHistoryArray objectAtIndex:[indexPath row]]; 
    
    [cell.wordsetTitleLabel setText: historyObject.wordsetTitle];
    [cell.timesLabel setText: [NSString stringWithFormat:@"Times: %@", historyObject.times,nil]];
    [cell.effectivenessLabel setText: [NSString stringWithFormat:@"Effectiveness: %@%%", historyObject.effectiveness, nil]];
    [cell.learningMethodLabel setText: [NSString stringWithFormat: @"Learning Method: %@", historyObject.learningMethod, nil]];
    [cell.lastAccessLabel setText: [NSString stringWithFormat:@"Last Access: %@", historyObject.lastAccessDate]]; 
    
    return cell;
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setBackgroundImageView:nil];
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
