//
//  deliverySlotCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 02/08/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import STPopup

let KdeliverSlotCellHeight = 56 + 10 // 1 for margin

class deliverySlotCell: UITableViewCell {

    @IBOutlet var slotBGView: AWView!
    @IBOutlet var lblSlotValue: UILabel!
    @IBOutlet var imgArrow: UIImageView!
    @IBOutlet var imgTime: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func getCurrentDeliverySlotString(grocery : Grocery) -> String{
        let slots = DeliverySlot.getAllDeliverySlots(DatabaseHelper.sharedInstance.backgroundManagedObjectContext, forGroceryID: grocery.dbID)
        let selectedSlotID = UserDefaults.getCurrentSelectedDeliverySlotId()
        
//        if let firstObj  = slots.first(where: {$0.dbID == selectedSlotID }) {
//
//         let slotString = DeliverySlot.getSlotFormattedString(firstObj)
//
//        }
        return ""
        
    }
    
    
    func configureCell (time : String , modeType : OrderType = .delivery) {
        
        let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(17), NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
        let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayBoldFont(17), NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
        
        let slotText = modeType == .delivery ? localizedString("delivery_time_slot", comment: "") : localizedString("lbl_Self_Collection", comment: "") + ":"
        
        let attributedString = NSMutableAttributedString(string: "" , attributes:attrs1 as [NSAttributedString.Key : Any])
       
        let attributedString1 = NSMutableAttributedString(string:slotText , attributes:attrs1 as [NSAttributedString.Key : Any])
        attributedString.append(attributedString1)
        let attributedString2 = NSMutableAttributedString(string: " " + time , attributes:attrs2 as [NSAttributedString.Key : Any])
        attributedString.append(attributedString2)
  
        DispatchQueue.main.async {
            self.lblSlotValue.attributedText = attributedString
        }
    
    }

    @IBAction func btnSlotHandler(_ sender: Any) {
        
        
        let popupViewController = AWPickerViewController(nibName: "AWPickerViewController", bundle: Bundle.resource)
        let popupController = STPopupController(rootViewController: popupViewController)
        if NSClassFromString("UIBlurEffect") != nil {
            // let blurEffect = UIBlurEffect(style: .dark)
            // popupController.backgroundView = UIVisualEffectView(effect: blurEffect)
        }
        //  popupController.backgroundView?.alpha = 0.8
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
}
extension deliverySlotCell : STPopupControllerTransitioning {
    
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
