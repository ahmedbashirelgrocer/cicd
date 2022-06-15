//
//  ItemCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 28/03/2018.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

let kItemCellIdentifier = "OrderTrackingItemCell"

class ItemCell: UICollectionViewCell {

    @IBOutlet weak var productImage: UIImageView!
    
    var placeholderPhoto = UIImage(named: "product_placeholder")!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: Data
    func configureWithProduct(_ product:Product) {
        
        if product.imageUrl != nil && product.imageUrl?.range(of: "http") != nil {
            
            self.productImage.sd_setImage(with: URL(string: product.imageUrl!), placeholderImage: self.placeholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.productImage, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.productImage.image = image
                        
                    }, completion: nil)
                }
            })
        }
    }
}
