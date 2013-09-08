//
//  Word+Create.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 23/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "Word.h"
#import "Wordset.h"


@interface Word (Create)

+ (Word *) wordWithWID: (NSString *)wid
           foreignName: (NSString *) foreignWord
            nativeName: (NSString *) nativeWord
             imagePath: (NSString *) imagePath
             audioPath: (NSString *) audioPath
         transcription: (NSString *) transcription
        foreignArticle: (NSString *) foreignArticle
        nativeArticle: (NSString *) nativeArticle
             inWordset: (Wordset *) wordset
   managedObjectContext: (NSManagedObjectContext *) managedObjectContext;

+ (NSData *) imageDataWithImagePath: (NSString *) imagePath;
@end
