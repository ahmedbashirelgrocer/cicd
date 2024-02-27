//
//  SlotTableViewCellViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 27/11/2023.
//

import Foundation
import RxSwift

protocol SlotTableViewCellViewModelInput { }

protocol SlotTableViewCellViewModelOutput {
    var radioButtonState: Observable<Bool> { get }
    var slotText: Observable<String?> { get }
}

protocol SlotTableViewCellViewModelType: SlotTableViewCellViewModelInput, SlotTableViewCellViewModelOutput {
    var inputs: SlotTableViewCellViewModelInput { get }
    var outputs: SlotTableViewCellViewModelOutput { get }
}

extension SlotTableViewCellViewModelType {
    var inputs: SlotTableViewCellViewModelInput { self }
    var outputs: SlotTableViewCellViewModelOutput { self }
}

class SlotTableViewCellViewModel: ReusableTableViewCellViewModelType, SlotTableViewCellViewModelType {
    var reusableIdentifier: String = "SlotsTableViewCell"
    
    /// Inputs
    
    /// Outputs
    var radioButtonState: Observable<Bool> { radioButtonStateSubject.asObservable() }
    var slotText: Observable<String?> { slotTextSubject.asObservable() }
    
    /// Subjects
    private let radioButtonStateSubject: BehaviorSubject<Bool> = .init(value: false)
    private let slotTextSubject: BehaviorSubject<String?> = .init(value: nil)
    
    init(deliverySlot: DeliverySlotDTO) {
        self.slotTextSubject.onNext(self.getFormattedDeliveryText(deliverySlot))
    }
    
    private func getFormattedDeliveryText(_ deliverySlot: DeliverySlotDTO) -> String {
        if deliverySlot.id == 0 {
            return "️Delivery within 60 min ⚡"
        }
        
        if let startTime = deliverySlot.startTime,
            let startTimeDate = startTime.convertStringToCurrentTimeZoneDate(),
            let endTime = deliverySlot.endTime,
            let endTimeDate = endTime.convertStringToCurrentTimeZoneDate() {
            
            let formattedStartTime = startTimeDate.formateDate()
            let formattedEndTime = endTimeDate.formateDate()
            return  formattedStartTime + " - " + formattedEndTime
        }
        
        return ""
    }
}
