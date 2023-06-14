//
//  GroceryCellForHome.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 12/06/2023.
//

import UIKit
import SDWebImage

class GroceryCellForHome: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblFreeDelivery: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 8
        clipsToBounds = true
        backgroundColor = .navigationBarWhiteColor()
        
        lblFreeDelivery.setCaptionOneBoldYellowStyle()
        lblFreeDelivery.backgroundColor = UIColor.promotionRedColor()
        
        imageView.sd_imageIndicator = SDWebImageActivityIndicator.medium
        lblFreeDelivery.isHidden = true
    }
}

extension GroceryCellForHome {
    func configure(grocery: Grocery) {
        if let urlString = grocery.smallImageUrl, let url = URL(string: urlString) {
            imageView.sd_setImage(with: url)
        }
        
        // lblFreeDelivery.isHidden = grocery.featured != 1
    }
}
