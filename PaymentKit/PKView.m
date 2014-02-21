//
//  PKPaymentField.m
//  PKPayment Example
//
//  Created by Alex MacCaw on 1/22/13.
//  Copyright (c) 2013 Stripe. All rights reserved.
//

//#define RGB(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]
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

#import "PKView.h"
#import "PKTextField.h"
#import "PKCardName.h"
#import "UIView+MyExtension.h"

@interface PKView () <UITextFieldDelegate> {
@private
    BOOL isNameState;
    BOOL isNumberState;
    BOOL isStateCardNameWorking;
}

@property (nonatomic, readonly, assign) UIResponder *firstResponderField;
@property (nonatomic, readonly, assign) PKTextField *firstInvalidField;
@property (nonatomic, readonly, assign) PKTextField *nextFirstResponder;

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
- (BOOL)cardNumberFieldShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString;
- (BOOL)cardExpiryShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString;
- (BOOL)cardCVCShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString;

@property (nonatomic) UIView *opaqueOverGradientView;
@property (nonatomic) PKCardNumber *cardNumber;
@property (nonatomic) PKCardExpiry *cardExpiry;
@property (nonatomic) PKCardCVC *cardCVC;
@property (nonatomic) PKAddressZip *addressZip;
@property (nonatomic) PKCardName *cardName;
@end

#pragma mark -

@implementation PKView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(changeTextField:)
                       name:NOTIFY_CHANGE_PKTextField
                     object:nil];
    }
    return self;
}

- (void)changeTextField:(NSNotification *)notify {
    NSNumber *index = [notify object];
    switch (index.integerValue) {
        case 0:
            break;
        case 1:
            [self stateMeta];
            break;
        case 2:
            [self stateMeta2];
            break;
        default: break;
    }

}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    isNameState = YES;
    isNumberState = NO;
    isStateCardNameWorking = NO;

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
    [self.innerView addSubview:self.cardNameField];

    UIImageView *gradientImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 34)];
    gradientImageView.image = [UIImage imageNamed:@"gradient"];
    [self.innerView addSubview:gradientImageView];

    self.opaqueOverGradientView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 9, 34)];
    self.opaqueOverGradientView.backgroundColor = [UIColor colorWithRed:0.9686 green:0.9686
                                                                   blue:0.9686 alpha:1.0000];
    self.opaqueOverGradientView.alpha = 0.0;
    [self.innerView addSubview:self.opaqueOverGradientView];

    [self addSubview:self.innerView];
    [self addSubview:self.placeholderView];

    [self stateCardName];
}


- (void)setupPlaceholderView
{
    self.placeholderView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 13, 32, 20)];
    self.placeholderView.backgroundColor = [UIColor clearColor];
    self.placeholderView.image = [UIImage imageNamed:@"placeholder"];

    CALayer *clip = [CALayer layer];
    clip.frame = CGRectMake(32, 0, 4, 20);
    clip.backgroundColor = [UIColor clearColor].CGColor;
    [self.placeholderView.layer addSublayer:clip];
}

- (void)setupCardNameField
{
    self.cardNameField = [[PKTextField alloc] initWithFrame:CGRectMake(12,3,220,20)];

    self.cardNameField.delegate = self;

    self.cardNameField.placeholder = @"LENSY TARO";
    self.cardNameField.keyboardType = UIKeyboardTypeASCIICapable;
    self.cardNameField.returnKeyType = UIReturnKeyNext;
    self.cardNameField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.cardNameField.textColor = DarkGreyColor;
    self.cardNameField.font = [UIFont fontWithName:@"Marion-Bold" size:18.0f];

    [self.cardNameField.layer setMasksToBounds:YES];
}

- (void)setupCardNumberField
{
    self.cardNumberField = [[PKTextField alloc] initWithFrame:CGRectMake(kPKViewCardNumberFieldStartX,0,170,20)];

    self.cardNumberField.delegate = self;

    self.cardNumberField.placeholder = NSLocalizedStringFromTable(@"placeholder.card_number", @"STPaymentLocalizable", nil);
    self.cardNumberField.keyboardType = UIKeyboardTypeNumberPad;
    self.cardNumberField.textColor = DarkGreyColor;
    self.cardNumberField.font = DefaultBoldFont;

    [self.cardNumberField.layer setMasksToBounds:YES];
}

- (void)setupCardExpiryField
{
    self.cardExpiryField = [[PKTextField alloc] initWithFrame:CGRectMake(kPKViewCardExpiryFieldStartX, 0, 60, 20)];
    self.cardExpiryField.delegate = self;
    self.cardExpiryField.placeholder = NSLocalizedStringFromTable(@"placeholder.card_expiry", @"STPaymentLocalizable", nil);
    self.cardExpiryField.keyboardType = UIKeyboardTypeNumberPad;
    self.cardExpiryField.textColor = DarkGreyColor;
    self.cardExpiryField.font = DefaultBoldFont;

    [self.cardExpiryField.layer setMasksToBounds:YES];
}

- (void)setupCardCVCField
{
    self.cardCVCField = [[PKTextField alloc] initWithFrame:CGRectMake(kPKViewCardCVCFieldStartX,0,
                                                                 55,20)];
    
    self.cardCVCField.delegate = self;
    
    self.cardCVCField.placeholder = @"CVC";
    self.cardCVCField.keyboardType = UIKeyboardTypeNumberPad;
    self.cardCVCField.textColor = DarkGreyColor;
    self.cardCVCField.font = DefaultBoldFont;
    
    [self.cardCVCField.layer setMasksToBounds:YES];
    self.cardCVCField = [[PKTextField alloc] initWithFrame:CGRectMake(kPKViewCardCVCFieldStartX, 0, 55, 20)];
    self.cardCVCField.delegate = self;
    self.cardCVCField.placeholder = NSLocalizedStringFromTable(@"placeholder.card_cvc", @"STPaymentLocalizable", nil);
    self.cardCVCField.keyboardType = UIKeyboardTypeNumberPad;
    self.cardCVCField.textColor = DarkGreyColor;
    self.cardCVCField.font = DefaultBoldFont;

    [self.cardCVCField.layer setMasksToBounds:YES];
}

#pragma mark - Accessors

- (PKCardName *)cardName
{
    return [PKCardName cardNameWithString:self.cardNameField.text];
}

- (PKCardNumber *)cardNumber
{
    return [PKCardNumber cardNumberWithString:self.cardNumberField.text];
}

- (PKCardExpiry *)cardExpiry
{
    return [PKCardExpiry cardExpiryWithString:self.cardExpiryField.text];
}

- (PKCardCVC *)cardCVC
{
    return [PKCardCVC cardCVCWithString:self.cardCVCField.text];
}

#pragma mark - State

- (void)stateCardName
{
    if (!isNameState) {
        // Animate left
        isNameState = YES;
        isStateCardNameWorking = YES;

        [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.opaqueOverGradientView.alpha = 0.0;
                         } completion:^(BOOL finished) {}];
        [UIView animateWithDuration:0.400
                              delay:0
                            options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                         animations:^{
                             self.cardExpiryField.frame = CGRectMake(kPKViewCardExpiryFieldStartX + 220,
                                                                self.cardExpiryField.frame.origin.y,
                                                                self.cardExpiryField.frame.size.width,
                                                                self.cardExpiryField.frame.size.height);
                             self.cardCVCField.frame = CGRectMake(kPKViewCardCVCFieldStartX + 220,
                                                             self.cardCVCField.frame.origin.y,
                                                             self.cardCVCField.frame.size.width,
                                                             self.cardCVCField.frame.size.height);
                             self.cardNumberField.frame = CGRectMake(kPKViewCardNumberFieldStartX,
                                                                self.cardNumberField.frame.origin.y,
                                                                self.cardNumberField.frame.size.width,
                                                                self.cardNumberField.frame.size.height);
                             self.cardNameField.frame = CGRectMake(12,
                                     self.cardNameField.frame.origin.y,
                                     self.cardNameField.frame.size.width,
                                     self.cardNameField.frame.size.height);
                         }
                         completion:^(BOOL completed) {
                             isStateCardNameWorking = NO;
                             [self.cardNumberField removeFromSuperview];
                             [self.cardExpiryField removeFromSuperview];
                             [self.cardCVCField removeFromSuperview];
                         }];
    }
    
    [self notifyCreditCardLabel:INPUT_CARD_DATA_KIND_NAME];
    [self.cardNameField becomeFirstResponder];
}

- (void)stateCardNumber
{
    if (!isNumberState) {
        // Animate left
        isNumberState = YES;

        [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                animations:^{
                             self.opaqueOverGradientView.alpha = 0.0;
                         } completion:^(BOOL finished) {
        }];
        [UIView animateWithDuration:0.400
                              delay:0
                            options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction)
                         animations:^{
                             self.cardExpiryField.frame = CGRectMake(kPKViewCardExpiryFieldStartX,
                                     self.cardExpiryField.frame.origin.y,
                                     self.cardExpiryField.frame.size.width,
                                     self.cardExpiryField.frame.size.height);
                             self.cardCVCField.frame = CGRectMake(kPKViewCardCVCFieldStartX,
                                     self.cardCVCField.frame.origin.y,
                                     self.cardCVCField.frame.size.width,
                                     self.cardCVCField.frame.size.height);
                             self.cardNumberField.frame = CGRectMake(12,
                                     self.cardNumberField.frame.origin.y,
                                     self.cardNumberField.frame.size.width,
                                     self.cardNumberField.frame.size.height);
                             self.cardNameField.frame = CGRectMake(- self.cardNameField.width,
                                     self.cardNameField.frame.origin.y,
                                     self.cardNameField.frame.size.width,
                                     self.cardNameField.frame.size.height);
                         }
                         completion:^(BOOL completed) {
                             [self.cardExpiryField removeFromSuperview];
                             [self.cardCVCField removeFromSuperview];
                         }];
    }

    [self notifyCreditCardLabel:INPUT_CARD_DATA_KIND_NUMBER];
    [self.cardNumberField becomeFirstResponder];
}

- (void)stateMeta
{
    isNameState = NO;
    
    [UIView animateWithDuration:0.05 delay:0.35 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.opaqueOverGradientView.alpha = 1.0;
                     } completion:^(BOOL finished) {}];
    [UIView animateWithDuration:0.400 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.cardNumberField.frame = CGRectMake(kPKViewCardNumberFieldEndX,
                self.cardNumberField.frame.origin.y,
                self.cardNumberField.frame.size.width,
                self.cardNumberField.frame.size.height);
        self.cardNameField.frame = CGRectMake(- self.cardNameField.width,
                self.cardNameField.frame.origin.y,
                self.cardNameField.frame.size.width,
                self.cardNameField.frame.size.height);
    } completion:nil];
    
    [self addSubview:self.placeholderView];
    [self.innerView addSubview:self.cardNumberField];
    [self notifyCreditCardLabel:INPUT_CARD_DATA_KIND_NUMBER];
    [self.cardNumberField becomeFirstResponder];
}

- (void)stateMeta2
{
    isNumberState = NO;

    CGSize cardNumberSize = [self.cardNumber.formattedString sizeWithAttributes:@{NSFontAttributeName: DefaultBoldFont}];
    CGSize lastGroupSize = [self.cardNumber.lastGroup sizeWithAttributes:@{NSFontAttributeName: DefaultBoldFont}];
    CGFloat frameX = self.cardNumberField.frame.origin.x - (cardNumberSize.width - lastGroupSize.width) - self.cardNameField.width;
    DLog(@"frameX:%f", frameX);

    [UIView animateWithDuration:0.05 delay:0.35 options:UIViewAnimationOptionCurveEaseInOut
            animations:^{
                         self.opaqueOverGradientView.alpha = 1.0;
                     } completion:^(BOOL finished) {
    }];
    [UIView animateWithDuration:0.400 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.cardExpiryField.frame = CGRectMake(kPKViewCardExpiryFieldEndX,
                self.cardExpiryField.frame.origin.y,
                self.cardExpiryField.frame.size.width,
                self.cardExpiryField.frame.size.height);
        self.cardCVCField.frame = CGRectMake(kPKViewCardCVCFieldEndX,
                self.cardCVCField.frame.origin.y,
                self.cardCVCField.frame.size.width,
                self.cardCVCField.frame.size.height);
        self.cardNumberField.frame = CGRectMake(frameX,
                self.cardNumberField.frame.origin.y,
                self.cardNumberField.frame.size.width,
                self.cardNumberField.frame.size.height);
    } completion:nil];

    [self.innerView addSubview:self.cardExpiryField];
    [self.innerView addSubview:self.cardCVCField];
    [self notifyCreditCardLabel:INPUT_CARD_DATA_KIND_EXPIRY];
    [self.cardExpiryField becomeFirstResponder];
}

- (void)stateCardCVC
{
    [self notifyCreditCardLabel:INPUT_CARD_DATA_KIND_CVC];
    [self.cardCVCField becomeFirstResponder];
}

- (BOOL)isValid
{
    return [self.cardName isValid] && [self.cardNumber isValid] && [self.cardExpiry isValid] && [self.cardCVC isValid];
}

- (PKCard *)card
{
    PKCard *card = [[PKCard alloc] init];
    card.name       = [self.cardName string];
    card.number     = [self.cardNumber string];
    card.cvc        = [self.cardCVC string];
    card.expMonth   = [self.cardExpiry month];
    card.expYear    = [self.cardExpiry year];
    
    return card;
}

- (void)setPlaceholderViewImage:(UIImage *)image
{
    if (![self.placeholderView.image isEqual:image]) {
        __block __unsafe_unretained UIView *previousPlaceholderView = self.placeholderView;
        [UIView animateWithDuration:kPKViewPlaceholderViewAnimationDuration delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.placeholderView.layer.opacity = 0.0;
                             self.placeholderView.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.2);
                         } completion:^(BOOL finished) {
            [previousPlaceholderView removeFromSuperview];
        }];
        self.placeholderView = nil;

        [self setupPlaceholderView];
        self.placeholderView.image = image;
        self.placeholderView.layer.opacity = 0.0;
        self.placeholderView.layer.transform = CATransform3DMakeScale(0.8, 0.8, 0.8);
        [self insertSubview:self.placeholderView belowSubview:previousPlaceholderView];
        [UIView animateWithDuration:kPKViewPlaceholderViewAnimationDuration delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.placeholderView.layer.opacity = 1.0;
                             self.placeholderView.layer.transform = CATransform3DIdentity;
                         } completion:^(BOOL finished) {
        }];
    }
}

- (void)setPlaceholderToCVC
{
    PKCardNumber *cardNumber = [PKCardNumber cardNumberWithString:self.cardNumberField.text];
    PKCardType cardType = [cardNumber cardType];

    if (cardType == PKCardTypeAmex) {
        [self setPlaceholderViewImage:[UIImage imageNamed:@"cvc-amex"]];
    } else {
        [self setPlaceholderViewImage:[UIImage imageNamed:@"cvc"]];
    }
}

- (void)setPlaceholderToCardType
{
    PKCardNumber *cardNumber = [PKCardNumber cardNumberWithString:self.cardNumberField.text];
    PKCardType cardType = [cardNumber cardType];
    NSString *cardTypeName = @"placeholder";

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

#pragma mark - Delegates

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.cardCVCField]) {
        [self setPlaceholderToCVC];
    } else {
        [self setPlaceholderToCardType];
    }
    if ([textField isEqual:self.cardNumberField] && !isNumberState) {
        [self stateCardNumber];
    }
    if ([textField isEqual:self.cardNameField]) {
        if ([PKTextField textByRemovingUselessSpacesFromString:self.cardNameField.text].length == 0) {
            self.cardNameField.text = @"";
        }
        else {
            self.cardNameField.text = [self.cardNameField.text uppercaseString];
        }
    }
    if ([textField isEqual:self.cardNameField] && !isNameState) {
        [self stateCardName];
    }
}


- (BOOL)isCardNameValid:(NSString *)cardName {
    NSPredicate *regex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[A-Za-z ]"];
    return [regex evaluateWithObject:cardName];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    if ([textField isEqual:self.cardNameField]) {
        if (0 == replacementString.length) {
            return YES;
        } else {
            if ([self isCardNameValid:[replacementString uppercaseString]]) {
                self.cardNameField.text = [NSString stringWithFormat:@"%@%@", self.cardNameField.text, [replacementString uppercaseString]] ;
            }
            return NO;
        }
    }

    if ([textField isEqual:self.cardNumberField]) {
        return [self cardNumberFieldShouldChangeCharactersInRange:range replacementString:replacementString];
    }

    if ([textField isEqual:self.cardExpiryField]) {
        return [self cardExpiryShouldChangeCharactersInRange:range replacementString:replacementString];
    }

    if ([textField isEqual:self.cardCVCField]) {
        return [self cardCVCShouldChangeCharactersInRange:range replacementString:replacementString];
    }

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self isValid]) {
        if ([self.delegate respondsToSelector:@selector(paymentView:withCard:isValid:)]) {
            [self.delegate paymentView:self withCard:self.card isValid:YES];
        }
    } else if (!isStateCardNameWorking && [textField isEqual:self.cardNameField] && [self.cardName isValid]) {
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

- (BOOL)cardNumberFieldShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    NSString *resultString = [self.cardNumberField.text stringByReplacingCharactersInRange:range withString:replacementString];
    resultString = [PKTextField textByRemovingUselessSpacesFromString:resultString];
    PKCardNumber *cardNumber = [PKCardNumber cardNumberWithString:resultString];

    if (![cardNumber isPartiallyValid])
        return NO;

    if (replacementString.length > 0) {
        self.cardNumberField.text = [cardNumber formattedStringWithTrail];
    } else {
        self.cardNumberField.text = [cardNumber formattedString];
    }

    [self setPlaceholderToCardType];

    if ([cardNumber isValid]) {
        [self textFieldIsValid:self.cardNumberField];
        [self stateMeta2];

    } else if ([cardNumber isValidLength] && ![cardNumber isValidLuhn]) {
        [self textFieldIsInvalid:self.cardNumberField withErrors:YES];

    } else if (![cardNumber isValidLength]) {
        [self textFieldIsInvalid:self.cardNumberField withErrors:NO];
    }

    return NO;
}

- (BOOL)cardExpiryShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    NSString *resultString = [self.cardExpiryField.text stringByReplacingCharactersInRange:range withString:replacementString];
    resultString = [PKTextField textByRemovingUselessSpacesFromString:resultString];
    PKCardExpiry *cardExpiry = [PKCardExpiry cardExpiryWithString:resultString];

    if (![cardExpiry isPartiallyValid]) return NO;

    // Only support shorthand year
    if ([cardExpiry formattedString].length > 5) return NO;

    if (replacementString.length > 0) {
        self.cardExpiryField.text = [cardExpiry formattedStringWithTrail];
    } else {
        self.cardExpiryField.text = [cardExpiry formattedString];
    }

    if ([cardExpiry isValid]) {
        [self textFieldIsValid:self.cardExpiryField];
        [self stateCardCVC];

    } else if ([cardExpiry isValidLength] && ![cardExpiry isValidDate]) {
        [self textFieldIsInvalid:self.cardExpiryField withErrors:YES];
    } else if (![cardExpiry isValidLength]) {
        [self textFieldIsInvalid:self.cardExpiryField withErrors:NO];
    }

    return NO;
}

- (BOOL)cardCVCShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    NSString *resultString = [self.cardCVCField.text stringByReplacingCharactersInRange:range withString:replacementString];
    resultString = [PKTextField textByRemovingUselessSpacesFromString:resultString];
    PKCardCVC *cardCVC = [PKCardCVC cardCVCWithString:resultString];
    PKCardType cardType = [[PKCardNumber cardNumberWithString:self.cardNumberField.text] cardType];

    // Restrict length
    if (![cardCVC isPartiallyValidWithType:cardType]) return NO;

    // Strip non-digits
    self.cardCVCField.text = [cardCVC string];

    if ([cardCVC isValidWithType:cardType]) {
        [self textFieldIsValid:self.cardCVCField];
    } else {
        [self textFieldIsInvalid:self.cardCVCField withErrors:NO];
    }

    return NO;
}


#pragma mark - Validations

- (void)checkValid
{
    if ([self isValid]) {
        isNameState = YES;

        if ([self.delegate respondsToSelector:@selector(paymentView:withCard:isValid:)]) {
            [self.delegate paymentView:self withCard:self.card isValid:YES];
        }

    } else if (![self isValid] && isNameState) {
        isNameState = NO;

        if ([self.delegate respondsToSelector:@selector(paymentView:withCard:isValid:)]) {
            [self.delegate paymentView:self withCard:self.card isValid:NO];
        }
    }
}

- (void)notifyCreditCardLabel:(INPUT_CARD_DATA_KIND)kind {
    if ([self.delegate respondsToSelector:@selector(paymentView:withCard:changedInputKind:)]) {
        [self.delegate paymentView:self withCard:self.card changedInputKind:kind];
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

#pragma mark -
#pragma mark UIResponder
- (UIResponder *)firstResponderField;
{
    NSArray *responders = @[self.cardNumberField, self.cardExpiryField, self.cardCVCField];
    for (UIResponder *responder in responders) {
        if (responder.isFirstResponder) {
            return responder;
        }
    }

    return nil;
}

- (PKTextField *)firstInvalidField;
{
    if (![[PKCardNumber cardNumberWithString:self.cardNumberField.text] isValid])
        return self.cardNumberField;
    else if (![[PKCardExpiry cardExpiryWithString:self.cardExpiryField.text] isValid])
        return self.cardExpiryField;
    else if (![[PKCardCVC cardCVCWithString:self.cardCVCField.text] isValid])
        return self.cardCVCField;

    return nil;
}

- (PKTextField *)nextFirstResponder;
{
    if (self.firstInvalidField)
        return self.firstInvalidField;

    return self.cardCVCField;
}

- (BOOL)isFirstResponder;
{
    return self.firstResponderField.isFirstResponder;
}

- (BOOL)canBecomeFirstResponder;
{
    return self.nextFirstResponder.canBecomeFirstResponder;
}

- (BOOL)becomeFirstResponder;
{
    return [self.nextFirstResponder becomeFirstResponder];
}

- (BOOL)canResignFirstResponder;
{
    return self.firstResponderField.canResignFirstResponder;
}

- (BOOL)resignFirstResponder;
{
    return [self.firstResponderField resignFirstResponder];
}

@end
