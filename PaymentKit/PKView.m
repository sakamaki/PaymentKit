//
//  PKPaymentField.m
//  PKPayment Example
//
//  Created by Alex MacCaw on 1/22/13.
//  Copyright (c) 2013 Stripe. All rights reserved.
//

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]
#define DarkGreyColor RGB(0,0,0)
#define RedColor RGB(253,0,17)
#define DefaultBoldFont [UIFont boldSystemFontOfSize:17]

#define kPKViewPlaceholderViewAnimationDuration 0.25

//#define kPKViewCardExpiryFieldStartX 84 + 200
//#define kPKViewCardCVCFieldStartX 177 + 200

//#define kPKViewCardExpiryFieldEndX 84
//#define kPKViewCardCVCFieldEndX 177
#define kPKViewCardNumberFieldStartX 220
#define kPKViewCardExpiryFieldStartX 84 + 200
#define kPKViewCardCVCFieldStartX 177 + 200

#define kPKViewCardNumberFieldEndX 12
#define kPKViewCardExpiryFieldEndX 84
#define kPKViewCardCVCFieldEndX 177

#import <QuartzCore/QuartzCore.h>
#import <BlocksKit/NSObject+BlockObservation.h>
#import "PKView.h"
#import "PKTextField.h"
#import "PKCardName.h"
#import "UIView+MyExtension.h"

@interface PKView () <UITextFieldDelegate> {
@private
    BOOL isInitialState;
    BOOL isNumberState;
    BOOL isValidState;
}

- (void)setup;
- (void)setupPlaceholderView;
- (void)setupCardNumberField;
- (void)setupCardExpiryField;
- (void)setupCardCVCField;
- (void)setupCardNameField;

- (void)stateCardName;
- (void)stateMeta;
- (void)stateCardCVC;

- (void)setPlaceholderViewImage:(UIImage *)image;
- (void)setPlaceholderToCVC;
- (void)setPlaceholderToCardType;

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString;
- (BOOL)cardNumberFieldShouldChangeCharactersInRange: (NSRange)range replacementString:(NSString *)replacementString;
- (BOOL)cardExpiryShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString;
- (BOOL)cardCVCShouldChangeCharactersInRange: (NSRange)range replacementString:(NSString *)replacementString;

- (void)checkValid;
- (void)textFieldIsValid:(UITextField *)textField;
- (void)textFieldIsInvalid:(UITextField *)textField withErrors:(BOOL)errors;
@end

@implementation PKView

@synthesize innerView, opaqueOverGradientView, cardNumberField,
            cardExpiryField, cardCVCField,
            placeholderView, delegate, cardNameField;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    isInitialState = YES;
    isNumberState = NO;
    isValidState   = NO;
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 290, 46);
    self.backgroundColor = [UIColor clearColor];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    backgroundImageView.image = [[UIImage imageNamed:@"textfield"]
                                 resizableImageWithCapInsets:UIEdgeInsetsMake(0, 8, 0, 8)];
    [self addSubview:backgroundImageView];
    
    self.innerView = [[UIView alloc] initWithFrame:CGRectMake(40, 12, self.frame.size.width - 40, 20)];
    self.innerView.clipsToBounds = YES;
    
    [self setupPlaceholderView];
    [self setupCardNameField];
    [self setupCardNumberField];
    [self setupCardExpiryField];
    [self setupCardCVCField];
    
//    [self.innerView addSubview:cardNumberField];
    [self.innerView addSubview:cardNameField];

    UIImageView *gradientImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 34)];
    gradientImageView.image = [UIImage imageNamed:@"gradient"];
    [self.innerView addSubview:gradientImageView];
    
    opaqueOverGradientView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 9, 34)];
    opaqueOverGradientView.backgroundColor = [UIColor colorWithRed:0.9686 green:0.9686
                                                              blue:0.9686 alpha:1.0000];
    opaqueOverGradientView.alpha = 0.0;
    [self.innerView addSubview:opaqueOverGradientView];
    
    [self addSubview:self.innerView];
    [self addSubview:placeholderView];

    [self stateCardName];
}


- (void)setupPlaceholderView
{
    placeholderView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 13, 32, 20)];
    placeholderView.backgroundColor = [UIColor clearColor];
    placeholderView.image = [UIImage imageNamed:@"placeholder"];
    
    CALayer *clip = [CALayer layer];
    clip.frame = CGRectMake(32, 0, 4, 20);
    clip.backgroundColor = [UIColor clearColor].CGColor;
    [placeholderView.layer addSublayer:clip];
}

- (void)setupCardNameField
{
    cardNameField = [[PKTextField alloc] initWithFrame:CGRectMake(12,3,220,20)];

    cardNameField.delegate = self;

    cardNameField.placeholder = @"LENSY TARO";
    cardNameField.keyboardType = UIKeyboardTypeASCIICapable;
    cardNameField.returnKeyType = UIReturnKeyNext;
    cardNameField.autocorrectionType = UITextAutocorrectionTypeNo;
    cardNameField.textColor = DarkGreyColor;
    cardNameField.font = [UIFont fontWithName:@"Marion-Bold" size:18.0f];

    [cardNameField.layer setMasksToBounds:YES];
}

- (void)setupCardNumberField
{
    cardNumberField = [[PKTextField alloc] initWithFrame:CGRectMake(kPKViewCardNumberFieldStartX,0,170,20)];
    
    cardNumberField.delegate = self;
    
    cardNumberField.placeholder = @"1234 5678 9012 3456";
    cardNumberField.keyboardType = UIKeyboardTypeNumberPad;
    cardNumberField.textColor = DarkGreyColor;
    cardNumberField.font = DefaultBoldFont;
    
    [cardNumberField.layer setMasksToBounds:YES];
}

- (void)setupCardExpiryField
{
    cardExpiryField = [[PKTextField alloc] initWithFrame:CGRectMake(kPKViewCardExpiryFieldStartX,0,60,20)];

    cardExpiryField.delegate = self;
    
    cardExpiryField.placeholder = @"MM/YY";
    cardExpiryField.keyboardType = UIKeyboardTypeNumberPad;
    cardExpiryField.textColor = DarkGreyColor;
    cardExpiryField.font = DefaultBoldFont;
    
    [cardExpiryField.layer setMasksToBounds:YES];
}

- (void)setupCardCVCField
{
    cardCVCField = [[PKTextField alloc] initWithFrame:CGRectMake(kPKViewCardCVCFieldStartX,0,
                                                                 55,20)];
    
    cardCVCField.delegate = self;
    
    cardCVCField.placeholder = @"CVC";
    cardCVCField.keyboardType = UIKeyboardTypeNumberPad;
    cardCVCField.textColor = DarkGreyColor;
    cardCVCField.font = DefaultBoldFont;
    
    [cardCVCField.layer setMasksToBounds:YES];
}

// Accessors

- (PKCardName *)cardName
{
    return [PKCardName cardNameWithString:cardNameField.text];
}

- (PKCardNumber*)cardNumber
{
    return [PKCardNumber cardNumberWithString:cardNumberField.text];
}

- (PKCardExpiry*)cardExpiry
{
    return [PKCardExpiry cardExpiryWithString:cardExpiryField.text];
}

- (PKCardCVC*)cardCVC
{
    return [PKCardCVC cardCVCWithString:cardCVCField.text];
}

// State

- (void)stateCardName
{
    if (!isInitialState) {
        // Animate left
        isInitialState = YES;
        
        [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             opaqueOverGradientView.alpha = 0.0;
                         } completion:^(BOOL finished) {}];
        [UIView animateWithDuration:0.400
                              delay:0
                            options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                         animations:^{
                             cardExpiryField.frame = CGRectMake(kPKViewCardExpiryFieldStartX + 220,
                                                                cardExpiryField.frame.origin.y,
                                                                cardExpiryField.frame.size.width,
                                                                cardExpiryField.frame.size.height);
                             cardCVCField.frame = CGRectMake(kPKViewCardCVCFieldStartX + 220,
                                                             cardCVCField.frame.origin.y,
                                                             cardCVCField.frame.size.width,
                                                             cardCVCField.frame.size.height);
                             cardNumberField.frame = CGRectMake(kPKViewCardNumberFieldStartX,
                                                                cardNumberField.frame.origin.y,
                                                                cardNumberField.frame.size.width,
                                                                cardNumberField.frame.size.height);
                             cardNameField.frame = CGRectMake(12,
                                     cardNameField.frame.origin.y,
                                     cardNameField.frame.size.width,
                                     cardNameField.frame.size.height);
                         }
                         completion:^(BOOL completed) {
                             [cardNumberField removeFromSuperview];
                             [cardExpiryField removeFromSuperview];
                             [cardCVCField removeFromSuperview];
                         }];
    }
    
    [self notifyCreditCardLabel:INPUT_CARD_DATA_KIND_NAME];
    [cardNameField becomeFirstResponder];
}

- (void)stateCardNumber
{
    if (!isNumberState) {
        // Animate left
        isNumberState = YES;

        [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                animations:^{
                    opaqueOverGradientView.alpha = 0.0;
                } completion:^(BOOL finished) {}];
        [UIView animateWithDuration:0.400
                              delay:0
                            options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                         animations:^{
                             cardExpiryField.frame = CGRectMake(kPKViewCardExpiryFieldStartX,
                                     cardExpiryField.frame.origin.y,
                                     cardExpiryField.frame.size.width,
                                     cardExpiryField.frame.size.height);
                             cardCVCField.frame = CGRectMake(kPKViewCardCVCFieldStartX,
                                     cardCVCField.frame.origin.y,
                                     cardCVCField.frame.size.width,
                                     cardCVCField.frame.size.height);
                             cardNumberField.frame = CGRectMake(12,
                                     cardNumberField.frame.origin.y,
                                     cardNumberField.frame.size.width,
                                     cardNumberField.frame.size.height);
                             cardNameField.frame = CGRectMake(- cardNameField.width,
                                     cardNameField.frame.origin.y,
                                     cardNameField.frame.size.width,
                                     cardNameField.frame.size.height);
                         }
                         completion:^(BOOL completed) {
                             [cardExpiryField removeFromSuperview];
                             [cardCVCField removeFromSuperview];
                         }];
    }

    [self notifyCreditCardLabel:INPUT_CARD_DATA_KIND_NUMBER];
    [self.cardNumberField becomeFirstResponder];
}

- (void)stateMeta
{
    isInitialState = NO;
    
    [UIView animateWithDuration:0.05 delay:0.35 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         opaqueOverGradientView.alpha = 1.0;
                     } completion:^(BOOL finished) {}];
    [UIView animateWithDuration:0.400 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        cardNumberField.frame = CGRectMake(kPKViewCardNumberFieldEndX,
                                           cardNumberField.frame.origin.y,
                                           cardNumberField.frame.size.width,
                                           cardNumberField.frame.size.height);
        cardNameField.frame = CGRectMake(- cardNameField.width,
                                           cardNameField.frame.origin.y,
                                           cardNameField.frame.size.width,
                                           cardNameField.frame.size.height);
    } completion:nil];
    
    [self addSubview:placeholderView];
    [self.innerView addSubview:cardNumberField];
    [self notifyCreditCardLabel:INPUT_CARD_DATA_KIND_NUMBER];
    [cardNumberField becomeFirstResponder];
}

- (void)stateMeta2
{
    isNumberState = NO;

    CGSize cardNumberSize = [self.cardNumber.formattedString sizeWithFont:DefaultBoldFont];
    CGSize lastGroupSize = [self.cardNumber.lastGroup sizeWithFont:DefaultBoldFont];
    CGFloat frameX = self.cardNumberField.frame.origin.x - (cardNumberSize.width - lastGroupSize.width) - cardNameField.width;
    DLog(@"frameX:%f", frameX);

    [UIView animateWithDuration:0.05 delay:0.35 options:UIViewAnimationOptionCurveEaseInOut
            animations:^{
                opaqueOverGradientView.alpha = 1.0;
            } completion:^(BOOL finished) {}];
    [UIView animateWithDuration:0.400 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        cardExpiryField.frame = CGRectMake(kPKViewCardExpiryFieldEndX,
                cardExpiryField.frame.origin.y,
                cardExpiryField.frame.size.width,
                cardExpiryField.frame.size.height);
        cardCVCField.frame = CGRectMake(kPKViewCardCVCFieldEndX,
                cardCVCField.frame.origin.y,
                cardCVCField.frame.size.width,
                cardCVCField.frame.size.height);
        cardNumberField.frame = CGRectMake(frameX,
                cardNumberField.frame.origin.y,
                cardNumberField.frame.size.width,
                cardNumberField.frame.size.height);
    } completion:nil];

    [self.innerView addSubview:cardExpiryField];
    [self.innerView addSubview:cardCVCField];
    [self notifyCreditCardLabel:INPUT_CARD_DATA_KIND_EXPIRY];
    [cardExpiryField becomeFirstResponder];
}

- (void)stateCardCVC
{
    [self notifyCreditCardLabel:INPUT_CARD_DATA_KIND_CVC];
    [cardCVCField becomeFirstResponder];
}

- (BOOL)isValid
{    
    return [self.cardName isValid] && [self.cardNumber isValid] && [self.cardExpiry isValid] && [self.cardCVC isValid];
}

- (PKCard*)card
{
    PKCard* card    = [[PKCard alloc] init];
    card.name       = [self.cardName string];
    card.number     = [self.cardNumber string];
    card.cvc        = [self.cardCVC string];
    card.expMonth   = [self.cardExpiry month];
    card.expYear    = [self.cardExpiry year];
    
    return card;
}

- (void)setPlaceholderViewImage:(UIImage *)image
{
    if(![placeholderView.image isEqual:image]) {
        __block __weak UIView *previousPlaceholderView = placeholderView;
        [UIView animateWithDuration:kPKViewPlaceholderViewAnimationDuration delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^
         {
             placeholderView.layer.opacity = 0.0;
             placeholderView.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.2);
         } completion:^(BOOL finished) {
             [previousPlaceholderView removeFromSuperview];
         }];
        placeholderView = nil;
        
        [self setupPlaceholderView];
        placeholderView.image = image;
        placeholderView.layer.opacity = 0.0;
        placeholderView.layer.transform = CATransform3DMakeScale(0.8, 0.8, 0.8);
        [self insertSubview:placeholderView belowSubview:previousPlaceholderView];
        [UIView animateWithDuration:kPKViewPlaceholderViewAnimationDuration delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^
         {
             placeholderView.layer.opacity = 1.0;
             placeholderView.layer.transform = CATransform3DIdentity;
         } completion:^(BOOL finished) {}];
    }
}

- (void)setPlaceholderToCVC
{
    PKCardNumber *cardNumber = [PKCardNumber cardNumberWithString:cardNumberField.text];
    PKCardType cardType      = [cardNumber cardType];
    
    if (cardType == PKCardTypeAmex) {
        [self setPlaceholderViewImage:[UIImage imageNamed:@"cvc-amex"]];
    } else {
        [self setPlaceholderViewImage:[UIImage imageNamed:@"cvc"]];
    }
}

- (void)setPlaceholderToCardType
{
    PKCardNumber *cardNumber = [PKCardNumber cardNumberWithString:cardNumberField.text];
    PKCardType cardType      = [cardNumber cardType];
    NSString* cardTypeName   = @"placeholder";
    
    switch (cardType) {
        case PKCardTypeAmex:
            cardTypeName = @"amex";
            break;
        case PKCardTypeDinersClub:
            cardTypeName = @"diners";
            break;
        case PKCardTypeDiscover:
            cardTypeName = @"discover";
            break;
        case PKCardTypeJCB:
            cardTypeName = @"jcb";
            break;
        case PKCardTypeMasterCard:
            cardTypeName = @"mastercard";
            break;
        case PKCardTypeVisa:
            cardTypeName = @"visa";
            break;
        default:
            break;
    }

    [self setPlaceholderViewImage:[UIImage imageNamed:cardTypeName]];
}

// Delegates

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:cardCVCField]) {
        [self setPlaceholderToCVC];
    } else {
        [self setPlaceholderToCardType];
    }
    if ([textField isEqual:cardNumberField] && !isNumberState) {
        [self stateCardNumber];
    }
    if ([textField isEqual:cardNameField]) {
        cardNameField.text = [cardNameField.text uppercaseString];
    }
    if ([textField isEqual:cardNameField] && !isInitialState) {
        [self stateCardName];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    if ([textField isEqual:cardNameField]) {
        if (0 == replacementString.length) {
            return YES;
        } else {
            cardNameField.text = [NSString stringWithFormat:@"%@%@", cardNameField.text, [replacementString uppercaseString]] ;
            return NO;
        }
    }

    if ([textField isEqual:cardNumberField]) {
        return [self cardNumberFieldShouldChangeCharactersInRange:range replacementString:replacementString];
    }
    
    if ([textField isEqual:cardExpiryField]) {
        return [self cardExpiryShouldChangeCharactersInRange:range replacementString:replacementString];
    }
    
    if ([textField isEqual:cardCVCField]) {
        return [self cardCVCShouldChangeCharactersInRange:range replacementString:replacementString];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:cardNameField] && [self.cardName isValid]) {
        [self stateMeta];
    }
    return YES;
}

- (void)pkTextFieldDidBackSpaceWhileTextIsEmpty:(PKTextField *)textField
{
    if (textField == self.cardCVCField) {
        [self notifyCreditCardLabel:INPUT_CARD_DATA_KIND_EXPIRY];
        [self.cardExpiryField becomeFirstResponder];
    } else if (textField == self.cardExpiryField) {
        [self notifyCreditCardLabel:INPUT_CARD_DATA_KIND_NUMBER];
        [self.cardNumberField becomeFirstResponder];
    } else if (textField == self.cardNumberField) {
        [self stateCardName];
    }
}

- (BOOL)cardNumberFieldShouldChangeCharactersInRange: (NSRange)range replacementString:(NSString *)replacementString
{
    NSString *resultString = [cardNumberField.text stringByReplacingCharactersInRange:range withString:replacementString];
    resultString = [PKTextField textByRemovingUselessSpacesFromString:resultString];
    PKCardNumber *cardNumber = [PKCardNumber cardNumberWithString:resultString];
    
    if ( ![cardNumber isPartiallyValid] )
        return NO;
    
    if (replacementString.length > 0) {
        cardNumberField.text = [cardNumber formattedStringWithTrail];
    } else {
        cardNumberField.text = [cardNumber formattedString];
    }
    
    [self setPlaceholderToCardType];
    
    if ([cardNumber isValid]) {
        [self textFieldIsValid:cardNumberField];
        [self stateMeta2];

    } else if ([cardNumber isValidLength] && ![cardNumber isValidLuhn]) {
        [self textFieldIsInvalid:cardNumberField withErrors:YES];
        
    } else if (![cardNumber isValidLength]) {
        [self textFieldIsInvalid:cardNumberField withErrors:NO];
    }
    
    return NO;
}

- (BOOL)cardExpiryShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    NSString *resultString = [cardExpiryField.text stringByReplacingCharactersInRange:range withString:replacementString];
    resultString = [PKTextField textByRemovingUselessSpacesFromString:resultString];
    PKCardExpiry *cardExpiry = [PKCardExpiry cardExpiryWithString:resultString];
    
    if (![cardExpiry isPartiallyValid]) return NO;
    
    // Only support shorthand year
    if ([cardExpiry formattedString].length > 5) return NO;
    
    if (replacementString.length > 0) {
        cardExpiryField.text = [cardExpiry formattedStringWithTrail];
    } else {
        cardExpiryField.text = [cardExpiry formattedString];
    }
    
    if ([cardExpiry isValid]) {
        [self textFieldIsValid:cardExpiryField];
        [self stateCardCVC];
        
    } else if ([cardExpiry isValidLength] && ![cardExpiry isValidDate]) {
        [self textFieldIsInvalid:cardExpiryField withErrors:YES];
    } else if (![cardExpiry isValidLength]) {
        [self textFieldIsInvalid:cardExpiryField withErrors:NO];
    }
    
    return NO;
}

- (BOOL)cardCVCShouldChangeCharactersInRange: (NSRange)range replacementString:(NSString *)replacementString
{
    NSString *resultString = [cardCVCField.text stringByReplacingCharactersInRange:range withString:replacementString];
    resultString = [PKTextField textByRemovingUselessSpacesFromString:resultString];
    PKCardCVC *cardCVC = [PKCardCVC cardCVCWithString:resultString];
    PKCardType cardType = [[PKCardNumber cardNumberWithString:cardNumberField.text] cardType];
    
    // Restrict length
    if ( ![cardCVC isPartiallyValidWithType:cardType] ) return NO;
    
    // Strip non-digits
    cardCVCField.text = [cardCVC string];
    
    if ([cardCVC isValidWithType:cardType]) {
        [self textFieldIsValid:cardCVCField];
    } else {
        [self textFieldIsInvalid:cardCVCField withErrors:NO];
    }
    
    return NO;
}

// Validations

- (void)checkValid
{
    if ([self isValid] && !isValidState) {

        isValidState = YES;

        if ([self.delegate respondsToSelector:@selector(paymentView:withCard:isValid:)]) {
            [self.delegate paymentView:self withCard:self.card isValid:YES];
        }
        
    } else if (![self isValid] && isValidState) {

        isValidState = NO;
        
        if ([self.delegate respondsToSelector:@selector(paymentView:withCard:isValid:)]) {
            [self.delegate paymentView:self withCard:self.card isValid:NO];
        }
    }
    /*
    else {
        if ([self.delegate respondsToSelector:@selector(paymentView:withCard:changedInputKind:)]) {
            if ([self.cardExpiry isValid]) {
                [self.delegate paymentView:self withCard:self.card changedInputKind:INPUT_CARD_DATA_KIND_CVC];
            } else if ([self.cardNumber isValid]) {
                [self.delegate paymentView:self withCard:self.card changedInputKind:INPUT_CARD_DATA_KIND_EXPIRY];
            } else if ([self.cardName isValid]){
                [self.delegate paymentView:self withCard:self.card changedInputKind:INPUT_CARD_DATA_KIND_NUMBER];
            } else {
                [self.delegate paymentView:self withCard:self.card changedInputKind:INPUT_CARD_DATA_KIND_NAME];
            }
        }
    }
    */
}

- (void)notifyCreditCardLabel:(INPUT_CARD_DATA_KIND)kind {
    if ([self.delegate respondsToSelector:@selector(paymentView:withCard:changedInputKind:)]) {
        [self.delegate paymentView:self withCard:self.card changedInputKind:kind];
        /*
        if ([self.cardExpiry isValid]) {
            [self.delegate paymentView:self withCard:self.card changedInputKind:INPUT_CARD_DATA_KIND_CVC];
        } else if ([self.cardNumber isValid]) {
            [self.delegate paymentView:self withCard:self.card changedInputKind:INPUT_CARD_DATA_KIND_EXPIRY];
        } else if ([self.cardName isValid]){
            [self.delegate paymentView:self withCard:self.card changedInputKind:INPUT_CARD_DATA_KIND_NUMBER];
        } else {
            [self.delegate paymentView:self withCard:self.card changedInputKind:INPUT_CARD_DATA_KIND_NAME];
        }
        */
    }
}

- (void)textFieldIsValid:(UITextField *)textField {
    textField.textColor = DarkGreyColor;
    [self checkValid];
}

- (void)textFieldIsInvalid:(UITextField *)textField withErrors:(BOOL)errors {
    if (errors) {
        textField.textColor = RedColor;
    } else {
        textField.textColor = DarkGreyColor;        
    }

    [self checkValid];
}

@end