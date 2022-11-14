//
//  ActiveCartProductCellViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 14/11/2022.
//

import Foundation
import RxSwift
import RxDataSources

protocol ActiveCartProductCellViewModelInput { }

protocol ActiveCartProductCellViewModelOutput { }

protocol ActiveCartProductCellViewModelType: ActiveCartProductCellViewModelInput, ActiveCartProductCellViewModelOutput {
    var inputs: ActiveCartProductCellViewModelInput { get }
    var outputs: ActiveCartProductCellViewModelOutput { get }
}

extension ActiveCartProductCellViewModelType {
    var inputs: ActiveCartProductCellViewModelInput { self }
    var outputs: ActiveCartProductCellViewModelOutput { self }
}

class ActiveCartProductCellViewModel: ActiveCartProductCellViewModelType, ReusableCollectionViewCellViewModelType {
    // MARK: Inputs
    
    // MARK: Outputs
    
    // MARK: Subjects
    
    // MARK: Properties
    var reusableIdentifier: String { ActiveCartProductCell.defaultIdentifier }
    
    // MARK: Initlizations
    init(product: ActiveCartProductDTO) { }
    
}

