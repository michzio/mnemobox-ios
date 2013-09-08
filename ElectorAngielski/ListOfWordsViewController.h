//
//  ListOfWordsViewController.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 24/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Wordset.h"
#import <AVFoundation/AVFoundation.h>


@interface ListOfWordsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate,AVAudioPlayerDelegate>

@property (nonatomic, strong) Wordset *wordset;

@end
