//
//  MainMenuViewController.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 21/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MainMenuDelegate;

@interface MainMenuViewController : UIViewController <MainMenuDelegate>

@property (weak, nonatomic) id <MainMenuDelegate> delegate;
@end

@protocol MainMenuDelegate <NSObject>

- (void) segueWithIdentifier: (NSString *) identifier;

@end