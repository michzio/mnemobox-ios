//
//  DictionaryWord+Create.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 08/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "DictionaryWord+Create.h"
#import "Word+Create.h"

@implementation DictionaryWord (Create)

+ (DictionaryWord *) dictionaryWordWithWID: (NSString *)wid
                               foreignName: (NSString *) foreignWord
                                nativeName: (NSString *) nativeWord
                                     image: (NSString *) imagePath
                                 audioPath: (NSString *) audioPath
                             transcription: (NSString *) transcription
                      managedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    
    DictionaryWord *dictionaryWord = nil;
    /* checking whether this word is already saved in Core Data on the Dictionary List 
       if so we need only to update it, else we need to create new input in database */
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DictionaryWord"];
    request.predicate = [NSPredicate predicateWithFormat: @"wordId = %@", wid, nil];
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"foreign"
                                                               ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDesc];
    
    NSError *fetchError = nil;
    NSArray *dictionaryWords = [managedObjectContext executeFetchRequest: request
                                                                   error:&fetchError];
    
    if(!dictionaryWords || [dictionaryWords count] > 1) {
        NSLog(@"Error while checking for existance of word for given Word Id in Core Data.");
    } else if([dictionaryWords count] == 0) {
        NSLog(@"Creating new Dictionary Word object in database.");
        dictionaryWord = [NSEntityDescription insertNewObjectForEntityForName:@"DictionaryWord"
                                                       inManagedObjectContext:managedObjectContext];
        dictionaryWord.wordId = wid;
        dictionaryWord.foreign = foreignWord;
        dictionaryWord.native = nativeWord;
        dictionaryWord.image = [Word imageDataWithImagePath:imagePath];
        dictionaryWord.recording = audioPath;
        dictionaryWord.transcription = transcription;
        
    } else {
        dictionaryWord = [dictionaryWords lastObject];
        NSLog(@"Updating existing Dictionary Word object = %@ in database", dictionaryWord.foreign);
        dictionaryWord.foreign = foreignWord;
        dictionaryWord.native = nativeWord;
        dictionaryWord.image = [Word imageDataWithImagePath:imagePath];
        dictionaryWord.recording = audioPath;
        dictionaryWord.transcription = transcription;
    }
    
    return dictionaryWord;
}

@end
