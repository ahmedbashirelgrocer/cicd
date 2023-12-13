//
//  DynamicComponentContainerCellViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 23/11/2023.
//

import Foundation
import RxSwift
import RxDataSources

protocol DynamicComponentContainerCellInput {
}

protocol DynamicComponentContainerCellOutput {
    var isArabic: Observable<Bool> { get }
    var productCollectionCellViewModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { get }
    var productCount: Observable<Int> { get }
}

protocol DynamicComponentContainerCellType: DynamicComponentContainerCellInput, DynamicComponentContainerCellOutput {
    var inputs: DynamicComponentContainerCellInput { get }
    var outputs: DynamicComponentContainerCellOutput { get }
}

extension DynamicComponentContainerCellType {
    var inputs: DynamicComponentContainerCellInput { self }
    var outputs: DynamicComponentContainerCellOutput { self }
}

class DynamicComponentContainerCellViewModel: DynamicComponentContainerCellType, ReusableTableViewCellViewModelType {
    
    //FIXME: Need to update in future
    var reusableIdentifier: String {
        switch component.sectionName {
        case .bannerImage:
            return "RxBannersTableViewCell"
        case .topDeals:
            return kHomeCellIdentifier
        case .productsOnly:
            return "RxCollectionViewOnlyTableViewCell"
        case .categorySection:
            return "RxCollectionViewOnlyTableViewCell"
        default:
            return ""
        }
    }
    
    // MARK: Inputs
    // MARK: Outputs
    var isArabic: Observable<Bool> { isArabicSubject.asObservable() }
    var productCollectionCellViewModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { self.productCollectionCellViewModelsSubject.asObservable() }
    var productCount: Observable<Int> { productCountSubject.asObservable() }
    // MARK: Subject
        private let isArabicSubject = BehaviorSubject<Bool>(value: false)
                let productCollectionCellViewModelsSubject = BehaviorSubject<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]>(value: [])
                var productCountSubject = BehaviorSubject<Int>(value: 1)
    // MARK: Properties
    var component: CampaignSection
    init(component: CampaignSection) {
        self.component = component
        self.isArabicSubject.onNext(ElGrocerUtility.sharedInstance.isArabicSelected())
    }
    
}
