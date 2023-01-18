//
//  GenericBannersCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 27/07/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
import RxSwift

let KGenericBannersCell = "GenericBannersCell"
let KBrandBannerRatio = CGFloat(3.2)
let KBannerRation = CGFloat(2)

protocol GenericBannersCellViewModelInput { }

protocol GenericBannersCellViewModelOutput {
    var banners: Observable<[BannerDTO]> { get }
    var bannersCount: Observable<Int> { get }
}

protocol GenericBannersCellViewModelType: GenericBannersCellViewModelInput, GenericBannersCellViewModelOutput {
    var inputs: GenericBannersCellViewModelInput { get }
    var outputs: GenericBannersCellViewModelOutput { get }
}

extension GenericBannersCellViewModelType {
    var inputs: GenericBannersCellViewModelInput { self }
    var outputs: GenericBannersCellViewModelOutput { self }
}

class GenericBannersCellViewModel: GenericBannersCellViewModelType, ReusableTableViewCellViewModelType {
    
    // MARK: Outputs
    var banners: Observable<[BannerDTO]> { self.bannersSubject.asObservable() }
    var bannersCount: Observable<Int> { self.bannersCountSubject.asObservable() }
    
    // MARK: Subjects
    private var bannersSubject = BehaviorSubject<[BannerDTO]>(value: [])
    private var bannersCountSubject = BehaviorSubject<Int>(value: 0)
    var reusableIdentifier: String { GenericBannersCell.defaultIdentifier }
    
    init(banners: [BannerDTO]) {
        self.bannersSubject.onNext(banners)
        self.bannersCountSubject.onNext(banners.count)
    }
}

class GenericBannersCell: RxUITableViewCell {
    private var scrollTimer : Timer?
    @IBOutlet var bgView: UIView!
    @IBOutlet var bannerList: GenricBannerList!
    @IBOutlet var pageControl: UIPageControl! {
        didSet {
            pageControl.currentPageIndicatorTintColor = ApplicationTheme.currentTheme.pageControlActiveColor
        }
    }
    @IBOutlet var topX: NSLayoutConstraint!
    
    var isNeedToScroll : Bool = true
    override func awakeFromNib() {
        super.awakeFromNib()
       
        pageControl.hidesForSinglePage = true
        bannerList.currentPage = { [weak self] (page , collectionView ) in
            guard let self = self else {return}
            self.pageControl.currentPage = page
        }
        
        bannerList.isCurrentScrolling = { [weak self] (isCurrentScrolling) in
            guard let self = self else {return}
            guard isCurrentScrolling != nil else {
                return
            }
            self.isNeedToScroll = !isCurrentScrolling!
            if self.isNeedToScroll {
                if let timer = self.scrollTimer {
                    timer.invalidate()
                    self.scrollTimer  = nil
                }
                self.scrollTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.moveToNext), userInfo: nil, repeats: true)
            }else{
                if let timer = self.scrollTimer {
                    timer.invalidate()
                    self.scrollTimer  = nil
                }
            }
            
        }
    }
    
    override func configure(viewModel: Any) {
        let viewModel = viewModel as! GenericBannersCellViewModelType
        
        viewModel.outputs.banners.bind(to: self.bannerList.rx.banners).disposed(by: disposeBag)
        viewModel.outputs.bannersCount.subscribe(onNext: { [weak self] bannersCount in
            guard let self = self else { return }
            
            self.setViewForMultiBanner(isMultiBanner: bannersCount > 1)
            self.pageControl.numberOfPages = bannersCount
        }).disposed(by: disposeBag)
        
        if let timer = self.scrollTimer {
            timer.invalidate()
            self.scrollTimer  = nil
        }
        self.scrollTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(moveToNext), userInfo: nil, repeats: true)
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
       // self.bannerList.collectionView?.isPagingEnabled = true
      
        
       
    }
    @objc func moveToNext() {
        
        guard self.isNeedToScroll else {
            return
        }
        guard !(self.bannerList.collectionView?.isDecelerating ?? false) else {
            return
        }
       
        if  self.pageControl.numberOfPages > (self.pageControl.currentPage + 1){
            let indexPath = IndexPath(item: self.pageControl.currentPage + 1 , section: 0)
             self.bannerList.behavior.scrollToItem(at: indexPath.row , animated: true)
//            if let _ = self.bannerList.collectionView?.cellForItem(at: indexPath) {
//
//
//                //self.bannerList.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally , animated: true)
//            }
        }else{
             self.bannerList.behavior.scrollToItem(at: 0 , animated: true)
           // self.bannerList.collectionView?.scrollToNextItem()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configured(_ bannersList : [Banner] ) {
        self.bannerList.configureData(bannersList)
        self.pageControl.numberOfPages = bannersList.count
        self.trackViewBanners(bannersList)
        if let timer = self.scrollTimer {
            timer.invalidate()
            self.scrollTimer  = nil
        }
        self.scrollTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(moveToNext), userInfo: nil, repeats: true)
    }
    
    func setViewForMultiBanner(isMultiBanner : Bool = true) {
        
        self.topX.constant = isMultiBanner ? 8 : 16
        DispatchQueue.main.async {
            self.contentView.setNeedsLayout()
            self.contentView.layoutIfNeeded()
        }
    }
    
    
    func configured(_ bannersList : [BannerCampaign] ) {
        self.bannerList.configureData(bannersList)
        self.pageControl.numberOfPages = bannersList.count
        self.setViewForMultiBanner(isMultiBanner: bannersList.count > 1)
        if let timer = self.scrollTimer {
            timer.invalidate()
            self.scrollTimer  = nil
        }
        self.scrollTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(moveToNext), userInfo: nil, repeats: true)
    }
    
    @objc
    func callCollectionViewNext() {
        UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: {
            self.bannerList.collectionView?.scrollToNextItem(KBannerRation)
        }) { (isSuccess) in }
    }
    
    func trackViewBanners (_ bannersList : [Banner] ) {
        for banner in bannersList {
        //    elDebugPrint("banner.bannerLinks[0].isDeals \(banner.bannerLinks[0].isDeals)")
            let bannerID = banner.bannerId.stringValue
            let topVCName = FireBaseEventsLogger.gettopViewControllerName() ?? ""
            if !UserDefaults.isBannerDisplayed(bannerID , topControllerName: topVCName ) {
                UserDefaults.addBannerID(bannerID, topControllerName: topVCName)
                let isSingle =   banner.bannerGroup.int32Value != KRecipeBannerID
                for bannerLink in banner.bannerLinks {
                    FireBaseEventsLogger.trackBannerView(isSingle: isSingle , brandName: ElGrocerUtility.sharedInstance.isArabicSelected() ? bannerLink.bannerBrand?.nameEn ?? "" : bannerLink.bannerBrand?.name ?? "" , bannerLink.bannerCategory?.nameEn ?? bannerLink.bannerCategory?.name ?? ""  , bannerLink.bannerSubCategory?.subCategoryNameEn ?? bannerLink.bannerSubCategory?.subCategoryName ?? "", link: bannerLink )
                }
            }
        }
    }
    
}
