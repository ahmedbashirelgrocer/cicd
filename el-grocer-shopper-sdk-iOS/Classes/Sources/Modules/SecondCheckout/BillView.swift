//
//  BillView.swift
//  ElGrocerShopper
//
//  Created by Rashid Khan on 26/08/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

class BillView: UIView {
    private lazy var viewBG: AWView = {
        let view = AWView()
        
        view.backgroundColor = .white
        view.cornarRadius = 8.0
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.backgroundColor = .clear
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var divider: UIView = {
        let view = UIView()
        
        view.backgroundColor = UIColor.separatorColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var lblFinalAmountText: UILabel = {
        let label = UILabel()
        
        label.text = localizedString("amount_to_pay", comment: "")
        label.textAlignment = .left
        label.setBody3BoldUpperLimitedStockStyle()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var lblFinalAmount: UILabel = {
        let label = UILabel()
        
        label.text = "AED 600.00"
        label.textAlignment = .right
        
        label.setBody3BoldUpperLimitedStockStyle()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var lblPromotion: UILabel = {
        let label = UILabel()
        
        label.text = "AED 30.00 SAVED!"
        label.textAlignment = .center
        label.setCaptionTwoSemiboldYellowStyle()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var promotionView: UIView = {
        let view = UIView()
        
        view.isHidden = true
        view.layer.cornerRadius = 10
        view.backgroundColor = UIColor.promotionRedColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var totalPriceEntryView = BillEntryView(isGreen: false)
    private var serviceFeeEntryView = BillEntryView(isGreen: false)
    private var grandTotalEntryView = BillEntryView(isGreen: false)
    private var priceVarianceView = BillEntryView(isGreen: true)
    private var smilesView = BillEntryView(isGreen: true)
    private var elWalletView = BillEntryView(isGreen: true)
    private var savingsView = BillEntryView(isGreen: true)
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        self.addViews()
        self.setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews() {
        self.addSubview(viewBG)
        viewBG.addSubview(stackView)
        
        viewBG.addSubview(divider)
        viewBG.addSubview(lblFinalAmountText)
        viewBG.addSubview(lblFinalAmount)
        
        promotionView.addSubview(lblPromotion)
        viewBG.addSubview(promotionView)
    }
    
    func configure(productTotal: Double, serviceFee: Double, total: Double, productSaving: Double, finalTotal: Double, elWalletRedemed: Double, smilesRedemed: Double, promocode: PromoCode?, quantity: Int?,message: String?, priceVariance: Double?) {
        stackView.addArrangedSubview(totalPriceEntryView)
        stackView.addArrangedSubview(serviceFeeEntryView)
        
        self.totalPriceEntryView.configure(title: localizedString("total_price_incl_VAT", comment: ""), amount: productTotal)
        self.totalPriceEntryView.setTotalProductsTitle(quantity: quantity ?? 0)
        self.serviceFeeEntryView.configure(title: localizedString("service_price", comment: ""), amount: serviceFee)
        self.grandTotalEntryView.configure(title: localizedString("grand_total", comment: ""), amount: total)
        self.lblFinalAmount.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: finalTotal)
//        self.lblFinalAmount.text = CurrencyManager.getCurrentCurrency() + " " + finalTotal
        
        
        if let promoValue = promocode?.value {
            self.stackView.addArrangedSubview(savingsView)
            if promoValue == 0 {
                savingsView.isHidden = true
            }else {
                savingsView.isHidden = false
                savingsView.configure(title: localizedString("discount_text", comment: ""), amount: promoValue,isNegative: true)
            }
        }else {
            savingsView.isHidden = true
        }
        
        if  productSaving > 0 {
            self.promotionView.visibility = .visible
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                self.lblPromotion.text =  localizedString("txt_Saved", comment: "") + " " + ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: productSaving)
            }else {
                self.lblPromotion.text =  ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: productSaving) + " " + localizedString("txt_Saved", comment: "")
            }
        }else {
            self.promotionView.visibility = .gone
            self.lblPromotion.text =  ""
        }
        if let priceVariance = priceVariance, priceVariance != 0 {
            self.stackView.addArrangedSubview(priceVarianceView)
            self.priceVarianceView.isHidden = false
            priceVarianceView.configure(title: localizedString("Card_Price_Variance_Title", comment: ""), amount: priceVariance, isNegative: false)
        }else {
            self.priceVarianceView.isHidden = true
        }
        stackView.addArrangedSubview(grandTotalEntryView)
        
        if elWalletRedemed > 0 {
            self.stackView.addArrangedSubview(elWalletView)
            self.elWalletView.isHidden = false
            elWalletView.configure(title: localizedString("elwallet_credit_applied", comment: ""), amount: elWalletRedemed, isNegative: true)
        }else {
            self.elWalletView.isHidden = true
        }
        
        if smilesRedemed > 0 {
            self.stackView.addArrangedSubview(smilesView)
            self.smilesView.isHidden = false
            smilesView.configure(title: localizedString("smiles_points_applied", comment: ""), amount: smilesRedemed, isNegative: true)
        }else {
            self.smilesView.isHidden = true
        }
        
        if let message = message {
            
        }else {
            
        }
            
    }
    
    private func setupConstraint() {
        
        viewBG.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        viewBG.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        viewBG.topAnchor.constraint(equalTo: self.topAnchor, constant: 8 ).isActive = true
        viewBG.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
        
        stackView.leadingAnchor.constraint(equalTo: viewBG.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: viewBG.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: viewBG.topAnchor).isActive = true
        
        divider.leadingAnchor.constraint(equalTo: viewBG.leadingAnchor, constant: 16).isActive = true
        divider.trailingAnchor.constraint(equalTo: viewBG.trailingAnchor, constant: -16).isActive = true
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        divider.topAnchor.constraint(equalTo: stackView.bottomAnchor).isActive = true
        
        lblFinalAmountText.leadingAnchor.constraint(equalTo: viewBG.leadingAnchor, constant: 16).isActive = true
        lblFinalAmountText.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 16).isActive = true
        
        lblFinalAmount.trailingAnchor.constraint(equalTo: viewBG.trailingAnchor, constant: -16).isActive = true
        lblFinalAmount.centerYAnchor.constraint(equalTo: lblFinalAmountText.centerYAnchor).isActive = true
        
        lblPromotion.leadingAnchor.constraint(equalTo: promotionView.leadingAnchor, constant: 8).isActive = true
        lblPromotion.trailingAnchor.constraint(equalTo: promotionView.trailingAnchor, constant: -8).isActive = true
        lblPromotion.centerYAnchor.constraint(equalTo: promotionView.centerYAnchor).isActive = true
        
        promotionView.trailingAnchor.constraint(equalTo: viewBG.trailingAnchor, constant: -16).isActive = true
        promotionView.topAnchor.constraint(equalTo: lblFinalAmount.bottomAnchor, constant: 12).isActive = true
        promotionView.bottomAnchor.constraint(equalTo: viewBG.bottomAnchor, constant: -16).isActive = true
        promotionView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
    }
}

class BillEntryView: UIView {
    private lazy var viewBG: AWView = {
        let view = AWView()
        
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var lblTitle: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .left
        label.setBody3RegDarkStyle()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var lblAmount: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .right
        label.setBody3RegDarkStyle()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    init(frame: CGRect = .zero, isGreen: Bool) {
        super.init(frame: frame)
        
        if isGreen {
            self.lblTitle.setBody3RegGreenStyle()
            self.lblAmount.setBody3RegGreenStyle()
        } else {
            self.lblTitle.setBody3RegDarkStyle()
            self.lblAmount.setBody3RegDarkStyle()
        }
        
        
        self.addViews()
        self.setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews() {
        self.addSubview(viewBG)
        viewBG.addSubview(lblTitle)
        viewBG.addSubview(lblAmount)
    }
    
    private func setupConstraint() {
        self.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        viewBG.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        viewBG.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
        viewBG.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        viewBG.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        lblTitle.leadingAnchor.constraint(equalTo: viewBG.leadingAnchor, constant: 16).isActive = true
        lblTitle.centerYAnchor.constraint(equalTo: viewBG.centerYAnchor).isActive = true

        lblAmount.trailingAnchor.constraint(equalTo: viewBG.trailingAnchor, constant: -16).isActive = true
        lblAmount.centerYAnchor.constraint(equalTo: viewBG.centerYAnchor).isActive = true
    }
    
    func setTotalProductsTitle(quantity: Int) {
        let quantityString = ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: String(quantity))
        self.lblTitle.text = localizedString("total_price_incl_VAT", comment: "") + " " + quantityString + " " + (quantity == 1 ? localizedString("shopping_basket_items_count_singular", comment: "") : localizedString("shopping_basket_items_count_plural", comment: ""))
        self.lblTitle.highlight(searchedText: quantityString + " " + (quantity == 1 ? localizedString("shopping_basket_items_count_singular", comment: "") : localizedString("shopping_basket_items_count_plural", comment: "")), color: UIColor.disableButtonColor(), size: UIFont.SFProDisplayNormalFont(14))
    }
    
    func setFinalBillAmountFont() {
        self.lblTitle.font = UIFont.SFProDisplayBoldFont(14)
        self.lblAmount.font = UIFont.SFProDisplayBoldFont(14)
    }

    func configureForPoints(title: String, amount: Int) {
        self.lblTitle.text = title
        let amountString = Double(amount).formateDisplayString()
        self.lblAmount.text = ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: amountString)
    }
    
    func configure(title: String, amount: Double, isNegative: Bool = false) {
        self.lblTitle.text = title
        let initialString = CurrencyManager.getCurrentCurrency() + " "
        var finalString = ""
        if isNegative {
            finalString = "-" + (amount.formateDisplayString() == "" ? "0.00" : amount.formateDisplayString())
        }else {
            finalString = (amount.formateDisplayString() == "" ? "0.00" : amount.formateDisplayString())
        }
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            if isNegative {
                self.lblAmount.text = "-" +  ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: amount)
            }else {
                self.lblAmount.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: amount)
            }
        }else {
            self.lblAmount.text = initialString + finalString
        }
    }
}
