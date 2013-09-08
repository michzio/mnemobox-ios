//
//  SpeakingViewController.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 02/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericLearningViewController.h"
#import <OpenEars/OpenEarsEventsObserver.h>

@interface SpeakingViewController : GenericLearningViewController <OpenEarsEventsObserverDelegate>
{
    OpenEarsEventsObserver *openEarsEventsObserver;
}

@property (strong, nonatomic) OpenEarsEventsObserver *openEarsEventsObserver;

@end
