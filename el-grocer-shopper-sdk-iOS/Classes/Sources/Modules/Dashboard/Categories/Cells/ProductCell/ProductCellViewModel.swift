//
//  ProductCellViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 17/01/2023.
//

import Foundation

protocol ProductCellViewModelInput { }

protocol ProductCellViewModelOutput { }

protocol ProductCellViewModelType: ProductCellViewModelInput, ProductCellViewModelOutput {
    var inputs: ProductCellViewModelInput { get }
    var outputs: ProductCellViewModelOutput { get }
}

extension ProductCellViewModelType {
    var inputs: ProductCellViewModelInput { self }
    var outputs: ProductCellViewModelOutput { self }
}

class ProductCellViewModel: ProductCellViewModelType, ReusableCollectionViewCellViewModelType {
    var reusableIdentifier: String { ProductCell.defaultIdentifier }
    
    init(product: ProductDTO) {
        
    }
}
