//
//  ElgrocerStoreHeader.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 27/07/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
import STPopup


enum ElgrocerStoreHeaderDismissType {
    case dismisSDK
    case dismisVC
    case popVc
}

class ElgrocerStoreHeader:  UIView  {
    
    let headerMaxHeight: CGFloat = 104
    let headerMinHeight: CGFloat = 88
    
    private var dimisType: ElgrocerStoreHeaderDismissType = .dismisSDK
    
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
                    image = UIImage(name: "smile_Logo_elgrocer")!
                }
            }
            elgrocerLogoImgView.image = image
        }
    }
    
    @IBOutlet var bGView: UIView! { didSet {
        bGView.layer.insertSublayer(setupGradient(height: bGView.frame.size.height, topColor: UIColor.smileBaseColor().cgColor, bottomColor: UIColor.smileSecondaryColor().cgColor), at: 0)
    }}
    
    @IBOutlet var groceryBGView: UIView!
    
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
    
    @IBOutlet weak var iconLocation: UIImageView! { didSet {
        iconLocation.image = iconLocation.image?.withRenderingMode(.alwaysTemplate)
    } }
    
    
    @IBOutlet weak var lblLocation: UILabel! {
        didSet{
            lblLocation.setYellowSemiBoldStyle()
        }
    }
    @IBOutlet weak var lblSlots: UILabel!
    
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
    
 
    @objc func btnBackPressed() {
        
        switch self.dimisType {
        case .dismisVC:
            UIApplication.topViewController()?.dismiss(animated: true)
        case .dismisSDK:
            SDKManager.shared.rootContext?.dismiss(animated: true)
        case .popVc:
            UIApplication.topViewController()?.navigationController?.popViewController(animated: true)
        }
        
        
    }
    @objc func profileBTNClicked() {
        
        MixpanelEventLogger.trackNavBarProfile()
        if let topVc = UIApplication.topViewController() {
            let settingController = ElGrocerViewControllers.settingViewController()
            topVc.navigationController?.pushViewController(settingController, animated: true)
        }
    }
    
    func setDismisType(_ type: ElgrocerStoreHeaderDismissType) {
        self.dimisType = type
        
        switch self.dimisType {
        case .dismisVC:
            self.btnMenu.isHidden = true
        case .dismisSDK:
            self.btnMenu.isHidden = false
        case .popVc:
            self.btnMenu.isHidden = true
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
    
    func configureHeader(grocery: Grocery, location: DeliveryAddress?){
       
        self.setSlotData()
        guard let location = location else {
            self.lblLocation.text = ""
            return
        }
        self.lblLocation.text = ElGrocerUtility.sharedInstance.getFormattedAddress(location)
    }
    
    func callSendBird(){
        guard let vc = UIApplication.topViewController() else {
            return
        }
        MixpanelEventLogger.trackStoreHelp()
        let sendBirdDeskManager = SendBirdDeskManager(controller: vc, orderId: "0", type: .agentSupport)
        sendBirdDeskManager.setUpSenBirdDeskWithCurrentUser()
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
                var slotStringData = DeliverySlotManager.getSlotFormattedStrForStoreHeader(slot: firstObj, ElGrocerUtility.sharedInstance.isDeliveryMode)
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
               
                
            }
        }else {

        }
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
