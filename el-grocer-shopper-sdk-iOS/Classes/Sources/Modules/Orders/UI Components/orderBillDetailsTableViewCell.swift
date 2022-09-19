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
    private var earnSmilesPointView = BillEntryView(isGreen: true)
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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setInitialAppearance()
        addViewsInstackView()
        adjustDividerConstraints()
//        configure()
    }
    
    func setInitialAppearance() {
        self.stackBGView.borderColor = .borderGrayColor()
        self.stackBGView.borderWidth = 1
        self.stackBGView.cornarRadius = 8
    }
    
    func adjustDividerConstraints() {
        dividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        self.dividerView.leadingAnchor.constraint(equalTo: self.billStackView.leadingAnchor, constant: 8).isActive = true
        self.dividerView.trailingAnchor.constraint(equalTo: self.billStackView.trailingAnchor, constant: -8).isActive = true
        
    }
    
    func addViewsInstackView() {
        self.billStackView.addArrangedSubview(self.totalPriceEntryView)
        self.billStackView.addArrangedSubview(self.seriviceFeeView)
        self.billStackView.addArrangedSubview(self.earnSmilesPointView)
        self.billStackView.addArrangedSubview(self.grandToatalView)
        self.billStackView.addArrangedSubview(self.burnElwalletPointsView)
        self.billStackView.addArrangedSubview(self.burnSmilePointsView)
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
        
        
        priceSum = order.totalValue
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
        
        let priceVariance = Double(order.priceVariance ?? "0") ?? 0.00
        
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
        
        let grandTotal = priceSum + serviceFee - priceVariance - discount
        
        if (order.isSmilesUser?.boolValue ?? false) {
            let total = grandTotal - burnSmilePoints
            smileEarn = SmilesManager.getEarnPointsFromAed(total)
        }
        
        priceSum = order.finalBillAmount?.doubleValue ?? 0.00 //grandTotal - discount - burnSmilePoints - burnElwalletPoints
        
        setBillDetails(totalPriceWithVat: totalWithVat, serviceFee: serviceFee, promoTionDiscount: discount, smileEarn: smileEarn, grandTotal: grandTotal, priceVariance: priceVariance, smileBurn: burnSmilePoints, elwalletBurn: burnElwalletPoints, finalBillAmount: priceSum, quantity: summaryCount)
    }
    
    func setBillDetails(totalPriceWithVat: Double, serviceFee: Double, promoTionDiscount: Double, smileEarn: Int, grandTotal: Double, priceVariance: Double, smileBurn: Double, elwalletBurn: Double, finalBillAmount: Double, quantity: Int) {

        self.billStackView.addArrangedSubview(self.totalPriceEntryView)
        self.totalPriceEntryView.configure(title: localizedString("total_price_incl_VAT", comment: ""), amount: totalPriceWithVat.formateDisplayString())
        self.totalPriceEntryView.setTotalProductsTitle(quantity: quantity)
        self.seriviceFeeView.configure(title: localizedString("service_price", comment: ""), amount: serviceFee.formateDisplayString())
        self.billStackView.addArrangedSubview(self.seriviceFeeView)
        if promoTionDiscount > 0 {
            self.billStackView.addArrangedSubview(self.promoDiscountView)
            self.promoDiscountView.isHidden = false
            self.promoDiscountView.configure(title: localizedString("promotion_discount_aed", comment: ""), amount: promoTionDiscount.formateDisplayString(), isNegative: true)
        }else {
            self.promoDiscountView.isHidden = true
        }
        
        if smileEarn > 0 {
            self.earnSmilesPointView.isHidden = false
            self.billStackView.addArrangedSubview(self.earnSmilesPointView)
            self.earnSmilesPointView.configure(title: localizedString("txt_smile_point", comment: ""), amount: String(smileEarn))
        }else {
            self.earnSmilesPointView.isHidden = true
        }
        if priceVariance > 0 {
            self.billStackView.addArrangedSubview(self.priceVarianceView)
            self.grandToatalView.configure(title: localizedString("grand_total", comment: ""), amount: grandTotal.formateDisplayString(), isNegative: true)
        }else {
            self.priceVarianceView.isHidden = true
        }
        self.billStackView.addArrangedSubview(self.grandToatalView)
        self.grandToatalView.configure(title: localizedString("grand_total", comment: ""), amount: grandTotal.formateDisplayString())
        
        if elwalletBurn > 0 {
            self.billStackView.addArrangedSubview(self.burnElwalletPointsView)
            self.burnElwalletPointsView.isHidden = false
            self.burnElwalletPointsView.configure(title: localizedString("elwallet_credit_applied", comment: ""), amount: elwalletBurn.formateDisplayString(), isNegative: true)
        }else {
            self.burnElwalletPointsView.isHidden = true
        }
        
        if smileBurn > 0 {
            self.billStackView.addArrangedSubview(self.burnSmilePointsView)
            self.burnSmilePointsView.isHidden = false
            self.burnSmilePointsView.configure(title: localizedString("smiles_points_applied", comment: ""), amount: smileBurn.formateDisplayString(), isNegative: true)
        }else {
            self.burnSmilePointsView.isHidden = true
        }
        self.billStackView.addArrangedSubview(self.dividerView)
        self.billStackView.addArrangedSubview(self.finalBillAmountView)
        self.finalBillAmountView.configure(title: localizedString("total_bill_amount", comment: ""), amount: finalBillAmount.formateDisplayString())
        self.finalBillAmountView.setFinalBillAmountFont()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
