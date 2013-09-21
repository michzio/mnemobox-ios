//
//  HistoryCell.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 18/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *wordsetTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timesLabel;
@property (weak, nonatomic) IBOutlet UILabel *effectivenessLabel;
@property (weak, nonatomic) IBOutlet UILabel *learningMethodLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastAccessLabel;

@end
