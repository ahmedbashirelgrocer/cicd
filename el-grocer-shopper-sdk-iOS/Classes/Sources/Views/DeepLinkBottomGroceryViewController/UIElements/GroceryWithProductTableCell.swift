//
//  GroceryWithProductTableCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 16/12/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

class GroceryWithProductTableCell: UITableViewCell {
    
    @IBOutlet var productAndGroceryBGView: UIView!{
        didSet{
            productAndGroceryBGView.roundWithShadow(corners: [.layerMinXMinYCorner,.layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner ], radius: 16, withShadow: false)
        }
    }
    @IBOutlet var imgGrocery: UIImageView!
    @IBOutlet var productBGView: UIView!{
        didSet{
            productBGView.roundWithShadow(corners: [.layerMinXMinYCorner,.layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner ], radius: 16, withShadow: false)
            productBGView.layer.borderWidth = 1
            productBGView.layer.borderColor = UIColor.newBorderGreyColor().cgColor
        }
    }
    @IBOutlet var imgProduct: UIImageView!
    @IBOutlet var lblProductName: UILabel!{
        didSet{
            lblProductName.setBody2RegDarkStyle()
        }
    }
    @IBOutlet var lblProductDescription: UILabel!{
        didSet{
            lblProductDescription.setCaptionOneRegDarkStyle()
        }
    }
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblOrignalStrikePrice: UILabel!{
        didSet{
            lblOrignalStrikePrice.setCaptionTwoRegSecondaryBlackStyle()
        }
    }
    @IBOutlet var percentageBGView: UIView!{
        didSet{
            percentageBGView.backgroundColor = UIColor.promotionRedColor()
            percentageBGView.roundWithShadow(corners: [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner], radius: 8)
        }
    }
    @IBOutlet var lblPercentage: UILabel!{
        didSet{
            lblPercentage.setCaptionTwoSemiboldYellowStyle()
        }
    }
    @IBOutlet var plusBGView: UIView!{
        didSet{
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                plusBGView.roundWithShadow(corners: [.layerMinXMaxYCorner, .layerMaxXMinYCorner], radius: 16)
            }else {
                plusBGView.roundWithShadow(corners: [.layerMinXMinYCorner, .layerMaxXMaxYCorner], radius: 16)
            }
            
        }
    }
    @IBOutlet var imgPlus: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setAppearance()
    }
    func setAppearance() {
        self.selectionStyle = .none
    }

    @IBAction func btnPlusHandler(_ sender: Any) {
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func configureGroceryAndProduct(grocery: Grocery, product: Product){
        
        configureProduct(product: product, grocery)
        configureGrocery(grocery: grocery)
    }
    
    func configureGrocery(grocery: Grocery) {
        
        self.AssignImage(imageUrl: grocery.smallImageUrl ?? "", imageView: self.imgGrocery)
        
    }
    
    func configureProduct(product: Product, _ grocery: Grocery ) {
        
        self.lblProductName.text = product.name
        self.lblProductDescription.text = product.descr
        self.AssignImage(imageUrl: product.imageUrl ?? "", imageView: self.imgProduct)
        
        
        var priceValue : NSNumber? = nil
        
        var productPrice : NSNumber = NSNumber.init(value: 0.0)
        var promoPrice : NSNumber = NSNumber.init(value: 0.0)
        var promoDict : NSDictionary? = nil
        
        if let shopsA = product.shops {
            let shops = product.convertToDictionaryArray(text: shopsA)
            for shop in shops ?? [] {
                if let dbID = shop["retailer_id"] as? Int {
                    if "\(dbID)" == grocery.getCleanGroceryID() {
                        if let price = shop["price"] as? NSNumber {
                            priceValue = price
                            productPrice = price
                        }
                    }
                }
            }
        }
        
        var isPromotional = false
        
        if let shopsA = product.promotionalShops {
            let shops = product.convertToDictionaryArray(text: shopsA)
            for shop in shops ?? [] {
                if let dbID = shop["retailer_id"] as? Int {
                    if "\(dbID)" == grocery.getCleanGroceryID() {
                        let strtTime = shop["start_time"] as? Int ?? 0
                        let endTime = shop["end_time"] as? Int ?? 0
                        let time = ElGrocerUtility.sharedInstance.getCurrentMillisOfGrocery(id: "\(dbID)")
                        if strtTime <= time && endTime >= time {
                            if let price = shop["price"] as? NSNumber {
                                priceValue = price
                                promoPrice = price
                                promoDict  = shop
                                isPromotional = true
                            }
                        }
                    }
                }
            }
        }
        
        if let price = priceValue {
            self.setPrice(price: price)
        }
        self.setPromotionAppearance(isPromo: isPromotional)
        if let slotData = grocery.initialDeliverySlotData {
            
            /**
             {
             "end_time" = "2022-01-07T05:00:00Z";
             "estimated_delivery_at" = "2022-01-07T04:00:00Z";
             id = 135214;
             "start_time" = "2022-01-07T04:00:00Z";
             "time_milli" = 1641528000000;
             usid = 202201135214;
             }
             **/
            if let data = grocery.convertStringToDictionary(slotData), let time =  ElGrocerUtility.sharedInstance.getCurrentMillisOfGrocery(id: grocery.dbID) as? Int64 {
                let startTime = promoDict?["start_time"] as? Int64 ?? Int64(Date.getCurrentDate().timeIntervalSince1970)
                let endTime =  promoDict?["end_time"] as? Int64 ?? Int64(Date.getCurrentDate().timeIntervalSince1970)
                if startTime <= time && endTime >= time {
                    if productPrice.doubleValue > 0 && promoPrice.doubleValue > 0 {
                        let percentage = ProductQuantiy.getPercentageFromPrice(price: productPrice.doubleValue, promoPrice: promoPrice.doubleValue)
                        if productPrice.doubleValue > promoPrice.doubleValue {
                            setSpecialDiscountView(isNeedToShowPercentage: true, percentage: percentage)
                            self.setPrice(price: promoPrice)
                            self.lblOrignalStrikePrice.visibility = .visible
                            let priceToDisplay =  NSString(format: "%@ %.2f" ,CurrencyManager.getCurrentCurrency(), productPrice.doubleValue)
//                            self.lblOrignalStrikePrice.text = String(priceToDisplay)
                            self.lblOrignalStrikePrice.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: productPrice.doubleValue)
                            self.lblOrignalStrikePrice.strikeThrough(true)
                            return
                        }
                        if productPrice.doubleValue == promoPrice.doubleValue {
                            setSpecialDiscountView(isNeedToShowPercentage: false, percentage: percentage)
                            self.lblOrignalStrikePrice.strikeThrough(false)
                            if let price = priceValue {
                                self.setPrice(price: price)
                            }
                            return
                        }else {
                            setSpecialDiscountView(isNeedToShowPercentage: false, percentage: 0)
                            self.lblOrignalStrikePrice.strikeThrough(false)
                            if let price = priceValue {
                                self.setPrice(price: price)
                            }
                        }
                    }
                }else{
                    setSpecialDiscountView(isNeedToShowPercentage: false, percentage: 0)
                    self.lblOrignalStrikePrice.strikeThrough(false)
                    if let price = priceValue {
                        self.setPrice(price: price)
                    }
                }
                
            }
        }
       
  
    }
    
    func setSpecialDiscountView(isNeedToShowPercentage : Bool , percentage : Int) {
        
        if !isNeedToShowPercentage {
            self.lblOrignalStrikePrice.visibility = .goneX
            self.lblOrignalStrikePrice.attributedText = nil
            self.lblOrignalStrikePrice.text = ""
            self.lblPercentage.text = localizedString("lbl_Special_Discount", comment: "")
            self.percentageBGView.isHidden = false
//            self.strikeLblDistanceFromQtyLbl.constant = 23
//            self.lblDistanceFromPercentageView.constant = 0
        }else{
            self.lblPercentage.text = "-" + ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: String(percentage)) + " " + localizedString("txt_off", comment: "")
//            self.strikeLblDistanceFromQtyLbl.constant = 4
//            self.lblDistanceFromPercentageView.constant = 10
        }
        
    }
    
    func setPromotionAppearance(isPromo: Bool = false){
        if isPromo {
            self.percentageBGView.visibility = .visible
            self.lblOrignalStrikePrice.isHidden = false
        }else{
            self.percentageBGView.visibility = .gone
            self.lblOrignalStrikePrice.isHidden = true
        }
    }
    
    func setPrice (price: NSNumber) {

//            let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(12), NSAttributedString.Key.foregroundColor : UIColor.secondaryBlackColor()]
//            let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(16), NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()]
//            let attributedString1 = NSMutableAttributedString(string: CurrencyManager.getCurrentCurrency() , attributes:attrs1 as [NSAttributedString.Key : Any])
//            let priceToDisplay =  NSString(format: " %.2f" , price.doubleValue)
//            let attributedString2 = NSMutableAttributedString(string:priceToDisplay as String , attributes:attrs2 as [NSAttributedString.Key : Any])
//            attributedString1.append(attributedString2)
//            self.lblPrice.attributedText = attributedString1
        self.lblPrice.attributedText = ElGrocerUtility.sharedInstance.getPriceAttributedString(priceValue: price.doubleValue)
    }

    func AssignImage(imageUrl: String , imageView: UIImageView){
        if imageUrl != nil && imageUrl.range(of: "http") != nil {
            
            imageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: imageView, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        imageView.image = image
                        
                    }, completion: nil)
                }
            })
        }
    }
}
