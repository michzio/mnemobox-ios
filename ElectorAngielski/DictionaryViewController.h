//
//  DictionaryViewController.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 07/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol DictionaryButtonTouched;

@interface DictionaryViewController : UIViewController <UITextFieldDelegate, AVAudioPlayerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIManagedDocument *database;

@property (nonatomic, assign) id <DictionaryButtonTouched> delegate;

@end

@protocol DictionaryButtonTouched <NSObject>

- (void) segueToDictionaryWordsView;

@end
