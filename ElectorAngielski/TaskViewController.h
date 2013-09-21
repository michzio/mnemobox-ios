//
//  TaskViewController.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 10/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataViewController.h"
#import "Task+Create.h"

@interface TaskViewController : CoreDataViewController
<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) Task *task;

@end
