//
//  PKCardName.h
//  PaymentKit Example
//
//  Created by Yoshitaka Sakamaki on 2013/08/05.
//  Copyright (c) 2013年 Stripe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PKCardName : NSObject

@property (nonatomic, readonly) NSString * string;

+ (id)cardNameWithString:(NSString *)string;

- (NSString *)string;

- (BOOL)isValid;
@end
