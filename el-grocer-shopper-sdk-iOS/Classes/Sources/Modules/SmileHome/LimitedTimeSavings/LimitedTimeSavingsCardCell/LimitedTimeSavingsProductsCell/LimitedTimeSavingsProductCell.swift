//
//  LimitedTimeSavingsProductCell.swift
//  Adyen
//
//  Created by ELGROCER-STAFF on 01/04/2024.
//

import UIKit
import SDWebImage
class LimitedTimeSavingsProductCell: UICollectionViewCell {

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productPrice: UILabel!{
        didSet{
            productPrice.setCaptionOneBoldDarkStyle()
        }
    }
    @IBOutlet weak var oldPrice: UILabel!{
        didSet{
            oldPrice.setCaptionRegGreyStyle()
        }
    }
    
    func configureCell(product: LimitedTimeSavingsProduct, groceryId: String){
        oldPrice.strikeThrough(true)
        self.AssignImage(imageUrl: product.photo_url)
        //productImageView.assignImage(imageUrl: product.photo_url)
        //let shops = product.shops.filter { (String($0.retailer_id) == groceryId) }
        //let promotionalShops = product.promotionalShops.filter { (String($0.retailer_id) == groceryId) }
        if(product.promotionalShop != nil){
            self.productPrice.text = product.promotionalShop!.price_currency + " " + product.promotionalShop!.price
            if(product.shop != nil){
                self.oldPrice.text = product.shop!.price_currency + " " + product.shop!.price
            }else{
                self.oldPrice.text = "AED 0.0"
            }
        }else{
            if(product.shop != nil){
                self.productPrice.text = product.shop!.price_currency + " " + product.shop!.price
                self.oldPrice.text = product.shop!.price_currency + " " + product.shop!.price
            }else{
                self.productPrice.text = "AED 0.0"
                self.oldPrice.text = "AED 0.0"
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 8
        self.layer.borderColor = UIColor.newBorderGreyColor().cgColor
    }

}
extension LimitedTimeSavingsProductCell{
    func AssignImage(imageUrl: String){
        if imageUrl != nil && imageUrl.range(of: "http") != nil {
            
            self.productImageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.productImageView, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.productImageView.image = image
                        
                    }, completion: nil)
                }
                if(error?.localizedDescription != nil){
                    self.productImageView.image = productPlaceholderPhoto
                }
            })
        }
    }
}
