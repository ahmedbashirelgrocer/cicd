
//
//  GenricBannerList.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 28/07/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import Foundation
import MSPeekCollectionViewDelegateImplementation
import RxSwift
import RxCocoa

class GenricBannerList : CustomCollectionView {
   
    
    var isCurrentScrolling: ((_ scrolling : Bool?)->Void)?
    var behavior: MSCollectionViewPeekingBehavior!
    
    var collectionData : [Any] = [Any]()
    var bannerCliked: ((_ bannerLink : Banner )->Void)?
    var bannerCampaignClicked: ((_ bannerLink : BannerCampaign )->Void)?
    var bannerClicked: ((BannerDTO)->())?
    var currentPage: ((_ currentPage : Int , _ collectionView : UICollectionView )->Void)?
   // private var indexOfCellBeforeDragging = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        self.registerCellsAndSetDelegateAndDataSource()
        self.setUpInitialApearance()
    }
    
    func setUpInitialApearance() {
        self.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
    }
    
    func registerCellsAndSetDelegateAndDataSource () {
        
        self.addCollectionViewWithDirection(.horizontal)
        let genericBannerCollectionViewCell = UINib(nibName: KGenericBannerCollectionViewCell , bundle: Bundle.resource)
        self.collectionView?.register(genericBannerCollectionViewCell, forCellWithReuseIdentifier: KGenericBannerCollectionViewCell )
        self.collectionView?.isScrollEnabled = true
       // self.collectionView?. = true
       
         //  behavior = MSCollectionViewPeekingBehavior()
        self.behavior = MSCollectionViewPeekingBehavior(cellSpacing: CGFloat(5), cellPeekWidth: CGFloat(10))
        self.collectionView?.configureForPeekingBehavior(behavior: behavior)
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView?.reloadData()
        
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
            self.collectionView?.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.collectionView?.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
        }
        
        
        
    }
    
    func configureData (_ dataA : [Banner]) {
        collectionData = dataA
        UIView.performWithoutAnimation {
            self.layoutIfNeeded()
            self.collectionView?.reloadData()
        }
        
    }
    
    func configureData (_ dataA : [BannerCampaign]) {
        collectionData = dataA
        UIView.performWithoutAnimation {
            self.layoutIfNeeded()
            self.collectionView?.reloadData()
        }
        
        
    }
    
}

// MARK: Rx Extension for binding Banner View with BannerDTOs
extension Reactive where Base: GenricBannerList {
    var banners: Binder<[BannerDTO]> {
        return Binder(self.base) { bannerListView, banners in
            bannerListView.collectionData = banners
            
            UIView.performWithoutAnimation {
                bannerListView.layoutIfNeeded()
                bannerListView.collectionView?.reloadData()
            }
        }
    }
}

extension GenricBannerList : UICollectionViewDelegate , UICollectionViewDataSource , UIScrollViewDelegate {
    
    
    // MARK:- UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionData.count  // return collectionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KGenericBannerCollectionViewCell , for: indexPath) as! GenericBannerCollectionViewCell
        if self.collectionData.count > indexPath.row {
            if self.collectionData[indexPath.row] is BannerCampaign {
                let banner : BannerCampaign = self.collectionData[indexPath.row] as! BannerCampaign
                
                let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
                if currentLang == "ar" {
                    cell.bannerImage.transform = CGAffineTransform(scaleX: -1, y: 1)
                    cell.bannerImage.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
                }
                cell.setImage(banner.getFinalImage())
                
                
            }else if self.collectionData[indexPath.row] is Banner  {
                let banner : Banner = self.collectionData[indexPath.row] as! Banner
                let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
                if currentLang == "ar" {
                    cell.setImage(banner.bannerLinks[0].bannerLinkImageUrlAr)
                    if banner.bannerLinks[0].bannerLinkImageUrlAr.count == 0 {
                        cell.setImage(banner.bannerLinks[0].bannerLinkImageUrl)
                    }
                    cell.bannerImage.transform = CGAffineTransform(scaleX: -1, y: 1)
                    cell.bannerImage.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
                }else{
                    cell.setImage(banner.bannerLinks[0].bannerLinkImageUrl)
                }
            } else if self.collectionData[indexPath.row] is BannerDTO {
                let banner: BannerDTO = self.collectionData[indexPath.row] as! BannerDTO
                
                let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
                if currentLang == "ar" {
                    cell.bannerImage.transform = CGAffineTransform(scaleX: -1, y: 1)
                    cell.bannerImage.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
                }
                cell.setImage(banner.imageURL)
            }
        }
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard indexPath.row < self.collectionData.count else {return}
        
        if self.collectionData[indexPath.row] is BannerCampaign {
            let banner : BannerCampaign = self.collectionData[indexPath.row] as! BannerCampaign
            
            let bannerID = banner.dbId.stringValue
            let topVCName = FireBaseEventsLogger.gettopViewControllerName() ?? ""
            if !UserDefaults.isBannerDisplayed(bannerID , topControllerName: topVCName ) {
                elDebugPrint("banner.bannerId : \(bannerID)")
                elDebugPrint("trackBannerView: \(banner.title)")
                let isSingle =   false
                var brandName = ""
                var catName = ""
                var subCateName = ""
                if  banner.brands?.count ?? 0 > 0 {
                    let brand = banner.brands?[0]
                    brandName = brand?.name ?? ""
                }
                if  banner.categories?.count ?? 0 > 0 {
                    let brand = banner.categories?[0]
                    catName = brand?.name ?? ""
                }
                if  banner.subCategories?.count ?? 0 > 0 {
                    let brand = banner.subCategories?[0]
                    subCateName = brand?.name ?? ""

                }
                FireBaseEventsLogger.trackBannerView(isSingle: isSingle , brandName: brandName , catName  , subCateName , link: nil , banner )
                UserDefaults.addBannerID(bannerID, topControllerName: topVCName)
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard  self.collectionData[indexPath.row] is BannerCampaign  else {
            if self.collectionData[indexPath.row] is Banner {
                let banner : Banner = self.collectionData[indexPath.row] as! Banner
                if banner.bannerLinks.count > 0 {
                    let bannerLink = banner.bannerLinks[0]
                    let isSingle =   banner.bannerGroup.int32Value != KRecipeBannerID  &&  !(self.collectionData.count > 1)
                    FireBaseEventsLogger.trackBrandBanner(isSingle: isSingle , brandName: ElGrocerUtility.sharedInstance.isArabicSelected() ? bannerLink.bannerBrand?.nameEn ?? "" : bannerLink.bannerBrand?.name ?? "" , bannerLink.bannerCategory?.nameEn ?? bannerLink.bannerCategory?.name ?? ""  , bannerLink.bannerSubCategory?.subCategoryNameEn ?? bannerLink.bannerSubCategory?.subCategoryName ?? "" , link : bannerLink, possition: String(describing: (indexPath.row ) + 1) )
                    GoogleAnalyticsHelper.trackEventName(GoogleAnalyticsHelper.kSingleBrandTypeEvent,  ElGrocerUtility.sharedInstance.isArabicSelected() ? bannerLink.bannerBrand?.nameEn ?? "" : bannerLink.bannerBrand?.name ?? "")
                    if let clouser = self.bannerCliked {
                        clouser(banner)
                    }
                }
            } else if self.collectionData[indexPath.row] is BannerDTO {
                let banner = self.collectionData[indexPath.row] as! BannerDTO
                if let bannerClicked = self.bannerClicked {
                    bannerClicked(banner)
                    
                    // Logging segment event for banner clicked
                    let bannerCampign = BannerCampaign.init()
                    
                    bannerCampign.dbId = (banner.id ?? 0) as NSNumber
                    bannerCampign.title = banner.name ?? ""
                    bannerCampign.priority = (banner.priority ?? 0) as NSNumber
                    bannerCampign.campaignType = (banner.campaignType?.rawValue ?? -1) as NSNumber
                    bannerCampign.imageUrl = banner.imageURL ?? ""
                    bannerCampign.bannerImageUrl = banner.bannerImageURL ?? ""
                    bannerCampign.url = banner.url ?? ""
                    bannerCampign.categories = banner.categories?.map { bannerCategories(dbId: $0.id as? NSNumber ?? -1, name: $0.name ?? "", slug: $0.slug ?? "") }
                    bannerCampign.subCategories = banner.subcategories?.map { bannerSubCategories(dbId: $0.id as? NSNumber ?? -1, name: $0.name ?? "", slug: $0.slug ?? "") }
                    bannerCampign.brands = banner.brands?.map { bannerBrands(dbId: $0.id as? NSNumber ?? -1, name: $0.name ?? "", slug: $0.slug ?? "", image_url: $0.imageURL ?? "") }
                    bannerCampign.retailerIds = banner.retailerIDS
                    bannerCampign.locations = banner.locations
                    bannerCampign.storeTypes = banner.storeTypes
                    bannerCampign.retailerGroups = banner.retailerGroups
                    
                    SegmentAnalyticsEngine.instance.logEvent(event: BannerClickedEvent(banner: bannerCampign, position: indexPath.row + 1))
                }
            }
            return
        }
        if  let banner : BannerCampaign = self.collectionData[indexPath.row] as? BannerCampaign {
            if let clouser = self.bannerCampaignClicked {
                
                if let bidid = banner.resolvedBidId {
                    TopsortManager.shared.log(.clicks(resolvedBidId: bidid))
                }
                
                FireBaseEventsLogger.trackBannerClicked(brandName: banner.brands?.map { $0.slug }.joined(separator: ",") ?? "", banner.categories?.map { $0.slug }.joined(separator: ",") ?? "", banner.subCategories?.map { $0.slug }.joined(separator: ",") ?? "", link: banner, possition: String(describing: (indexPath.row ) + 1) )
                
                ElGrocerUtility.sharedInstance.resolvedBidIdForBannerClicked = banner.resolvedBidId
                clouser(banner)
                
                // Logging segment event for banner clicked
                SegmentAnalyticsEngine.instance.logEvent(event: BannerClickedEvent(banner: banner, position: indexPath.row + 1))
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let collectionView = self.collectionView {
            let center = CGPoint(x: scrollView.contentOffset.x + (scrollView.frame.width / 2.5), y: (scrollView.frame.height / 2))
            if let ip = collectionView.indexPathForItem(at: center) {
                if let cloure = self.currentPage {
                    cloure(ip.row, collectionView )
                }
                //            self.pageControl.currentPage = ip.row
            }
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        behavior.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
        if let clouser = self.isCurrentScrolling {
            clouser(false)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let clouser = self.isCurrentScrolling {
            clouser(true)
        }
    }
    
   

}

extension GenricBannerList : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width - (collectionView.frame.size.width * 0.1466)
        var cellSize:CGSize = CGSize(width: width  , height: width / KBannerRation )
        
        if cellSize.width > collectionView.frame.width {
            cellSize.width = collectionView.frame.width
        }
        
        if cellSize.height > collectionView.frame.height {
            cellSize.height = collectionView.frame.height
        }
        
        
        return cellSize
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16 , bottom: 0 , right: 12)
    }
    
}
