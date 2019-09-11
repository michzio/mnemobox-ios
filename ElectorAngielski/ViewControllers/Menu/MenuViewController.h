//
//  MenuViewController.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 08/10/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuButtonTouchedDelegate;

@interface MenuViewController : UIViewController

@property (weak, nonatomic) id <MenuButtonTouchedDelegate> delegate;

@end

@protocol MenuButtonTouchedDelegate <NSObject>

- (void) buttonTouchedWithIdentifier: (NSString *) buttonIdentifier;

@end
