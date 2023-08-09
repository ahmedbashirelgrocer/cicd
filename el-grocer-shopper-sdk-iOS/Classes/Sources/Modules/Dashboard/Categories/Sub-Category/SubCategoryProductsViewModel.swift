//
//  SubCategoryProductsViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 09/08/2023.
//

import Foundation

protocol SubCategoryProductsViewModelInputs { }

protocol SubCategoryProductsViewModelOutputs { }

protocol SubCategoryProductsViewModelType: SubCategoryProductsViewModelInputs, SubCategoryProductsViewModelOutputs {
    var inputs: SubCategoryProductsViewModelInputs { get }
    var outputs: SubCategoryProductsViewModelOutputs { get }
}

extension SubCategoryProductsViewModelType {
    var inputs: SubCategoryProductsViewModelInputs { self }
    var outputs: SubCategoryProductsViewModelOutputs { self }
}

class SubCategoryProductsViewModel: SubCategoryProductsViewModelType {
    
}
