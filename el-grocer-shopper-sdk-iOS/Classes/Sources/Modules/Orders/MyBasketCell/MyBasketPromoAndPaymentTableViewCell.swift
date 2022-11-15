//
//  MyBasketPromoAndPaymentTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 01/11/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
import NBBottomSheet
class MyBasketPromoAndPaymentTableViewCell: UITableViewCell {
    
    @IBOutlet var paymentViewHeight: NSLayoutConstraint!
    //    var creditCardA : [CreditCard] = []
//    var selectedCreditCard: CreditCard?
    @IBOutlet var lblpromoCodeTopAnchor: NSLayoutConstraint!
    @IBOutlet var lblpriceTopAnchor: NSLayoutConstraint!
    var promoRefreshed: ((_ isAdded : Bool)->Void)?
    @IBOutlet var imagePayment: UIImageView!
    @IBOutlet var lblPaymentType: UILabel!
    @IBOutlet var lblPaymentMethod: UILabel!
    @IBOutlet var txtCvv: UITextField! {
        didSet{
            self.txtCvv.attributedPlaceholder = NSAttributedString.init(string: self.txtCvv.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.textViewPlaceHolderColor()])
        }
        
    }
    @IBOutlet var creditCardSuperBGView: AWView!
    @IBOutlet var creditCardBGView: AWView!
    @IBOutlet var cvvWidth: NSLayoutConstraint!
    @IBOutlet var btnChange: AWButton!
    @IBOutlet var lblPaymentErrorMsg: UILabel!
    @IBOutlet var billViewHeight: NSLayoutConstraint!
    @IBOutlet var spaceFromErrorLbl: NSLayoutConstraint!
    
    // promo code
    @IBOutlet var promoView: AWView!
    @IBOutlet var btnApplyPromo: AWButton!
    @IBOutlet var promoCallActivity: UIActivityIndicatorView!
    @IBOutlet var txtPromo: UITextField! {
        didSet{
            txtPromo.placeholder = localizedString("enter_promo_code", comment: "")
        }
    }
    @IBOutlet var lblpromoMessage: UILabel!
    
    @IBOutlet var lblServiceFeeTitle: UILabel! {
        didSet {
            lblServiceFeeTitle.text = localizedString("service_price", comment: "")
        }
    }
    @IBOutlet var lblGrandTotalPrice: UILabel! {
        didSet {
            lblGrandTotalPrice.text = localizedString("grand_total", comment: "")
        }
    }
    
    @IBOutlet var lblFInalBillAmount: UILabel! {
        didSet {
            lblFInalBillAmount.text = localizedString("total_bill_amount", comment: "")
        }
    }
    // bill amount
    @IBOutlet var paymentDetailsBackGroundView: AWView!
    @IBOutlet var paymentDetailBackGroundHeightConstraint: NSLayoutConstraint!
    @IBOutlet var lblPriceCount: UILabel!
    @IBOutlet var lblGrandTotal: UILabel!
    @IBOutlet var lblTotalPriceAmount: UILabel!
    @IBOutlet var lblServiceFeeAmount: UILabel!
    @IBOutlet var lblGrandTotalAmount: UILabel!
    @IBOutlet var lblFinaBillAmountAmount: UILabel!
    @IBOutlet var lblDiscounttxt: UILabel!
    @IBOutlet var lblPromoValue: UILabel!
    @IBOutlet var promoTextFieldHeight: NSLayoutConstraint!
    
    @IBOutlet var lblPriceVarience: UILabel!
    @IBOutlet var lblpriceValueAmount: UILabel!
    
    //promotion
//    @IBOutlet var lblPromoCodeDiscount: UILabel!{
//        didSet{
//            lblPromoCodeDiscount.setBody3RegGreenStyle()
//        }
//    }
//    @IBOutlet var lblPromoDiscountValue: UILabel!{
//        didSet{
//            lblPromoDiscountValue.setBody3RegGreenStyle()
//        }
//    }
    @IBOutlet var percentOffBGView: UIView!{
        didSet{
            percentOffBGView.backgroundColor = .promotionRedColor()
            percentOffBGView.layer.cornerRadius = 8
        }
    }
    @IBOutlet var lblPercentValue: UILabel!{
        didSet{
            lblPercentValue.setCaptionTwoSemiboldYellowStyle()
        }
    }
    @IBOutlet var grandTotalTopConstraint: NSLayoutConstraint!
    
    // smiles burn points labels outlets for bill details
    @IBOutlet weak var lblSmilesPoints: UILabel!{
        didSet{
        lblSmilesPoints.setBody3RegGreyStyle()
            lblSmilesPoints.text = localizedString("txt_smile_point", comment: "")
        lblSmilesPoints.textColor = .navigationBarColor()
        }
    }
    
    @IBOutlet weak var lblSmilesPointsValue: UILabel!{
        didSet{
            lblSmilesPointsValue.setBody3RegGreyStyle()
            lblSmilesPointsValue.textColor = .navigationBarColor()
        }
    }
    
    var selectedController : MyBasketViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.btnChange.setTitle(localizedString("change_button_title", comment: ""), for: .normal)
        self.txtPromo.attributedPlaceholder = NSAttributedString.init(string: self.txtPromo.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.textViewPlaceHolderColor()])
        showPromotion()
        //hide smiles points by default
        self.lblSmilesPoints.superview?.visibility = .goneY
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
     }
    
    func showPromotion(_ isHiden : Bool = true ,_ isPromoCode : Bool = false){
        if isHiden{
            self.percentOffBGView.visibility = .gone
//            self.lblPromoCodeDiscount.visibility = .gone
//            self.lblPromoDiscountValue.visibility = .gone
            if isPromoCode{
//                self.lblPromoCodeDiscount.visibility = .visible
//                self.lblPromoDiscountValue.visibility = .visible
                //self.grandTotalTopConstraint.constant = 5
                self.paymentDetailBackGroundHeightConstraint.constant = 235
            }else{
//                self.lblPromoCodeDiscount.visibility = .gone
//                self.lblPromoDiscountValue.visibility = .gone
               // self.grandTotalTopConstraint.constant = 0
                self.paymentDetailBackGroundHeightConstraint.constant = 215
            }
            
        }else{
            if isPromoCode{
//                self.lblPromoCodeDiscount.visibility = .visible
//                self.lblPromoDiscountValue.visibility = .visible
               // self.grandTotalTopConstraint.constant = 5
                self.paymentDetailBackGroundHeightConstraint.constant = 240
            }else{
//                self.lblPromoCodeDiscount.visibility = .gone
//                self.lblPromoDiscountValue.visibility = .gone
              //  self.grandTotalTopConstraint.constant = 0
                self.paymentDetailBackGroundHeightConstraint.constant = 215
                
            }
            self.percentOffBGView.visibility = .visible
            
            
            
        }
        self.layoutSubviews()
        self.layoutIfNeeded()
    }
    
    
    func configurePaymentForOrderDetail (_  orderController : OrderDetailsViewController) {
        if self.paymentDetailBackGroundHeightConstraint != nil {
            self.paymentDetailBackGroundHeightConstraint.constant = 145
        }
        self.cvvWidth.constant = 0
        self.promoTextFieldHeight.constant = 0
        self.lblpriceTopAnchor.constant = 0
        self.lblpromoCodeTopAnchor.constant = 0
        self.btnChange.isHidden = true
        self.lblPaymentMethod.textColor = .navigationBarWhiteColor()
        if orderController.order != nil {
              self.setPaymentFromOrder(orderController.order)
//              self.setOrderInvoice(orderController.order)
//              self.setPaymentDetailsForOrder(orderController)
        }
        
        
        
    }
    
    func designForHistory(_ design : Bool){
        if design{
            
            
            self.paymentViewHeight.constant = 58
            self.spaceFromErrorLbl.constant = 16
            self.lblpriceTopAnchor.constant = 16
            self.creditCardBGView.backgroundColor = UIColor.navigationBarWhiteColor()
            self.creditCardBGView.borderWidth = 1.0
            self.creditCardBGView.borderColor = UIColor.newBorderGreyColor()
            self.imagePayment.changePngColorTo(color: UIColor.newBlackColor())
            self.lblPaymentMethod.textColor = UIColor.newBlackColor()
            self.lblPaymentType.textColor = UIColor.newBlackColor()
            self.creditCardSuperBGView.layer.masksToBounds = true
            self.creditCardSuperBGView.isHidden = false
            
        }else{
            self.creditCardBGView.backgroundColor = UIColor.navigationBarColor()
            self.creditCardBGView.borderWidth = 0.0
            self.creditCardBGView.borderColor = UIColor.clear
            self.imagePayment.changePngColorTo(color: UIColor.navigationBarWhiteColor())
            self.lblPaymentMethod.textColor = UIColor.navigationBarWhiteColor()
            self.lblPaymentType.textColor = UIColor.navigationBarWhiteColor()
            self.creditCardSuperBGView.layer.masksToBounds = false
        }
        
    }
    
    
    func designForSubstitute(_ isSubstitute : Bool){
        if isSubstitute {
            
            self.cvvWidth.constant = 0
            self.promoTextFieldHeight.constant = 0
            self.lblpriceTopAnchor.constant = 16
            self.lblpromoCodeTopAnchor.constant = 0
            self.paymentViewHeight.constant = 0
            self.spaceFromErrorLbl.constant = 0
            self.creditCardBGView.backgroundColor = UIColor.navigationBarWhiteColor()
            self.creditCardBGView.borderWidth = 1.0
            self.creditCardBGView.borderColor = UIColor.newBorderGreyColor()
            self.imagePayment.changePngColorTo(color: UIColor.newBlackColor())
            self.lblPaymentMethod.textColor = UIColor.newBlackColor()
            self.lblPaymentType.textColor = UIColor.newBlackColor()
            self.creditCardSuperBGView.layer.masksToBounds = true
            self.creditCardSuperBGView.isHidden = false
            self.paymentDetailBackGroundHeightConstraint.constant = self.contentView.frame.size.height - 10
            
        }else{
            self.creditCardBGView.backgroundColor = UIColor.navigationBarColor()
            self.creditCardBGView.borderWidth = 0.0
            self.creditCardBGView.borderColor = UIColor.clear
            self.imagePayment.changePngColorTo(color: UIColor.navigationBarWhiteColor())
            self.lblPaymentMethod.textColor = UIColor.navigationBarWhiteColor()
            self.lblPaymentType.textColor = UIColor.navigationBarWhiteColor()
            self.creditCardSuperBGView.layer.masksToBounds = false
        }
        
    }
    
    
    func setValueForSubstitution( totalAmount : String , service : String , promoCode :String , grandTotal : String , totalProductCount : Int) {
        
        
        self.lblDiscounttxt.setBodyRegulrGreenStyle()
        self.lblDiscounttxt.text = localizedString("promotion_discount_aed", comment: "")
        lblPriceCount.text  =  localizedString("total_price", comment: "") + " \(totalProductCount)" + " " + localizedString("brand_items_count_label", comment: "")
        lblPriceCount.highlight(searchedText: "\(totalProductCount) " + localizedString("brand_items_count_label", comment: ""), color: UIColor.darkGrayTextColor(), size: UIFont.SFProDisplayBoldFont(14))
        lblTotalPriceAmount.text = totalAmount
        lblServiceFeeAmount.text  =  service
        
        
        
        var value = String(grandTotal.replacingOccurrences(of: CurrencyManager.getCurrentCurrency() , with: ""))
        value = value.replacingOccurrences(of: " ", with: "")
        let grandTotalInt = Double(value)
        if grandTotalInt != nil , grandTotalInt! > 0 {
            lblFinaBillAmountAmount.text  =  grandTotal
        }else {
//            lblFinaBillAmountAmount.text  =  "\(CurrencyManager.getCurrentCurrency()) " + ((NSString(format: "%.2f", 0.0) as String) as String)
            lblFinaBillAmountAmount.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: 0.0)
        }
        
       
        lblGrandTotalAmount.text = grandTotal
        
        if promoCode.count == 0 {
            
            lblPromoValue.text = ""
            self.lblDiscounttxt.text = ""
        } else {

            self.lblDiscounttxt.text = localizedString("promotion_discount_aed", comment: "")
            self.lblPromoValue.text = "-" + promoCode
        }
      
    }
    
    func setPaymentDetailsForOrder(_  orderController : OrderDetailsViewController ) {
        
   
        var summaryCount = 0
        var priceSum = 0.00
        for product in orderController.orderProducts {
            
            let item = orderController.shoppingItemForProduct(product)
            if let notNilItem = item {
                if notNilItem.wasInShop.boolValue == true{
                    summaryCount += notNilItem.count.intValue
                    
                    if product.promoPrice?.intValue == 0 || !(product.promotion?.boolValue ?? false) {
                        priceSum += product.price.doubleValue * notNilItem.count.doubleValue
                    }else{
                        priceSum += product.promoPrice!.doubleValue * notNilItem.count.doubleValue
                    }
                   
                }
            }
        }
        
//         lblTotalPriceAmount.text  =  "\(CurrencyManager.getCurrentCurrency()) " + ((NSString(format: "%.2f", priceSum) as String) as String)
        lblTotalPriceAmount.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: priceSum)
       // let countLabel = orderController.orderProducts.count == 1 ? localizedString("shopping_basket_items_count_singular", comment: "") : localizedString("shopping_basket_items_count_plural", comment: "")

        let itemsVat = priceSum - (priceSum / ((100 + Double(truncating: orderController.order.grocery.vat))/100))
       elDebugPrint("Value Added Tax Value:",itemsVat)
        
        
        
        
        var serviceFee = ElGrocerUtility.sharedInstance.getFinalServiceFee(currentGrocery: orderController.order.grocery, totalPrice: priceSum)
        if orderController.order.foodSubscriptionStatus?.boolValue ?? false {
            serviceFee = 0.0
        }
        priceSum = priceSum + serviceFee
        
        let serviceVat = serviceFee - (serviceFee / ((100 + Double(truncating: orderController.order.grocery.vat))/100))
       elDebugPrint("Value Added Tax Value:",serviceVat)
        
        let vatTotal = itemsVat + serviceVat
        
        //        self.vatAmountLabel.text = String(format:"%.2f %@", vatTotal,kProductCurrencyAEDName)
        //        self.vatAmountLabel.text = ("\(kProductCurrencyAEDName) " + (NSString(format: "%.2f", vatTotal) as String) as String) // .createTopAlignedPriceString(self.vatAmountLabel.font, price:NSNumber(value:vatTotal))
        //        self.vatLabel.isHidden = true
        //        self.vatAmountLabel.isHidden = true
        
        
     
        // Adjust the summary if a promo code was present in an order.
        var isPromo : Bool = false
        if let promoCode = orderController.order.promoCode {
            
            // totalPriceLabel.attributedText = itemsSummaryPriceLabel.attributedText
            
            let promoCodeValue = promoCode.valueCents  as Double
            
            if promoCodeValue > 0 {
                self.lblDiscounttxt.setBodyRegulrGreenStyle()
                self.lblDiscounttxt.text = localizedString("promotion_discount_aed", comment: "")
//                self.lblPromoValue.text = "-" +  ("\(CurrencyManager.getCurrentCurrency()) " + String(format: "%.2f", promoCodeValue) as String)
                self.lblPromoValue.text = "-" + ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: promoCodeValue)
                isPromo = true
            }  else {
                self.lblDiscounttxt.text = ""
                self.lblPromoValue.text = ""
            }
            
            if priceSum - promoCodeValue <= 0.0 {
                priceSum = 0.0
            } else {
                priceSum = priceSum - promoCodeValue
            }
        }

        var grandTotal = priceSum
        if let price = orderController.order.priceVariance?.doubleValue {
            grandTotal = grandTotal + price
         
            if price > 0 {
                self.lblPriceVarience.text = localizedString("Card_Price_Variance_Title", comment: "")
//                self.lblpriceValueAmount.text  = "\(CurrencyManager.getCurrentCurrency()) " + (NSString(format: "%.2f", price) as String)
                self.lblpriceValueAmount.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: price)
                self.paymentDetailBackGroundHeightConstraint.constant =  175 + (isPromo ? 15 : 0)
            }else{
                self.lblPriceVarience.text = ""
                self.lblpriceValueAmount.text  = ""
                self.paymentDetailBackGroundHeightConstraint.constant =  165 + (isPromo ? 10 : 0)
            }            
        }else{
            self.lblPriceVarience.text = ""
            self.lblpriceValueAmount.text  = ""
            self.paymentDetailBackGroundHeightConstraint.constant =  175
        }
        
 
        //TODO: if requirement changed in future 
        //if let smilesSupported = orderController.order.grocery.smileSupport {
        if let smilesSupported = orderController.order.isSmilesUser?.boolValue {
            if smilesSupported {
                self.lblSmilesPoints.superview?.visibility = .visible
                self.lblSmilesPointsValue.visibility = .visible
                ////TODO: replace with value recieved from api
                //TODO: checkit
                let smilePoints = Int(orderController.order.smilesBurnPoints)
                if smilePoints > 0 {
                    //points burned
                    
                    self.lblSmilesPointsValue.text = "- \(ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: grandTotal))"
                    
                } else {
                    //points earned
                    let earnedpopints = SmilesManager.getEarnPointsFromAed(grandTotal)
                    self.lblSmilesPointsValue.text = "\(earnedpopints)"
                }
                //self.lblSmilesPointsValue.text = "-\(200)"
                self.paymentDetailBackGroundHeightConstraint.constant =  175 + 25 + (isPromo ? 15 : 0)

            } else {
                self.lblSmilesPoints.superview?.visibility = .goneY
                self.paymentDetailBackGroundHeightConstraint.constant =  175 + 25 + (isPromo ? 15 : 0)
            }
        }
        if orderController.order.foodSubscriptionStatus?.boolValue ?? false {
            lblServiceFeeAmount.text = localizedString("txt_free", comment: "")
        }else {
            lblServiceFeeAmount.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: serviceFee)
        }
        lblGrandTotalAmount.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: grandTotal)
        let smilePoints = Int(orderController.order.smilesBurnPoints)
        if smilePoints > 0 {
            lblGrandTotalAmount.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: 0.00)
            lblFinaBillAmountAmount.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: 0.00)
        }else {
            lblFinaBillAmountAmount.text = lblGrandTotalAmount.text
        }
        
        lblPriceCount.text  =  localizedString("total_price", comment: "") + ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: " \(summaryCount)") + " " + localizedString("brand_items_count_label_orderDetails", comment: "")
        lblPriceCount.highlight(searchedText: ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: " \(summaryCount) ") + localizedString("brand_items_count_label_orderDetails", comment: ""), color: UIColor.darkGrayTextColor(), size: UIFont.SFProDisplayBoldFont(14))

    }
    
    
  
    func setPaymentFromOrder (_ order : Order) {
        
        self.lblPaymentType.text = localizedString("setting_PayementMethod", comment: "")
        if order.payementType?.intValue == Int(PaymentOption.creditCard.rawValue),let _ = order.refToken {
            if order.cardType == "7" || order.cardType == "8" {
                self.lblPaymentMethod.text  = localizedString("pay_via_Apple_pay", comment: "")
            }else {
                self.lblPaymentMethod.text  = localizedString("lbl_Card_ending_in", comment: "") + (order.cardLast ?? "")
            }
        }else{
            if order.payementType?.intValue == Int(PaymentOption.cash.rawValue) {
                 self.lblPaymentMethod.text = localizedString("cash_On_Delivery_string", comment: "")
            }else if order.payementType?.intValue == Int(PaymentOption.card.rawValue) {
                 self.lblPaymentMethod.text = localizedString("pay_via_card", comment: "")
            }else if order.payementType?.intValue == Int(PaymentOption.creditCard.rawValue) {
                self.lblPaymentMethod.text = localizedString("pay_via_CreditCard", comment: "")
            }else if order.payementType?.intValue == Int(PaymentOption.smilePoints.rawValue){
                self.lblPaymentMethod.text = localizedString("pay_via_smiles_points", comment: "")
            }else{
                self.lblPaymentMethod.text = ""
            }
        }
    }
    
    func setOrderInvoice(_ order : Order?) {
        guard order != nil else {return}
        
        
        
        
    }
    
    /*
    func configPaymentType (selectedController :  MyBasketViewController ) {
        self.selectedController = selectedController
        guard selectedController.paymentMethodA.count > 0 else {
            self.lblPaymentType.text = localizedString("setting_PayementMethod", comment: "")
            self.lblPaymentMethod.text = localizedString("payment_method_title", comment: "")
            self.cvvWidth.constant = 0
            self.promoCallActivity.isHidden = true
            setPaymentDetails()
            return
        }
        
        if self.selectedController?.selectedPaymentOption != nil {
             self.setPaymentLable(self.selectedController?.selectedPaymentOption)
        }else{
            
             self.setPaymentLable(nil)
        }
        self.setPromoDefaultState()
        setPaymentDetails()
        if selectedController.currentCvv.count == 0 {
         self.txtCvv.text = ""
        }
        selectedController.currentCvv = self.txtCvv.text ?? ""
    }*/
    
    @IBAction func changeHandler(_ sender: Any) {
        self.changePaymentTypeMethod(sender)
    }
    @IBAction func selectPaymentMethodHandler(_ sender: Any) {
         self.changePaymentTypeMethod(sender)
    }
    
    
    
    @IBAction func applyPromoAction(_ sender: Any) {
        /*
        guard self.selectedController?.selectedPaymentOption != nil else {
            self.setAnimatedFailureState(localizedString("shopping_basket_payment_info_label", comment: ""))
            self.paymentDetailBackGroundHeightConstraint.constant = 210
            return
        }
        
        guard self.lblpromoMessage.isHidden  == true || self.lblpromoMessage.text?.count ?? 0 == 0 else {
            UIView.animate(withDuration: 1.5) { [weak self] in
                self?.promoView.borderColor =  .colorWithHexString(hexString: "E7E7E7")
            }
            self.lblpromoMessage.isHidden = true
            self.lblpromoMessage.text = ""
            self.paymentDetailBackGroundHeightConstraint.constant = 215
            self.txtPromo.text = ""
            self.btnApplyPromo.setTitle(localizedString("promo_code_alert_yes", comment: ""), for: .normal)
            self.btnApplyPromo.setImage(nil, for: .normal)
            return
        }
  
        guard self.txtPromo.text?.count ?? 0 > 0 else {
            self.selectedController?.view.endEditing(true)
            return
        }
        setCallingPromoState()
        self.selectedController?.checkPromoCode(self.txtPromo.text!, cell: self)
        */
        
    }
    
    func setPaymentDetails() {
        
        self.selectedController?.getTotalShoppingAmount()
//        lblTotalPriceAmount.text  = String(format:"%@ %.2f", CurrencyManager.getCurrentCurrency() ,  self.selectedController?.itemsSummaryValue ?? 0)
        lblTotalPriceAmount.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: self.selectedController?.itemsSummaryValue ?? 0)
//        lblServiceFeeAmount.text  = String(format:"%@ %.2f", CurrencyManager.getCurrentCurrency() , self.selectedController?.serviceFee ?? 0)
        lblServiceFeeAmount.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: self.selectedController?.serviceFee ?? 0)
//        lblGrandTotalAmount.text  = String(format:"%@ %.2f", CurrencyManager.getCurrentCurrency() ,   self.selectedController?.getFinalAmount() ?? 0 ) //String(format:"%.2f %@",  self.selectedController?.priceSum ?? 0,kProductCurrencyAEDName)
        lblGrandTotalAmount.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: self.selectedController?.getFinalAmount() ?? 0 )
//        lblFinaBillAmountAmount.text  =  String(format:"%@ %.2f", CurrencyManager.getCurrentCurrency() ,   self.selectedController?.getFinalAmountToDisplay() ?? 0 )
        lblFinaBillAmountAmount.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: self.selectedController?.getFinalAmountToDisplay() ?? 0 )
        
        var discountedPriceIs = 0.0
        if let vc = self.selectedController{
            if let promoCodeValue = UserDefaults.getPromoCodeValue() {
                
                discountedPriceIs = vc.getTotalSavingsAmountWithoutPromo()
    
                if discountedPriceIs > 0 {
                    showPromotion(false,true)
                    lblPercentValue.text = localizedString("aed", comment: "") + discountedPriceIs.formateDisplayString() + " " + localizedString("txt_Saved", comment: "")
                    // for cart above place order button
                    vc.savedAmountBGView.isHidden = false
                    vc.lblSavedAmount.text = localizedString("aed", comment: "") + discountedPriceIs.formateDisplayString() + " " + localizedString("txt_Saved", comment: "")
                    vc.savedAmountBGView.layoutIfNeeded()
                }
            }else{
                discountedPriceIs = vc.getTotalSavingsAmountWithoutPromo()
                if discountedPriceIs > 0{
                    showPromotion(false,false)
                    
//                    lblPercentValue.text = localizedString("aed", comment: "") + discountedPriceIs.formateDisplayString() + " " + localizedString("txt_Saved", comment: "")
                    lblPercentValue.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: discountedPriceIs) + " " + localizedString("txt_Saved", comment: "")
                    // for cart above place order button
                    
                    vc.savedAmountBGView.isHidden = false
//                    vc.lblSavedAmount.text = localizedString("aed", comment: "") + discountedPriceIs.formateDisplayString() + " " + localizedString("txt_Saved", comment: "")
                    vc.lblSavedAmount.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: discountedPriceIs) + " " + localizedString("txt_Saved", comment: "")
                    vc.savedAmountBGView.layoutIfNeeded()
                }
            }
            if discountedPriceIs == 0{
                vc.savedAmountBGView.isHidden = true
                showPromotion()
            }
        }
        
        
        

        
         let countLabel = self.selectedController?.products.count == 1 ? localizedString("shopping_basket_items_count_singular", comment: "") : localizedString("shopping_basket_items_count_plural", comment: "")
        
        if let itemCount = self.selectedController?.purchasedItemCount{
            
            
            if itemCount == 1{
                
                lblPriceCount.text =  localizedString("total_price", comment: "") + " " + ("\(itemCount)") + " " + localizedString("shopping_basket_items_count_singular", comment: "")
                lblPriceCount.highlight(searchedText: "\(itemCount) " + localizedString("shopping_basket_items_count_singular", comment: ""), color: UIColor.darkGrayTextColor(), size: UIFont.SFProDisplayBoldFont(14))
            }else if itemCount > 1{
                lblPriceCount.text =  localizedString("total_price", comment: "") + " " + ("\(itemCount)") + " " + localizedString("shopping_basket_items_count_plural", comment: "")
                lblPriceCount.highlight(searchedText: "\(itemCount) " + localizedString("shopping_basket_items_count_plural", comment: ""), color: UIColor.darkGrayTextColor(), size: UIFont.SFProDisplayBoldFont(14))
            }
            
        }
            self.lblDiscounttxt.setBodyRegulrGreenStyle()
        if let promoCodeValue = UserDefaults.getPromoCodeValue() {
            self.lblDiscounttxt.text = localizedString("promotion_discount_aed", comment: "")
//            self.lblPromoValue.text = "-" +  String(format:"%@ %.2f", CurrencyManager.getCurrentCurrency() ,  promoCodeValue.valueCents )
            lblPromoValue.text = "-" + ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: promoCodeValue.valueCents)
        } else {
            self.lblDiscounttxt.text = ""
             self.lblPromoValue.text = ""
        }
         
    }
  
}

extension MyBasketPromoAndPaymentTableViewCell {
    
    func setPromoDefaultState() {
        
        if let promoCodeValue = UserDefaults.getPromoCodeValue() {
            self.txtPromo.text = promoCodeValue.code
            self.promoCallActivity.isHidden = true
            self.btnApplyPromo.setTitle("", for: .normal)
            self.promoView.borderColor =  .navigationBarColor()
            self.btnApplyPromo.tintColor = .navigationBarColor()
            self.btnApplyPromo.setImage(UIImage(name: "MyBasketPromoSuccess"), for: .normal)
            return
        }
        self.btnApplyPromo.setTitle(localizedString("promo_code_alert_yes", comment: ""), for: .normal)
        self.btnApplyPromo.setImage(nil, for: .normal)
        
        self.promoCallActivity.isHidden = true
        self.btnApplyPromo.isHidden = false
        self.promoView.borderColor =  .colorWithHexString(hexString: "E7E7E7")
    }
    
    func setCallingPromoState() {
        self.txtPromo.isUserInteractionEnabled = false
        self.promoCallActivity.isHidden = false
        self.promoCallActivity.startAnimating()
        self.btnApplyPromo.isHidden = true
        self.promoView.borderColor =  .colorWithHexString(hexString: "E7E7E7")
    }
    
    func setAnimatedSuccessState(_ text : String) {
        
        self.endEditing(true)
        self.txtPromo.resignFirstResponder()
        self.txtPromo.isUserInteractionEnabled = false
        self.promoCallActivity.isHidden = true
        self.btnApplyPromo.isHidden = false
        self.promoView.borderColor =  .navigationBarColor()
        self.btnApplyPromo.setTitle("", for: .normal)
        self.btnApplyPromo.tintColor = .navigationBarColor()
        self.btnApplyPromo.setImage(UIImage(name: "MyBasketPromoSuccess"), for: .normal)
        self.lblpromoMessage.textColor = .navigationBarColor()
        self.lblpromoMessage.isHidden = false
        self.lblpromoMessage.text = text
        self.paymentDetailBackGroundHeightConstraint.constant = 210 + self.getPromoMessageLabelHeight(text: text) + self.lblPromoValue.frame.size.height + (self.percentOffBGView.isHidden ? 0 : 15)
        self.setPaymentDetails()
        self.layoutIfNeeded()
        ElGrocerUtility.sharedInstance.delay(0.1) {
            self.lblpromoMessage.isHidden = false
            self.lblpromoMessage.text = text
        }
        ElGrocerUtility.sharedInstance.delay(2) {
           
            self.txtPromo.isUserInteractionEnabled = true
            self.lblpromoMessage.isHidden = true
            self.lblpromoMessage.text = ""
            self.paymentDetailBackGroundHeightConstraint.constant = 210 + self.lblPromoValue.frame.size.height + (self.percentOffBGView.isHidden ? 0 : 10)
            self.layoutIfNeeded()
        }
    }
    
    func setPaymentErrorMessage (_ msg : String , _ isCvv : Bool = false , _ isNeedToDefaultPaymentMethod : Bool = true) {
        
        
        DispatchQueue.main.async {  [weak self ] in
            self?.lblPaymentErrorMsg.isHidden = false
            self?.lblPaymentErrorMsg.text = msg
            self?.lblPaymentErrorMsg.textColor  =  .redInfoColor()
            if isCvv {
                self?.txtCvv.layer.cornerRadius = 2
                self?.txtCvv.layer.borderWidth = 1
                self?.txtCvv.layer.borderColor = UIColor.redInfoColor().cgColor
            }
            
            self?.setNeedsLayout()
            self?.layoutIfNeeded()
        }
        
        if isNeedToDefaultPaymentMethod {
            ElGrocerUtility.sharedInstance.delay(2) { [weak self ] in
                self?.setDefaultStateForPayment()
            }
            if let clouser = self.promoRefreshed {
                clouser(false)
            }
        }
 
    }
    
    func setDefaultStateForPayment() {
        
        UIView.animate(withDuration: 2.0) {
            self.lblPaymentErrorMsg.isHidden = true
            self.lblPaymentErrorMsg.text = ""
            self.txtCvv.layer.cornerRadius = 2
            self.txtCvv.layer.borderWidth = 0
            self.txtCvv.layer.borderColor = UIColor.clear.cgColor
        }
        
    }
    
    func getPromoMessageLabelHeight(text : String) -> CGFloat{
        
       let height =  text.height(withConstrainedWidth: self.lblpromoMessage.frame.width , font: self.lblpromoMessage.font)
        
       return height
        
//        else if text.count > 45 && text.count < 90{
//            return 25
//        }
    }
    
    func setAnimatedFailureState(_ text : String) {
        
        self.txtPromo.isUserInteractionEnabled = true
        self.promoCallActivity.isHidden = true
        self.btnApplyPromo.isHidden = false
        self.promoView.borderColor =  .redInfoColor()
        self.lblpromoMessage.textColor = .redInfoColor()
        self.lblpromoMessage.isHidden = false
        self.lblpromoMessage.text = text
      
        self.btnApplyPromo.tintColor = .lightTextGrayColor()
        self.btnApplyPromo.setTitle("", for: .normal)
        self.btnApplyPromo.setImage(UIImage(name: "MyBasketPromoClose"), for: .normal)
        self.setPaymentDetails()
        
        self.paymentDetailBackGroundHeightConstraint.constant = 210 + self.getPromoMessageLabelHeight(text: text) + (self.percentOffBGView.isHidden ? 0 : 15)
        self.paymentDetailsBackGroundView.layoutIfNeeded()
        
//         ElGrocerUtility.sharedInstance.delay(2) {
//            UIView.animate(withDuration: 1.5) { [weak self] in
//                self?.promoView.borderColor =  .colorWithHexString(hexString: "E7E7E7")
//            }
//            self.lblpromoMessage.isHidden = true
//            self.lblpromoMessage.text = ""
//            self.btnApplyPromo.setTitle(localizedString("promo_code_alert_yes", comment: ""), for: .normal)
//            self.btnApplyPromo.setImage(nil, for: .normal)
//        }
    }
    
    
}


extension MyBasketPromoAndPaymentTableViewCell {
    
    
    func setPaymentState () {
        let storeId = ElGrocerUtility.sharedInstance.cleanGroceryID(self.selectedController?.grocery?.dbID)
        let option = UserDefaults.getPaymentMethod(forStoreId: storeId)
       // self.selectedController?.selectedPaymentOption =  PaymentOption(rawValue: option) //option
        self.setPaymentLable(PaymentOption(rawValue: option))
        
    }
    
    
    func setPaymentLable(_ selectPaymentType : PaymentOption?) {
        
       // self.selectedController?.setPaymentState()
        DispatchQueue.main.async {
            self.lblPaymentType.text = localizedString("setting_PayementMethod", comment: "")
           // self.lblPaymentMethod.text = self.changeSegmentAccordingToPaymentSelection(selectPaymentType)
            self.lblpromoMessage.isHidden = true
            self.lblpromoMessage.text = ""
        }
        let storeId = ElGrocerUtility.sharedInstance.cleanGroceryID(self.selectedController?.grocery?.dbID)
        if let type = selectPaymentType?.rawValue {
            UserDefaults.setPaymentMethod(type, forStoreId: storeId)
        }
 
    }
    /*
    private func changeSegmentAccordingToPaymentSelection (_ payment : PaymentOption?) -> String {
        var findSegment  = localizedString("payment_method_title", comment: "")
        
        if let selectedOption = payment {
            if selectedOption.rawValue == PaymentOption.cash.rawValue {
                findSegment = localizedString("cash_On_Delivery_string", comment: "")
                self.imagePayment.image = UIImage(name: "cash-List-white")
                self.cvvWidth.constant = 0
            }else if selectedOption.rawValue == PaymentOption.card.rawValue {
                findSegment = localizedString("pay_via_card", comment: "")
                self.imagePayment.image = UIImage(name: "CardOnDelivery-white")
                self.cvvWidth.constant = 0
            }else if selectedOption.rawValue == PaymentOption.creditCard.rawValue {
                
                self.imagePayment.image = UIImage(name: "placeorder-card-white")
                let cardID = UserDefaults.getCardID(userID: selectedController?.userProfile?.dbID.stringValue ?? "-1")
                if cardID.count > 0 {
                    let cardSelected =  selectedController?.creditCardA.filter { (card) -> Bool in
                        return "\(card.cardID)" == cardID
                    }
                    if cardSelected?.count ?? 0 > 0 {
                        self.selectedController?.selectedCreditCard = cardSelected![0]
                        let cardNumber = localizedString("lbl_Card_ending_in", comment: "") + (selectedController?.selectedCreditCard?.last4 ?? "")
                        findSegment =  (cardNumber == localizedString("lbl_Card_ending_in", comment: "")) ? localizedString("payment_method_title", comment: "") : cardNumber
                        self.cvvWidth.constant = 56
                    }else{
                        self.cvvWidth.constant = 0
                    }
                }else{
                    self.cvvWidth.constant = 0
                }
            }else{
                self.cvvWidth.constant = 0
            }
        }else{
             self.cvvWidth.constant = 0
        }
        return findSegment
    }
    */
  
    
    func changePaymentTypeMethod(_ sender: Any) {
        
//        var configuration = NBBottomSheetConfiguration(animationDuration: 0.4, sheetSize: .fixed(CGFloat(500)))
//        configuration.backgroundViewColor = UIColor.newBlackColor().withAlphaComponent(0.56)
//        let bottomSheetController = NBBottomSheetController(configuration: configuration)
        
        let creditVC = CreditCardListViewController(nibName: "CreditCardListViewController", bundle: Bundle.resource)
        if #available(iOS 13, *) {
            creditVC.view.backgroundColor = .clear
        } else {
            creditVC.view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        }
        creditVC.userProfile = selectedController?.userProfile
        creditVC.selectedGrocery = selectedController?.grocery
        creditVC.isNeedShowAllPaymentType = true
       // creditVC.paymentMethodA = selectedController?.paymentMethodA ?? []
        let navigation = ElgrocerGenericUIParentNavViewController.init(rootViewController: creditVC)
        if #available(iOS 13, *) {
            navigation.view.backgroundColor = .clear
        }else{
            navigation.view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        }
        
       
        //present(creditVC, animated: true, completion: nil)
        creditVC.paymentMethodSelection = { [weak self] (methodSelect) in
            guard let self = self else {return}
            self.setPaymentState ()
        }
        creditVC.goToAddNewCard = { [weak self] (credit) in
            guard let self = self else {return}
          //  self.selectedController?.goToAddNewCardController()
        }
        
        creditVC.creditCardSelected = { [weak self] (creditCardSelected) in
            guard let self = self else {return}
//            self.selectedController?.selectedPaymentOption = PaymentOption.creditCard
//            self.selectedController?.selectedCreditCard = creditCardSelected
            self.setViewAccordingToSelectedCreditCard(card: creditCardSelected!)
            UserDefaults.setCardID(cardID: creditCardSelected?.cardID ?? ""  , userID: self.selectedController?.userProfile?.dbID.stringValue ?? "")
            NotificationCenter.default.post(name: Notification.Name(rawValue: kBasketUpdateForEditNotificationKey), object: nil)
            self.setPaymentState ()
            creditVC.dismiss(animated: true) {}
        }
        
        creditVC.creditCardDeleted = { [weak self] (creditCardSelected) in
            guard let self = self else {return}
           // self.selectedController?.selectedCreditCard = nil
        }
        
        creditVC.addCard = {
            creditVC.dismiss(animated: true) {
                //  self.selectedController?.addNewCreditCardAction("")
            }
        }
        //bottomSheetController.present(creditVC, on: MyBasketViewController())
         self.selectedController?.present(navigation, animated: true, completion: nil)
        
    }
    
    func setViewAccordingToSelectedCreditCard (card : CreditCard) {
        
        self.lblPaymentMethod.text = localizedString("card_title", comment: "") + ": **** **** **** " + card.last4.convertEngNumToPersianNum()
      
    }

}

extension MyBasketPromoAndPaymentTableViewCell : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.txtPromo {
            self.btnApplyPromo.setTitle(localizedString("promo_code_alert_yes", comment: ""), for: .normal)
            self.btnApplyPromo.setImage(nil, for: .normal)
        }
       
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
       
    }
    /* // commenting this as we are not using cvv in this controller
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        
        defer {
            ElGrocerUtility.sharedInstance.delay(0.1) {
                 self.selectedController?.currentCvv =  self.txtCvv.text ?? ""
            }
        }
        if textField == self.txtCvv {
            textField.layer.borderColor = UIColor.clear.cgColor
            
            // Create an `NSCharacterSet` set which includes everything *but* the digits
            let inverseSet = NSCharacterSet(charactersIn:"0123456789").inverted
            
            // At every character in this "inverseSet" contained in the string,
            // split the string up into components which exclude the characters
            // in this inverse set
            let components = string.components(separatedBy: inverseSet)
            
            // Rejoin these components
            let filtered = components.joined(separator: "")  // use join("", components) if you are using Swift 1.2
            
            // If the original string is equal to the filtered string, i.e. if no
            // inverse characters were present to be eliminated, the input is valid
            // and the statement returns true; else it returns false
            if string == filtered {
                let maxLength = 3
                let currentString: NSString = (textField.text ?? "") as NSString
                let newString: NSString =
                    currentString.replacingCharacters(in: range, with: string) as NSString
                return newString.length <= maxLength
                
            }
            
            return string == filtered
        }
        
        return true
      
    }
    */
    
}
