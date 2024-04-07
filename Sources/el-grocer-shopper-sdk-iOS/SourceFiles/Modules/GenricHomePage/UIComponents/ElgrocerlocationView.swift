//
//  ElgrocerlocationView.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 27/07/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
import ThirdPartyObjC
import SDWebImage

let KElgrocerlocationViewFullHeight : CGFloat = CGFloat(165)


extension UIViewController : SlotChangeRefreshing {
    
    @objc func refreshSlotChange() { }
}

protocol SlotChangeRefreshing {
    func refreshSlotChange ()
}
struct LocalDeliverAddress {
    var lat: Double
    var lng: Double
    var address: String
}
class ElgrocerlocationView:  UIView  {
    
    
    var currentVC : UIViewController? {
        didSet{
            if currentVC != nil {
                ElGrocerUtility.sharedInstance.slotViewControllerList.insert(currentVC!)
            }
            
        }
    }
    
    var currentSelectedSlot : DeliverySlot?
    var localLoadedAddress: LocalDeliverAddress?
    var loadedAddress : DeliveryAddress?
    
    let halfWidth : CGFloat = 0.445
    let FullWidth : CGFloat = 0.9
    
    @IBOutlet var showLocationArrow: UIImageView!
    @IBOutlet var btnLocation: UIButton!
    @IBOutlet var myGroceryImage: UIImageView!{
        didSet{
            myGroceryImage.backgroundColor = sdkManager.isSmileSDK ?  .navigationBarWhiteColor() : .navigationBarWhiteColor()
            myGroceryImage.roundWithShadow(corners: [.layerMaxXMinYCorner , .layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 8, withShadow: false)
        }
    }
    @IBOutlet var myGroceryName: UILabel! {
        didSet {
           
            self.myGroceryName.autoresizingMask = .flexibleHeight
            self.myGroceryName.setH4SemiBoldWhiteStyle()
            if SDKManager.shared.isSmileSDK {
                self.myGroceryName.textColor = ApplicationTheme.currentTheme.newBlackColor
            }
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
    @IBOutlet var widthMultiplier: NSLayoutConstraint!
    @IBOutlet var slotsView: AWView!
    @IBOutlet var lblSlot: UILabel!{
        didSet{
            lblSlot.setSubHead1SemiboldWhiteStyle()
            if SDKManager.shared.isSmileSDK {
                self.lblSlot.textColor = ApplicationTheme.currentTheme.newBlackColor
            }
        }
    }
    
    @IBOutlet var lblAddress: UILabel! {
        didSet{
            lblAddress.setBody3BoldUpperStyle(false)
            if sdkManager.isShopperApp {
                self.lblAddress.textColor = ApplicationTheme.currentTheme.newBlackColor
            }
            if let lng = UserDefaults.getCurrentLanguage(){
                if lng == "ar"{
                    lblAddress.textAlignment = .right
                }else{
                    lblAddress.textAlignment = .left
                }
            }
        }
    }
    
    // sab New UI
    
    @IBOutlet var bGView: UIView!{
        didSet {
            bGView.backgroundColor = ApplicationTheme.currentTheme.viewWhiteBGColor
        }
    }
    @IBOutlet var groceryBGView: UIView!{
        didSet{
            groceryBGView.backgroundColor = .clear
        }
    }
    @IBOutlet var imgDeliverySlot: UIImageView!{
        didSet{
            imgDeliverySlot.image = sdkManager.isSmileSDK ? UIImage(name: "ClockSecondaryBlack") :  UIImage(name: "clockWhite")
        }
    }
    @IBOutlet var searchSuperBGView: UIView!{
        didSet{
            searchSuperBGView.backgroundColor = .clear
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
    
    @IBOutlet var shoppingListBGView: UIView!{
        didSet{
            shoppingListBGView.backgroundColor = .clear
        }
    }
    @IBOutlet var imgShoppingList: UIImageView!{
        didSet{
            imgShoppingList.image = UIImage(name: "addShoppingListYellow")
            if sdkManager.isSmileSDK {
                imgShoppingList.isHidden = true
            }
        }
    }
    @IBOutlet var btnlblShopping: UILabel!{
        didSet{
            btnlblShopping.text = localizedString("btn_shopping_list_title", comment: "")
            btnlblShopping.setBody3SemiBoldYellowStyle()
            if sdkManager.isSmileSDK {
                btnlblShopping.isHidden = true
            }
        }
    }
    @IBOutlet var btnShoppingList: UIButton!{
        didSet{
            btnShoppingList.setTitle("", for: UIControl.State())
            if sdkManager.isSmileSDK {
                btnShoppingList.isEnabled = false
            }
            
        }
    }
    @IBOutlet var btnLblHelp: UILabel!{
        didSet{
            btnLblHelp.text = localizedString("btn_help", comment: "")
            btnLblHelp.setBody3SemiBoldWhiteStyle()
        }
    }
    @IBOutlet var imgHelp: UIImageView!{
        didSet{
            imgHelp.image = UIImage(name: "nav_chat_icon")
        }
    }
    @IBOutlet var btnHelp: UIButton!
    
    @IBOutlet var slotdistanceFromClockIcon: NSLayoutConstraint!
    
    let headerMaxHeight: CGFloat = 105
    
    typealias tapped = (_ isShoppingTapped: Bool)-> Void
    var shoppingListTapped: tapped?
    var storeTapped: (()->())?
    
    
    class func loadFromNib() -> ElgrocerlocationView? {
        return  self.loadFromNib(withName: "ElgrocerlocationView")
    }
    
    override func awakeFromNib() {
        setInitialUI(isExpanded: true)
        super.awakeFromNib()
        hideSlotImage()
        
        self.myGroceryImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(storeIconTap(_ :))))
    }
    
    @objc func storeIconTap(_ sender: UITapGestureRecognizer) {
        if let storeTapped = self.storeTapped {
            storeTapped()
        }
    }
    
    func setInitialUI(isExpanded: Bool = true) {
        self.txtSearchBar.delegate = self
        if isExpanded{
            self.searchSuperBGView.visibility = .visible
            self.shoppingListBGView.visibility = .gone
            self.groceryBGView.visibility = .visible
        }else{
            self.searchSuperBGView.visibility = .visible
            self.shoppingListBGView.visibility = .gone
            self.groceryBGView.visibility = .gone
        }
        
        if sdkManager.isShopperApp {
            self.bGView.backgroundColor = .navigationBarColor()
        } 
    }
    
//    fileprivate func setUpGradientView (){
//
//        let gradient: CAGradientLayer = CAGradientLayer()
//        gradient.frame = CGRect(x: 0.0, y: 0.0, width: ScreenSize.SCREEN_WIDTH , height: 300)
//        gradient.colors = [UIColor.smileBaseColror().cgColor, UIColor.smileSecondaryColor().cgColor]
//        gradient.locations = [0.0 , 1.0]
//        self.bGView.layer.insertSublayer(gradient, at: 0)
//
//    }
    
    
    @IBAction func btnShoppingListHandler(_ sender: Any) {
//        if let closure = self.shoppingListTapped{
//            closure(true)
//        }
        
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
    @IBAction func btnHelpHandler(_ sender: Any) {
//        if let closure = self.shoppingListTapped{
//            closure(false)
//        }
        callSendBird()
    }
    
    @IBAction func btnChangeSlotHandler(_ sender: Any) {
    }
    
    func configureHeader(grocery: Grocery){
//        self.lblGroceryName.text = grocery.name
//        self.setDeliveryDate(grocery.genericSlot ?? "")
//        self.AssignImage(imageUrl: grocery.smallImageUrl ?? "")
    }
    
    fileprivate func hideSlotImage(_ isHidden: Bool = true){
        if isHidden{
           
            self.slotdistanceFromClockIcon.constant = 0
            self.imgDeliverySlot.visibility = .goneX
        }else{
            self.slotdistanceFromClockIcon.constant = 5
            self.imgDeliverySlot.visibility = .visible
            
        }
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
       elDebugPrint("Implement in controller")
        
        guard let vc = UIApplication.topViewController() else {
            return
        }
        
        let searchController = ElGrocerViewControllers.getUniversalSearchViewController()
        ElGrocerEventsLogger.sharedInstance.trackScreenNav( ["clickedEvent" : "Search" , "isUniversal" : "0" ,  FireBaseParmName.CurrentScreen.rawValue : (FireBaseEventsLogger.gettopViewControllerName() ?? "") , FireBaseParmName.NextScreen.rawValue : FireBaseScreenName.Search.rawValue ])
        MixpanelEventLogger.trackStoreSearch()
        searchController.navigationFromControllerName = FireBaseEventsLogger.gettopViewControllerName() ?? ""
        searchController.searchFor = .isForStoreSearch
        searchController.searchString = self.txtSearchBar.text ?? ""
        vc.navigationController?.modalTransitionStyle = .crossDissolve
        vc.navigationController?.modalPresentationStyle = .formSheet
        vc.navigationController?.pushViewController(searchController, animated: true)
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
//                    slotString = localizedString("today_title", comment: "") + " " +  localizedString("60_min", comment: "")  + "⚡️"
                    slotString = localizedString("delivery_within_60_min", comment: "")
                    let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayBoldFont(14), NSAttributedString.Key.foregroundColor : !sdkManager.isShopperApp ? ApplicationTheme.currentTheme.newBlackColor : UIColor.navigationBarWhiteColor()]
                    let attributedString = NSMutableAttributedString(string: slotString , attributes:attrs2 as [NSAttributedString.Key : Any])
                    self.setAttributedValueForSlotOnMainThread(attributedString)
                    self.currentSelectedSlot = firstObj
                    return
                }
                self.currentSelectedSlot = firstObj
                let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14), NSAttributedString.Key.foregroundColor : !sdkManager.isShopperApp ? ApplicationTheme.currentTheme.newBlackColor : UIColor.navigationBarWhiteColor()]
                let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayBoldFont(14), NSAttributedString.Key.foregroundColor : !sdkManager.isShopperApp ? ApplicationTheme.currentTheme.newBlackColor : UIColor.navigationBarWhiteColor()]
                    let attributedString = NSMutableAttributedString(string: "" , attributes:attrs1 as [NSAttributedString.Key : Any])
                    
                    var data = slotString.components(separatedBy: " ")
                    if data.count > 0 {
                        var dayName = localizedString("lbl_next_delivery", comment: "")
                        if ElGrocerUtility.sharedInstance.isDeliveryMode {
                            dayName = localizedString("lbl_next_delivery", comment: "")
                        }else {
                            dayName = localizedString("lbl_next_self_collection", comment: "")
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
//                var slotString = self.getSlotFormattedStrForStoreHeader(slot: firstObj, ElGrocerUtility.sharedInstance.isDeliveryMode)
                var slotStringData = DeliverySlotManager.getSlotFormattedStrForStoreHeader(slot: firstObj, ElGrocerUtility.sharedInstance.isDeliveryMode)
                var slotString = slotStringData.slot
                self.hideSlotImage(slotStringData.hideSlotImage)
                if firstObj.isInstant.boolValue {
//                    slotString = localizedString("today_title", comment: "") + " " +  localizedString("60_min", comment: "")  + "⚡️"
                    slotString = localizedString("delivery_within_60_min", comment: "")
                    let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayBoldFont(14), NSAttributedString.Key.foregroundColor : sdkManager.isSmileSDK ? ApplicationTheme.currentTheme.newBlackColor : UIColor.navigationBarWhiteColor()]
                    let attributedString = NSMutableAttributedString(string: slotString , attributes:attrs2 as [NSAttributedString.Key : Any])
                    self.setAttributedValueForSlotOnMainThread(attributedString)
                    self.currentSelectedSlot = firstObj
                    return
                }
                self.currentSelectedSlot = firstObj
                let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14), NSAttributedString.Key.foregroundColor : sdkManager.isSmileSDK ? ApplicationTheme.currentTheme.newBlackColor : UIColor.navigationBarWhiteColor()]
                let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayBoldFont(14), NSAttributedString.Key.foregroundColor : sdkManager.isSmileSDK ? ApplicationTheme.currentTheme.newBlackColor : UIColor.navigationBarWhiteColor()]
                let attributedString = NSMutableAttributedString(string: "" , attributes:attrs1 as [NSAttributedString.Key : Any])
                
                var data = slotString.components(separatedBy: " ")
                if data.count == 0 {
                    var dayName = localizedString("lbl_next_delivery", comment: "")
                    if ElGrocerUtility.sharedInstance.isDeliveryMode {
                        dayName = localizedString("lbl_next_delivery", comment: "")
                    }else {
                        dayName = localizedString("lbl_next_self_collection", comment: "")
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
                
                if let jsonSlot = grocery.initialDeliverySlotData {
                   if let dict = grocery.convertToDictionary(text: jsonSlot) {
                       let slotString = DeliverySlotManager.getStoreGenericSlotFormatterTimeStringWithDictionarySpecialityMarket(dict, isDeliveryMode: grocery.isDelivery.boolValue)
                       setDeliveryDate(slotString)
                       return
                   }
               }
                self.lblSlot.text = localizedString("no_slots_available", comment: "")
                self.hideSlotImage(true)
               
            }
        }else{
             self.lblSlot.text = localizedString("no_slots_available", comment: "")
            self.hideSlotImage(true)
        }
    }
    
    func setDeliveryDate (_ data : String) {
        
        
        let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14), NSAttributedString.Key.foregroundColor : sdkManager.isSmileSDK ? ApplicationTheme.currentTheme.newBlackColor : UIColor.navigationBarWhiteColor()]
        let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayBoldFont(14), NSAttributedString.Key.foregroundColor : sdkManager.isSmileSDK ? ApplicationTheme.currentTheme.newBlackColor : UIColor.navigationBarWhiteColor()]
        let attributedString = NSMutableAttributedString(string: "" , attributes:attrs1 as [NSAttributedString.Key : Any])
        
        
        let dataA = data.components(separatedBy: CharacterSet.newlines)
        if dataA.count == 1 {
            if self.lblSlot.text?.count ?? 0 > 13 {
                 let attributedString1 = NSMutableAttributedString(string: dataA[0], attributes:attrs1 as [NSAttributedString.Key : Any])
                 self.lblSlot.attributedText = attributedString1
                return
            }
        }
        let attributedString1 = NSMutableAttributedString(string:dataA[0], attributes:attrs1 as [NSAttributedString.Key : Any])
        let timeText = dataA.count > 1 ? dataA[1] : ""
        let attributedString2 = NSMutableAttributedString(string:" \(timeText)", attributes:attrs2 as [NSAttributedString.Key : Any])
        attributedString1.append(attributedString2)
        self.lblSlot.attributedText = attributedString1
        self.lblSlot.minimumScaleFactor = 0.5;
        
    }
    
    
    func setAttributedValueForSlotOnMainThread(_ attributedString : NSMutableAttributedString) {
        
        DispatchQueue.main.async {
            //elDebugPrint("check: oldValue : \(self.lblSlot.attributedText?.string)")
            //elDebugPrint("check: NewValue : \(attributedString.string)")
            
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
                elDebugPrint("refreshCalled: controller : \(UIApplication.gettopViewControllerName())")
                //elDebugPrint("check: refreshCalled")
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
        elDebugPrint("")
       // setSlotData()
        if (newWindow == nil) {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: KUpdateGenericSlotView), object: nil)
        }
    }
    
    override func didMoveToWindow() {
        if self.window != nil {
            NotificationCenter.default.addObserver(self,selector: #selector(ElgrocerlocationView.setSlotData), name: NSNotification.Name(rawValue: KUpdateGenericSlotView), object: nil)
        }
    }

    
    func setUpHeight(_ height : CGFloat) {
        self.frame.size.height = height
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
    }
  
    func configured() {
        self.myGroceryName.isHidden = true
        self.myGroceryImage.isHidden = true
        self.slotsView.isHidden = true
        self.widthMultiplier.setMultiplier(multiplier: FullWidth)
        self.setUpHeight(52)
        guard let address = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress() else {
            self.lblAddress.text = localizedString("error_-6", comment: "")
            return
        }
        
        var addressString = ""
        if let nickName = address.nickName, nickName.count > 0 {
            addressString = "\(nickName):"
        }
        addressString = addressString + (ElGrocerUtility.sharedInstance.getFormattedAddress(address).count > 0 ? ElGrocerUtility.sharedInstance.getFormattedAddress(address) : address.locationName + address.address)
        self.lblAddress.text   = addressString
         self.loadedAddress = address
        self.localLoadedAddress = LocalDeliverAddress(lat: address.latitude, lng: address.longitude, address: address.locationName)
        
        
       
  
    }
    
    func configuredLocationAndGrocey(_ grocery : Grocery?, _ marketType: LaunchOptions.MarketType = .marketPlace) {
        
        
        guard grocery != nil else {
            self.configured()
            return
        }
        
        self.slotsView.isHidden = false
        self.btnLocation.isUserInteractionEnabled = false
        self.showLocationArrow.isHidden = true
        
        guard let address = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress() else {
            self.lblAddress.text = localizedString("error_-6", comment: "")
            return
        }
        
        self.loadedAddress = address
        self.localLoadedAddress = LocalDeliverAddress(lat: address.latitude, lng: address.longitude, address: address.locationName)
        self.lblAddress.text   = ElGrocerUtility.sharedInstance.getFormattedAddress(address).count > 0 ? ElGrocerUtility.sharedInstance.getFormattedAddress(address) : address.locationName + address.address
        
        self.configureCell(grocery!)
        self.widthMultiplier.setMultiplier(multiplier: halfWidth)
        self.setUpHeight(KElgrocerlocationViewFullHeight)
        
    }
    
    
    func configureCell (_ grocery : Grocery) {
        let name = grocery.name ?? ""
        self.myGroceryName.text = name
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

    @IBAction func changeLocation(_ sender: Any) {
//        changeLocation()
    }
    
    @IBAction func changeSlotAction(_ sender: Any) {
        
       /*

        let popupViewController = AWPickerViewController(nibName: "AWPickerViewController", bundle: Bundle.resource)
        popupViewController.changeSlot = { [weak self] (slot) in
            self?.setSlotData()
        }
    
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
        */
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
                
                // Logging segment event for address clicked
                SegmentAnalyticsEngine.instance.logEvent(event: AddressClickedEvent(source: .settings))
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
extension ElgrocerlocationView : STPopupControllerTransitioning {
    
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
extension ElgrocerlocationView : UITextFieldDelegate {
    
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
