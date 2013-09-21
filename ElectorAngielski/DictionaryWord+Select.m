//
//  DictionaryWord+Select.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 08/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "DictionaryWord+Select.h"

@implementation DictionaryWord (Select)

+ (NSArray *) selectAllDictionaryWords: (NSManagedObjectContext *) managedObjectContext
{
    NSArray *dictionaryWords = nil;
    
    NSFetchRequest *request = [NSFetchRequest
                               fetchRequestWithEntityName:@"DictionaryWord"];
    //we don't specify predicate so we get all DictionaryWord objects
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"foreign" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObjects:sortDesc, nil];
    
    NSError *fetchError = nil;
    dictionaryWords = [managedObjectContext executeFetchRequest:request error:&fetchError];
    
    return dictionaryWords;
}
@end
