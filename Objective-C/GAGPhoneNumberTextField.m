//
//  GAGPhoneNumberTextField.m
//  
//
//  Created by Volodymyr Fedorenko on 4/4/17.
//  Copyright © 2017 Soft Industry. All rights reserved.
//

#import "GAGPhoneNumberTextField.h"
#import "GAGConstants.h"
#import "GAGAppearance.h"

@interface GAGPhoneNumberTextField () <UITextFieldDelegate>

@property (nonatomic) UIToolbar *editingToolbar;

@end

@implementation GAGPhoneNumberTextField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupPhoneNumberTextField];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupPhoneNumberTextField];
}

- (void)setupPhoneNumberTextField
{
    self.delegate = self;
    self.inputAccessoryView = self.editingToolbar;
    NSString *placeholder = self.placeholder;
    if (placeholder.length == 0)
    {
        placeholder = NSLocalizedString(@"7", @"");
    }
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder
                                                                                attributes:@{ NSFontAttributeName : self.font, NSForegroundColorAttributeName : [GAGAppearance linedTextFieldPlaceholderColor] }];
}

- (UIKeyboardType)keyboardType
{
    return UIKeyboardTypePhonePad;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL shouldBegin = YES;
    
    if ([self.shouldBeginEditDelegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        shouldBegin = [self.shouldBeginEditDelegate textFieldShouldBeginEditing: textField];
    }
    
    return shouldBegin;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL shouldChange = YES;
    
    NSString *currentString = textField.text;
    
    if ([currentString isEqualToString:[GAGConstants phoneNumberPrefix]] && string.length == 0) // If trying to remove prefix string
    {
        shouldChange = NO;
    }
    else
    {
        NSString *replacementStringFiltered = [[string componentsSeparatedByCharactersInSet: [[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString: @""];
        NSString *newString = [currentString stringByReplacingCharactersInRange:range withString:replacementStringFiltered];
        if ([currentString isEqualToString:[GAGConstants phoneNumberPrefix]] &&
            [replacementStringFiltered hasPrefix:[GAGConstants phoneNumberPrefix]] &&
            replacementStringFiltered.length == [GAGConstants maxPhoneNumberLength])
        {
            textField.text = replacementStringFiltered;
            shouldChange = NO;
        }
        else
        {
            if (newString.length <= [GAGConstants maxPhoneNumberLength])
            {
                if (replacementStringFiltered.length < string.length)
                {
                    textField.text = newString;
                    shouldChange = NO;
                }
                else
                {
                    NSCharacterSet *charactersFromString = [NSCharacterSet characterSetWithCharactersInString:newString];
                    shouldChange = [[NSCharacterSet decimalDigitCharacterSet] isSupersetOfSet:charactersFromString];
                }
            }
            else
            {
                shouldChange = NO;
            }
        }
    }
    
    return shouldChange;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.text.length == 0)
    {
        textField.text = [GAGConstants phoneNumberPrefix];
    }
}

- (UIToolbar *)editingToolbar
{
    if (_editingToolbar == nil)
    {
        _editingToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 44)];
        _editingToolbar.translucent = YES;
        _editingToolbar.translatesAutoresizingMaskIntoConstraints = NO;
        _editingToolbar.barStyle = UIBarStyleBlack;
        
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Скрыть", @"") style:UIBarButtonItemStylePlain target:self action:@selector(doneAction:)];
        doneButton.tintColor = [GAGAppearance mainFontColor];
        
        [_editingToolbar setItems:@[flexSpace, doneButton] animated:NO];
    }
    return _editingToolbar;
}

- (void)doneAction:(id)sender
{
    [self resignFirstResponder];
}

@end
