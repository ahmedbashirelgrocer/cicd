//
//  EGBasketProgress.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 31/10/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
import STPopup
import SDWebImage

class EGBasketProgress: UIView {

    @IBOutlet var viewForProgress: UIView!
    @IBOutlet var imageGrocery: UIImageView!
    @IBOutlet var lblGrocery: UILabel!
    
    @IBOutlet var progressFullBar: UIImageView!
    @IBOutlet var progressHalfFilled: UIImageView!
    @IBOutlet var HalfFIllBucket: UIImageView!
    @IBOutlet var completeCheckOut: UIImageView!
    
    @IBOutlet var lblMessage: UILabel!
    @IBOutlet var lblDeliveryDetails: UILabel! {
        didSet{
            lblDeliveryDetails.text =   localizedString("dashboard_location_navigation_bar_title", comment: "")
        }
    }
    @IBOutlet var lblDeliverySlot: UILabel!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblDeliveryAddress: UILabel!
    
    @IBOutlet var deliveryDetailHeight: NSLayoutConstraint!
    
    @IBOutlet var signInBtn: UIButton!
    @IBOutlet var continueShoppingBtn: AWButton! {
        didSet{
            continueShoppingBtn.setTitle(localizedString("lbl_Contnue_shopping", comment: "") , for: UIControl.State())
        }
    }
    
    var isMinReached : Bool = false
    
     var currentBasketController: MyBasketViewController?
    
    class func loadFromNib() -> EGBasketProgress? {
        return self.loadFromNib(withName: "EGBasketProgress")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }
    
    func setTopVC(basket : MyBasketViewController) {
        self.currentBasketController = basket
    }
    
    
    func setGrocery(grocery : Grocery?) {
        guard grocery != nil else {
            return
        }
        
        self.lblGrocery.text = grocery?.name ?? ""
        if grocery?.smallImageUrl != nil && grocery?.smallImageUrl?.range(of: "http") != nil {
            self.setGroceryImage(grocery!.smallImageUrl!)
        }else{
            self.imageGrocery.image = productPlaceholderPhoto
        }
    }
    
    fileprivate func setGroceryImage(_ urlString : String) {
        
        self.imageGrocery.sd_setImage(with: URL(string: urlString ), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: {[weak self] (image, error, cacheType, imageURL) in
            guard let self = self else {
                return
            }
            if cacheType == SDImageCacheType.none {
                
                UIView.transition(with: self.imageGrocery, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {[weak self] () -> Void in
                    guard let self = self else {
                        return
                    }
                    self.imageGrocery.image = image
                    }, completion: nil)
                
            }
        })
        
    }
    
    
    func configureHalfProgressState() {
        
        self.completeCheckOut.isHidden = true
        self.HalfFIllBucket.isHidden = false
        self.progressFullBar.image = UIImage(name: "MYBasketProgressNotFilled")
        
        
    }
    
    func configureCompleteProgressState() {
        self.HalfFIllBucket.isHidden = true
        self.completeCheckOut.isHidden = false
        self.progressFullBar.image = UIImage(name: "MYBasketProgressFilled")
        
    }
    
    func setContinueshoppingEnable (_ isEnable : Bool) {
        
        if isEnable {
            self.continueShoppingBtn.isHidden = false
            self.deliveryDetailHeight.constant = 64
            configureHalfProgressState()
    
        }else{
            self.continueShoppingBtn.isHidden = true
             self.deliveryDetailHeight.constant = 25
            configureCompleteProgressState()
            
        }
    }
    
    
    
    func setMessageForShopper (_ isReadedMinLimit : Bool , minLimit : String , remainingLimit : String , storeName : String) {

        self.setContinueshoppingEnable(!isReadedMinLimit)
        if isReadedMinLimit {
            self.isMinReached = true
            self.lblMessage.textColor = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
            self.lblMessage.text =   localizedString("lbl_congrtz", comment: "")
             self.configureCompleteProgressState()
            return
        }
        self.isMinReached = false
        self.configureHalfProgressState()
        let remaining = remainingLimit + " AED "
        self.lblMessage.text = "\(localizedString("lbl_reach", comment: "")) " + minLimit + " \(CurrencyManager.getCurrentCurrency()) " + "\(localizedString("lbl_placeorder", comment: ""))\n" + "\(localizedString("lbl_Add", comment: "")) " + remaining + "\(localizedString("lbl_morefrom", comment: "")) " + storeName
        self.makeStringGreenAndBold(lbl: self.lblMessage, totalString: self.lblMessage.text ?? ""  , changeString: remaining)
           
    }
    
    func makeStringGreenAndBold (lbl : UILabel ,  totalString : String , changeString : String) {
        
//
//        let dict1 = [NSAttributedString.Key.foregroundColor: UIColor.black,NSAttributedString.Key.font:UIFont.sanFranciscoTextSemibold(17.0)]
//        let dict2 = [NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.5),NSAttributedString.Key.font:UIFont.sanFranciscoTextSemibold(14.0)]
//
        let attributedString = NSMutableAttributedString(string:totalString)
        let range = (totalString as NSString).range(of: changeString)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: ApplicationTheme.currentTheme.labelPrimaryBaseTextColor , range: range)
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.SFProDisplaySemiBoldFont(14) , range: range)
        lbl.attributedText = attributedString
        
    }
    
    
    func setDeliverySlot (_ slot : String) {
        self.lblDeliverySlot.text = slot

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
    @IBAction func signInBtnAction(_ sender: Any) {
        
        let registrationProfileController = ElGrocerViewControllers.registrationPersonalViewController()
        let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navController.viewControllers = [registrationProfileController]
        self.currentBasketController?.present(navController, animated: true, completion: nil)
        
    }
    
    
       
    @IBAction func continueShoppingHandler(_ sender: Any) {
        if let topVC = UIApplication.topViewController() {
            topVC.tabBarController?.selectedIndex = 1
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
    
}

extension MyBasketViewController : STPopupControllerTransitioning {
    
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

