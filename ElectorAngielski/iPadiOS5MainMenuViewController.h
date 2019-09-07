//
//  iPadiOS5MainMenuViewController.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 16/10/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuViewController.h"

@interface iPadiOS5MainMenuViewController : UIViewController <MenuButtonTouchedDelegate>
@property (weak, nonatomic) IBOutlet UIView *detailContainer;
@property (weak, nonatomic) IBOutlet UIView *menuContainer;

@end
