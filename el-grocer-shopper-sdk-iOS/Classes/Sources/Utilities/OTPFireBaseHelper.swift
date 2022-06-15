//
//  OTPFireBaseHelper.swift
//  ElGrocerShopper
//
//  Created by Abubaker Majeed on 12/06/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth


//private let SharedInstance = OTPFireBaseHelper()
//let OTPFireBaseHelperSharedInstance = OTPFireBaseHelper.sharedInstance

class OTPFireBaseHelper {
    
//    class var sharedInstance : OTPFireBaseHelper {
//        return SharedInstance
//    }
    
    class func phoneAuthentication(phoneNumber : String , completion : @escaping ((_ isSuccess : Bool , _ phoneNumber : String? , _  token : String?) -> Void)) {
    
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (result, error) in
            if let _ = error {
                completion(false, nil , nil )
                return
            }
            completion(true , phoneNumber , result)
        }
//        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber ) { (result, error) in
//            if let _ = error {
//                completion(false, nil , nil )
//                return
//            }
//             completion(true , phoneNumber , result)
//        }

    }
    
    class func verifyCode(verificationID : String?  , testVerificationCode : String , completion : @escaping ((_ isSuccess : Bool) -> Void)) {
        
        let finalCode = OTPFireBaseHelper.convertArabicNumberIntoEnglish(testVerificationCode)
    
    let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID ?? "",
                                                             verificationCode: finalCode)
     
        
        Auth.auth().signIn(with: credential){ authData, error in
         if let _ = error {
            completion(false)
        } else {
            if let userData = authData {
                debugPrint(userData.user)
            }
            completion(true)
        }
    }
    }
    
    class func convertArabicNumberIntoEnglish(_ arabicNumberString : String) -> String {
        
        guard !arabicNumberString.isEmpty else {
            return ""
        }
        let formatter: NumberFormatter = NumberFormatter()
        formatter.locale = NSLocale(localeIdentifier: "EN") as Locale
        let final = formatter.number(from: arabicNumberString)
        return final?.stringValue ?? ""
    }
    
}
