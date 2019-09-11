//
//  AnswersStatsViewController.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 19/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

#define kLAST_WEEK @"Last Week"
#define kLAST_MONTH @"Last Month"

@interface AnswersStatsViewController : UIViewController <CPTBarPlotDataSource, CPTBarPlotDelegate, UITabBarControllerDelegate>

@property (nonatomic, strong) NSArray *badAnswersData;
@property (nonatomic, strong) NSArray *goodAnswersData;
@property (nonatomic, strong) NSArray *effectivenessData;
@property (nonatomic, strong) NSArray *datesLabels;
@property (nonatomic) CGFloat maxValue;
@property (nonatomic, strong) NSString *chartInterval;

@property (strong, nonatomic) NSString *startMonthText;
@property (strong, nonatomic) NSString *endMonthText;

- (void) initPlot;
@end
