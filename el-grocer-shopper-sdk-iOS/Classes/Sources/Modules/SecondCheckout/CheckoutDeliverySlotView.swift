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

    @IBOutlet weak var slotBGView: AWView!
    @IBOutlet weak var lblSlotPrefixText: UILabel! {
        didSet {
            lblSlotPrefixText.setBody1RegWhiteStyle()
        }
    }
    @IBOutlet weak var lblSlotValue: UILabel! {
        didSet {
            lblSlotValue.setBody1SemiBoldWhiteStyle()
        }
    }
    @IBOutlet weak var imgArrow: UIImageView!
    @IBOutlet weak var imgTime: UIImageView!
    
    private var deliverySlots: [DeliverySlotDTO] = []
    private var selectedDeliverySlot: DeliverySlotDTO?
    var changeSlot : ((_ slot : DeliverySlot?) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.lblSlotPrefixText.text = localizedString("delivery_time_slot", comment: "")
    }
    
    func configure(slots: [DeliverySlotDTO], selectedSlotId: Int, modelType: OrderType = .delivery) {
        
        guard slots.count > 0 else {
            self.lblSlotValue.text = " Select Slot"
            return
        }
        
        let selectedSlot: DeliverySlotDTO? = slots.filter { $0.id ==  selectedSlotId }.first
        self.deliverySlots = slots
        
        if let selectedSlot = selectedSlot {
            self.selectedDeliverySlot = selectedSlot
            self.lblSlotPrefixText.text = modelType == .delivery
            ? localizedString("delivery_time_slot", comment: "")
            : localizedString("lbl_Self_Collection", comment: "")
            if selectedSlot.id == 0 {
                self.lblSlotValue.text =  selectedSlot.getInstantText()
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
                self.lblSlotValue.text = " " + orderTypeDescription
            }
        } else {
            

            let selectedSlot: DeliverySlotDTO = slots.filter { $0.id ==  0 }.first ?? slots[0]
            self.selectedDeliverySlot = selectedSlot
            
            self.lblSlotPrefixText.text = modelType == .delivery
            ? localizedString("delivery_time_slot", comment: "")
            : localizedString("lbl_Self_Collection", comment: "")
            
            if selectedSlot.id == 0 {
                self.lblSlotValue.text =  selectedSlot.getInstantText()
                return
            }
            
                // TODO: need to check date time zone issue
            if let startDate = selectedSlot.startTime?.convertStringToCurrentTimeZoneDate() {
                let text = startDate.isToday ? localizedString("today_title", comment: "") : localizedString("tomorrow_title", comment: "")
                let time = startDate.dataInGST()?.formatDateForCandCFormateString() ?? ""
                self.lblSlotValue.text = " \(text) \(time)"
            }
        }
        
    }

    @IBAction func btnSlotHandler(_ sender: Any) {
        
        
        let popupViewController = AWPickerViewController(nibName: "AWPickerViewController", bundle: .resource)
        popupViewController.changeSlot = { [weak self] (slot) in
            if let closure = self?.changeSlot {
                closure(slot)
            }
        }
        
        let popupController = STPopupController(rootViewController: popupViewController)
        if NSClassFromString("UIBlurEffect") != nil {
            // let blurEffect = UIBlurEffect(style: .dark)
            // popupController.backgroundView = UIVisualEffectView(effect: blurEffect)
        }
        MixpanelEventLogger.trackCheckoutDeliverySlotClicked()
        popupController.navigationBarHidden = true
        popupController.transitioning = self
        popupController.style = .bottomSheet
        popupViewController.viewType = .basket
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
