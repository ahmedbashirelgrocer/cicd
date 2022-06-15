//
//  RecipeBannerCollectionViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 02/02/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

let KRecipeBannerCollectionViewCellIdentifier = "RecipeBannerCollectionViewCell"

class RecipeBannerCollectionViewCell: UICollectionViewCell {

    lazy var placeholderPhoto = UIImage(named: "product_placeholder")!
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pageControler: UIPageControl!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    
    func configureCell(_ banner: Banner, currentRow:NSInteger , numberOfBanner : NSInteger){
        
        pageControler.numberOfPages = numberOfBanner
        pageControler.currentPage = currentRow
        self.titleLabel.font = UIFont.SFProDisplaySemiBoldFont(18)
       // self.backgroundColor = banner.bannerBGColour
        
        let titleStr = String(format: "%@\n%@",banner.bannerTitle,banner.bannerSubTitle)
        self.titleLabel.text = titleStr
        self.titleLabel.textColor = banner.bannerTextColour
        
        if banner.bannerLinks.count > 0 {
            
            let bannerLink = banner.bannerLinks[0]
            
            if bannerLink.bannerLinkImageUrl.isEmpty == false {
                
                let finalUrl = bannerLink.bannerLinkImageUrl // .replacingOccurrences(of: "medium", with: "original")
                self.imgView.sd_setImage(with: URL(string: finalUrl), placeholderImage: self.placeholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                    if cacheType == SDImageCacheType.none {
                        
                        UIView.transition(with: self.imgView, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                            
                            self.imgView.image = image
                            
                        }, completion: nil)
                    }
                })
            }
        }
        
        
        imgView.setNeedsLayout()
        imgView.layoutIfNeeded()
    }

}
