//
//  Wordset+Create.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 22/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "Wordset+Create.h"

@implementation Wordset (Create)

+ (Wordset *) wordsetWithWID: (NSString *) wid foreignName: (NSString *) foreignName nativeName: (NSString *) nativeName level: (NSString *) level description: (NSString *) description forCategory: (WordsetCategory *) wordsetCategory inManagedObjectContext: (NSManagedObjectContext *) context {
    
    Wordset *wordset = nil;
    
    /* checking whether this category is alreay saved in the database, if so we need only to update it else
     we need to create new input in database */
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Wordset"];
    request.predicate = [NSPredicate predicateWithFormat:@"wid = %@", wid,nil];
    
    NSSortDescriptor *sortDesc1 = [NSSortDescriptor sortDescriptorWithKey:@"level" ascending:YES];
    NSSortDescriptor *sortDesc2 = [NSSortDescriptor sortDescriptorWithKey:@"foreignName" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObjects: sortDesc1, sortDesc2, nil];
    
    NSError *fetchError = nil;
    NSArray *wordsets = [context executeFetchRequest:request error:&fetchError];
    
    
    if(!wordsets || [wordsets count] > 1) { /* we suppose categories to be unique -> cid identifier */
        NSLog(@"Error while checking for existance of wordset for given WID in database.");
    } else if ([wordsets count] == 0) {
        NSLog(@"Creating new object in database");
        wordset = [NSEntityDescription insertNewObjectForEntityForName:@"Wordset"
                                                        inManagedObjectContext: context];
        wordset.wid = wid;
        wordset.foreignName = foreignName;
        wordset.nativeName = nativeName;
        wordset.about = description;
        wordset.level = level;
        wordset.words = [[NSSet alloc] init];
        wordset.category = wordsetCategory;
        
    } else { /* categories mut have one element */
        NSLog(@"Updating existing object in database");
        wordset = [wordsets lastObject];
        wordset.wid = wid;
        wordset.foreignName = foreignName;
        wordset.nativeName = nativeName;
        wordset.about = description;
        wordset.level = level;
        wordset.words = [[NSSet alloc] init];
        wordset.category = wordsetCategory;


    }
    
    return wordset;
}


@end
