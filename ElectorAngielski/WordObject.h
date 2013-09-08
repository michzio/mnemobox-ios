//
//  WordObject.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 24/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Word.h"


@interface WordObject : NSObject

@property (nonatomic, strong) NSString * foreign;
@property (nonatomic, strong) NSString * imagePath;
@property (nonatomic, strong) NSString * native;
@property (nonatomic, strong) NSString * recording;
@property (nonatomic, strong) NSString * transcription;
@property (nonatomic, strong) NSString * wordId;
@property (nonatomic, strong) NSString * foreignArticle;
@property (nonatomic, strong) NSString * nativeArticle;
@property (nonatomic, strong) UIImage * image;
@property (nonatomic) CGFloat imageHeight;
@property (nonatomic) BOOL imageLoaded;

- (id) initWithWID: (NSString *)wid
           foreignName: (NSString *) foreignWord
            nativeName: (NSString *) nativeWord
             imagePath: (NSString *) imagePath
             audioPath: (NSString *) audioPath
         transcription: (NSString *) transcription
        foreignArticle: (NSString *) foreignArticle
         nativeArticle: (NSString *) nativeArticle;

+ (WordObject *) wordObjectWithWord: (Word *) word;

@end
