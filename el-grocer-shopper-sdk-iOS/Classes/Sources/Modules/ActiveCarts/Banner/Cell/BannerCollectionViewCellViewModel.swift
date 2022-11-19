//
//  BannerCollectionViewCellViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 18/11/2022.
//

import Foundation

protocol BannerCellViewModelInput { }

protocol BannerCellViewModelOutput { }

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
    
    init(banner: BannerDTO) { }
    
}
