//
//  DictionaryWord+Create.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 08/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "DictionaryWord.h"

@interface DictionaryWord (Create)

+ (DictionaryWord *) dictionaryWordWithWID: (NSString *)wid
           foreignName: (NSString *) foreignWord
            nativeName: (NSString *) nativeWord
                 image: (NSString *) imagePath
             audioPath: (NSString *) audioPath
         transcription: (NSString *) transcription
  managedObjectContext: (NSManagedObjectContext *) managedObjectContext;

@end
