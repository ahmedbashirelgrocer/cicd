//
//  RecipeCellViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 07/08/2023.
//

import Foundation
import RxSwift

protocol RecipeCellViewModelInput { }

protocol RecipeCellViewModelOuput {
    var recipeList: Observable<[Recipe]> { get }
    var isBgGrey: Observable<Bool> { get }
    var showMiniView: Observable<Bool> { get }
}

protocol RecipeCellViewModelType: RecipeCellViewModelInput, RecipeCellViewModelOuput {
    var inputs: RecipeCellViewModelInput { get }
    var outputs: RecipeCellViewModelOuput { get }
}

extension RecipeCellViewModelType {
    var inputs: RecipeCellViewModelInput { self }
    var outputs: RecipeCellViewModelOuput { self }
}

class RecipeCellViewModel: RecipeCellViewModelType, ReusableTableViewCellViewModelType {
    var reusableIdentifier: String { "GenricHomeRecipeTableViewCell" }
    // Inputs
    
    
    // Outputs
    var recipeList: Observable<[Recipe]> { recipeListSubject.asObservable() }
    var isBgGrey: Observable<Bool> { isBgGreySubject.asObservable() }
    var showMiniView: Observable<Bool> { showMiniViewSubject.asObservable() }
    
    // Subjects
    private let recipeListSubject = BehaviorSubject<[Recipe]>(value: [])
    private let isBgGreySubject = BehaviorSubject<Bool>(value: false)
    private let showMiniViewSubject = BehaviorSubject<Bool>(value: false)
    
    // Properties
    
    // Initializations
    init(recipeList: [Recipe], isMiniView: Bool = false, isBGEabled: Bool = false) {
        self.recipeListSubject.onNext(recipeList)
        self.isBgGreySubject.onNext(isBGEabled)
        self.showMiniViewSubject.onNext(isMiniView)
    }
}
