//
//  PostItEditCell.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 28/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PostItEditButtonDelegate;

@interface PostItEditCell :UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UILabel *postItAuthorLabel;
@property (weak, nonatomic) IBOutlet UILabel *postItLabel;

@property (nonatomic, weak) id <PostItEditButtonDelegate> delegate;

@end

@protocol PostItEditButtonDelegate <NSObject>

- (void) performPostItEdition; 

@end
