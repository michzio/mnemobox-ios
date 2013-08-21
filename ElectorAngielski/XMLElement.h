//
//  XMLElement.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 21/08/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLElement : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDictionary *attributes;
@property (nonatomic, strong) NSMutableArray *subElements;
@property (nonatomic, weak) XMLElement *parent; 
           
@end
