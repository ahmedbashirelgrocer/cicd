//
//  SubCateReusableView.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 11/02/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit

let kSubCateHeaderCellIdentifier = "SubCateReusableView"
let kSubCateHeaderCellHeight: CGFloat = 150

class SubCateReusableView: UICollectionReusableView {

    
    @IBOutlet var customCollectionViewWithBanners: CustomCollectionViewWithBanners!
    var home : Home? = nil {
        didSet {
            if self.customCollectionViewWithBanners != nil {
                self.customCollectionViewWithBanners.homeFeed = home
            }
        }
        
    }
    
    var placeholderPhoto = UIImage(name: "product_placeholder")!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    // MARK: Data
    func configureWithSubcategory(_ currentBanner:[BannerCampaign]? , _  grocery : Grocery? = nil) {
        if currentBanner?.count ?? 0 > 0 {
            self.home = Home.init(withBanners: currentBanner, withType: .Banner, grocery: grocery)
        }
    }
    
    
    
    
  
    
    
}
