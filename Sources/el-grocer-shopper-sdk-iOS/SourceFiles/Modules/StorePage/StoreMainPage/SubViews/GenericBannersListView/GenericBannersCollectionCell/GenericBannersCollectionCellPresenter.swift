//
//  GenericBannersCollectionCellPresenter.swift
//  
//
//  Created by saboor Khan on 08/05/2024.
//

import Foundation
import UIKit

class GenericBannersCollectionCellPresenter {
    
    let banner: BannerDTO
    
    init(banner: BannerDTO) {
        self.banner = banner
    }

}

extension GenericBannersCollectionCellPresenter: ReusableTableViewCellPresenterType {
    var reusableIdentifier: String { GenericBannersCollectionCell.defaultIdentifier }
}
