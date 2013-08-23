//
//  Wordset+Create.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 22/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "Wordset.h"

@interface Wordset (Create)

+ (Wordset *) wordsetWithWID: (NSString *) wid foreignName: (NSString *) foreignName nativeName: (NSString *) nativeName level: (NSString *) level description: (NSString *) description forCategory: (WordsetCategory *) category inManagedObjectContext: (NSManagedObjectContext *) context;

@end
