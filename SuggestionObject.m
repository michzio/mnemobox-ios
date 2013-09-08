//
//  SuggestionObject.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 07/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "SuggestionObject.h"

@implementation SuggestionObject


+ (SuggestionObject *) suggestionWithText: (NSString *) textStr andTidsList: (NSString *) tidsListStr {
    
    SuggestionObject *suggestion = [[SuggestionObject alloc] init];
    
    [suggestion setText:textStr];
    [suggestion setTidsList: tidsListStr];
    
    return suggestion; 
    
}
@end
