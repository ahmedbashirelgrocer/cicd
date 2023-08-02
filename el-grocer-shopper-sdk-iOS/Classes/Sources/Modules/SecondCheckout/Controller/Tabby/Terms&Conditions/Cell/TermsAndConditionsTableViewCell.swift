//
//  TermsAndConditionsTableViewCell.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 26/06/2023.
//

import UIKit

class TermsAndConditionsTableViewCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel! {
        didSet {
            lblTitle.setBody3SemiBoldDarkStyle()
        }
    }
    @IBOutlet weak var lblDescription: UILabel! {
        didSet {
            lblDescription.setBody3RegDarkStyle()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.lblTitle.textAlignment = .right
            self.lblDescription.textAlignment = .right
        } else {
            self.lblTitle.textAlignment = .left
            self.lblDescription.textAlignment = .left
        }
    }

    func configure(title: String, description: String) {
        self.lblTitle.text = title
        self.lblDescription.text = description
    }
}
