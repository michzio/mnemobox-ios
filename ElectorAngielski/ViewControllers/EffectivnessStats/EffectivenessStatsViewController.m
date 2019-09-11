//
//  EffectivenessStatsViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 19/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "EffectivenessStatsViewController.h"
#import "AnswersStatsViewController.h"

#define IDIOM UI_USER_INTERFACE_IDIOM()
#define IPAD UIUserInterfaceIdiomPad
#define kUSER_STATS_SERVICE_URL @"http://www.mnemobox.com/webservices/userStats.xml.php?email=%@&pass=%@&from=%@&to=%@"
#define kLANG_FROM @"pl"
#define kLANG_TO @"en"

@interface EffectivenessStatsViewController ()
{
    BOOL isShowingLandscapeView;
}

@property (weak, nonatomic) IBOutlet CPTGraphHostingView *hostView;
@property (weak, nonatomic) IBOutlet UILabel *startMonth;
@property (weak, nonatomic) IBOutlet UILabel *endMonth;


@end

@implementation EffectivenessStatsViewController

@synthesize hostView = _hostView;
@synthesize effectivenessData = _effectivenessData;
@synthesize daysData = _daysData;
@synthesize chartInterval = _chartInterval;

#pragma mark - UIViewController lifecycle methods
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
     isShowingLandscapeView = NO;
    NSLog(@"Effectiveness View Did Appear"); 
    if(self.view.tag == 0) {
        [self reloadChartData];
    }
}

- (void) reloadChartData {
    NSLog(@"Reloading Chart Data."); 
    if(self.view.tag == 0) {
        NSLog(@"Setting chart data from AnswersStatsViewController"); 
        self.effectivenessData = [[self.tabBarController.viewControllers objectAtIndex:0] effectivenessData];
        self.daysData = [[self.tabBarController.viewControllers objectAtIndex:0] datesLabels];
        self.chartInterval = [[self.tabBarController.viewControllers objectAtIndex:0] chartInterval];
        self.startMonthText = [[self.tabBarController.viewControllers objectAtIndex:0] startMonthText];
        self.endMonthText = [[self.tabBarController.viewControllers objectAtIndex:0] endMonthText];
    }
    [self initPlot];
}

#pragma mark - Chart behavior
-(void)initPlot {
    [self configureHost];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
    [self.startMonth setText: self.startMonthText];
    [self.endMonth setText: self.endMonthText];
}

- (void) configureHost
{
    self.hostView.allowPinchScaling = YES;
}

- (void) configureGraph
{
    // 1 - Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    graph.plotAreaFrame.masksToBorder = NO;
     self.hostView.hostedGraph = graph;
    // 2 - Configure the graph
    [graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    graph.paddingBottom = 30.0f;
    graph.paddingLeft  =  40.0f;
    graph.paddingTop    = 0.0f;
    graph.paddingRight  = 10.0f;
    // 3 - Set graph title
    NSString *title = self.chartInterval;
    graph.title = title;
    // 3 - Create and set text style
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor blackColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 16.0f;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, -16.0f);
    // 4 - Set padding for plot area
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
        [graph.plotAreaFrame setPaddingLeft:-20.0f];
    } else {
        [graph.plotAreaFrame setPaddingLeft:-12.0f];
    }
    
    /*[graph.plotAreaFrame setPaddingBottom:30.0f];
    [graph.plotAreaFrame setPaddingRight: 10.0f];*/
    // 5 - Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    
}

- (void) configurePlots
{
    // 1 - Get graph and plot space
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    // 2 - Create the three plots
    CPTScatterPlot *effectivenessPlot = [[CPTScatterPlot alloc] init];
    effectivenessPlot.dataSource = self;
    effectivenessPlot.identifier = @"Effectiveness";
    CPTColor *effectivenessColor = [CPTColor redColor];
    [graph addPlot:effectivenessPlot toPlotSpace:plotSpace];
    
    // 3 - Set up plot space
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:effectivenessPlot, nil]];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:[NSNumber numberWithFloat:1.1f]];
    plotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:[NSNumber numberWithFloat:1.2f]];
    plotSpace.yRange = yRange;
    // 4 - Create styles and symbols
    CPTMutableLineStyle *effectivenessLineStyle = [effectivenessPlot.dataLineStyle mutableCopy];
    effectivenessLineStyle.lineWidth = 2.5;
    effectivenessLineStyle.lineColor = effectivenessColor;
    effectivenessPlot.dataLineStyle = effectivenessLineStyle;
    CPTMutableLineStyle *effectivenessSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    effectivenessSymbolLineStyle.lineColor = effectivenessColor;
    CPTPlotSymbol *effectivenessSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    effectivenessSymbol.fill = [CPTFill fillWithColor:effectivenessColor];
    effectivenessSymbol.lineStyle = effectivenessSymbolLineStyle;
    effectivenessSymbol.size = CGSizeMake(6.0f, 6.0f);
    effectivenessPlot.plotSymbol = effectivenessSymbol;
    
}

- (void) configureAxes
{
    // 1 - Create styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor blackColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor blackColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor blackColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 11.0f;
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 2.0f;
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    gridLineStyle.lineColor = [CPTColor blackColor];
    gridLineStyle.lineWidth = 1.0f;
    // 2 - Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    // 3 - Configure x-axis
    CPTAxis *x = axisSet.xAxis;
    //x.title = @"September";
    //x.titleTextStyle = axisTitleStyle;
    //x.titleOffset = 20.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = 4.0f;
    x.tickDirection = CPTSignNegative;
    CGFloat dateCount = [self.daysData count];
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
    NSInteger i = 0;
    for (NSString *date in self.daysData) {
        CGFloat location = i++;
        if([self.chartInterval isEqualToString:kLAST_MONTH] && self.view.tag == 0 && i%2 == 0) continue;
        NSString *day = [[date componentsSeparatedByString:@"/"] objectAtIndex:0];
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:day  textStyle:x.labelTextStyle];
        
        label.tickLocation = [NSNumber numberWithFloat:location];
        label.offset = x.majorTickLength;
        if (label) {
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithFloat:location]];
        }
    }

    x.axisLabels = xLabels;
    x.majorTickLocations = xLocations;
    // 4 - Configure y-axis
    CPTAxis *y = axisSet.yAxis;
    y.title = @"Effectiveness [%]";
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = -40.0f;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 16.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    NSInteger majorIncrement = 10;
    NSInteger minorIncrement = 5;
    CGFloat yMax = 100.0f;  // should determine dynamically based on max price
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    for (NSInteger j = minorIncrement; j <= yMax; j += minorIncrement) {
        NSUInteger mod = j % majorIncrement;
        if (mod == 0) {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i", j] textStyle:y.labelTextStyle];
            NSNumber *location = [NSNumber numberWithFloat: j];
            label.tickLocation = location;
            label.offset = -y.majorTickLength - y.labelOffset;
            if (label) {
                [yLabels addObject:label];
            }
            [yMajorLocations addObject:location];
        } else {
            [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
        }
    }
    y.axisLabels = yLabels;
    y.majorTickLocations = yMajorLocations;
    y.minorTickLocations = yMinorLocations;
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return [self.effectivenessData count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
   
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            if (index < [self.effectivenessData count]) {
                //return [self.daysData objectAtIndex:index];
                return [NSNumber numberWithUnsignedInteger:index];
            }
            break;
            
        case CPTScatterPlotFieldY:
            if ([plot.identifier isEqual:@"Effectiveness"]) {
                return [self.effectivenessData objectAtIndex:index];
            }
            break;
    }
    return [NSDecimalNumber zero];
}

- (void)orientationChanged:(NSNotification *)notification
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation) &&
        !isShowingLandscapeView)
    {
        if(IDIOM == IPAD) {
            isShowingLandscapeView = YES;
            
        } else {
            if(self.view.tag == 99) {
                ///do just nothing
            } else {
                [self performSegueWithIdentifier:@"Landscape View Segue" sender:self];
                isShowingLandscapeView = YES;
            }
        }
    }
    
    else if (UIDeviceOrientationIsPortrait(deviceOrientation) &&
             isShowingLandscapeView && deviceOrientation != UIDeviceOrientationPortraitUpsideDown)
    {
        if(IDIOM == IPAD) {
            isShowingLandscapeView = NO;
            
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
            isShowingLandscapeView = NO;
        }
        
        
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Landscape View Segue"])
    {
        NSLog(@"Landscape View Segue"); 
        [segue.destinationViewController setDaysData:self.daysData];
        [segue.destinationViewController setEffectivenessData: self.effectivenessData];
        [segue.destinationViewController setChartInterval: self.chartInterval];
        [segue.destinationViewController setStartMonthText:self.startMonthText];
        [segue.destinationViewController setEndMonthText:self.endMonthText];
        [segue.destinationViewController reloadChartData];
        
    }
}

- (void)viewDidUnload {
    [self setHostView:nil];
    [self setStartMonth:nil];
    [self setEndMonth:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return ((toInterfaceOrientation == UIInterfaceOrientationPortrait) || (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight));
    } else {
        
     return ((toInterfaceOrientation == UIInterfaceOrientationPortrait) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight));
    
    }
}
@end
