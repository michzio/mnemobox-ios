//
//  SuggestionObject.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 07/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SuggestionObject : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *tidsList;

+ (SuggestionObject *) suggestionWithText: (NSString *) textStr andTidsList: (NSString *) tidsListStr;
@end
