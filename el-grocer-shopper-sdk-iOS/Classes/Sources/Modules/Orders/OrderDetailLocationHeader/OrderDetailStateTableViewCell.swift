//
//  OrderDetailStateTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 28/11/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

class OrderDetailStateTableViewCell: UITableViewCell {
    
    var buttonClicked: (()->Void)?
    @IBOutlet var viewLine: UIView!
    @IBOutlet var imgGrocery: UIImageView!
    @IBOutlet var lblGrocery: UILabel!{
        didSet{
            lblGrocery.setBody2BoldDarkStyle()
        }
    }
    @IBOutlet var lblOrder: UILabel!
    @IBOutlet var lblOrderStatus: UILabel!{
        didSet{
            lblOrderStatus.font = UIFont.SFProDisplayBoldFont(14)
        }
    }
    @IBOutlet var lblNumberOfItems: UILabel!{
        didSet{
            lblNumberOfItems.setCaptionOneRegDarkStyle()
        }
    }
    @IBOutlet var lblDate: UILabel!{
        didSet{
            lblDate.setBody3BoldUpperStyle(false)
        }
    }
    @IBOutlet var lblPrice: UILabel!{
        didSet{
            lblPrice.setBody3BoldUpperStyle(false)
        }
    }
    @IBOutlet var btnChoose: AWButton!{
        didSet{
            btnChoose.setH4SemiBoldWhiteStyle()
        }
    }
    @IBOutlet var lblOrderType: UILabel!{
        didSet{
            lblOrderType.setBody3RegDarkStyle()
        }
    }
    
    @IBOutlet var progressView: UIProgressView! {
        
        didSet{
            
            progressView.progressTintColor = .navigationBarColor()
            progressView.layer.cornerRadius = 4
            progressView.clipsToBounds = true
            
        }
        
    }
    var order : Order!
    @IBOutlet var trackingView: UIView!
    @IBOutlet var lblOrderTracking: UILabel!
    @IBOutlet var lblTrackYourOrder: UILabel!{
        didSet{
            lblTrackYourOrder.text = localizedString("lbl_Track_your_order", comment: "")
        }
    }
    @IBAction func trackYourOrderAction(_ sender: Any) {
        if let trackingUrl = self.order.trackingUrl {
            TrackingNavigator.presentTrackingViewWith(trackingUrl, orderId: self.order.dbID.stringValue, statusId: self.order.getOrderDynamicStatus().getStatusKeyLogic().status_id.stringValue)
        }
    }
    
    
    func setProgressAccordingToStatus(_ status : DynamicOrderStatus? , totalStep : Float) {
        guard status != nil else {
            return
        }
        let progress : Float = status!.stepNumber.floatValue / totalStep
        self.progressView.setProgress(progress , animated: true)
    }
    
    
    lazy var getdataFormmater : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM dd,yyyy hh:mm a"
        return formatter
    }()
    
   

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func configureCell (_ order : Order? , orderProducts : [Product]? , orderItems : [ShoppingBasketItem]?  ) {
        
        guard order != nil else {
            return
        }
        
        self.setGrocery(grocery: order?.grocery)
        self.setOrderDetails(order, orderProducts: orderProducts , orderItems : orderItems  )
        self.setButtonType(order!)
        
    }
    
    

    
    
    @IBAction func buttonAction(_ sender: Any) {
        if let clouser = self.buttonClicked {
            clouser()
        }
    }
}

extension OrderDetailStateTableViewCell {
    
    func setButtonType (_ order : Order) {
        
        if order.status.intValue == OrderStatus.payment_pending.rawValue || order.status.intValue == OrderStatus.STATUS_WAITING_APPROVAL.rawValue {
            self.btnChoose.setTitle(localizedString("lbl_Payment_Confirmation", comment: ""), for: .normal)
        }else if order.status.intValue == OrderStatus.inSubtitution.rawValue {
            self.btnChoose.setTitle(localizedString("choose_substitutions_title", comment: ""), for: .normal)
        }else if ((order.status.intValue == OrderStatus.pending.rawValue) || (order.status.intValue == OrderStatus.inEdit.rawValue)) {
             self.btnChoose.setTitle(localizedString("order_confirmation_Edit_order_button", comment: ""), for: .normal)
        }else{
              self.btnChoose.setTitle(localizedString("lbl_repeat_order", comment: ""), for: .normal)
        }
    }
    
    
    private func shoppingItemForProduct(_ product:Product , orderItems : [ShoppingBasketItem] ) -> ShoppingBasketItem? {
        
        for item in orderItems {
            
            if product.dbID == item.productId {
                return item
            }
        }
        
        return nil
    }
    
    
    func setOrderDetails(_ order : Order?  , orderProducts : [Product]? , orderItems : [ShoppingBasketItem]?  ) {
        
        let string = NSMutableAttributedString(string: localizedString("order_lbl_numner", comment: "") +  ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: order?.dbID.stringValue ?? ""))
        string.setColorForText( localizedString("order_lbl_numner", comment: "") , with: .disableButtonColor())
        string.setFontForText( localizedString("order_lbl_numner", comment: "") , with: .SFProDisplayNormalFont(12))
        string.setColorForText(order?.dbID.stringValue ?? ""  , with: UIColor.newBlackColor())
        string.setFontForText(order?.dbID.stringValue ?? "" , with: .SFProDisplaySemiBoldFont(12))
        self.lblOrder.attributedText = string
        //order status
//        if order?.status.intValue == -1 {
//            self.lblOrderStatus.text = localizedString("lbl_Payment_Pending", comment: "")
//        }else{
//            self.lblOrderStatus.text = localizedString(OrderStatus.labels[order?.status.intValue ?? 7], comment: "")
//        }
//        self.lblOrderStatus.text =  self.lblOrderStatus.text?.uppercased()
//
//        if order?.status.intValue == 6 {
//            self.lblOrderStatus.textColor = .elGrocerYellowColor()
//            lblOrderType.text = "in substitution".capitalized
//        }else if order?.status.intValue  == 4 {
//            self.lblOrderStatus.textColor = .textfieldErrorColor()
//            lblOrderType.text = ""
//        }else{
//            self.lblOrderStatus.textColor = .navigationBarColor()
//            lblOrderType.text = localizedString("title_estimated_delivery", comment: "")
//        }
        
        //sab
        guard order != nil else {return}
        self.order = order
        
        self.trackingView.isHidden = self.order.trackingUrl?.count == 0
        self.lblDate.isHidden = !self.trackingView.isHidden
        
        
        let status = order!.getOrderDynamicStatus()
        let statusString : String = ElGrocerUtility.sharedInstance.isArabicSelected() ? status.nameAr : status.nameEn
        let statusUppercased = statusString.uppercased()
        self.lblOrderStatus.text = statusUppercased
        let data = status.getStatusKeyLogic()
        
        if data.service_id.intValue == Int(OrderType.delivery.rawValue){
            self.lblOrderType.text = localizedString("title_Estimated_delivery", comment: "")
        }else{
            self.lblOrderType.text = localizedString("lbl_self_collection_time", comment: "")
        }

        if data.status_id.intValue == OrderStatus.inSubtitution.rawValue {
            self.lblOrderType.textColor = .secondaryBlackColor()
            self.lblOrderStatus.textColor = status.color
            self.progressView.progressTintColor = status.color
           // self.lblOrderType.text = localizedString("title_Estimated_delivery", comment: "")
        }else if data.status_id.intValue == OrderStatus.canceled.rawValue {
            self.lblOrderType.textColor = .secondaryBlackColor()
            self.lblOrderStatus.textColor = status.color
            self.lblOrderType.isHidden = true
            self.lblDate.isHidden = true
            self.lblOrderType.isHidden = true
        }else if data.status_id.intValue == OrderStatus.enRoute.rawValue{
           // self.lblOrderType.text = localizedString("title_updated_delivery", comment: "")
          //  self.lblOrderType.textColor = .elGrocerYellowColor()
            self.lblOrderStatus.textColor = status.color
        }else{
            self.lblOrderType.textColor = .secondaryBlackColor()
            self.lblOrderStatus.textColor = status.color
            self.progressView.progressTintColor = status.color
        }
        
        // order prince // qunatity // date setting
        self.setOrderData(order: order , orderProducts: orderProducts ?? [] , orderItems: orderItems ?? [] )
    }
    
    
    func setOrderData( order : Order? , orderProducts : [Product] , orderItems : [ShoppingBasketItem] ) {
        
        guard order != nil else {return}
        
        var summaryCount = 0
        var priceSum = 0.0
        for product in orderProducts {
            let item = self.shoppingItemForProduct(product, orderItems: orderItems )
            if let notNilItem = item {
                if notNilItem.wasInShop.boolValue == true{
                    summaryCount += notNilItem.count.intValue
                    if product.promoPrice?.intValue == 0 || !(product.promotion?.boolValue ?? false) {
                        priceSum += product.price.doubleValue * notNilItem.count.doubleValue
                    }else{
                        priceSum += product.promoPrice!.doubleValue * notNilItem.count.doubleValue
                        
                    }
                   // priceSum += product.price.doubleValue * notNilItem.count.doubleValue
                }
            }
        }
        let countLabel = orderProducts.count == 1 ? localizedString("shopping_basket_items_count_singular", comment: "") : localizedString("shopping_basket_items_count_plural", comment: "")
        self.lblNumberOfItems.text = "(" + ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: "\(summaryCount) ") + countLabel + ")"
        let serviceFee = ElGrocerUtility.sharedInstance.getFinalServiceFee(currentGrocery: order!.grocery, totalPrice: priceSum)
            priceSum = priceSum + serviceFee
        if let promoCode = order!.promoCode {
            let promoCodeValue = promoCode.valueCents  as Double
            if priceSum - promoCodeValue <= 0.0 {
                priceSum = 0.0
            } else {
                priceSum = priceSum - promoCodeValue
            }
        }
        var grandTotal = priceSum
        if let price = Double(order!.priceVariance ?? "0") {
            grandTotal = grandTotal + price
        }
//        self.lblPrice.text = ("\(CurrencyManager.getCurrentCurrency()) " + (NSString(format: "%.2f", grandTotal) as String) as String)
        self.lblPrice.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: grandTotal)
        if order!.deliverySlot != nil  ,  order?.deliverySlot?.dbID != nil {
            self.lblDate.text  = order!.deliverySlot!.getSlotDisplayStringOnOrder(order!.grocery)
        }else{
            self.lblDate.text =  localizedString("60_min", comment: "")
        }
       
    }
    
    
    
    
    func setGrocery(grocery : Grocery?) {
        guard grocery != nil else {
            return
        }
        
        self.lblGrocery.text = grocery?.name ?? ""
        if grocery?.smallImageUrl != nil && grocery?.smallImageUrl?.range(of: "http") != nil {
            self.setGroceryImage(grocery!.smallImageUrl!)
        }else{
            self.imgGrocery.image = productPlaceholderPhoto
        }
    }
    
    
    fileprivate func setGroceryImage(_ urlString : String) {
        
        self.imgGrocery.sd_setImage(with: URL(string: urlString ), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: {[weak self] (image, error, cacheType, imageURL) in
            guard let self = self else {
                return
            }
            if cacheType == SDImageCacheType.none {
                
                UIView.transition(with: self.imgGrocery, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {[weak self] () -> Void in
                    guard let self = self else {
                        return
                    }
                    self.imgGrocery.image = image
                    }, completion: nil)
                
            }
        })
        
    }
    
    
}
