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

protocol ActiveCartProductCellViewModelOutput {
    var productImageUrl: Observable<URL?> { get }
    var productQuantity: Observable<String> { get }
}

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
    var productImageUrl: Observable<URL?> { self.productImageUrlSubject.asObservable() }
    var productQuantity: Observable<String> { self.productQuantitySubject.asObservable() }
    
    // MARK: Subjects
    private let productImageUrlSubject = BehaviorSubject<URL?>(value: nil)
    private let productQuantitySubject = BehaviorSubject<String>(value: "×0")
    
    // MARK: Properties
    var reusableIdentifier: String { ActiveCartProductCell.defaultIdentifier }
    
    // MARK: Initlizations
    init(product: ActiveCartProductDTO) {
        self.productImageUrlSubject.onNext(URL(string: product.photoUrl ?? ""))
        self.productQuantitySubject.onNext("×" + String(product.quantity ?? 0))
    }
    
}

