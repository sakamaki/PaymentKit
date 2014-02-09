//
//  PKCardName.m
//  PaymentKit Example
//
//  Created by Yoshitaka Sakamaki on 2013/08/05.
//  Copyright (c) 2013年 Stripe. All rights reserved.
//

#import "PKCardName.h"
#import "PKTextField.h"

@implementation PKCardName {
@private
    NSString* userName;
}

- (id)initWithString:(NSString *)string
{
    self = [super init];
    if (self) {
        // Strip non-digits
        userName = [[PKTextField textByRemovingUselessSpacesFromString:string ] uppercaseString];
    }
    return self;
}

+ (id)cardNameWithString:(NSString *)string
{
    return [[self alloc] initWithString:string];
}

- (NSString *)string
{
    return userName;
}

- (BOOL)isValid {
    if (0 < [PKTextField textByRemovingUselessSpacesFromString:userName].length)
        return YES;
    else
        return NO;
}
@end
