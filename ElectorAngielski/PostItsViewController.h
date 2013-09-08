//
//  PostItsViewController.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 27/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WordObject.h"
#import "PostItEditCell.h"

@interface PostItsViewController : UITableViewController <PostItEditButtonDelegate>

@property (strong, nonatomic) WordObject *wordObject;


@end
