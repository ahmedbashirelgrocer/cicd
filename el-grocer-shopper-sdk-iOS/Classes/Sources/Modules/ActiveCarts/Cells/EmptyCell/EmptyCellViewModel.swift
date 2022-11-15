//
//  EmptyCellViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 15/11/2022.
//

import Foundation
import RxSwift

protocol EmptyCellViewModelInput { }

protocol EmptyCellViewModelOutput {
    var errorMsg: Observable<String> { get }
}

protocol EmptyCellViewModelType: EmptyCellViewModelInput, EmptyCellViewModelOutput {
    var inputs: EmptyCellViewModelInput { get }
    var outputs: EmptyCellViewModelOutput { get }
}

extension EmptyCellViewModelType {
    var inputs: EmptyCellViewModelInput { self }
    var outputs: EmptyCellViewModelOutput { self }
}

class EmptyCellViewModel: EmptyCellViewModelType, ReusableTableViewCellViewModelType {
    var reusableIdentifier: String { EmptyTableViewCell.defaultIdentifier }
    
    var errorMsg: Observable<String> { errorMsgSubject.asObservable() }
    
    private let errorMsgSubject: BehaviorSubject<String>
    
    init(errorMsg: String) {
        errorMsgSubject = BehaviorSubject(value: errorMsg)
    }
}

