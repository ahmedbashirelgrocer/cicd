//
//  DateSliderCollectionViewCellViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 28/11/2023.
//

import Foundation
import RxSwift

protocol DateSliderCollectionViewCellViewModelInput {

}

protocol DateSliderCollectionViewCellViewModelOutput {
    var dateString: Observable<String> { get }
    var dayString: Observable<String> { get }
}

protocol DateSliderCollectionViewCellViewModelType: DateSliderCollectionViewCellViewModelInput, DateSliderCollectionViewCellViewModelOutput {
    var inputs: DateSliderCollectionViewCellViewModelInput { get }
    var outputs: DateSliderCollectionViewCellViewModelOutput { get }
}

extension DateSliderCollectionViewCellViewModelType {
    var inputs: DateSliderCollectionViewCellViewModelInput { self }
    var outputs: DateSliderCollectionViewCellViewModelOutput { self }
}

class DateSliderCollectionViewCellViewModel: ReusableCollectionViewCellViewModelType, DateSliderCollectionViewCellViewModelType {
    var reusableIdentifier: String = "DateSliderCollectionViewCell"
    
    /// Inputs
    
    /// Outputs
    var dateString: Observable<String> { dateStringSubject.asObservable() }
    var dayString: Observable<String> { dayStringSubject.asObservable() }
    
    private let dateStringSubject: BehaviorSubject<String> = .init(value: "")
    private let dayStringSubject: BehaviorSubject<String> = .init(value: "")
    
    init(date: Date) {
        dateStringSubject.onNext(date.formateDate(dateFormate: "dd MMM"))
        dayStringSubject.onNext(self.dayString(date: date))
    }
    
    private func dayString(date: Date) -> String {
        if date.isToday {
            return localizedString("today_title", comment: "")
        } else if date.isTomorrow {
            return localizedString("tomorrow_title", comment: "")
        } else {
            return date.getDayNameFull() ?? ""
        }
    }
}
