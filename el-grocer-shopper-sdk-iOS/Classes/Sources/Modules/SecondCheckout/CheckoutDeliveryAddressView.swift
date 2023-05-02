//
//  CheckoutDeliveryAddressView.swift
//  ElGrocerShopper
//
//  Created by Rashid Khan on 25/08/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import Foundation

class CheckoutDeliveryAddressView: UIView {
    @IBOutlet weak var lblAddress: UILabel! {
        didSet {
            lblAddress.setBody3RegDarkStyle()
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                lblAddress.textAlignment = .right
            }
        }
    }
    
    func configure(address: String) {
        self.lblAddress.text = address
    }
    
}
