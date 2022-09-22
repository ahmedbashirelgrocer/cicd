//
//  CheckoutButton.swift
//  ElGrocerShopper
//
//  Created by Rashid Khan on 26/08/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

class CheckoutButtonView: AWView {
    @IBOutlet weak var lblPoints: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var buttonCheckout: AWView!
    @IBOutlet weak var applePayStackView: UIStackView!
    @IBOutlet weak var lblOrderText: UILabel!
    @IBOutlet weak var ivForwardIcon: UIImageView!
    @IBOutlet weak var viewDiscountWrapper: UIView!
    @IBOutlet var lblAEDSavedBottomBGView: UIView!
    @IBOutlet var lblEarnPointsBGView: UIView!
    @IBOutlet weak var lblEarnSmilesPoints: UILabel! {
        didSet {
            lblEarnSmilesPoints.setCaptionTwoSemiboldYellowStyle()
        }
    }
    @IBOutlet weak var lblAEDSaved: UILabel! {
        didSet {
            lblAEDSaved.setCaptionTwoSemiboldYellowStyle()
        }
    }
    var checkOutClicked : (() -> Void)?
    
    
    
    override func awakeFromNib() {
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.ivForwardIcon.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.viewDiscountWrapper.roundWithShadow(corners: [.layerMinXMinYCorner, .layerMaxXMaxYCorner], radius: 8)
        } else {
            self.viewDiscountWrapper.roundWithShadow(corners: [.layerMaxXMinYCorner, .layerMinXMaxYCorner], radius: 8)
        }

        self.roundTopWithTopShadow(radius: 8)
        self.viewDiscountWrapper.layer.masksToBounds = true
    }
    
    func configure(paymentOption: PaymentOption, points: String, amount: String, aedSaved: String, earnSmilePoints: Int, promoCode: PromoCode?,isSmileOn: Bool) {
        self.buttonCheckout.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkoutButtonTap(_ :))))
        
        var totalSavedAED: Double = 0.00
        var stringAedSavedToConvert = aedSaved
        self.setPointsAndAmount(points: points, amount: amount)
        if stringAedSavedToConvert.elementsEqual("") {
            stringAedSavedToConvert = "0.00"
        }
        if let promoValue = Double(promoCode?.value ?? 0) as? Double ,let productSavings = Double(stringAedSavedToConvert) {
            let total = promoValue + productSavings
            if total > 0 {
                totalSavedAED = total
            }
        }
        
        self.setSavedAmountAndEarnSmilePoints(savedAed: totalSavedAED, earnSmilePoints: earnSmilePoints, paymentOption: paymentOption, isSmileTrue: isSmileOn)
        switch paymentOption {
            case .cash, .card, .creditCard, .smilePoints, .voucher, .PromoCode:
            self.enableButton(isApplePay: false)
            break
        case .applePay:
            self.enableButton(isApplePay: true)
            break
        case .none:
            disableButton()
            break
        }
    }
    
    private func setPointsAndAmount(points: String, amount: String)  {
        self.lblPoints.text = localizedString("or_label_text", comment: "") + " " + points + " " + localizedString("pay_via_smiles_points", comment: "")
        self.lblAmount.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: Double(amount) ?? 0.00)//localizedString("aed", comment: "") + " " + amount
    }
    private func setSavedAmountAndEarnSmilePoints(savedAed: Double, earnSmilePoints: Int, paymentOption: PaymentOption, isSmileTrue: Bool) {
        
        if paymentOption == .none ||  isSmileTrue {
            self.lblEarnPointsBGView.visibility = .goneX
        }else {
            if earnSmilePoints > 0 {
                self.lblEarnPointsBGView.visibility = .visible
                self.lblEarnSmilesPoints.text = localizedString("txt_earn", comment: "") + " +" + String(earnSmilePoints) + " " + localizedString("pay_via_smiles_points", comment: "")
            }else {
                self.lblEarnPointsBGView.visibility = .goneX
            }
            
        }
        
        if savedAed > 0 {
            self.lblAEDSavedBottomBGView.visibility = .visible
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                self.lblAEDSaved.text = localizedString("txt_Saved", comment: "") + " " + ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: savedAed) 
            }else {
                self.lblAEDSaved.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: savedAed) + " " + localizedString("txt_Saved", comment: "")
            }
            
        }else {
            self.lblAEDSavedBottomBGView.visibility = .goneX
        }
        
    }
    
    @objc func checkoutButtonTap(_ sender: UITapGestureRecognizer) {
        print("Implement ME <<>> checkout button tapped ... ")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    

    private func disableButton() {
        self.buttonCheckout.backgroundColor = UIColor.disableButtonColor()
        self.buttonCheckout.isUserInteractionEnabled = false
        self.applePayStackView.isHidden = true
        
    }
    
    private func enableButton(isApplePay: Bool) {
        self.buttonCheckout.isUserInteractionEnabled = true
        self.buttonCheckout.backgroundColor = isApplePay ? UIColor.black : UIColor.navigationBarColor()
        
        self.lblPoints.isHidden = isApplePay
        self.lblAmount.isHidden = isApplePay
        self.applePayStackView.isHidden = !isApplePay
        self.lblOrderText.isHidden = isApplePay
        self.ivForwardIcon.isHidden = isApplePay
    }
    
    @IBAction func checkOutButtonClicked(_ sender: Any) {
        if let closure = self.checkOutClicked {
            closure()
        }
    }
    
    
}


