//
//  SettingsViewController.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 20/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ModalDismissedDelegate;

@interface SettingsViewController : UIViewController <ModalDismissedDelegate>
@property (weak, nonatomic) id <ModalDismissedDelegate> delegate;
@end

@protocol ModalDismissedDelegate <NSObject>
- (void)modalViewControllerDismissed:(SettingsViewController *)modalViewController;
@end
