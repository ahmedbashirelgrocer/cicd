//
//  BannerCollectionViewCellViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 18/11/2022.
//

import Foundation
import RxSwift

protocol BannerCellViewModelInput { }

protocol BannerCellViewModelOutput {
    var bannerImage: Observable<URL?> { get }
}

protocol BannerCellViewModelType: BannerCellViewModelInput, BannerCellViewModelOutput {
    var inputs: BannerCellViewModelInput { get }
    var outputs: BannerCellViewModelOutput { get }
}

extension BannerCellViewModelType {
    var inputs: BannerCellViewModelInput { self }
    var outputs: BannerCellViewModelOutput { self }
}

class BannerCellViewModel: BannerCellViewModelType, ReusableCollectionViewCellViewModelType {
    var reusableIdentifier: String { BannerCollectionViewCell.defaultIdentifier }
    
    var bannerImage: RxSwift.Observable<URL?> { self.bannerImageSubject.asObservable() }
    
    private let bannerImageSubject: BehaviorSubject<URL?>
    
    init(banner: BannerDTO) {
        self.bannerImageSubject = BehaviorSubject<URL?>(value: URL(string: banner.bannerImageURL ?? ""))
    }
    
}
