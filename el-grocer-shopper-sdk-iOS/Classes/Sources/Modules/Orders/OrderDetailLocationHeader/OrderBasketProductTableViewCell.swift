//
//  OrderBasketProductTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 28/11/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

let KOrderBasketProductTableViewCellHeight = CGFloat(160)
class OrderBasketProductTableViewCell: UITableViewCell {
    var placeholderPhoto = UIImage(name: "product_placeholder")!
    
    @IBOutlet var saleView: UIImageView!
    @IBOutlet var imageProduct: UIImageView!
    @IBOutlet var productName: UILabel!
    @IBOutlet var productQuantity: UILabel! {
        didSet {
            productQuantity.setTextStyleWhite()
            productQuantity.backgroundColor = ApplicationTheme.currentTheme.viewthemePrimaryBlackBGColor
            productQuantity.layer.cornerRadius = 12
            productQuantity.textAlignment = .center
            productQuantity.clipsToBounds = true
        }
    }
    @IBOutlet weak var productUnit: UILabel!
    
    @IBOutlet var productPrice: UILabel!
    @IBOutlet var lblStrikePrice: UILabel!{
        didSet{
            lblStrikePrice.setCaptionTwoRegDarkStyle()
        }
    }
    @IBOutlet var percentageViewDistaceFromStrikeLbl: NSLayoutConstraint!
    @IBOutlet var percentOffBGView: UIView!{
        didSet{
            percentOffBGView.backgroundColor = ApplicationTheme.currentTheme.viewthemePrimaryBlackBGColor
            percentOffBGView.layer.cornerRadius = 8
            percentOffBGView.clipsToBounds = true
        }
    }
    @IBOutlet var lblPercent: UILabel!{
        didSet{
            lblPercent.setCaptionTwoSemiboldYellowStyle()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageProduct.sd_cancelCurrentImageLoad()
        self.imageProduct.image =  self.placeholderPhoto
    }
    
    func configureProduct (_ product : Product , grocery : Grocery? , item : ShoppingBasketItem?, orderPosition: NSDictionary? = nil) {
        
        guard grocery != nil else {
            return
        }
        guard item != nil else {
            return
        }
        ElGrocerUtility.sharedInstance.setPromoImage(imageView:  self.saleView)
        
        // set Image
        if product.imageUrl != nil && product.imageUrl?.range(of: "http") != nil {
            
            self.imageProduct.sd_setImage(with: URL(string: product.imageUrl!), placeholderImage: self.placeholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: {[weak self] (image, error, cacheType, imageURL) in
                guard let self = self else {
                    return
                }
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.imageProduct, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {[weak self] () -> Void in
                        guard let self = self else {
                            return
                        }
                        self.imageProduct.image = image
                        }, completion: nil)
                }
            })
        }
      
        // setName and qunatiy
        self.productName.text = product.name

        let itemsCount = item!.count.intValue
        // let countLabel = itemsCount == 1 ? localizedString("shopping_basket_items_count_singular", comment: "") : localizedString("shopping_basket_items_count_plural", comment: "")
        
        self.productQuantity.text  = "x\(itemsCount)" //"(" + ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: "\(itemsCount)") + " "  + countLabel + ")"
        
//        if(actual_weight == 0.0){
//            unit_weight + product_size_unit
//        } else{
//            actual_weight /quantity+ product_size_unit
//        }
        
        if let orderPosition = orderPosition {
            var unit = ""
            
            let aWeight = (orderPosition["actual_weight"] as? NSNumber) ?? 0
            let uWeight = orderPosition["unit_weight"] as? NSNumber ?? 0
            let psUnit = orderPosition["product_size_unit"] as? String ?? ""
            
            if aWeight == 0 {
                self.productUnit.text = (uWeight > 0 ? "\(uWeight)": "") + psUnit
            } else {
                self.productUnit.text = "\(round(aWeight.doubleValue / Double(itemsCount) * 100) / 100)" + psUnit
            }
        }
        
        
//        self.lblStrikePrice.text = localizedString("aed", comment: "") + " " + product.price.doubleValue.formateDisplayString()
        self.lblStrikePrice.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: product.price.doubleValue)
        self.lblStrikePrice.strikeThrough(true)
        let stringPercent = ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: String(ElGrocerUtility.sharedInstance.getPercentage(product: product ,  true)))
        self.lblPercent.text = "-" + stringPercent + localizedString("txt_off", comment: "")
        
        let promotionValues = ProductQuantiy.checkPromoNeedToDisplayWithoutTimeCheckForOrders(product)
        if promotionValues.isNeedToDisplayPromo {
            self.lblStrikePrice.isHidden = false
            self.percentOffBGView.isHidden = false
//            self.productPrice.text = (NSString(format: "%@ %.2f",CurrencyManager.getCurrentCurrency() , product.orderPromoPrice?.doubleValue ?? 0.0) as String)
            self.productPrice.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: product.orderPromoPrice?.doubleValue ?? 0.0)
            
//            let attrs1ForPromtion = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(12), NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()]
//            let attrs2Promotion = [NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(16), NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()]
//            let attributedString1Promotion = NSMutableAttributedString(string: CurrencyManager.getCurrentCurrency() , attributes:attrs1ForPromtion as [NSAttributedString.Key : Any])
//            let pricePromotion =  NSString(format: " %.2f" , product.orderPromoPrice?.doubleValue ?? 0.0)
//            let attributedString2Promotion = NSMutableAttributedString(string:pricePromotion as String , attributes:attrs2Promotion as [NSAttributedString.Key : Any])
//            attributedString1Promotion.append(attributedString2Promotion)
//            self.productPrice.attributedText = attributedString1Promotion
            self.productPrice.attributedText = ElGrocerUtility.sharedInstance.getPriceAttributedString(priceValue: product.orderPromoPrice?.doubleValue ?? 0.0)
            
            if !promotionValues.isNeedToShowPromoPercentage {
                self.lblStrikePrice.visibility = .goneX
                self.lblStrikePrice.attributedText = nil
                self.lblStrikePrice.text = ""
                self.lblPercent.text = localizedString("lbl_Special_Discount", comment: "")
                self.percentOffBGView.isHidden = false
                self.percentageViewDistaceFromStrikeLbl.constant = 0
                self.saleView.isHidden = false
            }else{
                self.percentageViewDistaceFromStrikeLbl.constant = 8
                self.lblStrikePrice.visibility = .visible
                self.saleView.isHidden = true
            }
        } else if promotionValues.isNeedToDisplayPromo {
            
            
        }else {
            self.lblStrikePrice.isHidden = true
            self.percentOffBGView.isHidden = true
            
//            self.productPrice.text = (NSString(format: "%@ %.2f",CurrencyManager.getCurrentCurrency() , product.price.doubleValue) as String)
            self.productPrice.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price:  product.price.doubleValue)
            
//            let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(10), NSAttributedString.Key.foregroundColor : UIColor(red: 0.347, green: 0.347, blue: 0.347, alpha: 1)]
//            let attrs2 = [NSAttributedString.Key.font :UIFont.SFProDisplayNormalFont(15), NSAttributedString.Key.foregroundColor : UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)]
//            let attributedString1 = NSMutableAttributedString(string: CurrencyManager.getCurrentCurrency() , attributes:attrs1 as [NSAttributedString.Key : Any])
//            let price =  NSString(format: " %.2f" , product.price.doubleValue)
//            let attributedString2 = NSMutableAttributedString(string:price as String , attributes:attrs2 as [NSAttributedString.Key : Any])
//            attributedString1.append(attributedString2)
//            self.productPrice.attributedText = attributedString1
            self.productPrice.attributedText = ElGrocerUtility.sharedInstance.getPriceAttributedString(priceValue: product.price.doubleValue)
            self.saleView.isHidden = true
        }
       
    
        
    }
    
    fileprivate func getAttributedString(_ title:String, description:String) -> NSMutableAttributedString {
        
        let dict1 = [NSAttributedString.Key.foregroundColor: UIColor.colorWithHexString(hexString: "909090"),NSAttributedString.Key.font:UIFont.SFProDisplaySemiBoldFont(16)]
        
        let dict2 = [NSAttributedString.Key.foregroundColor: UIColor.colorWithHexString(hexString: "333333"),NSAttributedString.Key.font:UIFont.SFProDisplaySemiBoldFont(16.0)]
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4.0
        
        
        let titlePart = NSMutableAttributedString(string:String(format:"%@ ",title), attributes:dict1)
        titlePart.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, titlePart.length))
        
        let descriptionPart = NSMutableAttributedString(string:description, attributes:dict2)
        
        let attttributedText = NSMutableAttributedString()
        
        attttributedText.append(titlePart)
        attttributedText.append(descriptionPart)
        
        return attttributedText
    }
    
}
