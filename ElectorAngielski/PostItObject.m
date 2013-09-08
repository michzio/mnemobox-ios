//
//  PostItObject.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 28/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "PostItObject.h"

@implementation PostItObject

@synthesize postItID = _postItID;
@synthesize postItText = _postItText;
@synthesize isCreatedByYou = _isCreatedByYou;
@synthesize authorID = _authorID;
@synthesize authorFirstName = _authorFirstName;
@synthesize authorLastName = _authorLastName;

- (id) initWithPID: (NSString *) postItID
              text: (NSString *) postItText
      createdByYou: (BOOL) isCreatedByYou
          authorID: (NSString *) authorID
         firstName: (NSString *) authorFirstName
          lastName: (NSString *) authorLastName
{
    
    self = [super init];
    if(self) {
        
        self.postItID = postItID;
        self.postItText = postItText;
        self.isCreatedByYou = isCreatedByYou;
        self.authorID = authorID;
        self.authorFirstName = authorFirstName;
        self.authorLastName = authorLastName;
    }

    return self;
}

@end
