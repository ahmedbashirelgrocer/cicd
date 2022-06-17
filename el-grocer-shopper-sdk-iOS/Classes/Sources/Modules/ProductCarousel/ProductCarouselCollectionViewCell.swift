//
//  ProductCarouselCollectionViewCell.swift
//  ElGrocerShopper
//
//  Created by Abubaker Majeed on 26/06/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

let KProductCarouselCollectionViewCellIdentifier  = "ProductCarouselCollectionViewCell"
let KCarouselCellWidth = 180
class ProductCarouselCollectionViewCell: UICollectionViewCell {
    let placeholderPhoto = UIImage(name: "product_placeholder")!
    @IBOutlet weak var bgView: UIView! 
    @IBOutlet weak var btnAddNow: UIButton!
    @IBOutlet weak var lblProductPrice: UILabel!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var imageProduct: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureWithProduct(_ product:Product) {

        self.lblProductName.text = product.name
        self.lblProductPrice.text = "\(String(describing: product.descr ?? "" )) \(product.price) \(CurrencyManager.getCurrentCurrency())"


        if product.imageUrl != nil && product.imageUrl?.range(of: "http") != nil {

            self.imageProduct.sd_setImage(with: URL(string: product.imageUrl!), placeholderImage: self.placeholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {

                    UIView.transition(with: self.imageProduct, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in

                        self.imageProduct.image = image

                    }, completion: nil)
                }
            })
        }
//        self.imageProduct.layer.borderWidth = 1
//        self.imageProduct.layer.borderColor = UIColor.navigationBarColor().cgColor
//        self.imageProduct.layer.cornerRadius = 2
    }

    
    @IBAction func addNowAction(_ sender: Any) {
        
    }
}
