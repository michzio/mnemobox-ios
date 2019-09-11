//
//  EffectivenessStatsViewController.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 19/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface EffectivenessStatsViewController : UIViewController <CPTPlotDataSource>

@property (nonatomic, strong) NSArray *effectivenessData;
@property (nonatomic, strong) NSArray *daysData;
@property (nonatomic, strong) NSString *chartInterval;
@property (nonatomic, strong) NSString *startMonthText;
@property (nonatomic, strong) NSString *endMonthText;

- (void) reloadChartData;

@end
