//
//  SubstitutionItemCell.swift
//  ElGrocerShopper
//
//  Created by Azeem Akram on 23/11/2017.
//  Copyright © 2017 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

let kSubstitutionItemCellIdentifier = "SubstitutionItem"

let kSubstitutionItemCellHeight_cancel: CGFloat = 186
let kSubstitutionItemCellHeight_sub: CGFloat = 346

class SubstitutionItemCell: UITableViewCell {

    @IBOutlet weak var viewBase: AWView!
    @IBOutlet weak var imageViewProduct: UIImageView!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblProductDescription: UILabel!
    @IBOutlet weak var lblProductPrice: UILabel!
    
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var lblTotalPrice: UILabel!
    
    @IBOutlet weak var viewBanner: UIView!
    @IBOutlet weak var lblBanner: UILabel!
    @IBOutlet weak var saleView: UIImageView!
    
    
    var placeholderPhoto = UIImage(name: "product_placeholder")!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupAppearnace()
    }
    
    
    
    private func setupAppearnace(){
        self.lblProductName.font        = UIFont.SFProDisplayNormalFont(14.0)
        self.lblProductDescription.font = UIFont.SFProDisplayNormalFont(14.0)
        self.lblProductPrice.font       = UIFont.SFProDisplayNormalFont(14.0)
        
        self.quantityLabel.font         = UIFont.SFProDisplayNormalFont(14.0)
        self.quantityLabel.text         = NSLocalizedString("quantity_:", comment: "")
        self.lblQuantity.font           = UIFont.SFProDisplayNormalFont(14.0)
        
        self.totalLabel.font            = UIFont.SFProDisplayNormalFont(14.0)
        self.totalLabel.text            = NSLocalizedString("total_:", comment: "")
        self.lblTotalPrice.font         = UIFont.SFProDisplaySemiBoldFont(14.0)
        
        self.lblBanner.font             = UIFont.SFProDisplayBoldFont(14.0)
    }
    
    // MARK: Data
    
    func configureWithProduct(_ shoppingItem:ShoppingBasketItem, product:Product, shouldHidePrice:Bool, isProductAvailable:Bool, isSubstitutionAvailable:Bool, priceDictFromGrocery:NSDictionary?) {
        
        if product.name != nil {
            print("Product Name:%@",product.name ?? "Product Name NULL")
            self.lblProductName.text = product.name
        }
        if product.descr != nil {
            print("Product Description:%@",product.descr ?? "Product Description NULL")
            self.lblProductDescription.text = product.descr
        }
        
        self.lblProductPrice.text   = String(format: "%@ %.2f",CurrencyManager.getCurrentCurrency() , product.price.floatValue)
        
        self.lblQuantity.text       = String(format: "%@",shoppingItem.count)
        
        let priceSum = product.price.doubleValue * shoppingItem.count.doubleValue
        self.lblTotalPrice.text = String(format: "%@ %.2f", CurrencyManager.getCurrentCurrency() , priceSum)
        
        if product.imageUrl != nil && product.imageUrl?.range(of: "http") != nil {
            
            self.imageViewProduct.sd_setImage(with: URL(string: product.imageUrl!), placeholderImage: self.placeholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.imageViewProduct, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.imageViewProduct.image = image
                        
                    }, completion: nil)
                }
            })
        }
    
        var alphaImage = CGFloat(1.0)
        var alphaLabel = CGFloat(1.0)
        
        
        var isBannerHidden : Bool   = true
        var highlightColor          = UIColor.clear
        var bannerText              = ""
        
        
        if !isProductAvailable && !isSubstitutionAvailable {
            
            alphaImage      = CGFloat(0.4)
            alphaLabel      = CGFloat(0.2)
            
            isBannerHidden  = false
           highlightColor  = UIColor(red: 255.0/255.0,green: 116.0/255.0,blue: 115.0/255.0,alpha:1.0)
            bannerText      = NSLocalizedString("no_replacement_suggested_title", comment: "")
            
        }else if !isProductAvailable && isSubstitutionAvailable {
            alphaImage      = CGFloat(0.4)
            alphaLabel      = CGFloat(1.0)
            
            isBannerHidden  = false
            highlightColor  = UIColor(red: 255.0/255.0,green: 173.0/255.0,blue: 54.0/255.0,alpha:1.0)
            bannerText      = NSLocalizedString("replacement_suggested_title", comment: "")
        }
        
        self.viewBase.borderColor           = highlightColor
        self.viewBanner.isHidden            = isBannerHidden
        self.viewBanner.backgroundColor     = highlightColor
        self.lblBanner.text                 = bannerText
        
        self.imageViewProduct.alpha         = alphaImage
        
        self.lblProductName.alpha           = alphaLabel
        self.lblProductDescription.alpha    = alphaLabel
        self.lblProductPrice.alpha          = alphaLabel
        
        self.quantityLabel.alpha            = alphaLabel
        self.lblQuantity.alpha              = alphaLabel
        
        self.totalLabel.alpha               = alphaLabel
        self.totalLabel.alpha               = alphaLabel
        self.lblTotalPrice.alpha            = alphaLabel
        
        self.saleView.isHidden = !product.isPromotion.boolValue
        ElGrocerUtility.sharedInstance.setPromoImage(imageView:  self.saleView)
        
    }
}
