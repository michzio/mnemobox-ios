//
//  MoneyHistoryObject.h
//  ElectorAngielski
//
//  Created by Michal Ziobro on 18/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoneyHistoryObject : NSObject

@property (strong, nonatomic) NSString *moneyHistoryId;
@property (strong, nonatomic) NSString *transactionTypeId;
@property (strong, nonatomic) NSString *transactionType;
@property (strong, nonatomic) NSString *transactionDate;
@property (strong, nonatomic) NSString *moneyTransfer;
@property (strong, nonatomic) NSString *operationDescription;
@property (strong, nonatomic) NSString *wordsetTitleForeign;
@property (strong, nonatomic) NSString *wordsetTitleNative;

+ (MoneyHistoryObject *) moneyHistoryObjectWithId: (NSString *) moneyHistoryId
                                transactionTypeId: (NSString *) transactionTypeId
                                  transactionType: (NSString *) transactionType
                                  transactionDate: (NSString *) transactionDate
                                    moneyTransfer: (NSString *) moneyTransfer
                             operationDescription: (NSString *) operationDescription
                              wordsetTitleForeign: (NSString *) foreignTitle
                                        andNative: (NSString *) nativeTitle;
@end
