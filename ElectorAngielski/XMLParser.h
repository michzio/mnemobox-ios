//
//  XMLParser.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 21/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLElement.h"

@interface XMLParser : NSObject <NSXMLParserDelegate>

@property (nonatomic, strong) NSXMLParser *xmlParser;
@property (nonatomic, strong) XMLElement *rootElement;
@property (nonatomic, strong) XMLElement *currentElementPointer;

- (id) initWithData: (NSData *) xmlData;
- (XMLElement *) parseAndGetRootElement; 

@end
