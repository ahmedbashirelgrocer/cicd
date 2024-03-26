//
//  OrderProductCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 17/04/2018.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

let kOrderProductCellIdentifier = "OrderProductCell"

class OrderProductCell: UICollectionViewCell {

    var product : Product?
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var saleView: UIImageView!
    @IBOutlet var lblProductCount: UILabel!{
        didSet{
            lblProductCount.backgroundColor = ApplicationTheme.currentTheme.viewthemePrimaryBlackBGColor
        }
    }
    @IBOutlet var lblProductCountView: AWView! {
        didSet{
            lblProductCountView.backgroundColor = ApplicationTheme.currentTheme.viewthemePrimaryBlackBGColor
        }
    }
    @IBOutlet var lblOutOfStock: UILabel! {
        didSet{
            lblOutOfStock.text =   localizedString("out_of_stock_title", comment: "")
        }
    }
    
    @IBOutlet var oosView: UIView!
    @IBOutlet var percentageBGView: UIView!{
        didSet{
            percentageBGView.backgroundColor = ApplicationTheme.currentTheme.viewthemePrimaryBlackBGColor
            percentageBGView.layer.cornerRadius = 8
            percentageBGView.layer.maskedCorners = [.layerMaxXMaxYCorner , .layerMinXMaxYCorner]
            percentageBGView.clipsToBounds = true
        }
    }
    @IBOutlet var lblPercentage: UILabel!{
        didSet{
            lblPercentage.setCaptionTwoSemiboldYellowStyle()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        self.productImage.layer.borderColor = UIColor.borderGrayColor().cgColor
//        self.productImage.layer.borderWidth = 1.0
        self.loadSaleTag()
        self.showPromotionView()
    }
    
    var placeholderPhoto = UIImage(name: "product_placeholder")!
    func loadSaleTag(){
        ElGrocerUtility.sharedInstance.setPromoImage(imageView:  self.saleView)
    }
    func showPromotionView(_ isHidden : Bool = true , _ value : Int = 0) {
        
        if !isHidden{
            self.percentageBGView.isHidden = isHidden
            let stringPercent = ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: String(value))
            self.lblPercentage.text = "-" + stringPercent + localizedString("txt_off", comment: "")
            self.saleView.isHidden = true
            if value < 1{
                self.lblPercentage.text = localizedString("lbl_Special_Discount", comment: "")
                self.saleView.isHidden = false
            }
        }else{
            self.percentageBGView.isHidden = isHidden
            self.saleView.isHidden = true
        }
    }
    
    // MARK: Data
    func configureWithProduct(_ product:Product) {
        
        self.product = product
        
        self.lblProductCount.isHidden = true

        ElGrocerUtility.sharedInstance.setPromoImage(imageView:  self.saleView)
        
        if product.imageUrl != nil && product.imageUrl?.range(of: "http") != nil {
            
            self.productImage.sd_setImage(with: URL(string: product.imageUrl!), placeholderImage: self.placeholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.productImage, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.productImage.image = image
                        
                    }, completion: nil)
                }
            })
        }
        let promotionValues = ProductQuantiy.checkPromoNeedToDisplay(product)
        if promotionValues.isNeedToDisplayPromo {
            let percentage = ProductQuantiy.getPercentage(product: product)
            showPromotionView(!promotionValues.isNeedToDisplayPromo, percentage)
        }else{
            showPromotionView()
        }
        
    }
    
    
    func configureWithProductAndSetItemlable(_ product:Product , shoppingItem : ShoppingBasketItem?) {
        self.product = product
         self.lblProductCount.isHidden = true
        
       
        
        
        //self.saleView.isHidden = !product.isPromotion.boolValue
        //ElGrocerUtility.sharedInstance.setPromoImage(imageView:  self.saleView)
        
        if product.imageUrl != nil && product.imageUrl?.range(of: "http") != nil {
            
            self.productImage.sd_setImage(with: URL(string: product.imageUrl!), placeholderImage: self.placeholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.productImage, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.productImage.image = image
                        
                    }, completion: nil)
                }
            })
        }
        let promotionValues = ProductQuantiy.checkPromoNeedToDisplay(product)
        if promotionValues.isNeedToDisplayPromo{
            let percentage = ProductQuantiy.getPercentage(product: product)
            showPromotionView(!promotionValues.isNeedToDisplayPromo, percentage)
        }else{
            showPromotionView()
        }
        
        if let item = shoppingItem {
            if !(product.isAvailable.boolValue && product.isPublished.boolValue)  {
                // out of stock logic
                oosView.isHidden = false
            }else{
                oosView.isHidden = true
            }
            self.lblProductCount.isHidden = false
            let count =  item.count.stringValue
            self.lblProductCount.text = "x" + count
        }else{
            oosView.isHidden = false
        }
        
    }
    
    func getPercentage(product : Product) -> Int{
        
        guard let promoPrice = product.promoPrice as? Double else{return 0}
        guard let price = product.price as? Double else{return 0}
        
        var percentage : Double = 0
        if price > 0{
            let percentageDecimal = ((price - promoPrice)/price)
            percentage = percentageDecimal * 100
           // percentage  = (promoPrice / price) * 100
        }
        
        
        return Int(percentage)
    }
    
    func configureWithProductImage(_ productURLString:String?) {
        self.oosView.isHidden  = true
        self.lblProductCount.isHidden = true
        self.lblProductCountView.isHidden = true
//        self.saleView.isHidden = !product.isPromotion.boolValue
//        ElGrocerUtility.sharedInstance.setPromoImage(imageView:  self.saleView)
        
        if productURLString != nil && productURLString?.range(of: "http") != nil {
            
            self.productImage.sd_setImage(with: URL(string: productURLString!), placeholderImage: self.placeholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.productImage, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.productImage.image = image
                        
                    }, completion: nil)
                }
            })
        }
    }
    
    func configureWithProductImageDictionary(_ data:NSDictionary?) {
        
        if let isShop = (data?["was_in_shop"] as? NSNumber) {
            self.oosView.isHidden = isShop.boolValue
        }else{
            self.oosView.isHidden  = true
        }
        
        if let count =  data?["amount"] {
            self.lblProductCount.isHidden = false
            self.lblProductCountView.isHidden = false
            self.lblProductCount.text = "x" + String(describing: count)
        }else{
            self.lblProductCount.isHidden = true
            self.lblProductCountView.isHidden = true
        }
        
        if let dataDict = data{
            let promotionValues = ProductQuantiy.checkPromoNeedToDisplayOrderProductDict(dataDict)
            if promotionValues.isNeedToDisplayPromo{
                let percentage = ProductQuantiy.getPercentageOrderProductDict(productDict: dataDict)
                showPromotionView(!promotionValues.isNeedToDisplayPromo, percentage)
            }else{
                showPromotionView()
            }
        }
    
        let productURLString = data?["image_url"] as? String
        if productURLString != nil && productURLString?.range(of: "http") != nil {
            
            self.productImage.sd_setImage(with: URL(string: productURLString!), placeholderImage: self.placeholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.productImage, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.productImage.image = image
                        
                    }, completion: nil)
                }
            })
        }
    }
}
