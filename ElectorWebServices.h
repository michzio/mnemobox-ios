//
//  ElectorWebServices.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 01/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WordObject.h"

@interface ElectorWebServices : NSObject

+ (void) saveWordToRememberMe: (NSString *) wordId;
+ (void) shareWordOnUserProfileWall: (WordObject *) word; 
@end
