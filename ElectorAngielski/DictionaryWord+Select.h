//
//  DictionaryWord+Select.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 08/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "DictionaryWord.h"

@interface DictionaryWord (Select)
+ (NSArray *) selectAllDictionaryWords: (NSManagedObjectContext *) managedObjectContext; 
@end
