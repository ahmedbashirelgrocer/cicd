//
//  DynamicComponentContainerCellViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 23/11/2023.
//

import Foundation
import RxSwift

protocol DynamicComponentContainerCellInput {
   
}

protocol DynamicComponentContainerCellOutput {
    var isArbic: Observable<Bool> { get }
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
    
    
    var reusableIdentifier: String {
        switch component.sectionName {
        case .bannerImage:
            return "RxBannersTableViewCell"
        case .productsOnly:
            return "TypeBCellIdentifier"
        default:
            return ""
        }
    }
    
    // MARK: Inputs
    
    // MARK: Outputs
    var isArbic: Observable<Bool> { isArbicSubject.asObservable() }
    // MARK: Subject
    private let isArbicSubject = BehaviorSubject<Bool>(value: false)    
    // MARK: Properties
    var component: CampaignSection
    
    
    init(component: CampaignSection) {
        self.component = component
        self.isArbicSubject.onNext(ElGrocerUtility.sharedInstance.isArabicSelected())
    }
    
    
    
    
}
