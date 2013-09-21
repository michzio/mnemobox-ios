//
//  MoneyHistoryObject.m
//  ElectorAngielski
//
//  Created by Michal Ziobro on 18/09/2013.
//  Copyright (c) 2013 Michal Ziobro. All rights reserved.
//

#import "MoneyHistoryObject.h"

@implementation MoneyHistoryObject

@synthesize moneyHistoryId = _moneyHistoryId;
@synthesize transactionTypeId = _transactionTypeId;
@synthesize transactionType = _transactionType;
@synthesize transactionDate = _transactionDate;
@synthesize moneyTransfer = _moneyTransfer;
@synthesize operationDescription = _operationDescription;
@synthesize wordsetTitleForeign = _wordsetTitleForeign;
@synthesize wordsetTitleNative = _wordsetTitleNative;


+ (MoneyHistoryObject *) moneyHistoryObjectWithId: (NSString *) moneyHistoryId
                                transactionTypeId: (NSString *) transactionTypeId
                                  transactionType: (NSString *) transactionType
                                  transactionDate: (NSString *) transactionDate
                                    moneyTransfer: (NSString *) moneyTransfer
                             operationDescription: (NSString *) operationDescription
                              wordsetTitleForeign: (NSString *) foreignTitle
                                        andNative: (NSString *) nativeTitle
{
    MoneyHistoryObject *result = nil;
    
    result = [[MoneyHistoryObject alloc] init];
    if(result != nil) {
        
        result.moneyHistoryId = moneyHistoryId;
        result.transactionTypeId = transactionTypeId;
        result.transactionType = transactionType;
        result.transactionDate = transactionDate;
        result.moneyTransfer = moneyTransfer;
        result.operationDescription = operationDescription;
        result.wordsetTitleForeign = foreignTitle;
        result.wordsetTitleNative = nativeTitle; 
    }
    
    return result;
}
@end
