//
//  GenericBannerCellViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 19/01/2023.
//

import Foundation
import RxSwift

protocol GenericBannersCellViewModelInput {
    var bannerTapObserver: AnyObserver<BannerDTO> { get }
    
    func addBanner(banner: BannerDTO)
}

protocol GenericBannersCellViewModelOutput {
    var banners: Observable<[BannerDTO]> { get }
    var bannersCount: Observable<Int> { get }
    var bannerTap: Observable<BannerDTO> { get }
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
    
    // MARK: Inputs
    var bannerTapObserver: AnyObserver<BannerDTO> { bannerTapSubject.asObserver() }
    
    // MARK: Outputs
    var banners: Observable<[BannerDTO]> { self.bannersSubject.asObservable() }
    var bannersCount: Observable<Int> { self.bannersCountSubject.asObservable() }
    var bannerTap: Observable<BannerDTO> { bannerTapSubject.asObservable() }
    
    // MARK: Subjects
    private var bannersSubject = BehaviorSubject<[BannerDTO]>(value: [])
    private var bannersCountSubject = BehaviorSubject<Int>(value: 0)
    private var bannerTapSubject = PublishSubject<BannerDTO>()
    
    var reusableIdentifier: String { GenericBannersCell.defaultIdentifier }
    private var bannersArr: [BannerDTO] = []
    
    init(banners: [BannerDTO]) {
        self.bannersArr = banners
        
        self.bannersSubject.onNext(banners)
        self.bannersCountSubject.onNext(banners.count)
    }
    
    func addBanner(banner: BannerDTO) {
        if self.bannersArr.contains(where: { $0.isStoryly ?? false }) == false {
            self.bannersArr.append(banner)
            
            self.bannersSubject.onNext(bannersArr)
            self.bannersCountSubject.onNext(bannersArr.count)
        }
    }
}
