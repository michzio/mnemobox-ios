//
//  Word+Create.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 23/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "Word.h"
#import "Wordset.h"

#define kIMAGE_SERVER @"http://mnemobox.com/uploads/images/"

@interface Word (Create)

+ (Word *) wordWithWID: (NSString *)wid
           foreignName: (NSString *) foreignWord
            nativeName: (NSString *) nativeWord
             imagePath: (NSString *) imagePath
         loadImageData: (BOOL) loadImageDataSync
             audioPath: (NSString *) audioPath
         transcription: (NSString *) transcription
        foreignArticle: (NSString *) foreignArticle
        nativeArticle: (NSString *) nativeArticle
             inWordset: (Wordset *) wordset
   managedObjectContext: (NSManagedObjectContext *) managedObjectContext;

+ (NSData *) imageDataWithImagePath: (NSString *) imagePath;
@end
