//
//  GAGPhoneNumberTextField.h
//  
//
//  Created by Volodymyr Fedorenko on 4/4/17.
//  Copyright © 2017 Soft Industry. All rights reserved.
//

#import "GAGLinedTextField.h"

@interface GAGPhoneNumberTextField : GAGLinedTextField

@property (nonatomic, weak) id<UITextFieldDelegate> shouldBeginEditDelegate;

@end
