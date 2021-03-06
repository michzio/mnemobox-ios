//
//  WordsetViewController.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 23/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Wordset.h"

@protocol WordsSynchronizationProgressDelegate;

@interface WordsetViewController : UIViewController

@property (nonatomic, strong) Wordset *wordset;
@property (nonatomic, assign) id <WordsSynchronizationProgressDelegate> progressDelegate;

@end

@protocol WordsSynchronizationProgressDelegate <NSObject>

@optional

- (void) setProgress: (CGFloat) progressInFloatPercent;

@end
