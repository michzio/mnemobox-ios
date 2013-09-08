//
//  RepetitionViewController.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 30/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "GenericLearningViewController.h"

@interface RepetitionViewController : GenericLearningViewController <UITextFieldDelegate>
@property (nonatomic, strong) UILabel *userAnswerLabel;

@end
