//
//  CheckoutDeliverySlotView.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 23/08/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit
import STPopup

class CheckoutDeliverySlotView: UIView  {

    @IBOutlet weak var slotBGView: AWView! {
        didSet {
            slotBGView.borderWidth = 1
            slotBGView.borderColor = ApplicationTheme.currentTheme.borderLightGrayColor
        }
    }
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSlotText: UILabel!
    @IBOutlet weak var ivArrowRight: UIImageView! {
        didSet{
            let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
            if currentLang == "ar" {
                ivArrowRight.transform = CGAffineTransform(scaleX: -1, y: 1)
                ivArrowRight.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            }
        }
    }
    
    private var deliverySlots: [DeliverySlotDTO] = []
    private var selectedDeliverySlot: DeliverySlotDTO?
    private var selectedDeliverySlotId: Int?
    var slotSelectionHandler : ((_ slot : DeliverySlotDTO?) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.lblTitle.text = localizedString("text_delivery_time", comment: "")
        self.slotBGView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHandler)))
        
        lblTitle.setBody2RegDarkStyle()
        lblSlotText.setBody3SemiBoldDarkStyle()
        
        let rightIcon = UIImage(name: "arrow-right-filled")?.withRenderingMode(.alwaysTemplate)
        ivArrowRight.tintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        ivArrowRight.image  = rightIcon
    }

    @objc func tapHandler(_ sender: UITapGestureRecognizer) {
        let popupViewController = AWPickerViewController(
            nibName: "AWPickerViewController",
            bundle: .resource,
            viewModel: AWPickerViewModel(
                grocery: ElGrocerUtility.sharedInstance.activeGrocery,
                selectedSlotId: self.selectedDeliverySlotId
            )
        )
        
        popupViewController.slotSelectedHandler = { [weak self] selectedDeliverySlot in
            guard let self = self else { return }
            
            if let slotSelectionHandler = self.slotSelectionHandler {
                slotSelectionHandler(selectedDeliverySlot)
            }
        }
        
        let popupController = STPopupController(rootViewController: popupViewController)
        MixpanelEventLogger.trackCheckoutDeliverySlotClicked()
        popupController.navigationBarHidden = true
        popupController.transitioning = self
        popupController.style = .bottomSheet
        if let topController = UIApplication.topViewController() {
            //topController.present(popupViewController, animated: true, completion: nil)
            popupController.backgroundView?.alpha = 1
            popupController.containerView.layer.cornerRadius = 16
            popupController.navigationBarHidden = true
            popupController.transitioning = self
            popupController.present(in: topController)
        }
    }
    
    func configure(selectedDeliverySlot: Int? = nil, deliverySlots: [DeliverySlotDTO]) {
        if deliverySlots.isEmpty {
            self.lblSlotText.text = "No Slot Available"
            self.lblTitle.text = localizedString("text_delivery_time", comment: "") + ":"
            return
        }
        
        self.deliverySlots = deliverySlots
        self.selectedDeliverySlotId = selectedDeliverySlot
        let selectedSlot: DeliverySlotDTO? = deliverySlots.filter { $0.id ==  selectedDeliverySlot || $0.usid == selectedDeliverySlot}.first
        if let selectedSlot = selectedSlot {
            self.selectedDeliverySlot = selectedSlot
            
            if selectedSlot.id == 0 {
                self.lblSlotText.text = selectedSlot.getInstantText()
                self.lblTitle.text = localizedString("text_delivery_time", comment: "") + ":"
                return
            }
            
            if let startDate = selectedSlot.startTime?.convertStringToCurrentTimeZoneDate(), let endDate = selectedSlot.endTime?.convertStringToCurrentTimeZoneDate() {
                let startTime = startDate.dataInGST()?.formatDateForCandCFormateString() ?? ""
                let endTime = endDate.dataInGST()?.formatDateForCandCFormateString() ?? ""
                
                let slotTimeText = startTime + " - " + endTime
                let slotDay = startDate.isToday
                    ? localizedString("today_title", comment: "")
                    : startDate.isTomorrow
                        ? localizedString("tomorrow_title", comment: "")
                        : startDate.getDayName()
                
                self.lblSlotText.text = String(format: "%@ %@", slotDay ?? "", slotTimeText)
                self.lblTitle.text = localizedString("text_delivery_time", comment: "") + ":"
            }
            
        } else {
            let selectedSlot: DeliverySlotDTO = deliverySlots.filter { $0.id ==  0 }.first ?? deliverySlots[0]
            self.selectedDeliverySlot = selectedSlot
            
            if selectedSlot.id == 0 {
                self.lblSlotText.text = selectedSlot.getInstantText()
                return
            }
            
            if let startDate = selectedSlot.startTime?.convertStringToCurrentTimeZoneDate(), let endDate = selectedSlot.endTime?.convertStringToCurrentTimeZoneDate() {
                let slotDay = startDate.isToday
                    ? localizedString("today_title", comment: "")
                    : startDate.isTomorrow
                        ? localizedString("tomorrow_title", comment: "")
                        : startDate.getDayName()
                
                let startTime = startDate.dataInGST()?.formatDateForCandCFormateString() ?? ""
                let endTime = endDate.dataInGST()?.formatDateForCandCFormateString() ?? ""

                let slotTimeText = startTime + " - " + endTime
                
                self.lblSlotText.text = String(format: "%@ %@", slotDay ?? "", slotTimeText)
                self.lblTitle.text = localizedString("text_delivery_time", comment: "") + ":"
            }
        }
        
    }
    
    func configure(slots: [DeliverySlotDTO], selectedSlotId: Int?, modelType: OrderType = .delivery) {
        
        guard slots.count > 0 else {
            self.lblSlotText.text = ""
            return
        }
        elDebugPrint(slots)
        let selectedSlot: DeliverySlotDTO? = slots.filter { $0.usid ==  selectedSlotId }.first
        self.deliverySlots = slots

        if let selectedSlot = selectedSlot {
            self.selectedDeliverySlot = selectedSlot
//            self.lblSlotPrefixText.text = modelType == .delivery
//            ? localizedString("delivery_time_slot", comment: "")
//            : localizedString("lbl_Self_Collection", comment: "")
            if selectedSlot.id == 0 {
//                self.lblSlotValue.text =  selectedSlot.getInstantText()
                return
            }
            if let startDate = selectedSlot.startTime?.convertStringToCurrentTimeZoneDate() {
                let time = startDate.dataInGST()?.formatDateForCandCFormateString() ?? ""
                var orderTypeDescription = time
                if  startDate.isToday {
                    let name =    localizedString("today_title", comment: "")
                    orderTypeDescription = String(format: "%@ %@", name ,orderTypeDescription)
                }else if startDate.isTomorrow  {
                    let name =    localizedString("tomorrow_title", comment: "")
                    orderTypeDescription = String(format: "%@ %@", name,orderTypeDescription)
                }else{
                    orderTypeDescription =  (startDate.getDayName() ?? "") + " " + orderTypeDescription
                }
//                self.lblSlotValue.text = " " + orderTypeDescription
            }
        } else {
            

            let selectedSlot: DeliverySlotDTO = slots.filter { $0.id ==  0 }.first ?? slots[0]
            self.selectedDeliverySlot = selectedSlot
            
//            self.lblSlotPrefixText.text = modelType == .delivery
//            ? localizedString("delivery_time_slot", comment: "")
//            : localizedString("lbl_Self_Collection", comment: "")
            
            if selectedSlot.id == 0 {
//                self.lblSlotValue.text =  selectedSlot.getInstantText()
                return
            }
                // TODO: need to check date time zone issue
            if let startDate = selectedSlot.startTime?.convertStringToCurrentTimeZoneDate() {
                let text = startDate.isToday ? localizedString("today_title", comment: "") : localizedString("tomorrow_title", comment: "")
                let time = startDate.dataInGST()?.formatDateForCandCFormateString() ?? ""
//                self.lblSlotValue.text = " \(text) \(time)"
            }
        }
        
    }

    @IBAction func btnSlotHandler(_ sender: Any) {
        
        
        let popupViewController = AWPickerViewController(nibName: "AWPickerViewController", bundle: .resource)
//        popupViewController.changeSlot = { [weak self] (slot) in
//            if let closure = self?.slotSelectionHandler {
//                closure(slot)
//            }
//        }
        
        let popupController = STPopupController(rootViewController: popupViewController)
        MixpanelEventLogger.trackCheckoutDeliverySlotClicked()
        popupController.navigationBarHidden = true
        popupController.transitioning = self
        popupController.style = .bottomSheet
//        popupViewController.viewType = .basket
        if let topController = UIApplication.topViewController() {
            //topController.present(popupViewController, animated: true, completion: nil)
            popupController.backgroundView?.alpha = 1
            popupController.containerView.layer.cornerRadius = 16
            popupController.navigationBarHidden = true
            popupController.transitioning = self
            popupController.present(in: topController)
        }
        
    }
}
extension CheckoutDeliverySlotView : STPopupControllerTransitioning {
    
    // MARK: STPopupControllerTransitioning
    
    func popupControllerTransitionDuration(_ context: STPopupControllerTransitioningContext) -> TimeInterval {
        return context.action == .present ? 0.40 : 0.35
    }
    
    func popupControllerAnimateTransition(_ context: STPopupControllerTransitioningContext, completion: @escaping () -> Void) {
        // Popup will be presented with an animation sliding from right to left.
        let containerView = context.containerView
        if context.action == .present {
            //            containerView.transform = CGAffineTransform(translationX: containerView.superview!.bounds.size.width - containerView.frame.origin.x, y: 0)
            containerView.transform = CGAffineTransform(translationX: 0, y: 0)
            containerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            
            UIView.animate(withDuration: popupControllerTransitionDuration(context), delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                containerView.transform = .identity
            }, completion: { _ in
                completion()
            });
            
        } else {
            UIView.animate(withDuration: popupControllerTransitionDuration(context), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                // containerView.transform = CGAffineTransform(translationX: -2 * (containerView.superview!.bounds.size.width - containerView.frame.origin.x), y: 0)
                containerView.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: { _ in
                containerView.transform = .identity
                completion()
            });
        }
    }
    
}
