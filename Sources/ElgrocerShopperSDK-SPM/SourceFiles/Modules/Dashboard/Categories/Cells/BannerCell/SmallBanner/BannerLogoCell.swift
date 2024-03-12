//
//  BannerLogoCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 13/06/2018.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage
let kBannerLogoCellIdentifier = "BannerLogoCell"

class BannerLogoCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    
    var placeholderPhoto = UIImage(name: "product_placeholder")!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.imgView.layer.cornerRadius = self.imgView.bounds.width/2
        self.imgView.layer.masksToBounds = true
    }
    
    // MARK: Data
    func configureCell(_ bannerLink: BannerLink, currentRow:NSInteger){
        
        if bannerLink.bannerLinkImageUrl.isEmpty == false{
            
            self.imgView.sd_setImage(with: URL(string: bannerLink.bannerLinkImageUrl), placeholderImage: self.placeholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.imgView, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.imgView.image = image
                        
                    }, completion: nil)
                }
            })
        }
    }
}
