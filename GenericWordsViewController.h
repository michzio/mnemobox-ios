//
//  GenericWordsViewController.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 17/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "CoreDataViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "PullableView.h"
#import "Wordset+Create.h"
#import "ProfileServices.h"
#import "WordsetCategory+Create.h"
#import "Word+Create.h"
#import "Reachability.h"

#define kLANG_FROM @"pl"
#define kLANG_TO @"en"

@interface GenericWordsViewController : CoreDataViewController
<UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate, PullableViewDelegate>

@property (strong, nonatomic) UIManagedDocument *database;
@property (strong, nonatomic) Wordset *genericWordset;
@property (strong, nonatomic) Reachability *internetReachable;

/* PullUpView menu implementation using external source code */
@property (nonatomic, strong) PullableView *pullUpView;
@property (nonatomic, strong) UILabel *pullUpLabel;
@property (nonatomic, strong) UIButton *presentationButton;
@property (nonatomic, strong) UIButton *repetitionButton;
@property (nonatomic, strong) UIButton *speakingButton;
@property (nonatomic, strong) UIButton *listeningButton;
@property (nonatomic, strong) UIButton *choosingButton;
@property (nonatomic, strong) UIButton *cartonsButton;
/*-----------------------------------------------------------*/

@end
