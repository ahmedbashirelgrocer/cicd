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
    @IBOutlet weak var lblPayUsing: UILabel! {
        didSet {
            lblPayUsing.setCaptionOneBoldDarkStyle()
        }
    }
    @IBOutlet weak var viewBG: AWView!
    @IBOutlet weak var imagePaymentType: UIImageView!
    @IBOutlet weak var lblPaymentTitle: UILabel! {
        didSet {
            lblPaymentTitle.setBody3RegGreenStyle()
        }
    }
    @IBOutlet weak var arrowForward: UIImageView!
    
    private var paymentTypes: [PaymentType] = []
    weak var delegate: PaymentMethodViewDelegate?
    
    override func awakeFromNib() {
        self.viewBG.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(paymentMethodTapHandler(_:))))
        self.lblPayUsing.text = localizedString("pay_using_text", comment: "")
        
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.arrowForward.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    @objc func paymentMethodTapHandler(_ sender: UITapGestureRecognizer) {
        delegate?.tap(on: self, paymentTypes: self.paymentTypes)
    }
    
    func configureImageAndName(paymentOption: PaymentOption?, name: String?, creditCard: CreditCard?) {
        switch paymentOption {
        case .cash:
            self.lblPaymentTitle.textColor = .newBlackColor()
            self.lblPaymentTitle.text = name ?? ""
            self.imagePaymentType.image = UIImage(named: "selectedCashOnDelivery")
        case .card:
            self.lblPaymentTitle.textColor = .newBlackColor()
            self.lblPaymentTitle.text = name ?? ""
            self.imagePaymentType.image = UIImage(named: "selectedCardOnDelivery")
        case .creditCard:
            
            if let creditCard = creditCard {
                if creditCard.cardType == .MASTER_CARD {
                    self.imagePaymentType.image = UIImage(named: "selectedMasterCard")
                }else if creditCard.cardType == .VISA {
                    self.imagePaymentType.image = UIImage(named: "selectedVisaCard")
                }
                self.lblPaymentTitle.textColor = .newBlackColor()
                self.lblPaymentTitle.text = localizedString("lbl_card_ending", comment: "") + creditCard.last4
            }
        case .applePay:
            self.lblPaymentTitle.textColor = .newBlackColor()
            self.lblPaymentTitle.text = name ?? ""
            self.imagePaymentType.image = UIImage(named: "selectedApplePayMethod")
        default:
            self.lblPaymentTitle.textColor = .navigationBarColor()
            self.lblPaymentTitle.text = localizedString("payment_method_title", comment: "")
            self.imagePaymentType.image = UIImage(named: "cardGeneric")
            break
        }
    }
    
    func configure(paymentTypes: [PaymentType], selectedPaymentId: UInt32?, creditCard: CreditCard? ) {
        
        guard paymentTypes.count > 0, let selectedPaymentId = selectedPaymentId else {
            self.lblPaymentTitle.textColor = .navigationBarColor()
            self.lblPaymentTitle.text = localizedString("payment_method_title", comment: "")
            return
        }
        self.paymentTypes = paymentTypes
        let filterPayment = paymentTypes.filter { type in
            (type.id == selectedPaymentId)
        }
        if  selectedPaymentId == PaymentOption.applePay.rawValue {            self.configureImageAndName(paymentOption: .applePay, name:  localizedString("pay_via_Apple_pay", comment: ""), creditCard: nil)
        }else if filterPayment.count > 0 {
            if selectedPaymentId == PaymentOption.creditCard.rawValue {
                configureImageAndName(paymentOption: .creditCard, name: "", creditCard: creditCard)
            }else{
                self.configureImageAndName(paymentOption: filterPayment.first?.getLocalPaymentOption(), name: filterPayment.first?.getLocalizedName(), creditCard: nil)
            }
        }else {
            self.configureImageAndName(paymentOption: PaymentOption.none, name: NSLocalizedString("payment_method_title", comment: ""), creditCard: nil)
        }
       
    }
}
