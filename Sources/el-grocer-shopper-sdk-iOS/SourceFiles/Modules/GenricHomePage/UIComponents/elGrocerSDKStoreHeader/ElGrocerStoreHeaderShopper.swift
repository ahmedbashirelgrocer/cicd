//
//  ElGrocerStoreHeaderShopper.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 27/07/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
import ThirdPartyObjC
import SDWebImage

let KElGrocerStoreHeaderShopperFullHeight : CGFloat = CGFloat(165)

class ElGrocerStoreHeaderShopper:  UIView  {
    
    @IBOutlet weak var searchViewTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var searchViewLeftAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var backButton: UIButton! {
        didSet {
            backButton.setTitle("", for: .normal)
            if LanguageManager.sharedInstance.getSelectedLocale() == "ar" {
                backButton.transform = CGAffineTransform.init(rotationAngle: Double.pi)
            }
        }
    }
    
    @IBOutlet weak var btnShopingList: UIButton! {
        didSet {
            btnShopingList.setTitle("", for: .normal)
            btnShopingList.addTarget(self, action: #selector(btnHelpHandler), for: .touchUpInside)
        }
    }
    @IBOutlet weak var btnHelp: UIButton! {
        didSet {
            var attributes: [NSAttributedString.Key : Any] = [:]
            attributes[.font] = UIFont.systemFont(ofSize: 12, weight: .bold)
            attributes[.foregroundColor] = ApplicationTheme.currentTheme.newBlackColor
            let title = localizedString("ios.ZDKHelpCenter.helpCenterOverview.title", comment: "")
            let atext = NSAttributedString(string: title, attributes: attributes)
            btnHelp.setAttributedTitle(atext, for: .normal)
            btnHelp.setTitleColor(ApplicationTheme.currentTheme.newBlackColor, for: .normal)
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
            // print("loaded Address: \(loadedAddress)")
        }
    }
    let halfWidth : CGFloat = 0.445
    let FullWidth : CGFloat = 0.9
    
//    @IBOutlet var showLocationArrow: UIImageView!
//    @IBOutlet var btnLocation: UIButton!
    @IBOutlet var myGroceryImage: UIImageView!{
        didSet{
            myGroceryImage.backgroundColor = .navigationBarWhiteColor()
            myGroceryImage.roundWithShadow(corners: [.layerMaxXMinYCorner , .layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 8, withShadow: false)
        }
    }
    @IBOutlet var myGroceryName: UILabel! {
        didSet {
            self.myGroceryName.autoresizingMask = .flexibleHeight
            self.myGroceryName.setH4SemiBoldWhiteStyle()
            if let lng = UserDefaults.getCurrentLanguage(){
                if lng == "ar"{
                    myGroceryName.textAlignment = .right
                }else{
                    myGroceryName.textAlignment = .left
                }
            }
            self.myGroceryName.sizeToFit()
        }
    }
//    @IBOutlet var widthMultiplier: NSLayoutConstraint!
//    @IBOutlet var slotsView: AWView!
    @IBOutlet var lblSlot: UILabel!{
        didSet {
            lblSlot.setSubHead1SemiboldWhiteStyle()
        }
    }
    
    // sab New UI
    
    @IBOutlet var bGView: UIView!{
        didSet{
            bGView.backgroundColor = .clear
            //bGView.backgroundColor = .navigationBarColor()
        }
    }
    @IBOutlet var groceryBGView: UIView!{
        didSet{
            groceryBGView.backgroundColor = .clear
            //groceryBGView.backgroundColor = .navigationBarColor()
        }
    }
    @IBOutlet var imgDeliverySlot: UIImageView!{
        didSet{
            imgDeliverySlot.image = UIImage(name: "clockWhite")
            imgDeliverySlot.image = imgDeliverySlot.image?.withCustomTintColor(color: ApplicationTheme.currentTheme.newGreyColor)
            
        }
    }
    @IBOutlet var searchBGView: UIView!{
        didSet{
            searchBGView.backgroundColor = .navigationBarWhiteColor()
            searchBGView.roundWithShadow(corners: [.layerMaxXMinYCorner , .layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 22, withShadow: false)
            searchBGView.layer.borderWidth = 1
            searchBGView.layer.borderColor = UIColor.newBorderGreyColor().cgColor
        }
    }
    @IBOutlet var imgSearch: UIImageView!{
        didSet{
            imgSearch.image = UIImage(name: "search-SearchBar")
        }
    }
    @IBOutlet var txtSearchBar: UITextField!{
        didSet{
            txtSearchBar.placeholder = localizedString("search_placeholder_store_header", comment: "")
            if ElGrocerUtility.sharedInstance.isArabicSelected(){
                txtSearchBar.textAlignment = .right
            }else{
                txtSearchBar.textAlignment = .left
            }
        }
    }
    
    @IBOutlet var slotdistanceFromClockIcon: NSLayoutConstraint!
    let headerMaxHeight: CGFloat = 155
    var shoppingListTapped: tapped?
    typealias tapped = (_ isShoppingTapped: Bool)-> Void
    class func loadFromNib() -> ElGrocerStoreHeaderShopper? {
        return self.loadFromNib(withName: "ElGrocerStoreHeaderShopper")
    }
    
    override func awakeFromNib() {
        setInitialUI(isExpanded: true)
        super.awakeFromNib()
        hideSlotImage()
    }
    
    func setInitialUI(isExpanded: Bool = true){
        self.txtSearchBar.delegate = self
        if isExpanded {
            self.groceryBGView.visibility = .visible
        } else {
            self.groceryBGView.visibility = .gone
        }
    }
    
    @IBAction func btnShoppingListHandler() {
        if let vcA = UIApplication.topViewController()?.navigationController?.viewControllers {
            for vc in vcA {
                if vc is ShoppingListViewController {
                    UIApplication.topViewController()?.navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
        }
        gotoShoppingListVC()
    }
    @IBAction func btnHelpHandler() {
        callSendBird()
    }

    func configureHeader(grocery: Grocery) {
    }
    
    fileprivate func hideSlotImage(_ isHidden: Bool = true) {
        
        if isHidden {
            self.slotdistanceFromClockIcon.constant = 0
            self.imgDeliverySlot.visibility = .goneX
        } else {
            self.slotdistanceFromClockIcon.constant = 5
            self.imgDeliverySlot.visibility = .visible
        }
        
    }
    
    func callSendBird() {
        
        guard let vc = UIApplication.topViewController() else {
            return
        }
        MixpanelEventLogger.trackStoreHelp()
        let sendBirdDeskManager = SendBirdDeskManager(controller: vc, orderId: "0", type: .agentSupport)
        sendBirdDeskManager.setUpSenBirdDeskWithCurrentUser()
    }
    
    func gotoShoppingListVC() {
        
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
//        ElGrocerUtility.sharedInstance.delay(1.0) {
//            if searchController.txtSearch != nil {
//                searchController.txtSearch.becomeFirstResponder()
//            }
//        }
        
    }
    
    
    
    
    @objc
    func setSlotData() {
        if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
            let slots = DeliverySlot.getAllDeliverySlots(DatabaseHelper.sharedInstance.mainManagedObjectContext, forGroceryID: grocery.dbID)
            if let firstObj  = slots.first(where: {$0.dbID == UserDefaults.getCurrentSelectedDeliverySlotId() }) {
//                var slotString = self.getSlotFormattedStrForStoreHeader(slot: firstObj, ElGrocerUtility.sharedInstance.isDeliveryMode)
                let slotStringData = DeliverySlotManager.getSlotFormattedStrForStoreHeader(slot: firstObj, ElGrocerUtility.sharedInstance.isDeliveryMode)
                var slotString = slotStringData.slot
                self.hideSlotImage(slotStringData.hideSlotImage)
                if firstObj.isInstant.boolValue {
                    slotString = localizedString("delivery_within_60_min", comment: "")
                    let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14), NSAttributedString.Key.foregroundColor : ApplicationTheme.currentTheme.newBlackColor]
                    let attributedString = NSMutableAttributedString(string: slotString , attributes:attrs2 as [NSAttributedString.Key : Any])
                    self.setAttributedValueForSlotOnMainThread(attributedString)
                    self.currentSelectedSlot = firstObj
                    return
                }
                self.currentSelectedSlot = firstObj
                let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14), NSAttributedString.Key.foregroundColor : ApplicationTheme.currentTheme.newBlackColor]
                let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14), NSAttributedString.Key.foregroundColor : ApplicationTheme.currentTheme.newBlackColor]
                    let attributedString = NSMutableAttributedString(string: "" , attributes:attrs1 as [NSAttributedString.Key : Any])
                    
                    var data = slotString.components(separatedBy: " ")
                    if data.count > 0 {
                        var dayName = localizedString("", comment: "")
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
//                var slotString = self.getSlotFormattedStrForStoreHeader(slot: firstObj, ElGrocerUtility.sharedInstance.isDeliveryMode)
                var slotStringData = DeliverySlotManager.getSlotFormattedStrForStoreHeader(slot: firstObj, ElGrocerUtility.sharedInstance.isDeliveryMode)
                var slotString = slotStringData.slot
                self.hideSlotImage(slotStringData.hideSlotImage)
                if firstObj.isInstant.boolValue {
//                    slotString = localizedString("today_title", comment: "") + " " +  localizedString("60_min", comment: "")  + "⚡️"
                    slotString = localizedString("delivery_within_60_min", comment: "")
                    let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14), NSAttributedString.Key.foregroundColor : ApplicationTheme.currentTheme.newBlackColor]
                    let attributedString = NSMutableAttributedString(string: slotString , attributes:attrs2 as [NSAttributedString.Key : Any])
                    self.setAttributedValueForSlotOnMainThread(attributedString)
                    self.currentSelectedSlot = firstObj
                    return
                }
                self.currentSelectedSlot = firstObj
                let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14), NSAttributedString.Key.foregroundColor : ApplicationTheme.currentTheme.newBlackColor]
                let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14), NSAttributedString.Key.foregroundColor : ApplicationTheme.currentTheme.newBlackColor]
                let attributedString = NSMutableAttributedString(string: "" , attributes:attrs1 as [NSAttributedString.Key : Any])
                
                var data = slotString.components(separatedBy: " ")
                if data.count == 0 {
                    var dayName = localizedString("", comment: "")
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
                self.lblSlot.text = localizedString("no_slots_available", comment: "")
                self.hideSlotImage(true)
            }
        }else{
             self.lblSlot.text = localizedString("no_slots_available", comment: "")
            self.hideSlotImage(true)
        }
    }
    
    func setAttributedValueForSlotOnMainThread(_ attributedString : NSMutableAttributedString) {
        
        DispatchQueue.main.async {
            //debugPrint("check: oldValue : \(self.lblSlot.attributedText?.string)")
            //debugPrint("check: NewValue : \(attributedString.string)")
            
            var isNeedToCallRefresh = false
            isNeedToCallRefresh = !(self.lblSlot.attributedText?.string == attributedString.string || self.lblSlot.attributedText?.string == "---" || self.lblSlot.attributedText?.string == "--" || self.lblSlot.attributedText?.string == localizedString("no_slots_available", comment: ""))
            
            self.lblSlot.attributedText = attributedString
            if self.myGroceryName.text != ElGrocerUtility.sharedInstance.activeGrocery?.name {
                isNeedToCallRefresh = false
            }
            if isNeedToCallRefresh  {
                
                ElGrocerUtility.sharedInstance.delay(1) {
                    if let topVc = UIApplication.topViewController() {
                        topVc.refreshSlotChange()
                    }
                }
                debugPrint("refreshCalled: controller : \(UIApplication.gettopViewControllerName())")
                //debugPrint("check: refreshCalled")
            }
        }
        
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
       // setSlotData()
        if (newWindow == nil) {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: KUpdateGenericSlotView), object: nil)
        }
    }
    
    override func didMoveToWindow() {
        if self.window != nil {
            NotificationCenter.default.addObserver(self,selector: #selector(ElGrocerStoreHeaderShopper.setSlotData), name: NSNotification.Name(rawValue: KUpdateGenericSlotView), object: nil)
        }
    }

    
//    func setUpHeight(_ height : CGFloat) {
//        self.frame.size.height = height
//        self.setNeedsLayout()
//        self.layoutIfNeeded()
//
//    }
  
    func configured() {
        self.myGroceryName.isHidden = true
        self.myGroceryImage.isHidden = true
//        self.slotsView.isHidden = true
//        self.widthMultiplier.setMultiplier(multiplier: FullWidth)
//        self.setUpHeight(52)
//        guard let address = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress() else {
//            self.lblAddress.text = localizedString("error_-6", comment: "")
//            return
//        }
//        self.lblAddress.text   = ElGrocerUtility.sharedInstance.getFormattedAddress(address).count > 0 ? ElGrocerUtility.sharedInstance.getFormattedAddress(address) : address.locationName + address.address
//         self.loadedAddress = address
//        self.localLoadedAddress = LocalDeliverAddress(lat: address.latitude, lng: address.longitude, address: address.locationName)
    }
    
    func configuredLocationAndGrocey(_ grocery : Grocery?) {
        
        guard grocery != nil else {
            self.configured()
            return
        }
        
//        self.slotsView.isHidden = false
//        self.btnLocation.isUserInteractionEnabled = false
//        self.showLocationArrow.isHidden = true
        
//        guard let address = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress() else {
//            self.lblAddress.text = localizedString("error_-6", comment: "")
//            return
//        }
//
//        self.loadedAddress = address
//        self.localLoadedAddress = LocalDeliverAddress(lat: address.latitude, lng: address.longitude, address: address.locationName)
//        self.lblAddress.text   = ElGrocerUtility.sharedInstance.getFormattedAddress(address).count > 0 ? ElGrocerUtility.sharedInstance.getFormattedAddress(address) : address.locationName + address.address
//
        self.configureCell(grocery!)
//        self.widthMultiplier.setMultiplier(multiplier: halfWidth)
//        self.setUpHeight(KElGrocerStoreHeaderShopperFullHeight)
        
    }
    
    
    func configureCell (_ grocery : Grocery) {
        
        self.myGroceryName.text = grocery.name ?? ""
        if grocery.smallImageUrl != nil && grocery.smallImageUrl?.range(of: "http") != nil {
            self.setGroceryImage(grocery.smallImageUrl!)
        }else{
            self.myGroceryImage.image = productPlaceholderPhoto
        }
//        self.myGroceryImage.layer.cornerRadius = self.myGroceryImage.frame.size.height / 2
        self.setSlotData()
    }
    
    func configureCellForBrand (_ brand : GroceryBrand) {
        
        self.setGroceryImage(brand.imageURL)
        self.myGroceryName.text = brand.name
        self.lblSlot.text = ""
    }
    
    
     func setGroceryImage(_ urlString : String) {
        
        self.myGroceryImage.sd_setImage(with: URL(string: urlString ), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: {[weak self] (image, error, cacheType, imageURL) in
            guard let self = self else {
                return
            }
            if cacheType == SDImageCacheType.none {
                
                UIView.transition(with: self.myGroceryImage, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {[weak self] () -> Void in
                    guard let self = self else {
                        return
                    }
                    self.myGroceryImage.image = image
                    }, completion: nil)
                
            }
        })
        
    }

//    @IBAction func changeLocation(_ sender: Any) {
////        changeLocation()
//    }
//
//    @IBAction func changeSlotAction(_ sender: Any) {
//
//       /*
//
//        let popupViewController = AWPickerViewController(nibName: "AWPickerViewController", bundle: nil)
//        popupViewController.changeSlot = { [weak self] (slot) in
//            self?.setSlotData()
//        }
//
//        let popupController = STPopupController(rootViewController: popupViewController)
//        if NSClassFromString("UIBlurEffect") != nil {
//           // let blurEffect = UIBlurEffect(style: .dark)
//           // popupController.backgroundView = UIVisualEffectView(effect: blurEffect)
//        }
//      //  popupController.backgroundView?.alpha = 0.8
//        popupController.navigationBarHidden = true
//        popupController.transitioning = self
//        popupController.style = .bottomSheet
//        if let topController = UIApplication.topViewController() {
//            //topController.present(popupViewController, animated: true, completion: nil)
//            popupController.backgroundView?.alpha = 1
//            popupController.containerView.layer.cornerRadius = 16
//            popupController.navigationBarHidden = true
//            popupController.transitioning = self
//            popupController.present(in: topController)
//        }
//        */
//    }
    
    
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
            return  localizedString("today_title", comment: "") + " " + localizedString("60_min", comment: "") + "⚡️"
        }else if  slot.isToday() {
            self.hideSlotImage(false)
            let name =  localizedString("today_title", comment: "")
            orderTypeDescription = String(format: "%@ %@", name ,orderTypeDescription)
        }else if slot.isTomorrow()  {
            self.hideSlotImage(false)
            let name =    localizedString("tomorrow_title", comment: "")
            orderTypeDescription = String(format: "%@ %@", name,orderTypeDescription)
        }else{
            self.hideSlotImage(false)
            orderTypeDescription =  (startDate.getDayNameLong() ?? "") + " " + orderTypeDescription
        }
        return orderTypeDescription
        
    }
    
}
extension ElGrocerStoreHeaderShopper : STPopupControllerTransitioning {
    
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
extension ElGrocerStoreHeaderShopper : UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == txtSearchBar {
//            if let topVc = UIApplication.topViewController() {
//                if let mainVc = topVc as? MainCategoriesViewController {
//                    mainVc.navigationBarSearchTapped()
//                }
//            }
            self.navigationBarSearchTapped()
            return false
        }
        return true
    }
    
    
}
