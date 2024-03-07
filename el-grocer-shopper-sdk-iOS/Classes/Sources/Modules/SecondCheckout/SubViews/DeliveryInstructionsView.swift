//
//  AdditionalInstructionsView.swift
//  ElGrocerShopper
//
//  Created by Rashid Khan on 25/08/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit
import GrowingTextView

protocol DeliveryInstructionsViewDelegate: AnyObject {
    func deliveryInstructionsView(_didTap view: DeliveryInstructionsView)
}

class DeliveryInstructionsView: UIView {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblValue: UILabel!
    @IBOutlet weak var viewBG: AWView!{
        didSet {
            viewBG.borderWidth = 1
            viewBG.borderColor = ApplicationTheme.currentTheme.borderLightGrayColor
        }
    }
    @IBOutlet weak var ivArrowForward: UIImageView!
    
    var delegate: DeliveryInstructionsViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblTitle.text = localizedString("text_delivery_instructions", comment: "")
        lblValue.text = ""
        
        self.viewBG.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapHandler)))
        
        lblTitle.setBody2RegDarkStyle()
        lblValue.setBody3SemiBoldDarkStyle()
        
        let rightIcon = UIImage(name: "arrow-right-filled")?.withRenderingMode(.alwaysTemplate)
        ivArrowForward.tintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        ivArrowForward.image  = rightIcon
        
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.ivArrowForward.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    func configure(instructions: String?) {
        self.lblValue.text = instructions
        self.lblTitle.text = (instructions?.isNotEmpty ?? false)
            ? localizedString("text_delivery_instructions", comment: "") + ":"
            : localizedString("text_delivery_instructions", comment: "")
    }
    
    @objc func viewTapHandler(_ sender: UITapGestureRecognizer) {
        self.delegate?.deliveryInstructionsView(_didTap: self)
    }
}
