//
//  BrandHeaderCell.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 09.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

let kBrandHeaderCellIdentifier = "BrandHeaderCell"
let kBrandHeaderCellHeight: CGFloat = 155

class BrandHeaderCell : UICollectionReusableView {
    
    @IBOutlet weak var brandName: UILabel!
    @IBOutlet var brandImage: UIImageView!
    @IBOutlet var customCollectionViewWithBanners: CustomCollectionViewWithBanners!
    @IBOutlet var imageAspectRatio: NSLayoutConstraint!
    
    
    var placeholderPhoto = UIImage(name: "product_placeholder")!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpBrandNameLabelAppearance()
        customCollectionViewWithBanners.backgroundColor = .tableViewBackgroundColor()
        self.backgroundColor = .tableViewBackgroundColor()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: Appearance
    
    fileprivate func setUpBrandNameLabelAppearance() {
        
        self.brandName.textColor = UIColor.colorWithHexString(hexString: "333333")
        self.brandName.font = UIFont.SFProDisplaySemiBoldFont(20)
    }
    
   
    
    // MARK: Data
    
    
//    func configureWithBrand(_ currentBanner:[BannerCampaign] , _ grocery : Grocery? , _ brand:GroceryBrand) {
//        self.brandName.text = brand.name
//        self.customCollectionViewWithBanners.homeFeed = Home.init(withBanners: currentBanner , withType: .Banner, grocery: grocery)
//
//    }
    
    
    func configureWithBrand(_ brand:GroceryBrand, itemsCount:Int, isForBrandDeepLink: Bool = true) {

        self.brandName.text = brand.name
//        let countString = itemsCount == 1 ? localizedString("shopping_basket_items_count_singular", comment: "") : localizedString("shopping_basket_items_count_plural", comment: "")
//        self.brandItemsCount.text = "\(itemsCount) \(countString)"

        var brandImageUrl = ""
        if !isForBrandDeepLink {
            imageAspectRatio.setMultiplier(multiplier: 2.0)
        }
        if brand.products.count > 0 {

            let product =  brand.products[0]
            let brandObj = Brand.getBrandForProduct(product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            //sab
            //brandImageUrl =  brandObj != nil ? brandObj!.imageUrl! : brand.imageURL
            brandImageUrl =  brand.imageURL

        }else{
            brandImageUrl = brand.imageURL
        }
        self.brandImage.isHidden = false
        self.brandImage.sd_setImage(with: URL(string: brandImageUrl) , placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 0) , completed: {[weak self] (image, error, cacheType, imageURL) in
            guard image != nil else {return}
            if cacheType == SDImageCacheType.none {
                self?.brandImage.image = image
            }
        })

    }
   
    func configureWithProduct(_ title:String, brandImageUrl:String) {
        self.brandName.text = title
    }
//
    
    
    func configureWithSubcategory(_ currentBanner:[BannerCampaign] , _ grocery : Grocery?) {
        
        guard grocery != nil else {
            return
        }
        guard currentBanner.count > 0 else {
            return
        }
        self.brandName.text = ""
        if currentBanner.count == 1 {
            self.brandName.text = currentBanner[0].title
        }
        self.customCollectionViewWithBanners.homeFeed = Home.init(withBanners: currentBanner , withType: .Banner, grocery: grocery)
        
    }
}
