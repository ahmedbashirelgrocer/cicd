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
            productPrice.setBody3SemiBoldDarkStyle()
        }
    }
    @IBOutlet weak var oldPrice: UILabel!{
        didSet{
            oldPrice.setCaptionRegGreyStyle()
        }
    }
    
    func configureCell(product: LimitedTimeSavingsProduct, groceryId: String){
        oldPrice.strikeThrough(true)
        productImageView.assignImage(imageUrl: product.photo_url)
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
            self.productPrice.text = "AED 0.0"
            self.oldPrice.text = "AED 0.0"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 8
        self.layer.borderColor = UIColor.newBorderGreyColor().cgColor
    }

}
