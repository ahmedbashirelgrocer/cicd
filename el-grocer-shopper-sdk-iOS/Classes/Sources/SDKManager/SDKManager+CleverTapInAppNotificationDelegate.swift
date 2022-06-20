//
//  SDKManager+CleverTapInAppNotificationDelegate.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 20/06/2022.
//

import CleverTapSDK

extension SDKManager : CleverTapInAppNotificationDelegate {

    func inAppNotificationButtonTapped(withCustomExtras customExtras: [AnyHashable : Any]!) {
      
        var promoCode = ""
        if let promo = customExtras["promoCode"] as? String {promoCode = promo}
        if let promo = customExtras["promocode"] as? String {promoCode = promo}
        if let promo = customExtras["to_be_copied"] as? String {promoCode = promo}
        if promoCode.count > 0 {
            let pasteBoard = UIPasteboard.general
            pasteBoard.string = promoCode
        }
    }
    
}
