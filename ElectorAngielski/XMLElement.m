//
//  XMLElement.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 21/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "XMLElement.h"

@implementation XMLElement

- (NSMutableArray *) subElements {
    if(_subElements == nil) {
        _subElements = [[NSMutableArray alloc] init];
    }
    return _subElements; 
}

@end
