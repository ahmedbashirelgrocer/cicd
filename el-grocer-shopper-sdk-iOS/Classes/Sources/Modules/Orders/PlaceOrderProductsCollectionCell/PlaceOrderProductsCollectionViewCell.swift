//
//  PlaceOrderProductsCollectionViewCell.swift
//  ElGrocerShopper
//
//  Created by Abubaker on 24/01/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import UIKit
import SDWebImage

class PlaceOrderProductsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var saleView: UIImageView!
    @IBOutlet weak var lblNumberOfItems: UILabel!
    
    var placeholderPhoto = UIImage(name: "product_placeholder")!
    
    // MARK: Data
    func configureWithProduct(_ product:Product) {
        
        self.lblNumberOfItems.font = UIFont.SFProDisplayBoldFont(8)
        self.lblNumberOfItems.layer.cornerRadius =  self.lblNumberOfItems.frame.size.width / 2.3
        self.lblNumberOfItems.clipsToBounds = true
        self.lblNumberOfItems.setNeedsLayout()
        self.lblNumberOfItems.layoutIfNeeded()
        self.lblNumberOfItems.text = "x1"
        if let item = ShoppingBasketItem.checkIfProductIsInBasket(product , grocery: ElGrocerUtility.sharedInstance.activeGrocery , context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
             self.lblNumberOfItems.text = "x" + "\(item.count.intValue)"
        }
        
        if product.imageUrl != nil && product.imageUrl?.range(of: "http") != nil {
            
            self.productImage.sd_setImage(with: URL(string: product.imageUrl!), placeholderImage: self.placeholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.productImage, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.productImage.image = image
                        
                    }, completion: nil)
                }
            })
        }
         self.productImage.layer.borderWidth = 1
         self.productImage.layer.borderColor = UIColor.navigationBarColor().cgColor
         self.productImage.layer.cornerRadius = 2
         self.saleView.isHidden = !product.isPromotion.boolValue
        ElGrocerUtility.sharedInstance.setPromoImage(imageView:  self.saleView)
        
        
    }
}
