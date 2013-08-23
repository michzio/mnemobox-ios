//
//  WordsetsTableViewController.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 22/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CoreDataTableViewController.h"
#import "XMLParser.h"
#import "Reachability.h"
#import "WordsetCategory.h"

@interface WordsetsTableViewController : CoreDataTableViewController <NSXMLParserDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) WordsetCategory *wordsetCategory; 
@property (nonatomic, strong) UIManagedDocument *wordsetsDatabase;

@end
