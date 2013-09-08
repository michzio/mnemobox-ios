//
//  WordDetailsViewController.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 26/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Word.h"
#import "WordObject.h"
#import <AVFoundation/AVFoundation.h>

@interface WordDetailsViewController : UIViewController <AVAudioPlayerDelegate>

@property (nonatomic, strong) Word *word; /* if we have Word object retrieved from Core Data */
@property (nonatomic, strong) WordObject *wordObject; /* if we have WordObject object retrieved from web services */

@end
