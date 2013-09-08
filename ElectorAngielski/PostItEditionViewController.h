//
//  PostItEditionViewController.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 27/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WordObject.h"
#import "PostItObject.h"

@interface PostItEditionViewController : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) WordObject *wordObject;
@property (strong, nonatomic) PostItObject *postItObject;

- (IBAction)dismissKeyboardOnTap:(id)sender;

@end
