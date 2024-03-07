//
//  WarningView.swift
//  ElGrocerShopper
//
//  Created by Rashid Khan on 08/09/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

class WarningView: UIView {
    @IBOutlet weak var lblWarningMsg: UILabel! {
        didSet {
            lblWarningMsg.setCaptionOneRegDarkStyle()
        }
    }
    @IBOutlet weak var viewBG: AWView! {
        didSet {
            viewBG.borderColor = ApplicationTheme.currentTheme.borderLightGrayColor
            viewBG.borderWidth = 1
        }
    }
    
    override func awakeFromNib() {
        lblWarningMsg.text = localizedString("checkout_all_fee_message_will_be_in_receipt_msg", comment: "")
        
        
    }
}
