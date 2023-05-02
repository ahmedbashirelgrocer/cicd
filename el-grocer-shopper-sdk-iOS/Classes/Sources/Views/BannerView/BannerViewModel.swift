//
//  BannerViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 18/11/2022.
//

import Foundation
import RxSwift
import RxDataSources

protocol BannerViewModelInput { }

protocol BannerViewModelOutput {
    var bannerCellViewModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { get }
}

protocol BannerViewModelType: BannerViewModelInput, BannerViewModelOutput {
    var inputs: BannerViewModelInput { get }
    var outputs: BannerViewModelOutput { get }
}

extension BannerViewModelType {
    var inputs: BannerViewModelInput { self }
    var outputs: BannerViewModelOutput { self }
}

class BannerViewModel: BannerViewModelType {
    // MARK: Inputs
    
    // MARK: Outputs
    var bannerCellViewModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { bannerCellViewModelsSubject.asObservable() }
    
    // MARK: Subjects
    private let bannerCellViewModelsSubject = BehaviorSubject<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]>(value: [])
    
    // MARK: Properties
    
    // MARK: Initlitzations
    init(banners: [BannerDTO]) {
        self.bannerCellViewModelsSubject.onNext([SectionModel(model: 0, items: banners.map { BannerCellViewModel(banner: $0) })])
    }
}
