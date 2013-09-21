//
//  ForgottenWordsViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 12/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "ForgottenWordsViewController.h"
#import "TracingHistoryAndStatistics.h"

//params: emailAddress, sha1Password,fromLang, toLang
#define kUSER_FORGOTTEN_WORDS_SERVICE_URL @"http://www.mnemobox.com/webservices/userForgotten.xml.php?email=%@&pass=%@&from=%@&to=%@"
//params: userId, fromLang, toLang
#define kFORGOTTEN_WORDS_SERVICE_URL @"http://www.mnemobox.com/webservices/getwordset.php?type=forgotten&email=%@&pass=%@&wordset=0&from=%@&to=%@"
//params: emailAddress, sha1Password, wordId, fromLang, toLang
#define kDELETE_FORGOTTEN_WORD_SERVICE_URL @"http://mnemobox.com/webservices/deleteForgotten.php?email=%@&pass=%@&translationId=%@&from=%@&to=%@"

@interface ForgottenWordsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *forgottenWordsTableView;

@end

@implementation ForgottenWordsViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    if(self.internetReachable.isReachable) { 
        //save locally stored forgotten words into web server database in order to synchronize it
        [TracingHistoryAndStatistics synchronizeForgottenWordsSavedInUserDefaults];
    }
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"Setting up TableView and FetchResultsController.");
    self.tableView = self.forgottenWordsTableView;
    //if Wordset with id: Forgotten hasn't been created yet we should creat such Wordset and we will put into it new forgotten words...
    self.title = @"Forgotten";
}

- (NSURL *) getWebServicesURL
{
    NSString *emailAddress = [ProfileServices emailAddressFromUserDefaults];
    NSString *sha1Password = [ProfileServices sha1PasswordFromUserDefaults];
    NSString *urlAsString = [NSString stringWithFormat:kFORGOTTEN_WORDS_SERVICE_URL, emailAddress, sha1Password, kLANG_FROM, kLANG_TO, nil];
    NSLog(@"Forgotten Words URL: %@", urlAsString);
    
    return [NSURL URLWithString:urlAsString];
}


- (void) createOrUpdateGenericWordsetInCoreData
{
    //[self.database.managedObjectContext performBlock:^{
        
        NSLog(@"Creating or updating forgotten wordset in core data.");
        
        WordsetCategory *category = [WordsetCategory wordsetCategoryWithCID:@"USER"
                                                                foreignName:@"User Wordsets"
                                                                 nativeName:@"Zestawy użytkownika"
                                                     inManagedObjectContext:self.database.managedObjectContext];
        
        self.genericWordset = [Wordset wordsetWithWID:@"FORGOTTEN"
                                            foreignName:@"Forgotten Words"
                                             nativeName:@"Zapomniane Słowa"
                                                  level:nil
                                            description:@"This is wordset collecting words which user forgot while learning."
                                            forCategory:category
                                 inManagedObjectContext:self.database.managedObjectContext];
   //}];
    
    
}


- (NSURL *) getDeletionRequestURLForWord: (Word *) word
{
    
    NSString *emailAddress = [ProfileServices emailAddressFromUserDefaults];
    NSString *sha1Password = [ProfileServices sha1PasswordFromUserDefaults]; 
    
    //params: emailAddress, sha1Password, forgottenId, fromLang, toLang
    NSString *urlAsString = [NSString stringWithFormat: kDELETE_FORGOTTEN_WORD_SERVICE_URL,
                             emailAddress, sha1Password, word.wordId, kLANG_FROM, kLANG_TO, nil];
    
    NSLog(@"Delete Forgotten Word URL: %@", urlAsString);
    
    return [NSURL URLWithString:urlAsString];
    
}

- (void)viewDidUnload {
    [self setForgottenWordsTableView:nil];
    [super viewDidUnload];
}
@end
