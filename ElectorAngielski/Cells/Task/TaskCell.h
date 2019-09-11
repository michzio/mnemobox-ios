//
//  TaskCell.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 10/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TaskCellSolutionsButtonDelegate;

@interface TaskCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *taskTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *solutionButton;


@property (nonatomic, weak) id <TaskCellSolutionsButtonDelegate> delegate; 
@end

@protocol TaskCellSolutionsButtonDelegate <NSObject>

- (void) solutionButtonTouchedOnTaskCell: (TaskCell *) taskCell;

@end