//
//  MoneyHistoryCell.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 18/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoneyHistoryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *transactionDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *transcraptionTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *wordsetTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
