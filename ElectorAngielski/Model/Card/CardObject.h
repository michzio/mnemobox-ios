//
//  CardObject.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 06/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CardObject : NSObject

@property (strong, nonatomic) NSString *label;
@property (nonatomic) BOOL isForeign;
@property (strong, nonatomic) NSString *foreign;
@property (strong, nonatomic) NSString *native;
@property (strong, nonatomic) NSString *wordId;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *recording;
@property (nonatomic) NSUInteger wordsArrayIdx;

- (id) initWithWID: (NSString *) wid foreign: (NSString *) foreign native: (NSString *) native wordImage: (UIImage *) image recording: (NSString *) recording isForeign: (BOOL) isForeign wordsArrayIdx: (NSUInteger) idx;

@end
