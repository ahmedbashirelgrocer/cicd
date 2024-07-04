//
//  FiltersBrandTableViewCellPresenter.swift
//  
//
//  Created by saboor Khan on 05/06/2024.
//

import UIKit

class FiltersBrandTableViewCellPresenter {
    
    let brand: BrandDTO
    var isSelected: Bool
    
    init(brand: BrandDTO, isSelected: Bool) {
        self.brand = brand
        self.isSelected = isSelected
    }

}

extension FiltersBrandTableViewCellPresenter: ReusableTableViewCellPresenterType {
    var reusableIdentifier: String { FiltersBrandTableViewCell.defaultIdentifier }
}
