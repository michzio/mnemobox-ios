//
//  iPadMainMenuViewController.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 08/10/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuViewController.h"

@interface iPadMainMenuViewController : UIViewController <MenuButtonTouchedDelegate>
@property (weak, nonatomic) IBOutlet UIView *detailContainer;
@property (weak, nonatomic) IBOutlet UIView *menuContainer;

@end
