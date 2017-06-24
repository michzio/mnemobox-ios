//
//  AnswersStatsViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 19/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "AnswersStatsViewController.h"
#import "EffectivenessStatsViewController.h"
#import "ProfileServices.h"
#import "XMLParser.h"
#import "XMLElement.h"
#import "Reachability.h"

#define kUSER_STATS_SERVICE_URL @"http://www.mnemobox.com/webservices/userStats.xml.php?email=%@&pass=%@&from=%@&to=%@"
#define kLANG_FROM @"pl"
#define kLANG_TO @"en"

@interface AnswersStatsViewController ()
{
    BOOL isShowingLandscapeView;
}

@property (weak, nonatomic) IBOutlet CPTGraphHostingView *hostView;
@property (nonatomic, strong) CPTBarPlot *badAnsPlot;
@property (nonatomic, strong) CPTBarPlot *goodAnsPlot;
@property (nonatomic, strong) CPTPlotSpaceAnnotation *countWordsAnnotation;

@property (nonatomic, strong) Reachability *internetReachable;

@property (weak, nonatomic) IBOutlet UISwitch *badSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *goodSwitch;
@property (weak, nonatomic) IBOutlet UILabel *startMonth;
@property (weak, nonatomic) IBOutlet UILabel *endMonth;

-(void)loadStatsDataFromWebServices; 
-(void)configureGraph;
-(void)configurePlots;
-(void)configureAxes;
-(void)hideAnnotation:(CPTGraph *)graph;

@end

@implementation AnswersStatsViewController

CGFloat const CPDBarWidth = 0.25f;
CGFloat const CPDBarInitialX = 0.25f;

@synthesize  hostView = _hostView;
@synthesize badAnsPlot = _badAnsPlot;
@synthesize goodAnsPlot = _goodAnsPlot;
@synthesize countWordsAnnotation = _countWordsAnnotation;

@synthesize badAnswersData = _badAnswersData;
@synthesize goodAnswersData = _goodAnswersData;
@synthesize datesLabels = _datesLabels;
@synthesize maxValue = _maxValue;
@synthesize chartInterval = _chartInterval;
@synthesize  startMonth = _startMonth;
@synthesize endMonth = _endMonth;
@synthesize internetReachable = _internetReachable;
@synthesize effectivenessData = _effectivenessData;
@synthesize startMonthText = _startMonthText;
@synthesize endMonthText = _endMonthText;

#pragma mark - UIViewController lifecycle methods
-(void)viewDidLoad {
    [super viewDidLoad];
     
        [self.tabBarController.navigationItem.rightBarButtonItem setTarget:self];
        [self.tabBarController.navigationItem.rightBarButtonItem setAction:@selector(changeIntervalBarButtonTapped:)];
        self.chartInterval = kLAST_WEEK;
        self.internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
        if(self.internetReachable.isReachable) {
            if(self.view.tag == 0) {
                [self loadStatsDataFromWebServices];
            }
            [self initPlot];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet connection lost!" message: @"Could not load statistics due to internet connection problems." delegate: self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
            [alert show]; 
        }
        [self adjustToSreenOrientation];

}

- (IBAction)changeIntervalBarButtonTapped:(UIBarButtonItem *)sender
{
    NSLog(@"Change Interval Bar Button Tapped.");
    if([sender.title isEqualToString:@"Last Week"]) {
        [sender setTitle:@"Last Month"];
        self.chartInterval = kLAST_WEEK;
        if(self.internetReachable.isReachable) {
            [self loadStatsDataFromWebServices];
            [self initPlot];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet connection lost!" message: @"Could not load statistics due to internet connection problems." delegate: self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
            [alert show];
        }
    } else if([sender.title isEqualToString:@"Last Month"]) {
        [sender setTitle:@"Last Week"];
        self.chartInterval = kLAST_MONTH;
        if(self.internetReachable.isReachable) {
            [self loadStatsDataFromWebServices];
            [self initPlot];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet connection lost!" message: @"Could not load statistics due to internet connection problems." delegate: self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    [[self.tabBarController.viewControllers objectAtIndex:1]
     reloadChartData];
    [self.badSwitch setOn:YES];
    [self.goodSwitch setOn:YES];
   
}

-(void)loadStatsDataFromWebServices
{
    NSString *emailAddress = [ProfileServices emailAddressFromUserDefaults];
    NSString *sha1Passowrd = [ProfileServices sha1PasswordFromUserDefaults];
    
    NSString *urlAsString = [NSString stringWithFormat:kUSER_STATS_SERVICE_URL, emailAddress, sha1Passowrd, kLANG_FROM, kLANG_TO, nil];
                             
    NSLog(@"User Stats URL: %@", urlAsString);
                             
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSError *error = nil;
    NSURLResponse *response = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
    if([data length] > 0 && error == nil) {
        //we have data do something with them
        [self getStatsFromData:data]; 
    } else if( [data length] == 0 && error == nil) {
        NSLog(@"Nothing has been downloaded."); 
    } else {
        NSLog(@"An error happened: %@", error);
    }

    
}

- (void) getStatsFromData: (NSData *) data
{
    XMLParser *xmlParser = [[XMLParser alloc] initWithData:data];
    XMLElement *statsElement = [xmlParser parseAndGetRootElement];
    NSString *badStatsString = [[statsElement.subElements objectAtIndex:0] text];
    NSString *goodStatsString = [[statsElement.subElements objectAtIndex:1] text];
    NSString *statsEffString = [[statsElement.subElements objectAtIndex:2]text];
    
    NSDictionary *badCountsForDay = [self dictionaryFromStatsString: badStatsString];
    NSDictionary *goodCountsForDay = [self dictionaryFromStatsString:goodStatsString];
    NSDictionary *effectivenessForDay = [self dictionaryFromStatsString:statsEffString];
    
            
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd/MM"];
        NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
        [monthFormatter setDateFormat:@"MMMM"];
    
        NSArray *dates;
        if([self.chartInterval isEqualToString: kLAST_WEEK]) {
            dates = [self lastSevenDays];
        } else {
            dates = [self lastMonthDays]; 
        }
        
        __block NSMutableArray *goodAnsCounts = [[NSMutableArray alloc] init];
        __block NSMutableArray *badAnsCounts = [[NSMutableArray alloc] init];
    __block NSMutableArray *effectivenessCounts = [[NSMutableArray alloc] init];
        __block NSMutableArray *datesLabels = [[NSMutableArray alloc] init];
        __block CGFloat maxValue = 50.0f;
    
        [dates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSDate *date = (NSDate *) obj;
            
            NSString *dateLabel = [formatter stringFromDate:date];
            NSLog(@"%@", dateLabel);
            //[datesLabels addObject: dateLabel];
            [datesLabels insertObject:dateLabel atIndex:0];
            
            NSString *badCount = [badCountsForDay objectForKey:dateLabel];
            if(badCount) {
                //[badAnsCounts addObject:badCount];
                [badAnsCounts insertObject:badCount atIndex:0];
                if([badCount floatValue] > maxValue) maxValue = [badCount floatValue];
                
            } else {
                //[badAnsCounts addObject:@"0"];
                [badAnsCounts insertObject:@"0" atIndex:0];
            }
            
            NSString *goodCount = [goodCountsForDay objectForKey:dateLabel];
            if(goodCount) {
                //[goodAnsCounts addObject:goodCount];
                [goodAnsCounts insertObject:goodCount atIndex:0];
                if([goodCount floatValue] > maxValue) maxValue = [goodCount floatValue];
                
            } else {
                //[goodAnsCounts addObject:@"0"];
                [goodAnsCounts insertObject:@"0" atIndex:0];
            }
            
            NSString *effCount = [effectivenessForDay objectForKey:dateLabel];
            if(effCount) {
                [effectivenessCounts insertObject:effCount atIndex:0];
            } else {
                [effectivenessCounts insertObject:@"0" atIndex:0];
            }
            
            //setting startMonthLabel and endMonthLabel
            if(idx == 0) {
                //endMonth label 
                NSString *endMonthString = [monthFormatter stringFromDate:date];
                self.endMonthText = endMonthString;
                
            } else if(idx == ([dates count] - 1)) {
                //startMonth label
                NSString *startMonthString = [monthFormatter stringFromDate:date];
                self.startMonthText = startMonthString;
            }
            
        }];
    
    self.datesLabels = datesLabels;
    self.badAnswersData = badAnsCounts;
    self.goodAnswersData = goodAnsCounts;
    self.effectivenessData = effectivenessCounts;
    self.maxValue = maxValue;
}

- (NSDictionary *) dictionaryFromStatsString: (NSString *) statsString
{
    if([statsString isEqualToString:@"[]"]) {
        NSLog(@"This stats string is empty");
        return [[NSDictionary alloc] init];
    }
    
    statsString = [statsString stringByReplacingOccurrencesOfString:@"[ [" withString:@""];
    statsString = [statsString stringByReplacingOccurrencesOfString:@"] ]" withString:@""];
    NSArray *dayStats = [statsString componentsSeparatedByString:@"], ["];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM"];
    
    
    __block NSMutableDictionary *countForDays = [[NSMutableDictionary alloc] initWithCapacity:[dayStats count]];

    [dayStats enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSString *dayStat =  (NSString *) obj;
        
        NSArray *timestampAndCount = [dayStat componentsSeparatedByString:@", "];
        
        NSString *timeStampString = [timestampAndCount objectAtIndex:0];
        timeStampString = [timeStampString substringToIndex:10];
        NSTimeInterval _interval=[timeStampString doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
        NSString *dateAsString = [formatter stringFromDate:date];
        NSString *count = [timestampAndCount objectAtIndex:1];
        
        NSLog(@"%@ has count: %@", date, count);
        
        [countForDays setObject:count forKey:dateAsString];
        
    }];
    
    return countForDays;

}


- (NSArray *)lastSevenDays {
    return [self lastNDays:8];
}

- (NSArray *)lastMonthDays {
    
    return [self lastNDays:30];
}

- (NSArray *)lastNDays: (NSInteger) numOfDays {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE dd/MM/yyyy"];
    
    NSDate *date = [NSDate date];
    NSMutableArray *lastNDays = [[NSMutableArray alloc] initWithCapacity:numOfDays];
    for (int i = 0; i > -numOfDays; i--) {
        NSString *nDay = [formatter stringFromDate:date];
        NSLog(@"%@", nDay); 
        //[lastNDays addObject:nDay];
        [lastNDays addObject: date];
        
        date = [self dateBySubtractingOneDayFromDate:date];
    }
    return lastNDays;
}

// Subtract one day from the current date (this compensates for daylight savings time, etc, etc.)
- (NSDate *)dateBySubtractingOneDayFromDate:(NSDate *)date {
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDateComponents *minusOneDay = [[NSDateComponents alloc] init];
    [minusOneDay setDay:-1];
    NSDate *newDate = [cal dateByAddingComponents:minusOneDay
                                           toDate:date
                                          options:0];
    return newDate;
}
//NSDate *nextDay = [calendar dateByAddingComponents:offset toDate:startDate options:0];
//options: NSWrapCalendarComponents]; causes while being to go back to ealier month not to change to that month!
//but wraping in current month 

#pragma mark - IBActions
- (IBAction)badAnsSwiched:(id)sender {
    NSLog(@"Bad Answer Swiched.");
    BOOL on = [((UISwitch *) sender) isOn];
    if (!on) {
        [self hideAnnotation:self.badAnsPlot.graph];
    }
    [self.badAnsPlot setHidden:!on];
}
- (IBAction)goodAnsSwiched:(id)sender {
    NSLog(@"Good Answer Swiched.");
    BOOL on = [((UISwitch *) sender) isOn];
    if (!on) {
        [self hideAnnotation:self.goodAnsPlot.graph];
    }
    [self.goodAnsPlot setHidden:!on];
}

-(void)hideAnnotation:(CPTGraph *)graph {
    /*annotation hidding if is used ;/ */
}

#pragma mark - Chart behavior
-(void)initPlot {
    NSLog(@"Initialization of Plot"); 
    self.hostView.allowPinchScaling = NO;
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
    [self.startMonth setText: self.startMonthText];
    [self.endMonth setText: self.endMonthText];
}

-(void)configureGraph {
    // 1 - Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    graph.plotAreaFrame.masksToBorder = NO;
    self.hostView.hostedGraph = graph;
    // 2 - Configure the graph
    [graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    graph.paddingBottom = 30.0f;
    graph.paddingLeft  = 40.0f;
    graph.paddingTop    = 0.0f;
    graph.paddingRight  = 10.0f;
    // 3 - Set up styles
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor blackColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 16.0f;
    // 4 - Set up title
    NSString *title = self.chartInterval;
    graph.title = title;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, -16.0f);
    // 5 - Set up plot space
    CGFloat xMin = 0.0f;
    //CGFloat xMax = [[[CPDStockPriceStore sharedInstance] datesInWeek] count];
    //CGFloat xMax = 7.0f;
    CGFloat xMax = [self.datesLabels count]; 
    CGFloat yMin = 0.0f;
    //CGFloat yMax = 400.0f;  // should determine dynamically based on max price
    CGFloat yMax = self.maxValue + 50.0f;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xMin) length:CPTDecimalFromFloat(xMax)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yMin) length:CPTDecimalFromFloat(yMax)];
    // 5 - Enable user interactions for plot space
    plotSpace.allowsUserInteraction = YES;
}

- (void) configurePlots
{
    // 1 - Get graph and plot space
    CPTGraph *graph = self.hostView.hostedGraph;
   // CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    // 2 - Create the good and bad plots
    self.badAnsPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor redColor] horizontalBars:NO];
    self.badAnsPlot.identifier = @"Bad Answers";
    self.goodAnsPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor grayColor] horizontalBars:NO];
    self.goodAnsPlot.identifier = @"Good Answers";
    // 3 - Set up line style
    CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
    barLineStyle.lineColor = [CPTColor lightGrayColor];
    barLineStyle.lineWidth = 0.5;
    // 3 - Add plots to graph
    CGFloat barX = CPDBarInitialX;
    NSArray *plots = [NSArray arrayWithObjects:self.badAnsPlot, self.goodAnsPlot, nil];
    for (CPTBarPlot *plot in plots) {
        plot.dataSource = self;
        plot.delegate = self;
        plot.barWidth = CPTDecimalFromDouble(CPDBarWidth);
        plot.barOffset = CPTDecimalFromDouble(barX);
        plot.lineStyle = barLineStyle;
        [graph addPlot:plot toPlotSpace:graph.defaultPlotSpace];
        barX += CPDBarWidth;
    }
}

- (void) configureAxes
{
    // 1 - Configure styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor blackColor];
    axisTitleStyle.fontName = @"Helvetica";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:1];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor blackColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 11.0f;
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    gridLineStyle.lineColor = [CPTColor blackColor];
    gridLineStyle.lineWidth = 1.0f;
    // 2 - Get the graph's axis set
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
    CGFloat dateCount = [self.datesLabels count];
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
    int i = 0;
    
    for (NSString *date in self.datesLabels) {
        CGFloat location = i++;
        if([self.chartInterval isEqualToString:kLAST_MONTH] && self.view.tag == 0 && i%2 == 0) continue;
        NSString *day = [[date componentsSeparatedByString:@"/"] objectAtIndex:0];
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:day  textStyle:x.labelTextStyle];
       
        label.tickLocation = CPTDecimalFromCGFloat(location);
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
    y.title = @"Count";
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
    int increment = (int) self.maxValue/6;
    NSInteger majorIncrement = increment - increment%10;
    NSInteger minorIncrement = majorIncrement/2;
    //CGFloat yMax = 400.0f;  // should determine dynamically based on max price
    CGFloat yMax = self.maxValue;
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    for (NSInteger j = minorIncrement; j <= yMax; j += minorIncrement) {
        NSUInteger mod = j % majorIncrement;
        if (mod == 0) {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i", j] textStyle:y.labelTextStyle];
            NSDecimal location = CPTDecimalFromInteger(j);
            label.tickLocation = location;
            label.offset = -y.majorTickLength - y.labelOffset;
            if (label) {
                [yLabels addObject:label];
            }
            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
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
    //return [[[CPDStockPriceStore sharedInstance] datesInWeek] count];
    
    return [self.datesLabels count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {

    if ((fieldEnum == CPTBarPlotFieldBarTip) && (index < [self.datesLabels count])) {
        if ([plot.identifier isEqual:@"Bad Answers"]) {
            return [self.badAnswersData objectAtIndex:index];
        } else if ([plot.identifier isEqual:@"Good Answers"]) {
            return [self.goodAnswersData objectAtIndex:index];
        } 
    }
    return [NSDecimalNumber numberWithUnsignedInteger:index];

}

- (void)awakeFromNib
{
    self.tabBarController.delegate = self;
    
    isShowingLandscapeView = NO;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSLog(@"Tab bar button selected.");
    if([viewController isKindOfClass: [EffectivenessStatsViewController class]]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:[tabBarController.viewControllers objectAtIndex:1]
                                                 selector:@selector(orientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    } else if([viewController isKindOfClass: [AnswersStatsViewController class]]) {
        //EffectivenessStatsViewController
        [[NSNotificationCenter defaultCenter] removeObserver:[tabBarController.viewControllers objectAtIndex:1]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
}


- (void)orientationChanged:(NSNotification *)notification
{
    [self adjustToSreenOrientation];
}

- (void) adjustToSreenOrientation {
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation) &&
        !isShowingLandscapeView)
    {
        if(self.view.tag == 99) {
            ///do just nothing
        } else {
            [self performSegueWithIdentifier:@"Landscape View Segue" sender:self];
            isShowingLandscapeView = YES;
        }
    }
    
    else if (UIDeviceOrientationIsPortrait(deviceOrientation) &&
             isShowingLandscapeView && deviceOrientation != UIDeviceOrientationPortraitUpsideDown)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        isShowingLandscapeView = NO;
        
        
    }

}
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Landscape View Segue"])
    {
        NSLog(@"Landscape View Segue");
        [segue.destinationViewController setDatesLabels:self.datesLabels];
        [segue.destinationViewController setBadAnswersData: self.badAnswersData];
        [segue.destinationViewController setGoodAnswersData:self.goodAnswersData];
        [segue.destinationViewController setChartInterval: self.chartInterval];
        [segue.destinationViewController setMaxValue: self.maxValue];
        [segue.destinationViewController setStartMonthText: self.startMonthText];
        [segue.destinationViewController setEndMonthText: self.endMonthText];
        
        [segue.destinationViewController initPlot];
    }
}

- (void)viewDidUnload {
  
    [self setHostView:nil];
    [self setStartMonth:nil];
    [self setEndMonth:nil];
    [self setBadSwitch:nil];
    [self setGoodSwitch:nil];
    [super viewDidUnload];
}
@end
