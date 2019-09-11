//
//  NSString+Utilities.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 31/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "NSString+Utilities.h"

@implementation NSString (Utilities)

+ (NSString *) stringWithCharacter: (NSString *) character ofLength: (NSUInteger) length {
    
    NSString *result = @"";
    
    for(NSUInteger i = 0; i < length; i++) {
        result = [result stringByAppendingFormat:@"%@", character, nil];
    }
    
    return result; 
}
@end
