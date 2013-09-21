//
//  WordsetCategory+Create.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 22/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "WordsetCategory+Create.h"

@implementation WordsetCategory (Create)

+ (WordsetCategory *) wordsetCategoryWithCID: (NSString *) cid foreignName: (NSString *) foreignName nativeName: (NSString *) nativeName inManagedObjectContext: (NSManagedObjectContext *) context {
    
    WordsetCategory *wordsetCategory = nil;
    
    /* checking whether this category is already saved in the database, if so we need only to update it else 
     we need to create new input in database */
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"WordsetCategory"];
    request.predicate = [NSPredicate predicateWithFormat:@"cid = %@", cid, nil];
    
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"foreignName" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject: sortDesc];
    
    NSError *fetchError = nil;
    NSArray *categories = [context executeFetchRequest:request error:&fetchError];
    
    
    if(!categories || [categories count] > 1) { /* we suppose categories to be unique -> cid identifier */
        NSLog(@"Error while checking for existance of category for given CID in database."); 
    } else if ([categories count] == 0) {
        wordsetCategory = [NSEntityDescription insertNewObjectForEntityForName:@"WordsetCategory"
                                                        inManagedObjectContext: context];
        wordsetCategory.cid = cid;
        wordsetCategory.foreignName = foreignName;
        wordsetCategory.nativeName = nativeName;
        
    } else { /* categories must have one element */ 
        wordsetCategory = [categories lastObject];
        wordsetCategory.foreignName = foreignName;
        wordsetCategory.nativeName = nativeName; 
    }

    return wordsetCategory;
}

@end
