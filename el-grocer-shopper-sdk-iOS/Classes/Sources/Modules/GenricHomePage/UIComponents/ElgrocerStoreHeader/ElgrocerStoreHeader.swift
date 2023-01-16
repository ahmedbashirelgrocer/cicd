//
//  ElgrocerStoreHeader.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 27/07/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
import STPopup

let KElgrocerStoreHeaderFullHeight : CGFloat = CGFloat(165)

class ElgrocerStoreHeader:  UIView  {
    
    @IBOutlet weak var btnMenu: UIButton! { didSet {
        self.btnMenu.setTitle("", for: .normal)
        self.btnMenu.addTarget(self, action: #selector(profileBTNClicked), for: .touchUpInside)
    }}
    
    @IBOutlet weak var backButton: UIButton! {
        didSet {
            backButton.setTitle("", for: .normal)
            if LanguageManager.sharedInstance.getSelectedLocale() == "ar" {
                backButton.transform = CGAffineTransform.init(rotationAngle: Double.pi)
            }
            backButton.addTarget(self, action: #selector(btnBackPressed), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var btnHelp: UIButton! {
        didSet {
            btnHelp.setTitle("", for: .normal)
            btnHelp.addTarget(self, action: #selector(btnHelpHandler), for: .touchUpInside)
        }
    }
    
    var currentVC : UIViewController? {
        didSet{
            if currentVC != nil {
                ElGrocerUtility.sharedInstance.slotViewControllerList.insert(currentVC!)
            }
            
        }
    }
    var currentSelectedSlot : DeliverySlot?
    
    var localLoadedAddress: LocalDeliverAddress?
    var loadedAddress : DeliveryAddress? {
        didSet {
            print("loaded Address: \(loadedAddress)")
        }
    }
//    let halfWidth : CGFloat = 0.445
//    let FullWidth : CGFloat = 0.9
    
    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        let purple = #colorLiteral(red: 0.5440375805, green: 0.3271837234, blue: 0.6164366603, alpha: 1)
        let red = #colorLiteral(red: 0.875736475, green: 0.2409847379, blue: 0.1460545063, alpha: 1)
        gradient.colors = [purple.cgColor, red.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0.6, y: 0.6)
        return gradient
    }()
    
    @objc func btnBackPressed() {
        SDKManager.shared.rootViewController?.dismiss(animated: true)
    }
    @objc func profileBTNClicked() {
        let navigationController = UIApplication.topViewController()?.navigationController
        let elNavigationController = navigationController as? ElGrocerNavigationController
        elNavigationController?.profileButtonClick()
    }
    
    @IBOutlet var bGView: UIView! { didSet {
        bGView.layer.insertSublayer(gradientLayer, at: 0)
    }}
    
    @IBOutlet var groceryBGView: UIView!
    
    @IBOutlet weak var iconLocation: UIImageView! { didSet {
        iconLocation.image = iconLocation.image?.withRenderingMode(.alwaysTemplate)
    } }
    @IBOutlet weak var lblLocation: UILabel!
    
    @IBOutlet var searchBGView: UIView!{
        didSet{
            searchBGView.backgroundColor = .navigationBarWhiteColor()
            searchBGView.roundWithShadow(corners: [.layerMaxXMinYCorner , .layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 20, withShadow: false)
            searchBGView.layer.borderWidth = 1
            searchBGView.layer.borderColor = UIColor.newBorderGreyColor().cgColor
        }
    }
    @IBOutlet var imgSearch: UIImageView!
    @IBOutlet var txtSearchBar: UITextField!{
        didSet{
            txtSearchBar.placeholder = "Search products..." //NSLocalizedString("search_placeholder_store_header", comment: "")
            if ElGrocerUtility.sharedInstance.isArabicSelected(){
                txtSearchBar.textAlignment = .right
            }else{
                txtSearchBar.textAlignment = .left
            }
        }
    }
    
//    @IBOutlet var slotdistanceFromClockIcon: NSLayoutConstraint!
    
    let headerMaxHeight: CGFloat = 155
    
    typealias tapped = (_ isShoppingTapped: Bool)-> Void
    var shoppingListTapped: tapped?
    
    
    class func loadFromNib() -> ElgrocerStoreHeader? {
        return self.loadFromNib(withName: "ElgrocerStoreHeader")
    }
    
    override func awakeFromNib() {
        setInitialUI(isExpanded: true)
        super.awakeFromNib()
        hideSlotImage()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bGView.bounds
    }
    
    func setInitialUI(isExpanded: Bool = true){
        self.txtSearchBar.delegate = self
        if isExpanded{
            self.groceryBGView.visibility = .visible
        }else{
            self.groceryBGView.visibility = .gone
        }
    }
    
//    @IBAction func btnShoppingListHandler() {
//
//        if let vcA = UIApplication.topViewController()?.navigationController?.viewControllers {
//            for vc in vcA {
//                if vc is ShoppingListViewController {
//                    UIApplication.topViewController()?.navigationController?.popToViewController(vc, animated: true)
//                    return
//                }
//            }
//        }
//        gotoShoppingListVC()
//    }
    @IBAction func btnHelpHandler() {
        callSendBird()
    }
    
    func configureHeader(grocery: Grocery){
    }
    
    fileprivate func hideSlotImage(_ isHidden: Bool = true){
//        if isHidden{
//
//            self.slotdistanceFromClockIcon.constant = 0
//            self.imgDeliverySlot.visibility = .goneX
//        }else{
//            self.slotdistanceFromClockIcon.constant = 5
//            self.imgDeliverySlot.visibility = .visible
//
//        }
    }
    
    func callSendBird(){
        guard let vc = UIApplication.topViewController() else {
            return
        }
        MixpanelEventLogger.trackStoreHelp()
        let sendBirdDeskManager = SendBirdDeskManager(controller: vc, orderId: "0", type: .agentSupport)
        sendBirdDeskManager.setUpSenBirdDeskWithCurrentUser()
    }
    
    func gotoShoppingListVC(){
        guard let vc = UIApplication.topViewController() else {
            return
        }
        MixpanelEventLogger.trackStoreShoppingList()
        let controller : SearchListViewController = ElGrocerViewControllers.getSearchListViewController()
        controller.isFromHeader = true
        let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navController.viewControllers = [controller]
        navController.modalPresentationStyle = .fullScreen
        vc.navigationController?.present(navController, animated: true, completion: nil)
    }

    func navigationBarSearchTapped() {
        print("Implement in controller")
        
        guard let vc = UIApplication.topViewController() else {
            return
        }
        
        let searchController = ElGrocerViewControllers.getUniversalSearchViewController()
        ElGrocerEventsLogger.sharedInstance.trackScreenNav( ["clickedEvent" : "Search" , "isUniversal" : "0" ,  FireBaseParmName.CurrentScreen.rawValue : (FireBaseEventsLogger.gettopViewControllerName() ?? "") , FireBaseParmName.NextScreen.rawValue : FireBaseScreenName.Search.rawValue ])
        MixpanelEventLogger.trackStoreSearch()
        searchController.navigationFromControllerName = FireBaseEventsLogger.gettopViewControllerName() ?? ""
        searchController.searchFor = .isForStoreSearch
        vc.navigationController?.modalTransitionStyle = .crossDissolve
        vc.navigationController?.modalPresentationStyle = .formSheet
        vc.navigationController?.pushViewController(searchController, animated: true)
        ElGrocerUtility.sharedInstance.delay(1.0) {
            if searchController.txtSearch != nil {
                searchController.txtSearch.becomeFirstResponder()
            }
        }
        
    }
    
    
    
    
    @objc
    func setSlotData() {
        if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
            let slots = DeliverySlot.getAllDeliverySlots(DatabaseHelper.sharedInstance.mainManagedObjectContext, forGroceryID: grocery.dbID)
            if let firstObj  = slots.first(where: {$0.dbID == UserDefaults.getCurrentSelectedDeliverySlotId() }) {
                let slotStringData = DeliverySlotManager.getSlotFormattedStrForStoreHeader(slot: firstObj, ElGrocerUtility.sharedInstance.isDeliveryMode)
                var slotString = slotStringData.slot
                self.hideSlotImage(slotStringData.hideSlotImage)
                if firstObj.isInstant.boolValue {
                    slotString = NSLocalizedString("delivery_within_60_min", comment: "")
                    let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayBoldFont(14), NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
                    let attributedString = NSMutableAttributedString(string: slotString , attributes:attrs2 as [NSAttributedString.Key : Any])
                    self.setAttributedValueForSlotOnMainThread(attributedString)
                    self.currentSelectedSlot = firstObj
                    return
                }
                self.currentSelectedSlot = firstObj
                let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14), NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
                let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayBoldFont(14), NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
                    let attributedString = NSMutableAttributedString(string: "" , attributes:attrs1 as [NSAttributedString.Key : Any])
                    
                    var data = slotString.components(separatedBy: " ")
                    if data.count > 0 {
                        var dayName = NSLocalizedString("lbl_next_delivery", comment: "")
                        if ElGrocerUtility.sharedInstance.isDeliveryMode {
                            dayName = NSLocalizedString("lbl_next_delivery", comment: "")
                        }else {
                            dayName = NSLocalizedString("lbl_next_self_collection", comment: "")
                        }
                        let attributedString2 = NSMutableAttributedString(string:dayName as String , attributes:attrs1 as [NSAttributedString.Key : Any])
                        attributedString.append(attributedString2)
                        data.removeFirst()
                    }
                    if data.count == 1 || data.count > 1 {
                        var slotName = slotString//" " + data.joined(separator: " ")
                        if !ElGrocerUtility.sharedInstance.isDeliveryMode {
                            let cAndcDateStringA = slotName.components(separatedBy: " - ")
                            if cAndcDateStringA.count > 1 {
                                slotName = cAndcDateStringA[0]
                            }else{
                                let cAndcDateStringA = slotName.components(separatedBy: "-")
                                slotName = cAndcDateStringA[0]
                            }
                        }
                        let attributedString2 = NSMutableAttributedString(string:slotName as String , attributes:attrs2 as [NSAttributedString.Key : Any])
                        attributedString.append(attributedString2)
                    }
                
                self.setAttributedValueForSlotOnMainThread(attributedString)
            }else if slots.count > 0 {
                let firstObj = slots[0]
                var slotStringData = DeliverySlotManager.getSlotFormattedStrForStoreHeader(slot: firstObj, ElGrocerUtility.sharedInstance.isDeliveryMode)
                var slotString = slotStringData.slot
                self.hideSlotImage(slotStringData.hideSlotImage)
                if firstObj.isInstant.boolValue {
                    slotString = NSLocalizedString("delivery_within_60_min", comment: "")
                    let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayBoldFont(14), NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
                    let attributedString = NSMutableAttributedString(string: slotString , attributes:attrs2 as [NSAttributedString.Key : Any])
                    self.setAttributedValueForSlotOnMainThread(attributedString)
                    self.currentSelectedSlot = firstObj
                    return
                }
                self.currentSelectedSlot = firstObj
                let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14), NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
                let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayBoldFont(14), NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
                let attributedString = NSMutableAttributedString(string: "" , attributes:attrs1 as [NSAttributedString.Key : Any])
                
                var data = slotString.components(separatedBy: " ")
                if data.count == 0 {
                    var dayName = NSLocalizedString("lbl_next_delivery", comment: "")
                    if ElGrocerUtility.sharedInstance.isDeliveryMode {
                        dayName = NSLocalizedString("lbl_next_delivery", comment: "")
                    }else {
                        dayName = NSLocalizedString("lbl_next_self_collection", comment: "")
                    }
                    let attributedString2 = NSMutableAttributedString(string:dayName as String , attributes:attrs1 as [NSAttributedString.Key : Any])
                    attributedString.append(attributedString2)
                    data.removeFirst()
                }
                if data.count > 1 {
                    let slotName = slotString//" " + data.joined(separator: " ")
                    let attributedString2 = NSMutableAttributedString(string:slotName as String , attributes:attrs2 as [NSAttributedString.Key : Any])
                    attributedString.append(attributedString2)
                }
                
                self.setAttributedValueForSlotOnMainThread(attributedString)
               
                
            }else{
                debugPrint("")
//                self.lblSlot.text = NSLocalizedString("no_slots_available", comment: "")
                self.hideSlotImage(true)
            }
        }else{
//             self.lblSlot.text = NSLocalizedString("no_slots_available", comment: "")
            self.hideSlotImage(true)
        }
    }
    
    func setAttributedValueForSlotOnMainThread(_ attributedString : NSMutableAttributedString) {
        
//        DispatchQueue.main.async {
//            var isNeedToCallRefresh = false
//            isNeedToCallRefresh = !(self.lblSlot.attributedText?.string == attributedString.string || self.lblSlot.attributedText?.string == "---" || self.lblSlot.attributedText?.string == "--" || self.lblSlot.attributedText?.string == NSLocalizedString("no_slots_available", comment: ""))
//
//            self.lblSlot.attributedText = attributedString
//            if self.myGroceryName.text != ElGrocerUtility.sharedInstance.activeGrocery?.name {
//                isNeedToCallRefresh = false
//            }
//            if isNeedToCallRefresh  {
//
//                ElGrocerUtility.sharedInstance.delay(1) {
//                    if let topVc = UIApplication.topViewController() {
//                        topVc.refreshSlotChange()
//                    }
//                }
//                debugPrint("refreshCalled: controller : \(UIApplication.gettopViewControllerName())")
//            }
//        }
        
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
       
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
      
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        debugPrint("")
        if (newWindow == nil) {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: KUpdateGenericSlotView), object: nil)
        }
    }
    
    override func didMoveToWindow() {
        if self.window != nil {
            NotificationCenter.default.addObserver(self,selector: #selector(ElgrocerStoreHeader.setSlotData), name: NSNotification.Name(rawValue: KUpdateGenericSlotView), object: nil)
        }
    }
  
    func configured() {
//        self.myGroceryName.isHidden = true
//        self.myGroceryImage.isHidden = true
    }
    
    func configuredLocationAndGrocey(_ grocery : Grocery?) {
        
        guard grocery != nil else {
            self.configured()
            return
        }
        self.configureCell(grocery!)
    }
    
    
    func configureCell (_ grocery : Grocery) {
        
//        self.myGroceryName.text = grocery.name ?? ""
        if grocery.smallImageUrl != nil && grocery.smallImageUrl?.range(of: "http") != nil {
            self.setGroceryImage(grocery.smallImageUrl!)
        }else{
//            self.myGroceryImage.image = productPlaceholderPhoto
        }
        self.setSlotData()
    }
    
    func configureCellForBrand (_ brand : GroceryBrand) {
        
        self.setGroceryImage(brand.imageURL)
//        self.myGroceryName.text = brand.name
//        self.lblSlot.text = ""
    }
    
    
     func setGroceryImage(_ urlString : String) {
//        self.myGroceryImage.sd_setImage(with: URL(string: urlString ), placeholderImage: productPlaceholderPhoto, completed: {[weak self] (image, error, cacheType, imageURL) in
//            guard let self = self else {
//                return
//            }
//                UIView.transition(with: self.myGroceryImage, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {[weak self] () -> Void in
//                    guard let self = self else {
//                        return
//                    }
//                    self.myGroceryImage.image = image
//                    }, completion: nil)
//
//        })
        
    }
    
    
    func changeLocation() {
        
        let dashboardLocationVC = ElGrocerViewControllers.dashboardLocationViewController()
        dashboardLocationVC.isFromNewHome = true
        dashboardLocationVC.isRootController = true
        let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [dashboardLocationVC]
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.setLogoHidden(true)
        DispatchQueue.main.async {
            if let top = UIApplication.topViewController() {
                top.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: Date Helper
    
    private func getSlotFormattedStrForStoreHeader(slot : DeliverySlot ,  _  isDeliveryMode : Bool ) -> String {
        // Delivery within 60 min ⚡️
        guard slot.start_time != nil && slot.end_time != nil else { return "" }
        
        let startDate =  slot.start_time!
        let endDate =  slot.end_time!
        var orderTypeDescription = ( isDeliveryMode ?  startDate.formatDateForDeliveryHAFormateString() : startDate.formatDateForCandCFormateString() ) + "-" + ( isDeliveryMode ?  endDate.formatDateForDeliveryHAFormateString() : endDate.formatDateForCandCFormateString())
        
        if slot.isInstant.boolValue {
            self.hideSlotImage(true)
            return  NSLocalizedString("today_title", comment: "") + " " + NSLocalizedString("60_min", comment: "") + "⚡️"
        }else if  slot.isToday() {
            self.hideSlotImage(false)
            let name =  NSLocalizedString("today_title", comment: "")
            orderTypeDescription = String(format: "%@ %@", name ,orderTypeDescription)
        }else if slot.isTomorrow()  {
            self.hideSlotImage(false)
            let name =    NSLocalizedString("tomorrow_title", comment: "")
            orderTypeDescription = String(format: "%@ %@", name,orderTypeDescription)
        }else{
            self.hideSlotImage(false)
            orderTypeDescription =  (startDate.getDayNameLong() ?? "") + " " + orderTypeDescription
        }
        return orderTypeDescription
        
    }
    
}
extension ElgrocerStoreHeader : STPopupControllerTransitioning {
    
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
                containerView.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: { _ in
                containerView.transform = .identity
                completion()
            });
        }
    }
    
}
extension ElgrocerStoreHeader : UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == txtSearchBar {
            self.navigationBarSearchTapped()
            return false
        }
        return true
    }
    
    
}
