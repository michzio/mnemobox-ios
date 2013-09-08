//
//  Word+Create.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 23/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "Word+Create.h"

@implementation Word (Create)

+ (Word *) wordWithWID: (NSString *)wid
           foreignName: (NSString *) foreignWord
            nativeName: (NSString *) nativeWord
             imagePath: (NSString *) imagePath
             audioPath: (NSString *) audioPath
         transcription: (NSString *) transcription
        foreignArticle: (NSString *) foreignArticle
        nativeArticle: (NSString *) nativeArticle
             inWordset: (Wordset *) wordset
managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
 
    Word *word = nil;
    /* checking whether this word is already saved in the database, if so we need only to update it else we need to creat new input in database */
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
    request.predicate = [NSPredicate predicateWithFormat:@"wordId = %@", wid, nil];
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"foreign" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDesc];
    
    NSError *fetchError = nil;
    NSArray *words = [managedObjectContext executeFetchRequest:request error:&fetchError];
    
    if(!words || [words count] > 1) {
        NSLog(@"Error while checking for existance of word for given Word Id in Core Data");
    } else if([words count] == 0) {
        NSLog(@"Creating new object in database");
        word = [NSEntityDescription insertNewObjectForEntityForName: @"Word"
                                             inManagedObjectContext:managedObjectContext];
        word.wordId = wid;
        word.foreign = foreignWord;
        word.native = nativeWord;
        word.image = [self imageDataWithImagePath: (NSString *) imagePath];
        word.recording = audioPath;
        word.transcription = transcription;
        word.foreignArticle = foreignArticle;
        word.nativeArticle = nativeArticle;
        word.inWordsets = [NSSet setWithObject:wordset];
        
        
    } else {
       
        word = [words lastObject];
        NSLog(@"Updating existing object = %@ in database", word.foreign);
        word.foreign = foreignWord;
        word.native = nativeWord;
        word.image = [self imageDataWithImagePath: (NSString *) imagePath];
        word.recording = audioPath;
        word.transcription = transcription;
        word.foreignArticle = foreignArticle;
        word.nativeArticle = nativeArticle;
        NSMutableSet *wordsets = [word.inWordsets mutableCopy];
        [wordsets addObject: wordset];
        word.inWordsets = wordsets;
        
    }
    return word;
}

#define kIMAGE_SERVER @"http://mnemobox.com/uploads/images/"

+ (NSData *) imageDataWithImagePath: (NSString *) imagePath
{
    NSData *imageData = nil;
    
    if(imagePath) { 
        NSString *imageServer = kIMAGE_SERVER;
        NSString *imageFullPath = [imageServer stringByAppendingString: imagePath];
        NSURL *url = [NSURL URLWithString:imageFullPath];
        imageData = [[NSData alloc] initWithContentsOfURL: url];
    }
    return imageData;
}

@end
