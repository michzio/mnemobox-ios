//
//  AddWordToUserWordsetViewController.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 22/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Wordset.h"

@interface AddWordToUserWordsetViewController : UIViewController <UITextFieldDelegate, AVAudioPlayerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIManagedDocument *database;
@property (strong, nonatomic) Wordset *userWordset;

@end
