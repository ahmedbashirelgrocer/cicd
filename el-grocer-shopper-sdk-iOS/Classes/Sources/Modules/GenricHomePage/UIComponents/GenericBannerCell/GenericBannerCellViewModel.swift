//
//  GenericBannerCellViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 19/01/2023.
//

import Foundation
import RxSwift

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
