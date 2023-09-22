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
        label.setBody3BoldUpperSecondaryDarkGreenStyle()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var lblFinalAmount: UILabel = {
        let label = UILabel()
        
        label.text = "AED 600.00"
        label.textAlignment = .right
        
        label.setBody3BoldUpperSecondaryDarkGreenStyle()
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
    
    private lazy var lblFreeDelivery: UILabel = {
        let label = UILabel()
        
        label.text = localizedString("txt_free_delivery_for_smile", comment: "")
        label.textAlignment = .center
        label.setCaptionTwoSemiboldYellowStyle()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var freeDeliveryView: UIView = {
        let view = UIView()
        
        view.isHidden = false
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.backgroundColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var freeDeliverySmileImageView: UIImageView = {
        let view = UIImageView()
        
        view.isHidden = false
        view.image = UIImage(name: "SmileFreeDeliverySmilie")
        view.backgroundColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var lblExtraBalanceMessageText: UILabel = {
        let label = UILabel()
        
        label.text = localizedString("", comment: "")
        label.textAlignment = .left
        label.setBody3BoldUpperSecondaryDarkGreenStyle()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private var totalPriceEntryView = BillEntryView(isGreen: false)
    private var serviceFeeEntryView = BillEntryView(isGreen: false)
    private var grandTotalEntryView = BillEntryView(isGreen: false)
    private var priceVarianceView = BillEntryView(isGreen: true)
    private var smilesView = BillEntryView(isGreen: true)
    private var elWalletView = BillEntryView(isGreen: true)
    private var savingsView = BillEntryView(isGreen: true)
    private var extraBalanceView = BillEntryView(isGreen: true)
    private var tabbyRedeemView = BillEntryView(isGreen: true)
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        self.addViews()
        self.setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        self.setUpGradients()
    }
    
    private func addViews() {
        self.addSubview(viewBG)
        viewBG.addSubview(stackView)
        self.addStackViewViews()
        viewBG.addSubview(divider)
        viewBG.addSubview(lblFinalAmountText)
        viewBG.addSubview(lblFinalAmount)
        
        promotionView.addSubview(lblPromotion)
        viewBG.addSubview(promotionView)
    }
    func addStackViewViews() {
        stackView.addArrangedSubview(totalPriceEntryView)
        stackView.addArrangedSubview(serviceFeeEntryView)
        self.stackView.addArrangedSubview(freeDeliveryView)
        self.setFreeDeliveryFeeViewConstraints()
        stackView.addArrangedSubview(grandTotalEntryView)
        self.stackView.addArrangedSubview(savingsView)
        self.stackView.addArrangedSubview(elWalletView)
        self.stackView.addArrangedSubview(smilesView)
    }
    
    func configure(productTotal: Double, serviceFee: Double, total: Double, productSaving: Double, finalTotal: Double, elWalletRedemed: Double, smilesRedemed: Double, promocode: PromoCode?, quantity: Int?, smilesSubscriber: Bool, tabbyRedeem: Double?) {
        stackView.addArrangedSubview(totalPriceEntryView)
        stackView.addArrangedSubview(serviceFeeEntryView)
        
        self.totalPriceEntryView.configure(title: localizedString("total_price_incl_VAT", comment: ""), amount: productTotal)
        self.totalPriceEntryView.setTotalProductsTitle(quantity: quantity ?? 0)
        if smilesSubscriber {
            self.serviceFeeEntryView.configureForFreeServiceFee()
            self.stackView.addArrangedSubview(freeDeliveryView)
            freeDeliveryView.isHidden = false
        }else {
            freeDeliveryView.isHidden = true
            self.serviceFeeEntryView.configure(title: localizedString("service_price", comment: ""), amount: serviceFee)
        }
        
        self.grandTotalEntryView.configure(title: localizedString("grand_total", comment: ""), amount: total)
        self.lblFinalAmount.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: finalTotal)

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
        stackView.addArrangedSubview(grandTotalEntryView)
        
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
        
        if let tabbyRedeem = tabbyRedeem, tabbyRedeem > 0 {
            self.tabbyRedeemView.isHidden = false
            stackView.addArrangedSubview(tabbyRedeemView)
            tabbyRedeemView.configure(title: localizedString("paid_with_tabby", comment: ""), amount: tabbyRedeem, isNegative: true)
        } else {
            self.tabbyRedeemView.isHidden = true
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
        
        self.totalPriceEntryView.trailingAnchor.constraint(equalTo: self.stackView.trailingAnchor, constant: 0).isActive = true
        self.totalPriceEntryView.leadingAnchor.constraint(equalTo: self.stackView.leadingAnchor, constant: 0).isActive = true
        
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
    
    func setFreeDeliveryFeeViewConstraints() {

        self.freeDeliveryView.addSubview(lblFreeDelivery)
        self.freeDeliveryView.addSubview(freeDeliverySmileImageView)
        lblFreeDelivery.centerYAnchor.constraint(equalTo: freeDeliveryView.centerYAnchor).isActive = true
        lblFreeDelivery.centerXAnchor.constraint(equalTo: freeDeliveryView.centerXAnchor, constant: 12).isActive = true
        
        freeDeliverySmileImageView.heightAnchor.constraint(equalToConstant: 12).isActive = true
        freeDeliverySmileImageView.widthAnchor.constraint(equalToConstant: 12).isActive = true
        freeDeliverySmileImageView.trailingAnchor.constraint(equalTo: lblFreeDelivery.leadingAnchor, constant: -5).isActive = true
        freeDeliverySmileImageView.centerYAnchor.constraint(equalTo: lblFreeDelivery.centerYAnchor).isActive = true
        
        freeDeliveryView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -16).isActive = true
        freeDeliveryView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16).isActive = true
        freeDeliveryView.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
//    func setUpGradients () {
//        let greLay = self.freeDeliveryView.setupGradient(height: self.freeDeliveryView.frame.size.height , topColor: UIColor.smileBaseColor().cgColor, bottomColor: UIColor.smileSecondaryColor().cgColor)
//        self.freeDeliveryView.layer.insertSublayer(greLay, at: 0)
//    }
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
    
    func setTitleForBags(bags: Int) {
        let quantityString = "\(ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: String(bags)))"
        self.lblTitle.text = localizedString("screen_order_details_bags_text", comment: "") + " ×" + quantityString
        self.lblTitle.highlight(searchedText: "×\(quantityString)", color: UIColor.disableButtonColor(), size: UIFont.SFProDisplayNormalFont(14))
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
    
    func configureForFreeServiceFee() {
        self.lblTitle.text = localizedString("service_price", comment: "")
        self.lblAmount.text = localizedString("txt_free", comment: "")
        self.lblAmount.textColor = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
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
