//
//  MissingItemQuestionCell.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 15/11/2023.
//

import UIKit

class MissingItemsPreferenceCell: UITableViewCell {
    @IBOutlet weak var radioButtonImage: UIImageView!
    @IBOutlet weak var lblQuestion: UILabel!
    
    private let checkedRadioIconName = sdkManager.isShopperApp ? "egRadioButtonFilled" : "RadioButtonFilled"
    private let unCheckedRadioIconName = sdkManager.isShopperApp ? "egRadioButtonUnfilled" :"RadioButtonUnfilled"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblQuestion.setBody2SemiboldDarkStyle()
        self.selectionStyle = .none
    }

    func configure(reason: Reasons, isSelected: Bool) {
        self.lblQuestion.text = reason.reasonString
        self.radioButtonImage.image = isSelected ? UIImage(name: checkedRadioIconName) : UIImage(name: unCheckedRadioIconName)
    }
    
}
