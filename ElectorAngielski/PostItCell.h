//
//  PostItCell.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 28/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostItCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *postItLabel;
@property (weak, nonatomic) IBOutlet UILabel *postItAuthorLabel;

@end
