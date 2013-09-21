//
//  DictionaryWord.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 12/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DictionaryWord : NSManagedObject

@property (nonatomic, retain) NSString * foreign;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * native;
@property (nonatomic, retain) NSString * recording;
@property (nonatomic, retain) NSString * transcription;
@property (nonatomic, retain) NSString * wordId;

@end
