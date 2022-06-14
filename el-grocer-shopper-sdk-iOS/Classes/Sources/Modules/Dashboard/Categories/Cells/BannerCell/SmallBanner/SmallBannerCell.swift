//
//  SmallBannerCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 12/06/2018.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit
let kSmallBannerCellIdentifier = "SmallBannerCell"

protocol SmallBannerCellDelegate : class {
    func samllBannerTapHandlerWithBannerLink(_ bannerLink: BannerLink)
}

class SmallBannerCell: UICollectionViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bannerImage: UIImageView!
    
    weak var delegate:SmallBannerCellDelegate?
    
    private var banner:Banner!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let bannerTitleCellNib = UINib(nibName: "BannerTitleCell", bundle:nil)
        self.collectionView.register(bannerTitleCellNib, forCellWithReuseIdentifier: kBannerTitleCellIdentifier)
        
        let bannerLogoCellNib = UINib(nibName: "BannerLogoCell", bundle:nil)
        self.collectionView.register(bannerLogoCellNib, forCellWithReuseIdentifier: kBannerLogoCellIdentifier)
        
        
      
        
        
    }
    
    // MARK: Data
    func configureCell(_ banner: Banner?, currentRow:NSInteger){
        
        guard banner != nil else {
            return
        }

       // self.collectionView.backgroundColor = banner.bannerBGColour
        self.banner = banner
        
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
            self.collectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.collectionView.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
        }
        
        self.collectionView.reloadData()
        
        self.bannerImage.layer.cornerRadius = 5
        self.bannerImage.layer.cornerRadius = 5
        self.bannerImage.clipsToBounds = true
        self.bannerImage.setNeedsLayout()
        self.bannerImage.layoutIfNeeded()
        let bannerLink = self.banner.bannerLinks[1]
        if bannerLink.bannerLinkImageUrl.isEmpty == false{
            
            self.bannerImage.sd_setImage(with: URL(string: bannerLink.bannerLinkImageUrl), placeholderImage: UIImage(named: "product_placeholder"), options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.bannerImage, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.bannerImage.image = image
                        
                    }, completion: nil)
                }
            })
        }
        
    }
}

extension SmallBannerCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard self.banner != nil else {
            return 0
        }
        return self.banner.bannerLinks.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell: UICollectionViewCell
        if indexPath.row == 0 {
            let bannerTitleCell = collectionView.dequeueReusableCell(withReuseIdentifier: kBannerTitleCellIdentifier, for: indexPath) as! BannerTitleCell
            bannerTitleCell.configureCell(self.banner, currentRow: indexPath.row)
            cell = bannerTitleCell
        }else{
            let bannerLogoCell = collectionView.dequeueReusableCell(withReuseIdentifier: kBannerLogoCellIdentifier, for: indexPath) as! BannerLogoCell
            let bannerLink = self.banner.bannerLinks[indexPath.row - 1]
            bannerLogoCell.configureCell(bannerLink, currentRow: indexPath.row)
            cell = bannerLogoCell
        }
        
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
            cell.contentView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        
        return cell
    }
}

extension SmallBannerCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row != 0 {
            let bannerLink = self.banner.bannerLinks[indexPath.row - 1]
            let isSingle =   self.banner.bannerGroup.int32Value != KRecipeBannerID
            
            FireBaseEventsLogger.trackBrandBanner(isSingle: isSingle  , brandName: ElGrocerUtility.sharedInstance.isArabicSelected() ? bannerLink.bannerBrand?.nameEn ?? "" : bannerLink.bannerBrand?.name ?? "" , bannerLink.bannerCategory?.nameEn ?? bannerLink.bannerCategory?.name ?? ""  , bannerLink.bannerSubCategory?.subCategoryNameEn ?? bannerLink.bannerSubCategory?.subCategoryName ?? "" , link : bannerLink, possition: String(describing: indexPath.row + 1))
            
            // we are adding delay so delegate do it work and banner screen is displayed. then we add this event
            // FireBaseEventsLogger.trackBrandBanner(isSingle: false, brandName: ElGrocerUtility.sharedInstance.isArabicSelected() ? bannerLink.bannerBrand?.nameEn ?? "" : bannerLink.bannerBrand?.name ?? "" )
            
             GoogleAnalyticsHelper.trackEventName(GoogleAnalyticsHelper.kMultiBrandTypeEvent,  ElGrocerUtility.sharedInstance.isArabicSelected() ? bannerLink.bannerBrand?.nameEn ?? "" : bannerLink.bannerBrand?.name ?? "")
             self.delegate?.samllBannerTapHandlerWithBannerLink(bannerLink)
        }
    }
}

extension SmallBannerCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard self.banner != nil else {
            return CGSize.zero
        }
        
        if indexPath.row == 0 {
            // create a cell size, and return it
            return CGSize(width: 200, height:  collectionView.frame.height)
        }else{
            return CGSize(width: 60, height: 60)
        }
    }
}
