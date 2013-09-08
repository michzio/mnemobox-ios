//
//  CardObject.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 06/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "CardObject.h"

@implementation CardObject

@synthesize label = _label;
@synthesize isForeign = _isForeign;
@synthesize foreign = _foreign;
@synthesize native = _native;
@synthesize image = _image;
@synthesize recording = _recording;
@synthesize wordId = _wordId;
@synthesize wordsArrayIdx = _wordsArrayIdx;

- (id) initWithWID: (NSString *) wid foreign: (NSString *) foreign native: (NSString *) native wordImage: (UIImage *) image recording: (NSString *) recording isForeign: (BOOL) isForeign wordsArrayIdx: (NSUInteger) idx
{
    self = [super init];
    if(self) {
        self.wordId = wid;
        self.foreign = foreign;
        self.native = native;
        self.isForeign = isForeign;
        if(isForeign) {
            self.label = foreign;
        } else {
            self.label = native;
        }
        self.image = image;
        self.recording = recording;
        self.wordsArrayIdx = idx;
    }
    return self; 
    
}

@end
