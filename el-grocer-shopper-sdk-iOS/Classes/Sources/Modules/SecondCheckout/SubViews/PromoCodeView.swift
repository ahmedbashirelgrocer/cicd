//
//  PromocodeView.swift
//  ElGrocerShopper
//
//  Created by Rashid Khan on 25/08/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

protocol PromocodeDelegate: AnyObject {
    func tap(promocode: String?)
}

class PromocodeView: UIView {

    @IBOutlet weak var viewBG: AWView! {
        didSet {
            viewBG.borderWidth = 1
            viewBG.borderColor = ApplicationTheme.currentTheme.borderLightGrayColor
        }
    }
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPromocode: UILabel! {
        didSet {
            lblPromocode.setBody3RegDarkStyle()
        }
    }
    @IBOutlet weak var ivForwardIcon: UIImageView! {
        didSet {
            ivForwardIcon.image = UIImage(name: sdkManager.isShopperApp ? "arrow-right-filled" : "arrow-right-filled")
        }
    }
    
    private var promocode: String?
    weak var delegate: PromocodeDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
        setupTheme()
    }
    
    func configure(promocode: String, promoCodeValue: Double?, primaryPaymentMethodId: Int?) {
        self.promocode = promocode
        
        if promocode != "" {
            if let promoCodeValue = promoCodeValue, promoCodeValue > 0 {
                let formattedDiscount = (promoCodeValue * -1).formateDisplayString() + " \(localizedString("aed", comment: ""))"
                let promoCodeText = promocode + " (\(formattedDiscount)" + ")"
                
                self.lblPromocode.text = promoCodeText
            } else {
                self.lblPromocode.text = promocode
            }
            self.lblTitle.text = localizedString("text_promocode_and_vouchers", comment: "") + ":"
        } else {
            self.lblPromocode.text = ""
            self.lblTitle.text = localizedString("text_promocode_and_vouchers", comment: "")
        }
    }
    
    @objc func promocodeTapHandler(_ sender: UITapGestureRecognizer) {
        self.delegate?.tap(promocode: promocode)
    }
    
    private func setupViews() {
        self.lblTitle.text = localizedString("text_promocode_and_vouchers", comment: "")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(promocodeTapHandler(_:)))
        self.viewBG.addGestureRecognizer(tapGesture)
        
        let rightIcon = UIImage(name: "arrow-right-filled")?.withRenderingMode(.alwaysTemplate)
        ivForwardIcon.tintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        ivForwardIcon.image  = rightIcon
        
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.ivForwardIcon.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    private func setupTheme() {
        lblTitle.setBody2RegDarkStyle()
        lblPromocode.setBody3SemiBoldDarkStyle()
    }
}
