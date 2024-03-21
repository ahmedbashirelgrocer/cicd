//
//  PaymentMethodView.swift
//  ElGrocerShopper
//
//  Created by Rashid Khan on 25/08/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

protocol PaymentMethodViewDelegate: AnyObject {
    func tap(on view: PaymentMethodView, paymentTypes: [PaymentType])
}

class PaymentMethodView: UIView {
    @IBOutlet weak var viewBG: AWView! {
        didSet {
            viewBG.borderWidth = 1
            viewBG.borderColor = ApplicationTheme.currentTheme.borderLightGrayColor
        }
    }
    @IBOutlet weak var imagePaymentType: UIImageView!
    @IBOutlet weak var lblPaymentMethod: UILabel!
    @IBOutlet weak var arrowForward: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    private var paymentTypes: [PaymentType] = []
    weak var delegate: PaymentMethodViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
        setupTheme()
    }
    
    @objc func paymentMethodTapHandler(_ sender: UITapGestureRecognizer) {
        delegate?.tap(on: self, paymentTypes: self.paymentTypes)
    }
    
    func configure(paymentTypes: [PaymentType], selectedPaymentId: UInt32?, creditCard: CreditCard? ) {
        self.paymentTypes = paymentTypes
        
        self.imagePaymentType.image = self.iconForPayment(selectedPaymentId, creditCard: creditCard)
        self.lblPaymentMethod.text = self.nameForPayment(selectedPaymentId, creditCard: creditCard)
        
        self.lblTitle.text = selectedPaymentId != nil
            ? localizedString("text_payment", comment: "") + ":"
            : localizedString("payment_method_title", comment: "")
    }
}

fileprivate extension PaymentMethodView {
    func setupViews() {
        lblTitle.text = localizedString("payment_method_title", comment: "")
        
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            arrowForward.transform = CGAffineTransform(scaleX: -1, y: 1)
            lblPaymentMethod.textAlignment = .right
            lblTitle.textAlignment = .right
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(paymentMethodTapHandler(_:)))
        self.viewBG.addGestureRecognizer(tapGesture)
    }
    
    func setupTheme() {
        lblTitle.setBody2RegDarkStyle()
        lblPaymentMethod.setBody3SemiBoldDarkStyle()
        
        let rightIcon = UIImage(name: "arrow-right-filled")?.withRenderingMode(.alwaysTemplate)
        arrowForward.tintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        arrowForward.image  = rightIcon
    }
    
    func iconForPayment(_ paymentId: UInt32?, creditCard: CreditCard?) -> UIImage? {
        guard let selectedPaymentId = paymentId, let paymentOption = PaymentOption(rawValue: selectedPaymentId) else {
            return UIImage(name: "ic_payment_method")
        }

        switch paymentOption {
            case .cash:         return UIImage(name: "selectedCashOnDelivery")
            case .card:         return UIImage(name: "selectedCardOnDelivery")
            case .tabby:        return UIImage(name: "ic_tabby_grey_bg")
            case .applePay:     return UIImage(name: "payWithApple")
            case .creditCard:   return creditCardIcon()
            case .none:         return UIImage(name: "ic_payment_method")
            
            // Secondary Payments
            case .smilePoints, .voucher, .PromoCode: return nil
        }
        
        func creditCardIcon() -> UIImage? {
            
            if let creditCard = creditCard {
                if creditCard.cardType == .MASTER_CARD {
                    return UIImage(name: "selectedMasterCard")
                } else if creditCard.cardType == .VISA {
                    return UIImage(name: "ic_visa_grey_bg")
                }
            } else {
                return UIImage(name: "payWithApple")
            }
            return nil
        }
    }
    
    func nameForPayment(_ paymentId: UInt32?, creditCard: CreditCard?) -> String {
        guard let selectedPaymentId = paymentId, let paymentOption = PaymentOption(rawValue: selectedPaymentId) else { return "" }
        
        if let selectedPaymentType = paymentTypes.first(where: { $0.id == selectedPaymentId }) {
            //in edit order for apple pay server still sends payment id 3(online payment) with credit card object as nil
            if paymentOption == .creditCard && creditCard == nil {
                return localizedString("pay_via_Apple_pay", comment: "")
            }
            if paymentOption == .creditCard {
                return localizedString("lbl_card_ending", comment: "") + (creditCard?.last4 ?? "")
            }
            
            return selectedPaymentType.getLocalizedName()
        }
        
        if paymentOption == .applePay { return localizedString("pay_via_Apple_pay", comment: "") }
        
        return ""
    }
}
