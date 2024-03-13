//
//  RXRecipePreprationTableViewCellViewModel.swift
//  Pods-el-grocer-shopper-sdk-iOS_Example
//
//  Created by Abdul Saboor on 20/02/2024.
//

import Foundation
import RxSwift
import RxDataSources

protocol RxRecipePreparationCellViewModelInput {
    
}

protocol RxRecipePreparationCellViewModelOuput {
    
    var stepNum: Observable<String?> { get }
    var stepDetails: Observable<String?> { get }
}

protocol RxRecipePreparationCellViewModelType: RxRecipePreparationCellViewModelInput, RxRecipePreparationCellViewModelOuput {
    var inputs: RxRecipePreparationCellViewModelInput { get }
    var outputs: RxRecipePreparationCellViewModelOuput { get }
}

extension RxRecipePreparationCellViewModelType {
    var inputs: RxRecipePreparationCellViewModelInput { self }
    var outputs: RxRecipePreparationCellViewModelOuput { self }
}

class RXRecipePreprationTableViewCellViewModel: ReusableTableViewCellViewModelType, RxRecipePreparationCellViewModelType {
    var reusableIdentifier: String = "RXRecipePreprationTableViewCell"
    
    //MARK: Inputs
    
    //MARK: Outputs
    var stepNum: Observable<String?> { self.stepNumSubject.asObservable() }
    var stepDetails: Observable<String?> { self.stepDetailsSubject.asObservable() }
    //MARK: Subject
    private let stepNumSubject = BehaviorSubject<String?>(value: nil)
    private let stepDetailsSubject = BehaviorSubject<String?>(value: nil)
    
    init(stepNum: String, stepDetails: String) {
        
        self.stepNumSubject.onNext(stepNum)
        self.stepDetailsSubject.onNext(stepDetails)
    }
}
