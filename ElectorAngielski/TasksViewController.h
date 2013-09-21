//
//  TasksViewController.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 10/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "CoreDataViewController.h"
#import "TaskCell.h"

@interface TasksViewController : CoreDataViewController <UITableViewDataSource, UITableViewDelegate, TaskCellSolutionsButtonDelegate>

@end
