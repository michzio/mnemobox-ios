//
//  WordObject.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 24/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "WordObject.h"

@implementation WordObject

@synthesize foreign = _foreign;
@synthesize imagePath = _imagePath;
@synthesize native = _native;
@synthesize recording = _recording;
@synthesize transcription = _transcription;
@synthesize wordId = _wordId;
@synthesize foreignArticle = _foreignArticle;
@synthesize nativeArticle = _nativeArticle;
@synthesize image = _image;
@synthesize imageHeight = _imageHeight;
@synthesize imageLoaded = _imageLoaded;

- (id) initWithWID: (NSString *)wid
       foreignName: (NSString *) foreignWord
        nativeName: (NSString *) nativeWord
         imagePath: (NSString *) imagePath
         audioPath: (NSString *) audioPath
     transcription: (NSString *) transcription
    foreignArticle: (NSString *) foreignArticle
     nativeArticle: (NSString *) nativeArticle
{
    self = [super init];
    if(self) {
        self.wordId = wid;
        self.foreign = foreignWord;
        self.native = nativeWord;
        self.imagePath = imagePath;
        self.recording = audioPath;
        self.transcription = transcription;
        self.foreignArticle = foreignArticle;
        self.nativeArticle = nativeArticle;
        self.imageLoaded = NO;
        self.image = nil;
        self.imageHeight = 0.0f;
    }
    
    return self;
}

+ (WordObject *) wordObjectWithWord: (Word *) word
{
    WordObject *wordObject = nil;
    
    wordObject = [[WordObject alloc] initWithWID:word.wordId
                                     foreignName:word.foreign
                                      nativeName:word.native
                                       imagePath:nil
                                       audioPath:word.recording
                                   transcription:word.transcription
                                  foreignArticle:word.foreignArticle
                                   nativeArticle:word.nativeArticle];
    
    [wordObject setImage:[UIImage imageWithData:word.image]];
    [wordObject setImageHeight:wordObject.image.size.height];
    [wordObject setImageLoaded:YES]; 
    
    return wordObject; 
}

@end
