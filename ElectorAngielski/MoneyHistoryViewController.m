//
//  MoneyHistoryViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 18/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "MoneyHistoryViewController.h"
#import "MoneyHistoryCell.h"
#import "XMLParser.h"
#import "XMLElement.h"
#import "Reachability.h"
#import "ProfileServices.h"
#import "MoneyHistoryObject.h"

#define kMONEY_HISTORY_SERVICE_URL @"http://www.mnemobox.com/webservices/userMoneyHistory.xml.php?email=%@&pass=%@&from=%@&to=%@"
#define kLANG_FROM @"pl"
#define kLANG_TO @"en"

@interface MoneyHistoryViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *moneyHistoryArray;
@property (strong, nonatomic) Reachability *internetReachable;
@property (strong, nonatomic) XMLElement *xmlRoot;

@end

@implementation MoneyHistoryViewController

@synthesize moneyHistoryArray = _moneyHistoryArray;
@synthesize internetReachable = _internetReachable;
@synthesize xmlRoot = _xmlRoot;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //we need to remotely load Money History from web services
    //and display it into table view MoneyHistoryCells
    [self loadMoneyHistoryFromWebServices];
}

- (void) loadMoneyHistoryFromWebServices
{
    NSLog(@"Loading Money History From Web Services.");
    
    self.internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];

    __weak MoneyHistoryViewController *weakSelf = self;
    self.internetReachable.reachableBlock = ^(Reachability *reach)
    {
        //update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Yayyy, we have the interwebs!");
        });
        
        [weakSelf getMoneyHistoryFromWebServices];
        
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

- (void) getMoneyHistoryFromWebServices
{
    NSString *emailAddress = [ProfileServices emailAddressFromUserDefaults];
    NSString *sha1Password = [ProfileServices sha1PasswordFromUserDefaults];
    
    NSString *urlAsString = [NSString stringWithFormat:kMONEY_HISTORY_SERVICE_URL,
                             emailAddress, sha1Password, kLANG_FROM, kLANG_TO, nil];
    
    NSLog(@"Money History URL: %@", urlAsString);
    
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL: url];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    __weak MoneyHistoryViewController *weakSelf = self;
    
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
    
    __block NSMutableArray *moneyHistoryObjects = [NSMutableArray arrayWithCapacity: [self.xmlRoot.subElements count]];
    
     [self.xmlRoot.subElements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
         
            XMLElement *transactionElement = (XMLElement *) obj;
            
         NSString *moneyHistoryId = [transactionElement.attributes valueForKey:@"mhid"];
         NSString *transactionTypeId = [transactionElement.attributes valueForKey:@"typeid"];
         NSString *transactionDate = [[transactionElement.subElements objectAtIndex:0] text];
         NSString *moneyTransfer = [[transactionElement.subElements objectAtIndex:1] text];
         NSString *operationDescription = [[transactionElement.subElements objectAtIndex:2] text];
         NSString *transactionType = [[transactionElement.subElements objectAtIndex:3] text];
         NSString *wordsetTitleNative = [[transactionElement.subElements objectAtIndex:4] text];
         NSString *wordsetTitleForeign = [[transactionElement.subElements objectAtIndex:5] text];
         
         NSLog(@"Money History Object Id: %@, transaction type: %@, %@, date: %@, money transfer %@, operation description: %@, wordset title: %@ - %@", moneyHistoryId, transactionTypeId, transactionType, transactionDate, moneyTransfer, operationDescription, wordsetTitleForeign, wordsetTitleNative);
         
         
         MoneyHistoryObject *moneyHistoryObject = [MoneyHistoryObject moneyHistoryObjectWithId: moneyHistoryId
                                                                             transactionTypeId:transactionTypeId
                                                                               transactionType:transactionType
                                                                               transactionDate:transactionDate
                                                                                 moneyTransfer:moneyTransfer
                                                                          operationDescription:operationDescription
                                                                           wordsetTitleForeign:wordsetTitleForeign
                                                                                     andNative:wordsetTitleNative];
         [moneyHistoryObjects addObject:moneyHistoryObject];
     }];
    
    self.moneyHistoryArray = moneyHistoryObjects;
    [self.tableView reloadData];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.moneyHistoryArray count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"Money History Cell";
    MoneyHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    if(cell == nil) {
        cell = [[MoneyHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    MoneyHistoryObject *moneyObject = [self.moneyHistoryArray objectAtIndex:[indexPath row]];
    [cell.wordsetTitleLabel setText: moneyObject.wordsetTitleForeign];
    [cell.transcraptionTypeLabel setText: [NSString stringWithFormat:@"Transaction: %@",moneyObject.transactionType, nil]];
    [cell.amountLabel setText: [NSString stringWithFormat:@"Amount: %@", moneyObject.moneyTransfer, nil]];
    [cell.transactionDescriptionLabel setText: moneyObject.operationDescription];
    [cell.dateLabel setText: [NSString stringWithFormat:@"Date: %@", moneyObject.transactionDate]];
    
    return cell;
}


- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}
@end
