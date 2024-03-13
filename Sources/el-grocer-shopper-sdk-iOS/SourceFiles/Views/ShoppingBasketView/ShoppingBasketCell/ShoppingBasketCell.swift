//
//  ShoppingBasketCell.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 10.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

let kShoppingBasketCellIdentifier = "ShoppingBasketCell"
let kShoppingBasketCellHeight: CGFloat = 60

let kProductPriceLabelWidth: CGFloat = 60

class ShoppingBasketCell : UITableViewCell {
    
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var labelsLeftMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var priceLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var productDescriptionTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var notAvailableContainer: UIView!
    @IBOutlet weak var notAvailableLabel: UILabel!
    
    @IBOutlet weak var notSubstitutedContainer: UIView!
    @IBOutlet weak var notSubstitutedLabel: UILabel!
    @IBOutlet weak var productImage: AWImageView!
     var placeholderPhoto = UIImage(name: "product_placeholder")!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpProductNameAndDescriptionAppearance()
        setUpProductPriceAppearance()
        setUpQuantityLabelAppearance()
        setUpNotAvailableLabel()
        setUpNotSubstitutedLabel()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.productImage.sd_cancelCurrentImageLoad()
        self.productImage.image = self.placeholderPhoto
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        self.backgroundColor = highlighted ? UIColor.black.withAlphaComponent(0.2) : UIColor.clear
    }
    
    // MARK: Appearance
    
    fileprivate func setUpProductNameAndDescriptionAppearance() {
        
        
       // self.groceryName.font = UIFont.openSansSemiBoldFont(25.0)
       //  self.groceryAddress.font = UIFont.openSansRegularFont(17.0)
        
        self.productName.textColor = UIColor.colorWithHexString(hexString: "8e8d8f")
        self.productName.font = UIFont.SFProDisplayNormalFont(14.0)
        
        self.productDescription.textColor = UIColor.colorWithHexString(hexString: "102546")
        self.productDescription.font = UIFont.SFProDisplayNormalFont(12.0)
        
        
    }
    
    fileprivate func setUpProductPriceAppearance() {
        
       // self.productPrice.textColor = UIColor.black
        self.productPrice.font = UIFont.SFProDisplayNormalFont(13.0)
    }
    
    fileprivate func setUpQuantityLabelAppearance() {
        
       // self.quantityLabel.textColor = UIColor.white
        self.quantityLabel.font = UIFont.SFProDisplaySemiBoldFont(14.0)
    }
    
    fileprivate func setUpNotAvailableLabel() {
        
        self.notAvailableLabel.text = localizedString("shopping_basket_item_substituted", comment: "")
        self.notAvailableLabel.textColor = UIColor.black
        self.notAvailableLabel.font = UIFont.SFProDisplaySemiBoldFont(10.5)
    }
    
    fileprivate func setUpNotSubstitutedLabel() {
        
        self.notSubstitutedLabel.text = localizedString("shopping_basket_item_not_available", comment: "")
        self.notSubstitutedLabel.textColor = UIColor.black
        self.notSubstitutedLabel.font = UIFont.SFProDisplaySemiBoldFont(13.0)
    }
    
    // MARK: Data
    
    func configureWithProduct(_ shoppingItem:ShoppingBasketItem, product:Product, shouldHidePrice:Bool, isProductAvailable:Bool, isSubstitutionAvailable:Bool, priceDictFromGrocery:NSDictionary?) {
        
        let brand = Brand.getBrandForProduct(product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        var productDescription = ""

        if product.name != nil {
            productDescription += product.name!
        }
        if product.descr != nil {
            productDescription += productDescription.count > 0 ? " " + product.descr! : product.descr!
        }
        
        self.productName.text = brand != nil ? brand!.name : ""
        self.productDescription.text = productDescription
        self.quantityLabel.text = shoppingItem.count.intValue < 10 ? "0\(shoppingItem.count.intValue)" : "\(shoppingItem.count.intValue)"
        
        //move product decsription to center
        if self.productName.text == nil {
            
           // self.productDescriptionTopConstraint.constant = -self.productDescription.font.pointSize / 2
            
        } else {
            
          //  self.productDescriptionTopConstraint.constant = 0
        }
        
        if !shouldHidePrice {
                        
            var price = product.price
            if let priceFromGrocery = priceDictFromGrocery?["price_full"] as? NSNumber {
                price = priceFromGrocery
            }
            let finalPrice = price.doubleValue * shoppingItem.count.doubleValue
            price = NSNumber.init(value: finalPrice)
            
            
            
            
            //self.productPrice.attributedText = "\(price)".createTopAlignedPriceString(self.productPrice.font, price: price)
            self.productPrice.text = (NSString(format: "%.2f", price.floatValue) as String)
            self.productPrice.isHidden = false
           // self.priceLabelWidthConstraint.constant = kProductPriceLabelWidth
            
        } else {
            
            //self.priceLabelWidthConstraint.constant = 8
            self.productPrice.isHidden = true
        }
        
        self.notAvailableContainer.isHidden = isProductAvailable
        self.notSubstitutedContainer.isHidden = isSubstitutionAvailable
        
        
        if product.imageUrl != nil && product.imageUrl?.range(of: "http") != nil {
            
            self.productImage.sd_setImage(with: URL(string: product.imageUrl!), placeholderImage: self.placeholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: {[weak self] (image, error, cacheType, imageURL) in
                guard let self = self else {
                    return
                }
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.productImage, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {[weak self] () -> Void in
                        guard let self = self else {
                            return
                        }
                        self.productImage.image = image
                        }, completion: nil)
                }
            })
        }
        
        
     
    }
}
