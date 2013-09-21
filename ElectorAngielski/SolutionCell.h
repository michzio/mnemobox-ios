//
//  SolutionCell.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 11/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SolutionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *solutionTeaserLabel;
@property (weak, nonatomic) IBOutlet UILabel *creationDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;


@end
