//
//  MainContainerViewController.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 08/10/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DictionaryViewController.h"
#import "DictionaryWordsViewController.h"

#define SegueIdentifierWordsetCategories @"Container Wordset Categories Segue"
#define SegueIdentifierDictionary @"Container Dictionary Segue"
#define SegueIdentifierDictionaryWords @"Container Dictionary Words Segue"
#define SegueIdentifierTasks @"Container Tasks Segue"
#define SegueIdentifierProfile @"Container Profile Segue"
#define SegueIdentifierForgotten @"Container Forgotten Segue"
#define SegueIdentifierRememberMe @"Container Remember Me Segue"

@interface MainContainerViewController : UIViewController <DictionaryButtonTouched, DictionaryWordsButtonTouched>

- (void)swapViewControllersWithSegueIdentifier: (NSString *) SegueIdentifier;

@end
