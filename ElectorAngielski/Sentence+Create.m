//
//  Sentence+Create.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 26/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "Sentence+Create.h"

@implementation Sentence (Create)

+ (Sentence *) sentenceWithSID: (NSString *) sid
                   foreignText:(NSString *) foreignText
                    nativeText: (NSString *) nativeText
                     recording: (NSString *) recording
                        inWord: (Word *) word
           manageObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    
    Sentence *sentence = nil;
    /* checking whether this sentence has been already saved in the Core Data, if so we need only 
      to update it else we need to create new input in database */
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Sentence"];
    request.predicate = [NSPredicate predicateWithFormat: @"sentenceId = %@", sid, nil];
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"foreign" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject: sortDesc];
    
    NSError *fetchError = nil;
    
    NSArray *sentences = [managedObjectContext executeFetchRequest: request
                                                             error:&fetchError];
    
    if(!sentences || [sentences count] > 1) {
        NSLog(@"Error while checking for existance of sentence for given Sentence Id in Core Data");
    } else if([sentences count] == 0) {
        NSLog(@"Creating new sentence object in database with sid: %@", sid);
        
        sentence = [NSEntityDescription insertNewObjectForEntityForName:@"Sentence"
                                                 inManagedObjectContext:managedObjectContext];
        sentence.sentenceId = sid;
        sentence.foreign = foreignText;
        sentence.native = nativeText;
        sentence.recording = recording;
        sentence.forWord = word;
        
    } else {
        NSLog(@"Updating existing sentence object with sid: %@ in database", sid);
        
        sentence = [sentences lastObject];
        sentence.foreign = foreignText;
        sentence.native = nativeText;
        sentence.recording = recording;
        sentence.forWord = word;
    }
    
    return sentence; 
}

@end
