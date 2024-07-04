//
//  StoreMainCategoriesCollectionViewCellPresenter.swift
//  
//
//  Created by saboor Khan on 12/05/2024.
//

import Foundation
import UIKit

class StoreMainCategoriesCollectionViewCellPresenter {
    
    let category: CategoryDTO
    
    init(category: CategoryDTO) {
        self.category = category
    }

}

extension StoreMainCategoriesCollectionViewCellPresenter: ReusableTableViewCellPresenterType {
    var reusableIdentifier: String { StoreMainCategoriesCollectionViewCell.defaultIdentifier }
}
