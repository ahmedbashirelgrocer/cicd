//
//  RXHeadingTableViewCellViewModel.swift
//  Pods
//
//  Created by Abdul Saboor on 21/02/2024.
//

import Foundation
import RxSwift
import RxDataSources

protocol RXHeadingTableViewCellViewModelInput {
    
}

protocol RXHeadingTableViewCellViewModelOuput {
    
    var title: Observable<String?> { get }
}

protocol RXHeadingTableViewCellViewModelType: RXHeadingTableViewCellViewModelInput, RXHeadingTableViewCellViewModelOuput {
    var inputs: RXHeadingTableViewCellViewModelInput { get }
    var outputs: RXHeadingTableViewCellViewModelOuput { get }
}

extension RXHeadingTableViewCellViewModelType {
    var inputs: RXHeadingTableViewCellViewModelInput { self }
    var outputs: RXHeadingTableViewCellViewModelOuput { self }
}

class RXHeadingTableViewCellViewModel: ReusableTableViewCellViewModelType, RXHeadingTableViewCellViewModelType {
    var reusableIdentifier: String = "RXHeadingTableViewCell"
    
    //MARK: Inputs
    
    //MARK: Outputs
    var title: Observable<String?> { self.titleSubject.asObservable() }
    //MARK: Subject
    private let titleSubject = BehaviorSubject<String?>(value: nil)
    
    init(title: String) {
        
        self.titleSubject.onNext(title)
    }
}
