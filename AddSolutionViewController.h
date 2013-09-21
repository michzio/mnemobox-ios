//
//  AddSolutionViewController.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 11/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"

@interface AddSolutionViewController : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) Task *task;

@end
