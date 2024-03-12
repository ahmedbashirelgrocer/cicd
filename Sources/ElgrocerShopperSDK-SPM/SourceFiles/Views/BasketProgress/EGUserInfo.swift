//
//  EGUserInfo.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 03/11/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
import ThirdPartyObjC
class EGUserInfo: UIView {

    
    @IBOutlet var lblDeliveryDetails: UILabel!{
        didSet{
            lblDeliveryDetails.text =   localizedString("dashboard_location_navigation_bar_title", comment: "")
        }
    }
    @IBOutlet var lblDeliverySlot: UILabel!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblDeliveryAddress: UILabel!
              var currentBasketController: MyBasketViewController?
    
    class func loadFromNib() -> EGUserInfo? {
        return self.loadFromNib(withName: "EGUserInfo")
    }
    
    func setTopVC(basket : MyBasketViewController) {
        self.currentBasketController = basket
    }
    
    
    func setUserData ( user : UserProfile?) {
        if let data = user {
            self.lblUserName.text = (data.name ?? data.email)
            let finalString =   (((data.name ?? data.email).count > 0) ? " , " : "") + (data.phone ?? "")
            self.lblUserName.text = (self.lblUserName.text ?? "") + finalString
            self.lblUserName.isHidden = false
        }else{
            self.lblUserName.isHidden = true
        }
        
    }
    
    func setAddress() {
        if let deliveryAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            let formatAddressStr =  ElGrocerUtility.sharedInstance.getFormattedAddress(deliveryAddress).count > 0 ? ElGrocerUtility.sharedInstance.getFormattedAddress(deliveryAddress) : deliveryAddress.locationName + deliveryAddress.address
            
            self.lblDeliveryAddress.text = formatAddressStr
        }else{
            self.lblDeliveryAddress.text = ""
        }
        
    }
    
    @IBAction func ActionDeliverySlot(_ sender: Any) {
        
        let popupViewController = AWPickerViewController(nibName: "AWPickerViewController", bundle: Bundle.resource)
        let popupController = STPopupController(rootViewController: popupViewController)
        if NSClassFromString("UIBlurEffect") != nil {
            // let blurEffect = UIBlurEffect(style: .dark)
            // popupController.backgroundView = UIVisualEffectView(effect: blurEffect)
        }
        //  popupController.backgroundView?.alpha = 0.8
        popupController.navigationBarHidden = true
        popupController.transitioning = self.currentBasketController
        popupController.style = .bottomSheet
        if let topController = UIApplication.topViewController() {
            //topController.present(popupViewController, animated: true, completion: nil)
            popupController.backgroundView?.alpha = 0.5
            popupController.containerView.layer.cornerRadius = 16
            popupController.navigationBarHidden = true
            popupController.transitioning = self.currentBasketController
            popupController.present(in: topController)
        }
        
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
extension EGUserInfo : STPopupControllerTransitioning {
    
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
