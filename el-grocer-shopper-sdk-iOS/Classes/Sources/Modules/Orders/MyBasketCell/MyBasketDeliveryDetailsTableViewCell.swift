//
//  MyBasketDeliveryDetailsTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 04/11/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
import STPopup

let deliveryDetailCellHeight = CGFloat(235.0)
let deliveryDetailWithOutSlotCellHeight = CGFloat(190.0)

enum deliveryDetailCellType {
    
    case Deleivery
    case cAndc
}

class MyBasketDeliveryDetailsTableViewCell: UITableViewCell {

    
    @IBOutlet var lblAlertView: UILabel!{
        didSet{
            lblAlertView.text = NSLocalizedString("lbl-collection-detail-alert", comment: "")
        }
    }
    @IBOutlet var alertViewTopAnchor: NSLayoutConstraint!
    @IBOutlet var alertViewHeight: NSLayoutConstraint!
    @IBOutlet var slotTopSpace: NSLayoutConstraint!
    @IBOutlet var slotViewHeight: NSLayoutConstraint!
    @IBOutlet var lblDeliveryDetails: UILabel!{
        didSet{
            lblDeliveryDetails.text =   NSLocalizedString("dashboard_location_navigation_bar_title", comment: "")
        }
    }
    @IBOutlet var lblDeliverySlot: UILabel!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblDeliveryAddress: UILabel!
    var currentBasketController: MyBasketViewController?
    @IBOutlet var lblUserInfoDetail: NSLayoutConstraint!
    @IBOutlet var slotView: AWView!
    
    var cellType : deliveryDetailCellType = .Deleivery {
        
        didSet{
            
            guard alertViewHeight != nil , alertViewTopAnchor != nil else {return}
            
            if cellType == .Deleivery {
                alertViewHeight.constant = 0
                alertViewTopAnchor.constant = 0
                
                if lblDeliveryDetails != nil {
                    lblDeliveryDetails.text =   NSLocalizedString("dashboard_location_navigation_bar_title", comment: "")
                }
                
            }else{
                alertViewHeight.constant = 48
                alertViewTopAnchor.constant = 16
                if lblDeliveryDetails != nil {
                    lblDeliveryDetails.text =   NSLocalizedString("lbl_collection_Details", comment: "")
                }
            }
            self.layoutSubviews()
            self.setNeedsLayout()
            
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
     }
    
    func setTopVC(basket : MyBasketViewController) {
        self.currentBasketController = basket
    }
    
    func setUserData ( user : UserProfile?) {
        if let data = user {
            self.lblUserName.text = (data.name ?? data.email)
            let finalString =   (((data.name ?? data.email).count > 0) ? "," : "") + (data.phone ?? "")
            self.lblUserName.text = (self.lblUserName.text ?? "") + finalString
            self.lblUserName.isHidden = false
            self.lblUserInfoDetail.constant = 116
            if data.name?.count ?? 0 > 0 {
                let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14), NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()]
                let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(14), NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()]
                let attributedString = NSMutableAttributedString(string: "" , attributes:attrs1 as [NSAttributedString.Key : Any])
                let phoneNumber = data.name ?? data.email
                let attributedString1 = NSMutableAttributedString(string: phoneNumber  , attributes:attrs2 as [NSAttributedString.Key : Any])
                attributedString.append(attributedString1)
                let attributedString2 = NSMutableAttributedString(string: "," + (data.phone ?? "")  , attributes:attrs1 as [NSAttributedString.Key : Any])
                attributedString.append(attributedString2)
                DispatchQueue.main.async {
                    UIView.performWithoutAnimation {
                        self.lblUserName.attributedText = attributedString
                    }
                }
            }
        }else{
            self.lblUserName.isHidden = true
            self.lblUserInfoDetail.constant = 55
        }
        
        lblAlertView.attributedText = setBoldForText(CompleteValue: NSLocalizedString("lbl_Alert_Arrive_on_time", comment: ""), textForAttribute: NSLocalizedString("lbl_Bold_Alert_Arrive_on_time", comment: ""))
   
    }
    
    //for setting multiple font in a label
    func setBoldForText(CompleteValue : String , textForAttribute: String) -> NSMutableAttributedString {
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: CompleteValue)
        let range: NSRange = attributedString.mutableString.range(of: textForAttribute, options: .caseInsensitive)
        let attrs = [NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(14), NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()]
        attributedString.addAttributes(attrs, range: range)
        return attributedString
    }
    
    func setSlotNill() {
        
        self.slotView.isHidden = true
        self.slotViewHeight.constant = 0
        self.slotTopSpace.constant = 0
        self.contentView.layoutIfNeeded()
        self.contentView.setNeedsLayout()
    }
    
    
    func setOrdeAddress(_ order : Order?) {
        guard order != nil else {
            self.lblDeliveryAddress.text = ""
            return
        }
        let formatAddressStr =  ElGrocerUtility.sharedInstance.getFormattedAddress(order?.deliveryAddress).count > 0 ? ElGrocerUtility.sharedInstance.getFormattedAddress(order?.deliveryAddress) : (order?.deliveryAddress.locationName ?? "") + (order?.deliveryAddress.address ?? "")
        self.lblDeliveryAddress.text = formatAddressStr
       
    }
    
    
    func setPickUpAddress() {
        
        if let basket = self.currentBasketController {
            /*
            if let address =  basket.dataHandler.pickUpLocation?.details {
                
                let attrs2  = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14), NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()]
                let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(14), NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()]
                
                let initialText = NSLocalizedString("title_self_collection_point", comment: "") + "\n"
                
                let attributedString = NSMutableAttributedString(string: initialText  , attributes:attrs1 as [NSAttributedString.Key : Any])
                
                let attributedString1 = NSMutableAttributedString(string: address , attributes:attrs2 as [NSAttributedString.Key : Any])
                attributedString.append(attributedString1)
    
                DispatchQueue.main.async {
                    self.lblDeliveryAddress.attributedText = attributedString
                }
                return
            }*/
        }
        
        if let deliveryAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            let formatAddressStr =  ElGrocerUtility.sharedInstance.getFormattedAddress(deliveryAddress).count > 0 ? ElGrocerUtility.sharedInstance.getFormattedAddress(deliveryAddress) : deliveryAddress.locationName + deliveryAddress.address
            
            self.lblDeliveryAddress.text = formatAddressStr
        }else{
            self.lblDeliveryAddress.text = ""
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
    
    func setDeliverySlot (_ slot : String) {
        
        let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14), NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
        let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayBoldFont(14), NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
        
        let slotText = self.currentBasketController?.isDeliveryMode ?? true ? NSLocalizedString("Delivery_Slot", comment: "") : NSLocalizedString("lbl_Self_Collection", comment: "") + ":"
        
        let attributedString = NSMutableAttributedString(string: "" , attributes:attrs1 as [NSAttributedString.Key : Any])
       
        let attributedString1 = NSMutableAttributedString(string:slotText , attributes:attrs1 as [NSAttributedString.Key : Any])
        attributedString.append(attributedString1)
        let attributedString2 = NSMutableAttributedString(string: " " + slot , attributes:attrs2 as [NSAttributedString.Key : Any])
        attributedString.append(attributedString2)
  
        DispatchQueue.main.async {
            self.lblDeliverySlot.attributedText = attributedString
        }
    
    }
    
    @IBAction func ActionDeliverySlot(_ sender: Any) {
        
        let popupViewController = AWPickerViewController(nibName: "AWPickerViewController", bundle: nil)
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
            popupController.backgroundView?.alpha = 1
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
extension MyBasketDeliveryDetailsTableViewCell : STPopupControllerTransitioning {
    
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
