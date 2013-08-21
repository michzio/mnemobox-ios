//
//  XMLParser.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 21/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "XMLParser.h"

@implementation XMLParser

- (id) initWithData: (NSData *) xmlData {
    
    self =  [super init];
    if(self) { 
        NSLog(@"Allocating XML Parser with data retrieved from web services");
        self.xmlParser = [[NSXMLParser alloc] initWithData: xmlData];
        self.xmlParser.delegate = self;
    }
    return self;
}

- (XMLElement *) parseAndGetRootElement {
    if([self.xmlParser parse]) {
        NSLog(@"The XML is parsed");
        return self.rootElement;
    } else {
        NSLog(@"Failed to parse the XML");
    }
     return nil;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    self.rootElement = nil;
    self.currentElementPointer = nil;
}

- (void) parser: (NSXMLParser *) parser
didStartElement: (NSString *) elementName
   namespaceURI: (NSString *) namespaceURI
  qualifiedName: (NSString *) qName
     attributes: (NSDictionary *) attributeDict {
    
    if(self.rootElement == nil) {
        /* we don't have root element. Create it and point to it */
        self.rootElement = [[XMLElement alloc] init];
        self.currentElementPointer = self.rootElement;
    } else {
        /* already have root. create new element and add it as one of the subelements of the current element */
        XMLElement *newElement = [[XMLElement alloc] init];
        newElement.parent = self.currentElementPointer;
        [self.currentElementPointer.subElements addObject: newElement];
        self.currentElementPointer = newElement;
    }
    self.currentElementPointer.name = elementName;
    self.currentElementPointer.attributes = attributeDict;
}

-(void) parser: (NSXMLParser *) parser
foundCharacters:(NSString *)string
{
    if([self.currentElementPointer.text length] > 0) {
        self.currentElementPointer.text = [self.currentElementPointer.text stringByAppendingString:string];
    } else {
        self.currentElementPointer.text = string;
    }
}

- (void) parser: (NSXMLParser *) parser
  didEndElement: (NSString *) elementName
   namespaceURI: (NSString *) namespaceURI
  qualifiedName:(NSString *)qName {
    self.currentElementPointer = self.currentElementPointer.parent;
}

- (void) parserDidEndDocument: (NSXMLParser *) parser {
    self.currentElementPointer = nil;
}

@end
