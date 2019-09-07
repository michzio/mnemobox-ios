//
//  SpeakingViewController.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 02/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericLearningViewController.h"
#import <OpenEars/OEEventsObserver.h>

@interface SpeakingViewController : GenericLearningViewController <OEEventsObserverDelegate>
{
    OEEventsObserver *openEarsEventsObserver;
}

    @property (strong, nonatomic) OEEventsObserver *openEarsEventsObserver;

@end
