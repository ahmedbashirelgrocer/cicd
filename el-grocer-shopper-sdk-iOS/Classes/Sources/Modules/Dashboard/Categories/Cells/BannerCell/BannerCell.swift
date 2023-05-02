//
//  BannerCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 02/06/2018.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

let KSlideRatio : CGFloat = 2.20
let KSingleRatio : CGFloat = 2.70

let KCustomBannerDesignWidth : CGFloat =  (ScreenSize.SCREEN_WIDTH - 20) * 0.80
let KCustomBannerDesignRatio : CGFloat = 1.55

let KRecipeBannerID = 732473
let kBannerCellIdentifier = "BannerCell"
let kBannerCellHeight: CGFloat = ((ScreenSize.SCREEN_WIDTH - 20) * 0.80 )  / KBannerRation

protocol BannerCellDelegate : class {
    func bannerTapHandlerWithBannerLink(_ bannerLink: BannerLink)
}

class BannerCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bannerCollectionView: UICollectionView!
    
    @IBOutlet weak var containerViewLeadingToSuperView: NSLayoutConstraint!
    @IBOutlet weak var containerViewTrallingToSuperView: NSLayoutConstraint!
    
    var selectedIndexPath : IndexPath?
    
    weak var delegate:BannerCellDelegate?
    
      private var banners = [Banner]()
    //private var banners = [BannerCampaign]()
    
    private var isRecipeBanners = false
    
            var isNeedToUpdateFrame = true
    
   // private var isNewBannerStyle = false
    
    private var scrollTimer : Timer?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = ApplicationTheme.currentTheme.viewWhiteBGColor
        
        self.containerView.backgroundColor = UIColor.clear
        
        let bannerCellNib = UINib(nibName: "LargeBannerCell", bundle: Bundle.resource)
        self.bannerCollectionView.register(bannerCellNib, forCellWithReuseIdentifier: kLargeBannerCellIdentifier)
        
        let samllBannerCellNib = UINib(nibName: "SmallBannerCell", bundle: Bundle.resource)
        self.bannerCollectionView.register(samllBannerCellNib, forCellWithReuseIdentifier: kSmallBannerCellIdentifier)
        
        
        let RecipeBannerCollectionViewNib = UINib(nibName: KRecipeBannerCollectionViewCellIdentifier, bundle: Bundle.resource)
        self.bannerCollectionView.register(RecipeBannerCollectionViewNib, forCellWithReuseIdentifier: KRecipeBannerCollectionViewCellIdentifier)
        
    }

    func configureCampaignCell(_ banners: [Banner], currentRow:NSInteger , _ isNewBannerStyle : Bool = false){
        self.banners = banners
        self.banners.sort { $0.bannerPriority < $1.bannerPriority}
        self.bannerCollectionView.setNeedsLayout()
        self.bannerCollectionView.layoutIfNeeded()
        self.bannerCollectionView.reloadData()
    }
    
    @objc
    func callCollectionViewNext() {
        UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: {
            
            self.bannerCollectionView.scrollToNextItem()
           
        }) { (isSuccess) in
            
        }
       
    }
}

extension BannerCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.banners.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        if indexPath.row < self.banners.count {
            let banner = self.banners[indexPath.row]
            
            collectionView.isPagingEnabled = true
            self.containerViewLeadingToSuperView.constant = 0.0
            self.containerViewTrallingToSuperView.constant = 0.0
            
            let smallBannerCell = collectionView.dequeueReusableCell(withReuseIdentifier: kSmallBannerCellIdentifier, for: indexPath) as! SmallBannerCell
            smallBannerCell.configureCell(banner, currentRow: indexPath.row)
            smallBannerCell.delegate = self
            smallBannerCell.setNeedsLayout()
            smallBannerCell.layoutIfNeeded()
            return smallBannerCell
            
            
           /*
            if banner.bannerStyletype == .CustomBanner {
                
                self.containerViewLeadingToSuperView.constant  = 5.0
                self.containerViewTrallingToSuperView.constant = 5.0
               // self.scrollTimer  = nil
                     collectionView.isPagingEnabled = false
                let largeBannerCell = collectionView.dequeueReusableCell(withReuseIdentifier: kLargeBannerCellIdentifier, for: indexPath) as! LargeBannerCell
                largeBannerCell.configureCell(banner, currentRow: indexPath.row , true)
                if let timer = self.scrollTimer {
                    timer.invalidate()
                    self.scrollTimer  = nil
                }
                self.scrollTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(callCollectionViewNext), userInfo: nil, repeats: true)
                
                largeBannerCell.setNeedsLayout()
                largeBannerCell.layoutIfNeeded()
                return largeBannerCell
                
                
            }else if self.banners[0].bannerGroup.int32Value == KRecipeBannerID ||  self.banners.count > 1 {
                
                self.containerViewLeadingToSuperView.constant = 0.0
                self.containerViewTrallingToSuperView.constant = 0.0
                collectionView.isPagingEnabled = true
                let largeBannerCell = collectionView.dequeueReusableCell(withReuseIdentifier: KRecipeBannerCollectionViewCellIdentifier, for: indexPath) as! RecipeBannerCollectionViewCell
                largeBannerCell.configureCell(banner, currentRow: indexPath.row , numberOfBanner: self.banners.count)
                if let timer = self.scrollTimer {
                    timer.invalidate()
                    self.scrollTimer  = nil
                }
                self.scrollTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(callCollectionViewNext), userInfo: nil, repeats: true)
                largeBannerCell.setNeedsLayout()
                largeBannerCell.layoutIfNeeded()
                return largeBannerCell
                
                
            }else if banner.bannerLinks.count == 1 {
                collectionView.isPagingEnabled = true
                self.containerViewLeadingToSuperView.constant = 0.0
                self.containerViewTrallingToSuperView.constant = 0.0
                
                let largeBannerCell = collectionView.dequeueReusableCell(withReuseIdentifier: kLargeBannerCellIdentifier, for: indexPath) as! LargeBannerCell
                largeBannerCell.configureCell(banner, currentRow: indexPath.row)
                largeBannerCell.setNeedsLayout()
                largeBannerCell.layoutIfNeeded()
                return largeBannerCell
                
            }else{
                collectionView.isPagingEnabled = true
                self.containerViewLeadingToSuperView.constant = 0.0
                self.containerViewTrallingToSuperView.constant = 0.0
                
                let smallBannerCell = collectionView.dequeueReusableCell(withReuseIdentifier: kSmallBannerCellIdentifier, for: indexPath) as! SmallBannerCell
                smallBannerCell.configureCell(banner, currentRow: indexPath.row)
                smallBannerCell.delegate = self
                smallBannerCell.setNeedsLayout()
                smallBannerCell.layoutIfNeeded()
                return smallBannerCell
            }
            */
        }
        
        
        
        
        
        let smallBannerCell = collectionView.dequeueReusableCell(withReuseIdentifier: kSmallBannerCellIdentifier, for: indexPath) as! SmallBannerCell
        smallBannerCell.configureCell(nil, currentRow: indexPath.row)
        smallBannerCell.delegate = self
        smallBannerCell.setNeedsLayout()
        smallBannerCell.layoutIfNeeded()
        return smallBannerCell
        
      
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        elDebugPrint(indexPath)
    }
    
}

extension BannerCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let banner = self.banners[indexPath.row]
        if banner.bannerLinks.count == 1 {
          let bannerLink = banner.bannerLinks[0]
          let isSingle =   banner.bannerGroup.int32Value != KRecipeBannerID  &&  !(self.banners.count > 1)
                FireBaseEventsLogger.trackBrandBanner(isSingle: isSingle , brandName: ElGrocerUtility.sharedInstance.isArabicSelected() ? bannerLink.bannerBrand?.nameEn ?? "" : bannerLink.bannerBrand?.name ?? "" , bannerLink.bannerCategory?.nameEn ?? bannerLink.bannerCategory?.name ?? ""  , bannerLink.bannerSubCategory?.subCategoryNameEn ?? bannerLink.bannerSubCategory?.subCategoryName ?? "" , link : bannerLink, possition: String(describing: indexPath.row +  1) )
                GoogleAnalyticsHelper.trackEventName(GoogleAnalyticsHelper.kSingleBrandTypeEvent,  ElGrocerUtility.sharedInstance.isArabicSelected() ? bannerLink.bannerBrand?.nameEn ?? "" : bannerLink.bannerBrand?.name ?? "")
            self.delegate?.bannerTapHandlerWithBannerLink(bannerLink)
        }
    }
}

extension BannerCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard isNeedToUpdateFrame else {
        return CGSize( width: collectionView.frame.size.width  , height:  collectionView.frame.size.height )
        }
        
        let banner = self.banners[indexPath.row]
        
        guard banner.bannerStyletype != .CustomBanner else {
           
           let widthData = KCustomBannerDesignWidth +  (banner.bannerTitle.count > 0 ? CGFloat(10.0) : CGFloat(0.0))
            return CGSize(width: widthData  , height:  KCustomBannerDesignWidth / KCustomBannerDesignRatio)
            
        }
        
        let isSingle =   banner.bannerGroup.int32Value != KRecipeBannerID  &&  !(self.banners.count > 1)
       
        if isSingle {
              return CGSize(width: ScreenSize.SCREEN_WIDTH - 10 , height:  ScreenSize.SCREEN_WIDTH / KSingleRatio)
        }else{
             return CGSize(width: ScreenSize.SCREEN_WIDTH  , height:  ScreenSize.SCREEN_WIDTH / KSlideRatio)
        }
//        if banner.bannerGroup.int32Value == KRecipeBannerID  {
//             return CGSize(width: ScreenSize.SCREEN_WIDTH  , height:  ScreenSize.SCREEN_WIDTH / KSlideRatio)
//        }else{
//            return CGSize(width: ScreenSize.SCREEN_WIDTH - 10 , height:  ScreenSize.SCREEN_WIDTH / KSingleRatio)
//        }
        
//        guard self.isRecipeBanners else {
//              return CGSize(width: ScreenSize.SCREEN_WIDTH - 10 , height:  ScreenSize.SCREEN_WIDTH / KSingleRatio)
//        }
//        return CGSize(width: ScreenSize.SCREEN_WIDTH  , height:  ScreenSize.SCREEN_WIDTH / KSlideRatio)
//        var width = collectionView.bounds.size.width
//        let banner = self.banners[indexPath.row]
//        if self.banners.count > 1 && banner.bannerLinks.count == 1 {
//            // create a cell size, and return it
//            width = collectionView.bounds.size.width - 20
//        }
//        return CGSize(width: width, height:  collectionView.frame.height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        guard isNeedToUpdateFrame else {
            return 0
        }
        
        guard self.banners.count > 0 , self.banners[0].bannerStyletype == .CustomBanner else {
            return 0
        }
        return 10
    }
}

extension BannerCell: SmallBannerCellDelegate {
    
    func samllBannerTapHandlerWithBannerLink(_ bannerLink: BannerLink){
        self.delegate?.bannerTapHandlerWithBannerLink(bannerLink)
    }
}
extension UICollectionView {
    
    
    
    @objc func scrollToNextItem(_ aspectRation : CGFloat = 0.0) {
        
        if aspectRation == KBannerRation {
            
            let cellWidth = self.bounds.size.width - (self.bounds.size.width * 0.1467)
            
            var contentOffset = CGFloat(floor(self.contentOffset.x + cellWidth))
            guard contentOffset <= self.contentSize.width - cellWidth else {
                self.moveToFrame(contentOffset: 0)
                return
            }
            if self.bounds.origin.x == 0 {
              // contentOffset = contentOffset - (self.bounds.size.width * 0.1)
            }else{
                 contentOffset = contentOffset + (cellWidth * 0.05)
            }
             
            self.moveToFrame(contentOffset: contentOffset)
            return
        }
        
        let contentOffset = CGFloat(floor(self.contentOffset.x + self.bounds.size.width))
        guard contentOffset <= self.contentSize.width - self.bounds.size.width else {
            self.moveToFrame(contentOffset: 0)
            return }
        self.moveToFrame(contentOffset: contentOffset)
    }
    
    @objc func scrollToNextItemHalf() {
        
        let contentOffset = CGFloat(floor(self.contentOffset.x + self.bounds.size.width - (self.bounds.size.width * 0.25)))
        guard contentOffset <= self.contentSize.width - self.bounds.size.width else {
            self.moveToFrame(contentOffset: 0)
            return }
        self.moveToFrame(contentOffset: contentOffset)
    }
    
    func scrollToPreviousItem() {
        let contentOffset = CGFloat(floor(self.contentOffset.x - self.bounds.size.width))
        self.moveToFrame(contentOffset: contentOffset)
    }
    
    func moveToFrame(contentOffset : CGFloat) {
        self.setContentOffset(CGPoint(x: contentOffset, y: self.contentOffset.y), animated: true)
    }
    
    func reloadDataOnMainThread(){
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
}
