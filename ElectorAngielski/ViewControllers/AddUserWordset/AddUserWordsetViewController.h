//
//  AddUserWordsetViewController.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 22/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddUserWordsetDelegate;

@interface AddUserWordsetViewController : UIViewController <UITextFieldDelegate,UITextViewDelegate, AddUserWordsetDelegate>

@property (weak, nonatomic) id <AddUserWordsetDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextField *foreignTitleTextField;
@property (weak, nonatomic) IBOutlet UITextField *nativeTitleTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@end

@protocol AddUserWordsetDelegate <NSObject>

- (void) cancelButtonTouchedOnView: (AddUserWordsetViewController *) sender;
- (void) addedUserWordsetOnView: (AddUserWordsetViewController *) sender;
- (void) foreignTextFieldValueChangedOnView: (AddUserWordsetViewController *) sender;
- (void) nativeTextFieldValueChangedOnView: (AddUserWordsetViewController *) sender;
- (void) descriptionTextViewValueChangedOnView: (AddUserWordsetViewController *) sender;

@end