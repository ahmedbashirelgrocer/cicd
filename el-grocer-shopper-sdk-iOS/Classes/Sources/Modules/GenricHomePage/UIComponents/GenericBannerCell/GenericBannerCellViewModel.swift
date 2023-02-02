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
    
    init(banners: [BannerDTO]) {
        self.bannersSubject.onNext(banners)
        self.bannersCountSubject.onNext(banners.count)
    }
}
