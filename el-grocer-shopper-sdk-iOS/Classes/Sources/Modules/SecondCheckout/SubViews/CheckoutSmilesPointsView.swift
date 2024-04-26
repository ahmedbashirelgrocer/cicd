//
//  SmilesPointsView.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 05/12/2023.
//

import UIKit

protocol CheckoutSmilesPointsViewDelegate: AnyObject {
    func smilesPointsView(_didTap view: CheckoutSmilesPointsView)
}

class CheckoutSmilesPointsView: UIView {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPointsApplied: UILabel!
    @IBOutlet weak var ivArrowForward: UIImageView!
    @IBOutlet weak var viewBG: AWView! {
        didSet {
            viewBG.borderWidth = 1
            viewBG.borderColor = ApplicationTheme.currentTheme.borderLightGrayColor
        }
    }
    var delegate: CheckoutSmilesPointsViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewBG.isUserInteractionEnabled = true
        viewBG.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapHandler)))
        
        lblTitle.text = localizedString("text_checkout_smiles_points_title", comment: "")
        lblTitle.setBody2RegDarkStyle()
        lblPointsApplied.setBody3SemiBoldDarkStyle()
        
        let rightIcon = UIImage(name: "arrow-right-filled")?.withRenderingMode(.alwaysTemplate)
        ivArrowForward.tintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        ivArrowForward.image  = rightIcon
        
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.ivArrowForward.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    func configure(smilesPointsRedeemed: Double, isEnabled: Bool = true, smilesBurntRatio: Double?, primaryPaymentMethodId: Int?) {
        if smilesPointsRedeemed > 0 {
            let smilesPointInAED = "\(smilesPointsRedeemed.formateDisplayString()) " + CurrencyManager.getCurrentCurrency()
            let smilesPoints = ElGrocerUtility.sharedInstance.calculateSmilePointsForAEDs(smilesPointsRedeemed, smilesBurntRatio: smilesBurntRatio)
            let smilesPoint = " (\(smilesPoints) \(localizedString("pay_via_smiles_points", comment: "")))"
            
            self.lblPointsApplied.text =  smilesPointInAED + smilesPoint
            lblTitle.text = localizedString("text_checkout_smiles_points_applied_title", comment: "")
        } else {
            self.lblPointsApplied.text = ""
            lblTitle.text = localizedString("text_checkout_smiles_points_title", comment: "")
        }
    }
    
    @objc func viewTapHandler(_ sender: UITapGestureRecognizer) {
        self.delegate?.smilesPointsView(_didTap: self)
    }
}
