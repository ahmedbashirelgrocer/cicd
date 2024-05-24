//
//  ElgrocerStoreHeader.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 27/07/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
import ThirdPartyObjC


enum ElgrocerStoreHeaderDismissType {
    case dismisSDK
    case dismisVC
    case popVc
}

class ElgrocerStoreHeader:  UIView  {
    var showLocationChange = false
    var headerMaxHeight: CGFloat { showLocationChange ? 170 : 125 }
    var headerMinHeight: CGFloat = 125
    
    private var dimisType: ElgrocerStoreHeaderDismissType = .dismisSDK
    
    @IBOutlet weak var btnChangeLocation: UIButton! { didSet {
        btnChangeLocation.setTitle(localizedString("changelocation_button", comment: ""), for: .normal)
    }}
    @IBOutlet weak var btnArrow: UIImageView! { didSet {
        btnArrow.image = LanguageManager.sharedInstance.getSelectedLocale() == "ar" ? UIImage(name: "LeftArrow"):UIImage(name: "RightArrow")
    }}
    @IBOutlet weak var msgFarAway: UILabel! { didSet {
        msgFarAway.text = localizedString("Looks like you're too far away.", comment: "")
    }}
    
    @IBOutlet weak var elgrocerLogoImgView: UIImageView! {
        
        didSet {
            var image = UIImage(name: "elGrocerLogo")!
            if SDKManager.shared.isSmileSDK {
                if SDKManager.shared.launchOptions?.navigationType == .singleStore {
                    if ElGrocerUtility.sharedInstance.isArabicSelected() {
                        image = UIImage(name: "smiles-Single-Store-ar")!
                    } else {
                        image = UIImage(name: "smiles-Single-Store-en")!
                    }
                } else {
                    image = UIImage(name: "smiles-Single-Store-en")!
                }
            }
            elgrocerLogoImgView.image = image
        }
    }
    
    
    @IBOutlet var bGView: UIView! { didSet {
        bGView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
    }}
    
    @IBOutlet var groceryBGView: UIView!
    
    @IBOutlet weak var arrowDown: UIImageView! {
        didSet{
            arrowDown.backgroundColor = ApplicationTheme.currentTheme.separatorColor
            arrowDown.roundWithShadow(corners: [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner], radius: (8))
            arrowDown.tintColor = sdkManager.isSmileSDK ? .black : .black
            arrowDown.image = UIImage(name: "yellowArrowDown")?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    @IBOutlet weak var btnMenu: UIButton! { didSet {
        let menuIcon = UIImage(named: "menu")?.withRenderingMode(.alwaysTemplate)
        self.btnMenu.tintColor = UIColor.smileBaseColor()
        self.btnMenu.setImage(menuIcon, for: .normal)
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
            var chatImage = UIImage(name: "icon_help_Purple")!
            btnHelp.setImage(chatImage, for: .normal)
            btnHelp.setTitle("", for: .normal)
            btnHelp.addTarget(self, action: #selector(btnHelpHandler), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var iconLocation: UIImageView! {
        didSet{
            iconLocation.tintColor = sdkManager.isSmileSDK ? .black : .black
            iconLocation.image = UIImage(name: "homeHeadeerLocationPin")?.withRenderingMode(.alwaysTemplate)
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                iconLocation.transform = CGAffineTransform(scaleX: -1, y: 1)
            }
        }
    }
    
    
    @IBOutlet weak var lblLocation: UILabel! {
        didSet{
            lblLocation.setYellowSemiBoldStyle()
            lblLocation.textColor = ApplicationTheme.currentTheme.newBlackColor
            
        }
    }
    @IBOutlet weak var lblSlots: UILabel!
    
    @IBOutlet var searchBGView: UIView!{
        didSet{
            searchBGView.backgroundColor = .navigationBarWhiteColor()
            searchBGView.roundWithShadow(corners: [.layerMaxXMinYCorner , .layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 18, withShadow: false)
            searchBGView.layer.borderWidth = 1
            searchBGView.layer.borderColor = UIColor.newBorderGreyColor().cgColor
        }
    }

    @IBOutlet var imgSearch: UIImageView!

    @IBOutlet var txtSearchBar: UITextField!{
        didSet{
            //txtSearchBar.text = localizedString("search_products", comment: "")
            txtSearchBar.setPlaceHolder(text: localizedString("search_products", comment: ""))
            if ElGrocerUtility.sharedInstance.isArabicSelected(){
                txtSearchBar.textAlignment = .right
            }else{
                txtSearchBar.textAlignment = .left
            }
        }
    }
    @IBAction func changeLocation(_ sender: Any) {
        self.changeLocation()
    }
    
    @IBOutlet weak var viewToolTip: AWView!
    @objc func btnBackPressed() {
        if ((UIApplication.topViewController()  as? MainCategoriesViewController) != nil) && sdkManager.isOncePerSession == false {
            sdkManager.isOncePerSession = true
            let vc = OfferAlertViewController.getViewController()
            vc.alertTitle = localizedString("Are you sure you want to exit?", comment:"" )
            vc.skipBtnText =  localizedString("Exit", comment:"" )
            vc.discoverBtnTitle =  localizedString("Discover Stores", comment:"" )
            vc.descrptionLblTitle =  localizedString("Discover our wide range of Supermarkets and speciality stores on groceries and pharmacies", comment:"" )
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            UIApplication.topViewController()?.present(vc, animated: true, completion: nil)
            return
        }
        switch self.dimisType {
            
        case .dismisVC:
            UIApplication.topViewController()?.dismiss(animated: true)
        case .dismisSDK:
           defer {
               SDKManager.shared.rootContext = nil
               SDKManager.shared.rootViewController = nil
               SDKManager.shared.currentTabBar = nil
               //sdkManager.isOncePerSession = false
            }
            SDKManager.shared.rootContext?.dismiss(animated: true)
            SegmentAnalyticsEngine.instance.logEvent(event: SDKExitedEvent())
           
        case .popVc:
            UIApplication.topViewController()?.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func profileBTNClicked() {
        
        MixpanelEventLogger.trackNavBarProfile()
        if let topVc = UIApplication.topViewController() {
            
            elDebugPrint("profileButtonClick")
            MixpanelEventLogger.trackNavBarProfile()
            let settingController = SettingViewController.make(viewModel: AppSetting.currentSetting.getSettingCellViewModel(), analyticsEventLogger: SegmentAnalyticsEngine())
            topVc.navigationController?.pushViewController(settingController, animated: true)
            // Logging segment event for menu button clicked
            SegmentAnalyticsEngine.instance.logEvent(event: MenuButtonClickedEvent())
        }
    }
    
    var locationChangedHandler: (() -> Void)?
    
    func setDismisType(_ type: ElgrocerStoreHeaderDismissType) {
        self.dimisType = type
        
        switch self.dimisType {
        case .dismisVC:
            self.btnMenu.visibility = .goneX
        case .dismisSDK:
            self.btnMenu.visibility = .visible
        case .popVc:
            self.btnMenu.visibility = .goneX
        }
    }
    
    
    var currentSelectedSlot : DeliverySlot?
    var currentVC : UIViewController? {
        didSet{
            if currentVC != nil {
                ElGrocerUtility.sharedInstance.slotViewControllerList.insert(currentVC!)
            }
        }
    }
    
    var localLoadedAddress: LocalDeliverAddress?
    var loadedAddress : DeliveryAddress?
    
    var changeLocationButtonHandler: (()->())?

    typealias tapped = (_ isShoppingTapped: Bool)-> Void
   
    class func loadFromNib() -> ElgrocerStoreHeader? {
        return self.loadFromNib(withName: "ElgrocerStoreHeader")
    }
    
    override func awakeFromNib() {
        setInitialUI(isExpanded: true)
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setInitialUI(isExpanded: Bool = true){
        self.txtSearchBar.delegate = self
        if isExpanded{
            self.groceryBGView.visibility = .visible
        }else{
            self.groceryBGView.visibility = .gone
        }
    }
    
    @IBAction func btnHelpHandler() {
        callSendBird()
    }
    
    func configureHeader(grocery: Grocery, location: DeliveryAddress?, isArrowDownHidden: Bool = true){
       
        self.arrowDown.isHidden = isArrowDownHidden
        self.setSlotData()
        guard let location = location else {
            self.lblLocation.text = ""
            return
        }
        
        if ElGrocerUtility.isAddressCentralisation {
            self.lblLocation.text = ElGrocerUtility.sharedInstance.getFormattedCentralisedAddress(location)
        } else {
            var addressString = ""
            if let nickName = location.nickName, nickName.count > 0 {
                addressString = "\(nickName):"
            }
            addressString = addressString + (ElGrocerUtility.sharedInstance.getFormattedAddress(location).count > 0 ? ElGrocerUtility.sharedInstance.getFormattedAddress(location) : location.locationName + location.address)
            
            self.lblLocation.text = addressString
        }
    }
    
    func configureLocationChangeToolTip(show: Bool) {
        self.showLocationChange = show
    }
    
    func callSendBird(){
        guard let vc = UIApplication.topViewController() else {
            return
        }
        MixpanelEventLogger.trackStoreHelp()
        let sendBirdDeskManager = SendBirdDeskManager(controller: vc, orderId: "0", type: .agentSupport)
        sendBirdDeskManager.setUpSenBirdDeskWithCurrentUser()
    }
    
    @IBAction func changeLocationButtonTap(_ sender: Any) {
        if let changeLocationButtonHandler = self.changeLocationButtonHandler {
            changeLocationButtonHandler()
        }
    }
    
    func navigationBarSearchTapped() {
        //  print("Implement in controller")
        
        guard let vc = UIApplication.topViewController() else {
            return
        }
        
        let searchController = ElGrocerViewControllers.getUniversalSearchViewController()
        ElGrocerEventsLogger.sharedInstance.trackScreenNav( ["clickedEvent" : "Search" , "isUniversal" : "0" ,  FireBaseParmName.CurrentScreen.rawValue : (FireBaseEventsLogger.gettopViewControllerName() ?? "") , FireBaseParmName.NextScreen.rawValue : FireBaseScreenName.Search.rawValue ])
        MixpanelEventLogger.trackStoreSearch()
        searchController.navigationFromControllerName = FireBaseEventsLogger.gettopViewControllerName() ?? ""
        searchController.navigationController?.navigationBar.isHidden = true
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
    
    
    
    /*
    @objc
    func setSlotData() {
        if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
            let slots = DeliverySlot.getAllDeliverySlots(DatabaseHelper.sharedInstance.mainManagedObjectContext, forGroceryID: grocery.dbID)
            if let firstObj  = slots.first(where: {$0.dbID == UserDefaults.getCurrentSelectedDeliverySlotId() }) {
                let slotStringData = DeliverySlotManager.getSlotFormattedStrForStoreHeader(slot: firstObj, ElGrocerUtility.sharedInstance.isDeliveryMode)
                var slotString = slotStringData.slot
                if firstObj.isInstant.boolValue {
                    slotString = localizedString("delivery_within_60_min", comment: "")
                    let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayMediumFont(12), NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
                    let attributedString = NSMutableAttributedString(string: slotString , attributes:attrs2 as [NSAttributedString.Key : Any])
                    self.setAttributedValueForSlotOnMainThread(attributedString)
                    self.currentSelectedSlot = firstObj
                    return
                }
                self.currentSelectedSlot = firstObj
                let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(12), NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
                let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayBoldFont(12), NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
                    let attributedString = NSMutableAttributedString(string: "" , attributes:attrs1 as [NSAttributedString.Key : Any])
                    
                    var data = slotString.components(separatedBy: " ")
                    if data.count > 0 {
                        var dayName = "" //localizedString("lbl_next_delivery", comment: "")
//                        if ElGrocerUtility.sharedInstance.isDeliveryMode {
//                            dayName = localizedString("lbl_next_delivery", comment: "")
//                        }else {
//                            dayName = localizedString("lbl_next_self_collection", comment: "")
//                        }
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
                let slotStringData = DeliverySlotManager.getSlotFormattedStrForStoreHeader(slot: firstObj, ElGrocerUtility.sharedInstance.isDeliveryMode)
                var slotString = slotStringData.slot
                if firstObj.isInstant.boolValue {
                    slotString = localizedString("delivery_within_60_min", comment: "")
                    let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayBoldFont(12), NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
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
                    let dayName = "" //localizedString("lbl_next_delivery", comment: "")
//                    if ElGrocerUtility.sharedInstance.isDeliveryMode {
//                        dayName = localizedString("lbl_next_delivery", comment: "")
//                    }else {
//                        dayName = localizedString("lbl_next_self_collection", comment: "")
//                    }
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
               
                
            }
        }else {

        }
    }
    */
    
    @objc
    func setSlotData() {
        
      
        if UserDefaults.isOrderInEdit(), let slots =  UserDefaults.getEditOrderSelectedDeliverySlot() {
            let slot = DeliverySlot.createDeliverySlotFromCustomDictionary(slots as! NSDictionary, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            self.currentSelectedSlot = slot
            let slotStringData = DeliverySlotManager.getSlotFormattedStrForStoreHeader(slot: slot, ElGrocerUtility.sharedInstance.isDeliveryMode)
            var slotString = slotStringData.slot
            let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14), NSAttributedString.Key.foregroundColor : sdkManager.isShopperApp ? ApplicationTheme.currentTheme.newBlackColor : UIColor.navigationBarWhiteColor()]
            let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14), NSAttributedString.Key.foregroundColor : sdkManager.isShopperApp ? ApplicationTheme.currentTheme.newBlackColor : UIColor.navigationBarWhiteColor()]
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
            
        }else if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
            let slots = DeliverySlot.getAllDeliverySlots(DatabaseHelper.sharedInstance.mainManagedObjectContext, forGroceryID: grocery.dbID)
            if let firstObj  = slots.first(where: {$0.backendDbId == UserDefaults.getCurrentSelectedDeliverySlotId() }) {
//                var slotString = self.getSlotFormattedStrForStoreHeader(slot: firstObj, ElGrocerUtility.sharedInstance.isDeliveryMode)
                let slotStringData = DeliverySlotManager.getSlotFormattedStrForStoreHeader(slot: firstObj, ElGrocerUtility.sharedInstance.isDeliveryMode)
                var slotString = slotStringData.slot
               // self.hideSlotImage(slotStringData.hideSlotImage)
                if firstObj.isInstant.boolValue {
//                    slotString = localizedString("today_title", comment: "") + " " +  localizedString("60_min", comment: "")  + "⚡️"
                    slotString = localizedString("delivery_within_60_min", comment: "")
                    let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14), NSAttributedString.Key.foregroundColor : sdkManager.isShopperApp ? ApplicationTheme.currentTheme.newBlackColor : UIColor.navigationBarWhiteColor()]
                    let attributedString = NSMutableAttributedString(string: slotString , attributes:attrs2 as [NSAttributedString.Key : Any])
                    self.setAttributedValueForSlotOnMainThread(attributedString)
                    self.currentSelectedSlot = firstObj
                    return
                }
                self.currentSelectedSlot = firstObj
                let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14), NSAttributedString.Key.foregroundColor : sdkManager.isShopperApp ? ApplicationTheme.currentTheme.newBlackColor : UIColor.navigationBarWhiteColor()]
                let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14), NSAttributedString.Key.foregroundColor : sdkManager.isShopperApp ? ApplicationTheme.currentTheme.newBlackColor : UIColor.navigationBarWhiteColor()]
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
            }else if ((grocery.isOpen.boolValue && (grocery.isInstant() || grocery.isInstantSchedule())) || grocery.initialDeliverySlotData != nil) {
                
                if grocery.isOpen.boolValue && (grocery.isInstant() || grocery.isInstantSchedule()) {
                    let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14), NSAttributedString.Key.foregroundColor : sdkManager.isShopperApp ? ApplicationTheme.currentTheme.newBlackColor : UIColor.navigationBarWhiteColor()]
                    let attributedString = NSMutableAttributedString(string: localizedString("delivery_within_60_min", comment: "") , attributes:attrs2 as [NSAttributedString.Key : Any])
                    self.setAttributedValueForSlotOnMainThread(attributedString)
                    return
                }
                
                if let jsonSlot = grocery.initialDeliverySlotData, let dict = grocery.convertToDictionary(text: jsonSlot) {
                   
                    let slotString = DeliverySlotManager.getStoreGenericSlotFormatterTimeStringWithDictionarySpecialityMarket(dict, isDeliveryMode: grocery.isDelivery.boolValue, false)
                  
                    let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14), NSAttributedString.Key.foregroundColor : sdkManager.isShopperApp ? ApplicationTheme.currentTheme.newBlackColor : UIColor.navigationBarWhiteColor()]
                    let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14), NSAttributedString.Key.foregroundColor : sdkManager.isShopperApp ? ApplicationTheme.currentTheme.newBlackColor : UIColor.navigationBarWhiteColor()]
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
                    return
                }
                
            }else if slots.count > 0 {
                let firstObj = slots[0]
//                var slotString = self.getSlotFormattedStrForStoreHeader(slot: firstObj, ElGrocerUtility.sharedInstance.isDeliveryMode)
                var slotStringData = DeliverySlotManager.getSlotFormattedStrForStoreHeader(slot: firstObj, ElGrocerUtility.sharedInstance.isDeliveryMode)
                var slotString = slotStringData.slot
               // self.hideSlotImage(slotStringData.hideSlotImage)
                if firstObj.isInstant.boolValue {
//                    slotString = localizedString("today_title", comment: "") + " " +  localizedString("60_min", comment: "")  + "⚡️"
                    slotString = localizedString("delivery_within_60_min", comment: "")
                    let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14), NSAttributedString.Key.foregroundColor : sdkManager.isSmileSDK ? ApplicationTheme.currentTheme.newBlackColor : UIColor.navigationBarWhiteColor()]
                    let attributedString = NSMutableAttributedString(string: slotString , attributes:attrs2 as [NSAttributedString.Key : Any])
                    self.setAttributedValueForSlotOnMainThread(attributedString)
                    self.currentSelectedSlot = firstObj
                    return
                }
                self.currentSelectedSlot = firstObj
                let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14), NSAttributedString.Key.foregroundColor : sdkManager.isSmileSDK ? ApplicationTheme.currentTheme.newBlackColor : UIColor.navigationBarWhiteColor()]
                let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14), NSAttributedString.Key.foregroundColor : sdkManager.isSmileSDK ? ApplicationTheme.currentTheme.newBlackColor : UIColor.navigationBarWhiteColor()]
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
                
                if let jsonSlot = grocery.initialDeliverySlotData {
                   if let dict = grocery.convertToDictionary(text: jsonSlot) {
                       let slotString = DeliverySlotManager.getStoreGenericSlotFormatterTimeStringWithDictionarySpecialityMarket(dict, isDeliveryMode: grocery.isDelivery.boolValue)
                       setDeliveryDate(slotString)
                       return
                   }
               }
                self.lblSlots.text = localizedString("no_slots_available", comment: "")
                //self.hideSlotImage(true)
               
            }
        }else{
             self.lblSlots.text = localizedString("no_slots_available", comment: "")
            //self.hideSlotImage(true)
        }
    }
    
    
    func setDeliveryDate (_ data : String) {
        
        
        let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14), NSAttributedString.Key.foregroundColor : sdkManager.isShopperApp ? ApplicationTheme.currentTheme.newBlackColor : UIColor.navigationBarWhiteColor()]
        let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayBoldFont(14), NSAttributedString.Key.foregroundColor : sdkManager.isShopperApp ? ApplicationTheme.currentTheme.newBlackColor : UIColor.navigationBarWhiteColor()]
        let attributedString = NSMutableAttributedString(string: "" , attributes:attrs1 as [NSAttributedString.Key : Any])
        
        let dataA = data.components(separatedBy: CharacterSet.newlines)
        if dataA.count == 1 {
            if self.lblSlots.text?.count ?? 0 > 13 {
                 let attributedString1 = NSMutableAttributedString(string: dataA[0], attributes:attrs1 as [NSAttributedString.Key : Any])
                 self.lblSlots.attributedText = attributedString1
                return
            }
        }
        let attributedString1 = NSMutableAttributedString(string:dataA[0], attributes:attrs1 as [NSAttributedString.Key : Any])
        let timeText = dataA.count > 1 ? dataA[1] : ""
        let attributedString2 = NSMutableAttributedString(string:" \(timeText)", attributes:attrs2 as [NSAttributedString.Key : Any])
        attributedString1.append(attributedString2)
        self.lblSlots.attributedText = attributedString1
        self.lblSlots.minimumScaleFactor = 0.5;
        
    }
    
    func setAttributedValueForSlotOnMainThread(_ attributedString : NSMutableAttributedString) {
        DispatchQueue.main.async {
            var isNeedToCallRefresh = false
            isNeedToCallRefresh = !(self.lblSlots.attributedText?.string == attributedString.string || self.lblSlots.attributedText?.string == "---" || self.lblSlots.attributedText?.string == "--" || self.lblSlots.attributedText?.string == localizedString("no_slots_available", comment: ""))

            self.lblSlots.attributedText = attributedString
//            if self.myGroceryName.text != ElGrocerUtility.sharedInstance.activeGrocery?.name {
//                isNeedToCallRefresh = false
//            }
            if isNeedToCallRefresh  {
                ElGrocerUtility.sharedInstance.delay(1) {
                    if let topVc = UIApplication.topViewController() {
                        topVc.refreshSlotChange()
                    }
                }
            }
        }
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
    
    func changeLocation() {
        
        
        DispatchQueue.main.async {
            if let top = UIApplication.topViewController() {
                if let sdkHomeVc = top as? SmileSdkHomeVC {
                    sdkHomeVc.locationButtonClick()
                } else if let storePage = top as? MainCategoriesViewController {
                    EGAddressSelectionBottomSheetViewController.showInBottomSheet(nil, mapDelegate: storePage.mapDelegate, presentIn: storePage, locationSelectionHandler: self.locationChangedHandler)
                } else {
//                    let dashboardLocationVC = ElGrocerViewControllers.dashboardLocationViewController()
//                    dashboardLocationVC.isFromNewHome = true
//                    dashboardLocationVC.isRootController = true
//                    let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
//                    navigationController.viewControllers = [dashboardLocationVC]
//                    navigationController.modalPresentationStyle = .fullScreen
//                    navigationController.setLogoHidden(true)
//                    top.present(navigationController, animated: true)
                }
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
            return  localizedString("today_title", comment: "") + " " + localizedString("60_min", comment: "") + "⚡️"
        }else if  slot.isToday() {
            let name =  localizedString("today_title", comment: "")
            orderTypeDescription = String(format: "%@ %@", name ,orderTypeDescription)
        }else if slot.isTomorrow()  {
            let name =    localizedString("tomorrow_title", comment: "")
            orderTypeDescription = String(format: "%@ %@", name,orderTypeDescription)
        }else{
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
