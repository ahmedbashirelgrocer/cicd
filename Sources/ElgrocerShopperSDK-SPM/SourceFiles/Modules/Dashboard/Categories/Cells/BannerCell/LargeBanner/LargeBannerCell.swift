//
//  LargeBannerCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 10/06/2018.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

let kLargeBannerCellIdentifier = "LargeBannerCell"

class LargeBannerCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var disclosureImgView: UIImageView!
    @IBOutlet var bannerImgView: UIImageView!
    @IBOutlet var lblExclusiveLable: UILabel!
    @IBOutlet var imageLeadingPossitionConstraint: NSLayoutConstraint!
    
    var placeholderPhoto = UIImage(name: "product_placeholder")!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        
        self.imgView.layer.cornerRadius = self.imgView.bounds.width/2
        self.imgView.layer.masksToBounds = true
        
        let image = ElGrocerUtility.sharedInstance.getImageWithName("Disclosure Arrow")
        self.disclosureImgView.image = image
    }
    
    // MARK: Data
    func configureCell(_ banner: Banner, currentRow:NSInteger , _ isNeedToShowTopTitle : Bool = false){
        
        ///self.backgroundColor = banner.bannerBGColour
        
        let titleStr = String(format: "%@\n%@",banner.bannerTitle,banner.bannerSubTitle)
        self.titleLabel.text = titleStr
        
        self.titleLabel.textColor = banner.bannerTextColour
//        self.lblExclusiveLable.text = "  " + banner.bannerTitle + "  "
//        self.lblExclusiveLable.layer.cornerRadius = self.lblExclusiveLable.frame.size.height / 2
//        self.lblExclusiveLable.clipsToBounds = true
//        self.lblExclusiveLable.isHidden = !isNeedToShowTopTitle
    //    imageLeadingPossitionConstraint.constant = self.lblExclusiveLable.isHidden ? 0:5
        
        if banner.bannerLinks.count > 0 {
            
            let bannerLink = banner.bannerLinks[0]
            
            if bannerLink.bannerLinkImageUrl.isEmpty == false{
                
                self.bannerImgView.sd_setImage(with: URL(string: bannerLink.bannerLinkImageUrl), placeholderImage: self.placeholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                    if cacheType == SDImageCacheType.none {
                        
                        UIView.transition(with: self.bannerImgView, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                            
                            self.bannerImgView.image = image
                            
                        }, completion: nil)
                    }
                    
                    self.bannerImgView.layer.cornerRadius = 5
                    self.bannerImgView.clipsToBounds = true
                    self.bannerImgView.setNeedsLayout()
                    self.bannerImgView.layoutIfNeeded()
                    
                })
            }
        }
        
        
        
        self.bannerImgView.layer.cornerRadius = 5
        self.bannerImgView.clipsToBounds = true
        self.bannerImgView.setNeedsLayout()
        self.bannerImgView.layoutIfNeeded()
    }
}
