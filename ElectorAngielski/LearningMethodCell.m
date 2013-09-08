//
//  LearningMethodCell.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 23/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "LearningMethodCell.h"

@implementation LearningMethodCell

@synthesize  nameLabel = _nameLabel;
@synthesize thumbnail = _thumbnail;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
