//
//  SingleStoreHeaderPresenter.swift
//  
//
//  Created by saboor Khan on 27/05/2024.
//

import Foundation

protocol SingleStoreHeaderInputs: AnyObject {
    func setInitialisers(grocery: Grocery, address: DeliveryAddress?)
    func updateSlot(slot: DeliverySlotDTO)
    func updateAddress(address: DeliveryAddress)
    func backButtonPressed()
    func helpButtonPressed()
    func searchBarTapped()
    func shoppingListTpped()
    func slotButtonTpped()
    func addressTapped()
    func menuTapped()
    func shouldShowToolTip(isHidden: Bool)
}

protocol SingleStoreHeaderOutputs: AnyObject {
    //Data sets
    func setDeliverySlot(slot: String)
    func setDeliveryAddress(address: String)
    func shouldShowToolTip(isHidden: Bool)
}

protocol SingleStoreHeaderDelegate: AnyObject {
    //Navigations
    func singleStoreMenuButtonPressed()
    func singleStoreBackButtonPressed()
    func singleStoreHelpButtonPressed()
    func singleStoreSearchBarTapped()
    func singleStoreShoppingListTpped()
    func singleStoreSlotButtonTpped(selectedSlotId: Int?)
    func singleStoreAddressButtonTpped()
    func singleStoreToolTipChangeLocationTpped()
}

extension SingleStoreHeaderDelegate {
    
    func singleStoreMenuButtonPressed() { }
    func singleStoreBackButtonPressed() { }
    func singleStoreHelpButtonPressed() { }
    func singleStoreSearchBarTapped() { }
    func singleStoreShoppingListTpped() { }
    func singleStoreSlotButtonTpped(selectedSlotId: Int?) { }
    func singleStoreAddressButtonTpped() { }
    func singleStoreToolTipChangeLocationTpped() {}
    
}

protocol SingleStoreHeaderType {
    var inputs: SingleStoreHeaderInputs? { get }
    var delegateOutputs: SingleStoreHeaderOutputs? { get set }
    var delegate: SingleStoreHeaderDelegate? { get set }
}

class SingleStoreHeaderPresenter: SingleStoreHeaderType {
    
    weak var inputs: SingleStoreHeaderInputs? { self }
    weak var delegateOutputs: SingleStoreHeaderOutputs?
    weak var delegate: SingleStoreHeaderDelegate?
    
    private var slot: DeliverySlotDTO?
    
    init(delegate: SingleStoreHeaderDelegate?) {
        self.delegate = delegate
    }
    
    func configure(grocery: Grocery, address: DeliveryAddress?) {
        self.delegateOutputs?.setDeliverySlot(slot: getDeliverySlotStringFromGrocery(grocery: grocery))
        self.delegateOutputs?.setDeliveryAddress(address: address?.addressString() ?? "")
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
extension SingleStoreHeaderPresenter: SingleStoreHeaderInputs {

    func setInitialisers(grocery: Grocery, address: DeliveryAddress?) {
        self.slot = nil
        self.configure(grocery: grocery, address: address)
        
    }

    func updateSlot(slot: DeliverySlotDTO) {
        self.slot = slot
        self.delegateOutputs?.setDeliverySlot(slot: getSlotStringFromSlot(slot: slot))
    }
    func updateAddress(address: DeliveryAddress) {
        self.delegateOutputs?.setDeliveryAddress(address: address.addressString())
    }
    
    func shouldShowToolTip(isHidden: Bool) {
        self.delegateOutputs?.shouldShowToolTip(isHidden: isHidden)
    }
    
    func backButtonPressed(){
        self.delegate?.singleStoreBackButtonPressed()
    }
    func helpButtonPressed(){
        self.delegate?.singleStoreHelpButtonPressed()
    }
    func addressTapped() {
        self.delegate?.singleStoreAddressButtonTpped()
    }
    func searchBarTapped(){
        self.delegate?.singleStoreSearchBarTapped()
    }
    func shoppingListTpped(){
        self.delegate?.singleStoreShoppingListTpped()
    }
    func slotButtonTpped(){
        self.delegate?.singleStoreSlotButtonTpped(selectedSlotId: slot?.id ?? nil)
    }
    func menuTapped() {
        self.delegate?.singleStoreMenuButtonPressed()
    }
}
