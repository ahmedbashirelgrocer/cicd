//
//  RxBannersTableViewCell.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 23/11/2023.
//

import UIKit
import RxSwift


class RxBannersTableViewCell: RxUITableViewCell {
    
    var bannerViewHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var bannerView: BannerView! {
        didSet{
            bannerView.bannerType = .custom_campaign_shopper
            bannerView.backgroundColor = .clear
            bannerViewHeightConstraint = bannerView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width * 0.305)
            bannerViewHeightConstraint?.isActive = true
        }
    }
    private var viewModel:RxBannersViewModel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func configure(viewModel: Any) {
        guard viewModel is DynamicComponentContainerCellViewModel else { return }
        self.viewModel = viewModel as? RxBannersViewModel
        self.bindViews()
        self.viewModel.getBanners(self.viewModel.component)
    }
    
    private func bindViews() {
        
        // Banner tap handler
        self.bannerView.bannerTapped = { [weak self] banner in
            self?.viewModel.bannerTapObserver.onNext(banner)
        }
        
        self.viewModel.isArbic
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] isArabic in
                self?.bannerView.transform = isArabic ? CGAffineTransform(scaleX: -1, y: 1) : CGAffineTransform(scaleX: 1, y: 1)
                self?.bannerView.semanticContentAttribute = isArabic ? .forceRightToLeft : .forceLeftToRight
        }).disposed(by: disposeBag)
        
        self.viewModel.banners
                   .observeOn(MainScheduler.instance)
                   .subscribe(onNext: { [weak self] banners in
                       self?.invalidateIntrinsicContentSize()
                       self?.bannerView.banners = banners
                   })
                   .disposed(by: disposeBag)
        
        self.viewModel.bannerTap.subscribe(onNext: { [weak self] banner in
            guard let self = self else { return }
            // navigation // No Need to implement yet
        }).disposed(by: disposeBag)
        
    }
    
}


class RxBannersViewModel: DynamicComponentContainerCellViewModel {
    
    // MARK: Inputs
    var bannerTapObserver: AnyObserver<BannerDTO> { self.bannerTapSubject.asObserver() }
    // MARK: Outputs
    var banners: Observable<[BannerDTO]> { bannersSubject.asObservable() }
    var bannerTap: Observable<BannerDTO> { bannerTapSubject.asObservable() }
    
    // MARK: Subject
    private var bannersSubject = BehaviorSubject<[BannerDTO]>(value: [])
    private let bannerTapSubject = PublishSubject<BannerDTO>()
    
    func getBanners(_ components : CampaignSection) {
        var bannersArray: [BannerDTO] = []
        bannersArray.append(components.convertToBannerDTO())
        self.bannersSubject.onNext(bannersArray)
    }
}

extension CampaignSection {
    func convertToBannerDTO() -> BannerDTO {
        return BannerDTO(name: self.title, campaignType: BannerCampaignType.customBanners, imageURL: self.image, bannerImageURL: self.image, url: self.image, categories: nil, subcategories: nil, brands: nil, retailerIDS: nil, locations: nil, storeTypes: nil, retailerGroups: nil)
    }
}
