//
//  LoginRegistrationFieldsValidator.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 02.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

class LoginRegistrationFieldsValidator {
    
    class func validateSignUpFields(_ name:String, email:String, password:String) -> Bool {
        
        let nameCorrect = !name.isEmpty
        let emailCorrect = email.isValidEmail()
        let passwordCorrect = !password.isEmpty && password.isValidPassword()
        
        let enableSignUpButton = nameCorrect && emailCorrect && passwordCorrect
        
        return enableSignUpButton
    }
    
    class func validateLoginFields(_ userName:String, password:String) -> Bool {
        
        let usernameCorrect = userName.isValidEmail()
        let passwordCorrect = !password.isEmpty
        
        let enableLoginButton = usernameCorrect && passwordCorrect
        
        return enableLoginButton
    }
    
}
