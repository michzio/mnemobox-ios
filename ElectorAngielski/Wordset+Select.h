//
//  Wordset+Select.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 23/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "Wordset.h"

@interface Wordset (Select)

+ (Wordset *) selectWordsetWithWID: (NSString *) wid
              managedObjectContext: (NSManagedObjectContext *) managedObjectContext;

@end
