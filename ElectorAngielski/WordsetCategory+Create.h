//
//  WordsetCategory+Create.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 22/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "WordsetCategory.h"

@interface WordsetCategory (Create)

+ (WordsetCategory *) wordsetCategoryWithCID: (NSString *) cid foreignName: (NSString *) foreignName nativeName: (NSString *) nativeName inManagedObjectContext: (NSManagedObjectContext *) context;

@end
