//
//  PKPaymentField.h
//  PKPayment Example
//
//  Created by Alex MacCaw on 1/22/13.
//  Copyright (c) 2013 Stripe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKCard.h"
#import "PKCardNumber.h"
#import "PKCardExpiry.h"
#import "PKCardCVC.h"
#import "PKAddressZip.h"
#import "PKUSAddressZip.h"

@class PKView, PKTextField;

typedef enum {
    INPUT_CARD_DATA_KIND_NUMBER,
    INPUT_CARD_DATA_KIND_EXPIRY,
    INPUT_CARD_DATA_KIND_CVC,
} INPUT_CARD_DATA_KIND;

@protocol PKViewDelegate <NSObject>
@optional
- (void) paymentView:(PKView*)paymentView withCard:(PKCard*)card isValid:(BOOL)valid;
- (void)paymentView:(PKView *)paymentView withCard:(PKCard *)card changedInputKind:(INPUT_CARD_DATA_KIND)changedInputKind;
@end

@interface PKView : UIView

- (BOOL)isValid;

@property (nonatomic, readonly) UIView *opaqueOverGradientView;
@property (nonatomic, readonly) PKCardNumber* cardNumber;
@property (nonatomic, readonly) PKCardExpiry* cardExpiry;
@property (nonatomic, readonly) PKCardCVC* cardCVC;
@property (nonatomic, readonly) PKAddressZip* addressZip;

@property IBOutlet UIView* innerView;
@property IBOutlet UIView* clipView;
@property IBOutlet PKTextField* cardNumberField;
@property IBOutlet PKTextField* cardExpiryField;
@property IBOutlet PKTextField* cardCVCField;
@property IBOutlet UIImageView* placeholderView;
@property id <PKViewDelegate> delegate;
@property (readonly) PKCard* card;

@end
