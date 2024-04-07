//
//  CheckoutElWalletView.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 05/12/2023.
//

import UIKit

protocol CheckoutElWalletViewDelegate: AnyObject {
    func elWalletView(_didTap view: CheckoutElWalletView)
}

class CheckoutElWalletView: UIView {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblWalletRedeemAmount: UILabel!
    @IBOutlet weak var ivForwardIcon: UIImageView!
    @IBOutlet weak var viewBG: AWView!{
        didSet {
            viewBG.borderWidth = 1
            viewBG.borderColor = ApplicationTheme.currentTheme.borderLightGrayColor
        }
    }
    
    var delegate: CheckoutElWalletViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
        setupTheme()
    }
    
    func configure(redeemAmount: Double, primaryPaymentMethodId: Int?) {
        if redeemAmount > 0 {
            lblWalletRedeemAmount.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: redeemAmount)
            lblTitle.text = localizedString("text_checkout_el_wallet_points_applied_title", comment: "")
        } else {
            lblWalletRedeemAmount.text = ""
            lblTitle.text = localizedString("text_checkout_el_wallet_points_title", comment: "")
        }
    }
    
    @objc func viewTapHandler(_ sender: UITapGestureRecognizer) {
        self.delegate?.elWalletView(_didTap: self)
    }
}

fileprivate extension CheckoutElWalletView {
    
    func setupViews() {
        viewBG.isUserInteractionEnabled = true
        lblTitle.text = localizedString("text_checkout_el_wallet_points_applied_title", comment: "")
        viewBG.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapHandler)))
        
        let rightIcon = UIImage(name: "arrow-right-filled")?.withRenderingMode(.alwaysTemplate)
        ivForwardIcon.tintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        ivForwardIcon.image  = rightIcon
        
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.ivForwardIcon.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    func setupTheme() {
        lblTitle.setBody2RegDarkStyle()
        lblWalletRedeemAmount.setBody3SemiBoldDarkStyle()
    }
}
