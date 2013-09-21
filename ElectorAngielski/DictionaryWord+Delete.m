//
//  DictionaryWord+Delete.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 09/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "DictionaryWord+Delete.h"

@implementation DictionaryWord (Delete)

+ (BOOL) deleteWord: (DictionaryWord *) word
{
    NSManagedObjectContext *managedObjectContext = word.managedObjectContext;
    
    [managedObjectContext deleteObject:word];
    
    NSError *savingError = nil;
    if([managedObjectContext save: &savingError]) {
        return YES;
    } else {
        return NO;
    }
}

@end
