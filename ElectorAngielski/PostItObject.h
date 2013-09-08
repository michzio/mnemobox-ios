//
//  PostItObject.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 28/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostItObject : NSObject

@property (nonatomic, strong) NSString *postItID;
@property (nonatomic, strong) NSString *postItText;
@property (nonatomic) BOOL isCreatedByYou;
@property (nonatomic, strong) NSString *authorFirstName;
@property (nonatomic, strong) NSString *authorLastName;
@property (nonatomic, strong) NSString *authorID; 


- (id) initWithPID: (NSString *) postItID
              text: (NSString *) postItText
      createdByYou: (BOOL) isCreatedByYou
          authorID: (NSString *) authorID
         firstName: (NSString *) authorFirstName
          lastName: (NSString *) authorLastName;
@end
