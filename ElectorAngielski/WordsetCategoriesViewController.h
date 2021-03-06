//
//  WordsetCategoriesViewController.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 21/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CoreDataTableViewController.h"
#import "XMLParser.h"
#import "Reachability.h"


@interface WordsetCategoriesViewController : CoreDataTableViewController <NSXMLParserDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UIManagedDocument *wordsetsDatabase;

@end
