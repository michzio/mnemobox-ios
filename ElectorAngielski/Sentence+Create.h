//
//  Sentence+Create.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 26/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "Sentence.h"

@interface Sentence (Create)


+ (Sentence *) sentenceWithSID: (NSString *) sid
                   foreignText:(NSString *) foreignText
                    nativeText: (NSString *) nativeText
                     recording: (NSString *) recording
                        inWord: (Word *) word
           manageObjectContext: (NSManagedObjectContext *) managedObjectContext;


@end
