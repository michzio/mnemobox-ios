//
//  PostItCell.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 28/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "PostItCell.h"

@implementation PostItCell

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
