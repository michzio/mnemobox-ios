//
//  DictionaryWordsViewController.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 08/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CoreDataViewController.h"

@interface DictionaryWordsViewController : CoreDataViewController <UITableViewDataSource, UITableViewDelegate,AVAudioPlayerDelegate>

@end
