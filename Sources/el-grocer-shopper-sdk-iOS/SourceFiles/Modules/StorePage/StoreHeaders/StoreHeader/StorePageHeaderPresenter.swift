//
//  StorePageHeaderPresenter.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by saboor Khan on 03/05/2024.
//

import Foundation

protocol StorePageHeaderInputs: AnyObject {
    func setInitialisers(grocery: Grocery)
    func updateSlot(slot: DeliverySlotDTO)
    func backButtonPressed()
    func helpButtonPressed()
    func searchBarTapped()
    func shoppingListTpped()
    func slotButtonTpped()
    func shouldHideSlot(isHidden: Bool)
}

protocol StorePageHeaderOutputs: AnyObject {
    //Data sets
    func setGroceryTitle(grocery: String)
    func setGroceryImage(url: String)
    func setDeliverySlot(slot: String)
    func shouldHideSlot(isHidden: Bool)
}

protocol StorePageHeaderDelegate: AnyObject {
    //Navigations
    func backButtonPressed()
    func helpButtonPressed()
    func searchBarTapped()
    func shoppingListTpped()
    func slotButtonTpped(selectedSlotId: Int?)
}

extension StorePageHeaderDelegate {
    func backButtonPressed() { }
    func helpButtonPressed() { }
    func searchBarTapped() { }
    func shoppingListTpped() { }
    func slotButtonTpped(selectedSlotId: Int?) { }
}

protocol StorePageHeaderType {
    var inputs: StorePageHeaderInputs? { get }
    var delegateOutputs: StorePageHeaderOutputs? { get set }
    var delegate: StorePageHeaderDelegate? { get set }
}

class StorePageHeaderPresenter: StorePageHeaderType {
    
    weak var inputs: StorePageHeaderInputs? { self }
    weak var delegateOutputs: StorePageHeaderOutputs?
    weak var delegate: StorePageHeaderDelegate?
    private var slot: DeliverySlotDTO?
    
    init(delegate: StorePageHeaderDelegate?) {
        self.delegate = delegate
    }
    
    func configure(grocery: Grocery) {
        self.delegateOutputs?.setGroceryTitle(grocery: grocery.name ?? "")
        self.delegateOutputs?.setGroceryImage(url: grocery.smallImageUrl ?? "")
        self.delegateOutputs?.setDeliverySlot(slot: getDeliverySlotStringFromGrocery(grocery: grocery))
    }
    
    func getSlotStringFromSlot(slot: DeliverySlotDTO)-> String {
        
        var slotString = ""
        
        if slot.isInstant {
            slotString = "🛵 " + localizedString("today_title", comment: "") + " " + localizedString("60_min", comment: "")
        }else {
            
            let slotStringData = DeliverySlotManager.getSlotFormattedStrForStorPageHeader(slot: slot)
            var data = slotStringData.components(separatedBy: " ")
            var dayName: String = ""
            var slotName: String = ""
            if data.count > 0 {
                dayName = localizedString("", comment: "")
                data.removeFirst()
            }
            if data.count == 1 || data.count > 1 {
                slotName = slotStringData
            }
            slotString = "🚛 " + dayName + slotName
        }
        return slotString
    }
    
    func getDeliverySlotStringFromGrocery(grocery: Grocery)-> String {
        let scheduledEmoji = "🚛 "
        if  (grocery.isOpen.boolValue && (grocery.isInstant() || grocery.isInstantSchedule())) {
            
            let instantSlotString = "🛵 " + localizedString("today_title", comment: "") + " " + localizedString("60_min", comment: "")
            return instantSlotString
            
        }else if let jsonSlot = grocery.initialDeliverySlotData {
            if let dict = grocery.convertToDictionary(text: jsonSlot) {
                var slotString = ""
                let slotStringData = DeliverySlotManager.getStoreGenericSlotFormatterTimeStringWithDictionary(dict, isDeliveryMode: grocery.isDelivery.boolValue)
                
                let data = slotStringData.components(separatedBy: CharacterSet.newlines)
                if data.count == 1 {
                    slotString = data[0]
                }else {
                    slotString = data[0] + " " + data[1]
                }
                return scheduledEmoji + slotString
            }else {
                return scheduledEmoji + (grocery.genericSlot ?? "")
            }
        }else {
            return scheduledEmoji + (grocery.genericSlot ?? "")
        }
        
    }
    
}

//MARK: Navugations
extension StorePageHeaderPresenter: StorePageHeaderInputs {
    func setInitialisers(grocery: Grocery) {
        self.slot = nil
        self.configure(grocery: grocery)
        
    }
    
    func updateSlot(slot: DeliverySlotDTO) {
        self.slot = slot
        self.delegateOutputs?.setDeliverySlot(slot: getSlotStringFromSlot(slot: slot))
    }
    
    func backButtonPressed(){
        self.delegate?.backButtonPressed()
    }
    func helpButtonPressed(){
        self.delegate?.helpButtonPressed()
    }
    func searchBarTapped(){
        self.delegate?.searchBarTapped()
    }
    func shoppingListTpped(){
        self.delegate?.shoppingListTpped()
    }
    func slotButtonTpped(){
        self.delegate?.slotButtonTpped(selectedSlotId: slot?.id ?? nil)
    }
    func shouldHideSlot(isHidden: Bool) {
        self.delegateOutputs?.shouldHideSlot(isHidden: isHidden)
    }
}
