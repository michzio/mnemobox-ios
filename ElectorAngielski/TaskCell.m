//
//  TaskCell.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 10/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "TaskCell.h"

@implementation TaskCell

- (IBAction)solutionButtonTouched:(UIButton *)sender {
    
    [self.delegate solutionButtonTouchedOnTaskCell:self];
}

@end
