//
//  GenericLearningViewController.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 29/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Wordset.h"
#import "WordObject.h"
#import <AVFoundation/AVFoundation.h>
#import "TracingHistoryAndStatistics.h"
#import "PullableView.h"

@interface GenericLearningViewController : UIViewController <AVAudioPlayerDelegate, PullableViewDelegate>

/* PullUpView menu implementation using external source code */
 @property (nonatomic, strong) PullableView *pullUpView;
 @property (nonatomic, strong) UILabel *pullUpLabel;
@property (nonatomic, strong) UIButton *infoButton;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *remembermeButton;
@property (nonatomic, strong) UIButton *postitButton;
/*-----------------------------------------------------------*/

@property (nonatomic, strong) Wordset *wordset;
@property (nonatomic, strong) WordObject *currentWord;
@property (nonatomic) NSInteger currentWordIndex;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic) BOOL wordsStoredInCoreData;
@property (nonatomic,strong) NSMutableArray *words;
@property (nonatomic, strong) NSString *learningMode; 

@property (nonatomic, strong) NSMutableArray *forgottenTwoAns; //wordIds of forgotten words with weight 2 
@property (nonatomic, strong) NSMutableArray *forgottenOneAns; //wordIds of forgotten words with weight 1
@property (nonatomic, strong) NSMutableArray *goodAns; //wordIds of words user remember

- (void) setPullUpViewPosition: (CGFloat) xOffset;

//method should be overriden in subclasses
- (void) setUpActivityIndicator;
- (void) playCurrentWordAudio;
- (void) playAudioFromURL: (NSURL *) url;
- (void) displayFirstWord;
- (void) displayEndView;
- (void) summarizeLearning;
- (void) loadCurrentWordObject; 
- (void) loadImageOfWord: (WordObject *) word toImageView: (UIImageView *) imageView;
- (void) addCurrentWordToForgottenOne;
- (void) addCurrentWordToForgottenTwo;
- (void) setInBackgroundImageNamed: (NSString *) imageName;
- (void) adjustToScreenOrientation;
@end
