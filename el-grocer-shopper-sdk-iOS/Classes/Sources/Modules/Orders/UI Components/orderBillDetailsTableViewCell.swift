//
//  orderBillDetailsTableViewCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 17/09/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

class orderBillDetailsTableViewCell: UITableViewCell {

    @IBOutlet var stackBGView: AWView!
    @IBOutlet var billStackView: UIStackView!
    private var totalPriceEntryView = BillEntryView(isGreen: false)
    private var seriviceFeeView = BillEntryView(isGreen: false)
    private var promoDiscountView = BillEntryView(isGreen: true)
    private var grandToatalView = BillEntryView(isGreen: false)
    private var priceVarianceView = BillEntryView(isGreen: true)
    private var burnSmilePointsView = BillEntryView(isGreen: true)
    private var burnElwalletPointsView = BillEntryView(isGreen: true)
    private var finalBillAmountView = BillEntryView(isGreen: true)
    private lazy var dividerView: UIView = {
        let view = UIView()
        
        view.backgroundColor = UIColor.separatorColor()
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
    
    private lazy var superFreeDeliveryView: UIView = {
        let view = UIView()
        
        view.isHidden = false
        view.backgroundColor = UIColor.navigationBarWhiteColor()
        view.translatesAutoresizingMaskIntoConstraints = false
 
        return view
    }()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setInitialAppearance()
        addViewsInstackView()
        adjustDividerConstraints()
//        configure()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
//        setUpGradients()
    }
//    func setUpGradients () {
//        let greLay = self.setupGradient(height: 20 , topColor: UIColor.smileBaseColor().cgColor, bottomColor: UIColor.smileSecondaryColor().cgColor)
//        self.freeDeliveryView.layer.insertSublayer(greLay, at: 0)
//    }
    
    func setInitialAppearance() {
        self.stackBGView.borderColor = .borderGrayColor()
        self.stackBGView.borderWidth = 1
        self.stackBGView.cornarRadius = 8
    }
    
    func adjustDividerConstraints() {
        self.totalPriceEntryView.trailingAnchor.constraint(equalTo: self.billStackView.trailingAnchor, constant: 0).isActive = true
        self.totalPriceEntryView.leadingAnchor.constraint(equalTo: self.billStackView.leadingAnchor, constant: 0).isActive = true

        self.seriviceFeeView.trailingAnchor.constraint(equalTo: self.billStackView.trailingAnchor, constant: 0).isActive = true
        self.seriviceFeeView.leadingAnchor.constraint(equalTo: self.billStackView.leadingAnchor, constant: 0).isActive = true

        self.grandToatalView.trailingAnchor.constraint(equalTo: self.billStackView.trailingAnchor, constant: 0).isActive = true
        self.grandToatalView.leadingAnchor.constraint(equalTo: self.billStackView.leadingAnchor, constant: 0).isActive = true

        self.promoDiscountView.trailingAnchor.constraint(equalTo: self.billStackView.trailingAnchor, constant: 0).isActive = true
        self.promoDiscountView.leadingAnchor.constraint(equalTo: self.billStackView.leadingAnchor, constant: 0).isActive = true

        self.burnSmilePointsView.trailingAnchor.constraint(equalTo: self.billStackView.trailingAnchor, constant: 0).isActive = true
        self.burnSmilePointsView.leadingAnchor.constraint(equalTo: self.billStackView.leadingAnchor, constant: 0).isActive = true

        self.burnElwalletPointsView.trailingAnchor.constraint(equalTo: self.billStackView.trailingAnchor, constant: 0).isActive = true
        self.burnElwalletPointsView.leadingAnchor.constraint(equalTo: self.billStackView.leadingAnchor, constant: 0).isActive = true

        self.priceVarianceView.trailingAnchor.constraint(equalTo: self.billStackView.trailingAnchor, constant: 0).isActive = true
        self.priceVarianceView.leadingAnchor.constraint(equalTo: self.billStackView.leadingAnchor, constant: 0).isActive = true

        self.finalBillAmountView.trailingAnchor.constraint(equalTo: self.billStackView.trailingAnchor, constant: 0).isActive = true
        self.finalBillAmountView.leadingAnchor.constraint(equalTo: self.billStackView.leadingAnchor, constant: 0).isActive = true
        
        dividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        self.dividerView.leadingAnchor.constraint(equalTo: self.billStackView.leadingAnchor, constant: 8).isActive = true
        self.dividerView.trailingAnchor.constraint(equalTo: self.billStackView.trailingAnchor, constant: -8).isActive = true
        
        self.setFreeDeliveryFeeViewConstraints()
        
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

        freeDeliveryView.trailingAnchor.constraint(equalTo: superFreeDeliveryView.trailingAnchor, constant: -16).isActive = true
        freeDeliveryView.leadingAnchor.constraint(equalTo: superFreeDeliveryView.leadingAnchor, constant: 16).isActive = true
        freeDeliveryView.topAnchor.constraint(equalTo: superFreeDeliveryView.topAnchor, constant: 0).isActive = true
        freeDeliveryView.bottomAnchor.constraint(equalTo: superFreeDeliveryView.bottomAnchor, constant: 0).isActive = true
        freeDeliveryView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
    }
    
    func addViewsInstackView() {
        self.billStackView.addArrangedSubview(self.totalPriceEntryView)
        self.billStackView.addArrangedSubview(self.seriviceFeeView)
        self.freeDeliveryView.addSubview(lblFreeDelivery)
        self.superFreeDeliveryView.addSubview(freeDeliveryView)
        self.billStackView.addArrangedSubview(self.superFreeDeliveryView)
        self.setFreeDeliveryFeeViewConstraints()
        self.billStackView.addArrangedSubview(self.grandToatalView)
        self.billStackView.addArrangedSubview(self.promoDiscountView)
        self.billStackView.addArrangedSubview(self.burnElwalletPointsView)
        self.billStackView.addArrangedSubview(self.burnSmilePointsView)
        self.billStackView.addArrangedSubview(self.priceVarianceView)
        self.billStackView.addArrangedSubview(self.dividerView)
        self.billStackView.addArrangedSubview(self.finalBillAmountView)
    }
    
    func configureBillDetails(order: Order, orderController: OrderDetailsViewController) {
        
        var totalWithVat = 0.00
        var summaryCount = 0
        var priceSum = 0.00
        var discount = 0.00
        var burnSmilePoints = 0.00
        var burnElwalletPoints = 0.00
        var smileEarn: Int = 0
        
        
        priceSum = order.produuctsTotal
        summaryCount = Int(order.totalProducts)
//        for product in orderController.orderProducts {
//
//            let item = orderController.shoppingItemForProduct(product)
//            if let notNilItem = item {
//                if notNilItem.wasInShop.boolValue == true{
//                    summaryCount += notNilItem.count.intValue
//
//                    if product.promoPrice?.intValue == 0 || !(product.promotion?.boolValue ?? false) {
//                        priceSum += product.price.doubleValue * notNilItem.count.doubleValue
//                    }else{
//                        priceSum += product.promoPrice!.doubleValue * notNilItem.count.doubleValue
//                    }
//
//                }
//            }
//        }
        totalWithVat = priceSum
        let serviceFee = order.serviceFee?.doubleValue ?? 0.0
//        let serviceFee = ElGrocerUtility.sharedInstance.getFinalServiceFee(currentGrocery: orderController.order.grocery, totalPrice: priceSum)
        
        let priceVariance = order.priceVariance?.doubleValue ?? 0.00
        
        if let orderPayments = order.orderPayments {
            for payment in orderPayments {
                let amount = payment["amount"] as? NSNumber ?? NSNumber(0)
                let paymentTypeId = payment["payment_type_id"] as? Int
                
                if (paymentTypeId ?? 0) == 4 {
                    burnSmilePoints = amount.doubleValue
                }else if (paymentTypeId ?? 0) == 5 {
                    burnElwalletPoints = amount.doubleValue
                }else if (paymentTypeId ?? 0) == 6 {
                    discount = amount.doubleValue
                }
            }
        }
        let grandTotal = order.totalValue//priceSum + serviceFee - priceVariance - discount
        //comenting for now because smile earn logic is shifted to backend
//        if (order.isSmilesUser?.boolValue ?? false) {
//            let total = grandTotal - burnSmilePoints
//            smileEarn = SmilesManager.getEarnPointsFromAed(total)
//        }
        smileEarn = order.smileEarn?.intValue ?? 0
        priceSum = order.finalBillAmount?.doubleValue ?? 0.00 //grandTotal - discount - burnSmilePoints - burnElwalletPoints
        
        setBillDetails(totalPriceWithVat: totalWithVat, serviceFee: serviceFee, promoTionDiscount: discount, smileEarn: smileEarn, grandTotal: grandTotal, priceVariance: priceVariance, smileBurn: burnSmilePoints, elwalletBurn: burnElwalletPoints, finalBillAmount: priceSum, quantity: summaryCount, smilesSubscriber: order.foodSubscriptionStatus?.boolValue ?? false)
    }
    
    func setBillDetails(totalPriceWithVat: Double, serviceFee: Double, promoTionDiscount: Double, smileEarn: Int, grandTotal: Double, priceVariance: Double, smileBurn: Double, elwalletBurn: Double, finalBillAmount: Double, quantity: Int, smilesSubscriber: Bool) {

        self.billStackView.addArrangedSubview(self.totalPriceEntryView)
        self.totalPriceEntryView.configure(title: localizedString("total_price_incl_VAT", comment: ""), amount: totalPriceWithVat)
        self.totalPriceEntryView.setTotalProductsTitle(quantity: quantity)
        if smilesSubscriber {
            self.billStackView.addArrangedSubview(self.seriviceFeeView)
            self.seriviceFeeView.configureForFreeServiceFee()
            self.billStackView.addArrangedSubview(superFreeDeliveryView)
            self.superFreeDeliveryView.isHidden = false
        }else {
            self.billStackView.addArrangedSubview(self.seriviceFeeView)
            self.seriviceFeeView.configure(title: localizedString("service_price", comment: ""), amount: serviceFee)
            self.superFreeDeliveryView.isHidden = true
        }
        self.billStackView.addArrangedSubview(self.grandToatalView)
        self.grandToatalView.configure(title: localizedString("grand_total", comment: ""), amount: grandTotal)
        
        if promoTionDiscount > 0 {
            self.billStackView.addArrangedSubview(self.promoDiscountView)
            self.promoDiscountView.isHidden = false
            self.promoDiscountView.configure(title: localizedString("promotion_discount_aed", comment: ""), amount: promoTionDiscount, isNegative: true)
        }else {
            self.promoDiscountView.isHidden = true
        }
        
        if elwalletBurn > 0 {
            self.billStackView.addArrangedSubview(self.burnElwalletPointsView)
            self.burnElwalletPointsView.isHidden = false
            self.burnElwalletPointsView.configure(title: localizedString("elwallet_credit_applied", comment: ""), amount: elwalletBurn, isNegative: true)
        }else {
            self.burnElwalletPointsView.isHidden = true
        }
        
        if smileBurn > 0 {
            self.billStackView.addArrangedSubview(self.burnSmilePointsView)
            self.burnSmilePointsView.isHidden = false
            self.burnSmilePointsView.configure(title: localizedString("smiles_points_applied", comment: ""), amount: smileBurn, isNegative: true)
        }else {
            self.burnSmilePointsView.isHidden = true
        }
        if priceVariance != 0 {
            self.priceVarianceView.isHidden = false
            self.billStackView.addArrangedSubview(self.priceVarianceView)
            self.priceVarianceView.configure(title: localizedString("Card_Price_Variance_Title", comment: ""), amount: priceVariance, isNegative: false)
        }else {
            self.priceVarianceView.isHidden = true
        }
        self.billStackView.addArrangedSubview(self.dividerView)
        self.billStackView.addArrangedSubview(self.finalBillAmountView)
        self.finalBillAmountView.configure(title: localizedString("total_bill_amount", comment: ""), amount: finalBillAmount)
        self.finalBillAmountView.setFinalBillAmountFont()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
