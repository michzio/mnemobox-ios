//
//  CartoonsViewController.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 06/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "CartonsViewController.h"
#import "CardObject.h"
#import "NSMutableArray+Shuffle.h"
#import "Word+Create.h"

@interface CartonsViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;

@property (weak, nonatomic) IBOutlet UIImageView *image0;
@property (weak, nonatomic) IBOutlet UIImageView *image1;
@property (weak, nonatomic) IBOutlet UIImageView *image2;
@property (weak, nonatomic) IBOutlet UIImageView *image3;
@property (weak, nonatomic) IBOutlet UIImageView *image4;
@property (weak, nonatomic) IBOutlet UIImageView *image5;
@property (weak, nonatomic) IBOutlet UIImageView *image6;
@property (weak, nonatomic) IBOutlet UIImageView *image7;
@property (weak, nonatomic) IBOutlet UIImageView *image8;
@property (weak, nonatomic) IBOutlet UIImageView *image9;
@property (weak, nonatomic) IBOutlet UIImageView *image10;
@property (weak, nonatomic) IBOutlet UIImageView *image11;

@property (weak, nonatomic) IBOutlet UIButton *button0;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *button3;
@property (weak, nonatomic) IBOutlet UIButton *button4;
@property (weak, nonatomic) IBOutlet UIButton *button5;
@property (weak, nonatomic) IBOutlet UIButton *button6;
@property (weak, nonatomic) IBOutlet UIButton *button7;
@property (weak, nonatomic) IBOutlet UIButton *button8;
@property (weak, nonatomic) IBOutlet UIButton *button9;
@property (weak, nonatomic) IBOutlet UIButton *button10;
@property (weak, nonatomic) IBOutlet UIButton *button11;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *reloadButton;


@property (strong, nonatomic) NSMutableArray *loadedWords;
@property (nonatomic) NSInteger uncoveredCardNumber;
@property (strong, nonatomic) UILabel *userAnswerLabel;

@end

@implementation CartonsViewController

@synthesize  loadedWords = _loadedWords;
@synthesize uncoveredCardNumber = _uncoveredCardNumber;
@synthesize userAnswerLabel = _userAnswerLabel;

- (void) setUpActivityIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator startAnimating];
        
    });
}
- (IBAction)reloadButton:(UIBarButtonItem *)sender {
    NSLog(@"Reload Button Touched.");
    
    [self cleanCurrentView];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingLabel setHidden:NO];
        [self.activityIndicator setHidden: NO];
       
    });
    [self setUpActivityIndicator];
    [self reloadCards];
    self.uncoveredCardNumber = -1;
    
}

- (void) displayFirstWord
{
    NSLog(@"Generating word's cards on screen in covered state.");
    
    if([self.words count] <= 0) { [self emptyWordsetAlert]; return; }
    
    //dummy initial setting of currentWordIndex
    self.currentWordIndex = [self.words count] -1;
    [self loadCurrentWordObject];
    self.userAnswerLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 5, 290, 64)];
    self.userAnswerLabel.textAlignment = UITextAlignmentCenter;
    self.userAnswerLabel.backgroundColor = [UIColor clearColor];
    self.userAnswerLabel.textColor = [UIColor whiteColor];
    self.userAnswerLabel.text = @"brak";
    self.userAnswerLabel.adjustsFontSizeToFitWidth = YES;
    self.userAnswerLabel.font = [UIFont boldSystemFontOfSize:15.0];
    
    [self.pullUpView addSubview:self.userAnswerLabel];
   
    srand(time(NULL));
    [self reloadCards];
    self.uncoveredCardNumber = -1;
    
 
}

- (void) endLoadingProcessAndDisplayCards
{
    NSLog(@"Ending loading proccess and displaying cards."); 
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating];
        [self.loadingLabel setHidden:YES];
        
        [self.button0 setHidden:NO];
        [self.button1 setHidden:NO];
        [self.button2 setHidden:NO];
        [self.button3 setHidden:NO];
        [self.button4 setHidden:NO];
        [self.button5 setHidden:NO];
        [self.button6 setHidden:NO];
        [self.button7 setHidden:NO];
        [self.button8 setHidden:NO];
        [self.button9 setHidden:NO];
        [self.button10 setHidden:NO];
        [self.button11 setHidden:NO];
    });
}

- (void) emptyWordsetAlert
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Empty Wordset" message:@"Could not find any words in wordset." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        
        [alert show];
    });
}

- (void) reloadCards
{
    NSLog(@"Reloading cards...");
dispatch_async(dispatch_queue_create("ReloadingCards", nil), ^{
    
    self.loadedWords = [NSMutableArray arrayWithCapacity:12];
    for(NSUInteger idx = 0; idx<6; idx++) {
        
        CardObject *cardObjectForeign = nil;
        CardObject *cardObjectNative = nil;
        
        if(self.wordsStoredInCoreData) {
            Word *word = [self.words objectAtIndex:idx];
            
            cardObjectForeign = [[CardObject alloc] initWithWID: word.wordId
                                                        foreign:[NSString stringWithFormat:@"%@ %@", word.foreignArticle, word.foreign, nil] 
                                                  native:[NSString stringWithFormat:@"%@ %@", word.nativeArticle, word.native, nil]
                                               wordImage: [UIImage imageWithData: word.image]
                                               recording:word.recording
                                               isForeign:YES
                                 wordsArrayIdx:idx];
            cardObjectNative = [[CardObject alloc] initWithWID: word.wordId
                                                        foreign:[NSString stringWithFormat:@"%@ %@", word.foreignArticle, word.foreign, nil]
                                                         native:[NSString stringWithFormat:@"%@ %@", word.nativeArticle, word.native, nil]
                                                      wordImage: [UIImage imageWithData: word.image]
                                                      recording:word.recording
                                                      isForeign:NO
                                wordsArrayIdx:idx];
        } else {
            WordObject *word = [self.words objectAtIndex:idx];
            
            NSData *imageData = [Word imageDataWithImagePath: word.imagePath];
            UIImage *image = [UIImage imageWithData:imageData];
            [word setImage: image];
            
            cardObjectForeign = [[CardObject alloc] initWithWID: word.wordId
                                                        foreign:[NSString stringWithFormat:@"%@ %@", word.foreignArticle, word.foreign, nil]
                                                         native:[NSString stringWithFormat:@"%@ %@", word.nativeArticle, word.native, nil]
                                                      wordImage:word.image
                                                      recording:word.recording
                                                      isForeign:YES
                                 wordsArrayIdx:idx];
            cardObjectNative = [[CardObject alloc] initWithWID: word.wordId
                                                       foreign:[NSString stringWithFormat:@"%@ %@", word.foreignArticle, word.foreign, nil]
                                                        native:[NSString stringWithFormat:@"%@ %@", word.nativeArticle, word.native, nil]
                                                     wordImage:word.image
                                                     recording:word.recording
                                                     isForeign:NO
                                wordsArrayIdx:idx];
        }
        
       
        [self.loadedWords addObject: cardObjectForeign];
        [self.loadedWords addObject: cardObjectNative];
    }
    
    //shuffle loadedWords array in order to have incidentious order of cards in Card Set
    [self.loadedWords shuffle];
 
    
    dispatch_async(dispatch_get_main_queue(), ^{
           
    //setting button 0 
    [self.button0 setTitle: [[self.loadedWords objectAtIndex:0] label] forState:UIControlStateNormal];
    [self.image0 setImage: [[self.loadedWords objectAtIndex:0] image]];
    [self.button0 setTag:0];
    
    //setting button 1
    [self.button1 setTitle: [[self.loadedWords objectAtIndex:1] label] forState:UIControlStateNormal];
    [self.image1 setImage: [[self.loadedWords objectAtIndex:1] image]];
    [self.button1 setTag:1];
    
    //setting button 2
    [self.button2 setTitle: [[self.loadedWords objectAtIndex:2] label] forState:UIControlStateNormal];
    [self.image2 setImage: [[self.loadedWords objectAtIndex:2] image]];
    [self.button2 setTag:2];
    
    //setting button 3
    [self.button3 setTitle: [[self.loadedWords objectAtIndex:3] label] forState:UIControlStateNormal];
    [self.image3 setImage: [[self.loadedWords objectAtIndex:3] image]];
    [self.button3 setTag:3];
    
    //setting button 4
    [self.button4 setTitle: [[self.loadedWords objectAtIndex:4] label] forState:UIControlStateNormal];
    [self.image4 setImage: [[self.loadedWords objectAtIndex:4] image]];
    [self.button4 setTag:4];
    
    //setting button 5
    [self.button5 setTitle: [[self.loadedWords objectAtIndex:5] label] forState:UIControlStateNormal];
    [self.image5 setImage: [[self.loadedWords objectAtIndex:5] image]];
    [self.button5 setTag:5];
    
    //setting button 6
    [self.button6 setTitle: [[self.loadedWords objectAtIndex:6] label] forState:UIControlStateNormal];
    [self.image6 setImage: [[self.loadedWords objectAtIndex:6] image]];
    [self.button6 setTag:6];
    
    //setting button 7
    [self.button7 setTitle: [[self.loadedWords objectAtIndex:7] label] forState:UIControlStateNormal];
    [self.image7 setImage: [[self.loadedWords objectAtIndex:7] image]];
    [self.button7 setTag:7];

    //setting button 8
    [self.button8 setTitle: [[self.loadedWords objectAtIndex:8] label] forState:UIControlStateNormal];
    [self.image8 setImage: [[self.loadedWords objectAtIndex:8] image]];
    [self.button8 setTag:8];

    //setting button 9
    [self.button9 setTitle: [[self.loadedWords objectAtIndex:9] label] forState:UIControlStateNormal];
    [self.image9 setImage: [[self.loadedWords objectAtIndex:9] image]];
    [self.button9 setTag:9];
    
    //setting button 10
    [self.button10 setTitle: [[self.loadedWords objectAtIndex:10] label] forState:UIControlStateNormal];
    [self.image10 setImage: [[self.loadedWords objectAtIndex:10] image]];
    [self.button10 setTag:10];
    
    //setting button 11
    [self.button11 setTitle: [[self.loadedWords objectAtIndex:11] label] forState:UIControlStateNormal];
    [self.image11 setImage: [[self.loadedWords objectAtIndex:11] image]];
    [self.button11 setTag:11];

    });
    [self endLoadingProcessAndDisplayCards];
});
}


- (IBAction)buttonTouched:(UIButton *)sender {
    NSLog(@"Button Touched.");
    

        [sender setHidden:YES];
        [[self getImageViewForIdx:sender.tag] setHidden:NO];
        self.title = nil;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 188.0/255
                                                                        green:0.0
                                                                         blue:38.0/255
                                                                        alpha:0.7];
    
    
    if(self.uncoveredCardNumber < 0) {
        
        NSLog(@"We haven't had uncovered card yet.");
        self.uncoveredCardNumber = sender.tag;
        
    } else if(self.uncoveredCardNumber <12) {
        
        NSLog(@"We have already had uncovered card. We check for accordance of two cards");
        CardObject *uncoveredCardObject =[self.loadedWords objectAtIndex: self.uncoveredCardNumber];
        CardObject *currentCardObject = [self.loadedWords objectAtIndex: sender.tag];
        
        if(uncoveredCardObject.wordId ==  currentCardObject.wordId) {
            NSLog(@"Two uncovered cards has matched. Success!");
            //we can add currentWordObject?
            self.currentWordIndex = [[self.loadedWords objectAtIndex: sender.tag] wordsArrayIdx];
            [self loadCurrentWordObject];
            self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 9/255.0
                                                                                green:97/255.0
                                                                                 blue:33/255.0
                                                                                alpha:0.7];
            self.title = currentCardObject.foreign;
            self.userAnswerLabel.text = currentCardObject.foreign;
            [self playCurrentWordAudio]; 
            
        } else {
            NSLog(@"Cards doesn't match. Both will be covered");
            //we cover cards again.
            [[self getImageViewForIdx:sender.tag] setHidden:YES];
            [sender setHidden:NO];
            
            [[self getImageViewForIdx:self.uncoveredCardNumber] setHidden:YES];
            [[self getButtonForIdx:self.uncoveredCardNumber] setHidden:NO];
           
        }
        //reseting, there isn't any new card uncovered now....
        self.uncoveredCardNumber = -1;
        
    } else {
        NSLog(@"Card number is out of bounds 0-11"); 
    }
    
}


- (UIButton *) getButtonForIdx: (NSUInteger) idx
{
    switch(idx) {
     
        case 0:{
            return self.button0;
        }
        case 1: {
            return self.button1;
        }
        case 2: {
            return self.button2;
        }
        case 3: {
            return self.button3;
        }
        case 4: {
            return self.button4;
        }
        case 5: {
            return self.button5;
        }
        case 6: {
            return self.button6;
        }
        case 7: {
            return self.button7;
        }
        case 8: {
            return self.button8;
        }
        case 9: {
            return self.button9;
        }
        case 10: {
            return self.button10;
        }
        case 11: {
            return self.button11;
        }
        default: {
            return self.button0;
        }
    
    }
}

- (UIImageView *) getImageViewForIdx: (NSUInteger) idx
{
    switch(idx) {
            
        case 0:{
            return self.image0;
        }
        case 1: {
            return self.image1;
        }
        case 2: {
            return self.image2;
        }
        case 3: {
            return self.image3;
        }
        case 4: {
            return self.image4;
        }
        case 5: {
            return self.image5;
        }
        case 6: {
            return self.image6;
        }
        case 7: {
            return self.image7;
        }
        case 8: {
            return self.image8;
        }
        case 9: {
            return self.image9;
        }
        case 10: {
            return self.image10;
        }
        case 11: {
            return self.image11;
        }
        default: {
            return self.image0;
        }
            
    }
}

- (void) cleanCurrentView
{
    NSLog(@"Cleaning current view."); 
    dispatch_async(dispatch_get_main_queue(), ^{
    [self.image0 setHidden: YES];
    [self.image1 setHidden: YES];
    [self.image2 setHidden: YES];
    [self.image3 setHidden: YES];
    [self.image4 setHidden: YES];
    [self.image5 setHidden: YES];
    [self.image6 setHidden: YES];
    [self.image7 setHidden: YES];
    [self.image8 setHidden: YES];
    [self.image9 setHidden: YES];
    [self.image10 setHidden: YES];
    [self.image11 setHidden: YES];
    [self.button0 setHidden: YES];
    [self.button1 setHidden: YES];
    [self.button2 setHidden: YES];
    [self.button3 setHidden: YES];
    [self.button4 setHidden: YES];
    [self.button5 setHidden: YES];
    [self.button6 setHidden: YES];
    [self.button7 setHidden: YES];
    [self.button8 setHidden: YES];
    [self.button9 setHidden: YES];
    [self.button10 setHidden: YES];
    [self.button11 setHidden: YES];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 188.0/255
                                                                            green:0.0
                                                                             blue:38.0/255
                                                                            alpha:0.7];

    }); 
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.learningMode = kLEARNING_MODE_CARTONS;
}

- (void) viewWillDisappear:(BOOL)animated
{
    self.title = nil;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 188.0/255
                                                                        green:0.0
                                                                         blue:38.0/255
                                                                        alpha:0.7];
}

- (void)viewDidUnload {
    [self setActivityIndicator:nil];
    [self setLoadingLabel:nil];
    [self setImage0:nil];
    [self setImage1:nil];
    [self setImage2:nil];
    [self setImage3:nil];
    [self setImage4:nil];
    [self setImage5:nil];
    [self setImage6:nil];
    [self setImage7:nil];
    [self setImage8:nil];
    [self setImage9:nil];
    [self setImage10:nil];
    [self setImage11:nil];
    [self setButton0:nil];
    [self setButton1:nil];
    [self setButton2:nil];
    [self setButton3:nil];
    [self setButton4:nil];
    [self setButton5:nil];
    [self setButton6:nil];
    [self setButton7:nil];
    [self setButton8:nil];
    [self setButton9:nil];
    [self setButton10:nil];
    [self setButton11:nil];
    [self setReloadButton:nil];
    [super viewDidUnload];
}
@end
