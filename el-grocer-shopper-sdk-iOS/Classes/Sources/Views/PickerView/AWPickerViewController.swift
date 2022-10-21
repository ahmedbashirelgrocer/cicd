//
//  AWPickerViewController.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 02/09/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit

import SwiftDate
import UIKit
import FBSDKCoreKit


enum PicketSlotViewType : Int {
    
    case `default` = 0
    case basket = 1
    
}


class AWPickerViewController : UIViewController {
    
    var viewType : PicketSlotViewType =  .default
    
    @IBOutlet var slotDaySegmentView: UIView!
    @IBOutlet var segmentHeights: NSLayoutConstraint!
    @IBOutlet var SegmentOneWidth: NSLayoutConstraint!
    @IBOutlet var lblTitle: UILabel! 
    @IBOutlet var slotsCollectionView: AWPickerList!
    @IBOutlet var lblSegmentOneDate: UILabel!
    @IBOutlet var lblSegmentOneDesc: UILabel!
    @IBOutlet var segmentOneIndicatorView: AWView!
    @IBOutlet var lblSegmentTwoDate: UILabel!
    @IBOutlet var lblSegmentTwoDesc: UILabel!
    @IBOutlet var segmentTwoIndicatorView: AWView!
    @IBOutlet var activityIndication: UIActivityIndicatorView!
    @IBOutlet var btnConfirm: AWButton! {
        didSet {
            btnConfirm.setTitle(localizedString("lbl_confirm_slot", comment: ""), for: .normal)
        }
    }
    @IBOutlet var lblNoSlot: UILabel! {
        didSet {
            lblNoSlot.setCaptionOneRegLightStyle()
            lblNoSlot.text = localizedString("no_slot_available_message", comment: "")
            lblNoSlot.isHidden = true
        }
    }
    
    var changeSlot : ((_ slot : DeliverySlot?) -> Void)?
    var currentGrocery : Grocery? = ElGrocerUtility.sharedInstance.activeGrocery
    var collectionData = [DeliverySlot]()
    var segmentOneDayNumber:NSNumber = 0
    var segmentTwoDayNumber:NSNumber = 0
    var segmentOneDate:Date = Date()
    var segmentOneWeekNumber:NSNumber = 0
    var segmentTwoWeekNumber:NSNumber = 0
    var segmentTwoDate:Date = Date()
    
    
    var segmentOneSlots : [DeliverySlot] = []
    var segmentTwoSlots : [DeliverySlot] = []
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        contentSizeInPopup = CGSize(width: ScreenSize.SCREEN_WIDTH , height:  ScreenSize.SCREEN_HEIGHT/2)
        landscapeContentSizeInPopup = CGSize(width: ScreenSize.SCREEN_HEIGHT , height: 500)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer.cornerRadius = 5
        self.view.clipsToBounds = true
        self.view.backgroundColor = UIColor.clear
        lblTitle.text = localizedString("lbl_change_delivery", comment: "")
        lblTitle.setH4SemiBoldStyle()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setConfirmButtonState()
        self.getGroceryDeliverySlots()
    }
    
    func setConfirmButtonState() -> Void {
        DispatchQueue.main.async {
            self.btnConfirm.layer.cornerRadius =  self.btnConfirm.frame.size.height/2
            self.btnConfirm.enableWithAnimation(self.collectionData.count > 0 )
            self.btnConfirm.clipsToBounds = true
        }
    }
    
    func getGroceryDeliverySlots(){
           
       
        self.slotDaySegmentView.isHidden = true
        self.activityIndication.startAnimating()
        
        guard let dbID = self.currentGrocery?.dbID, let zoneId = self.currentGrocery?.deliveryZoneId else {
            self.collectionData = DeliverySlot.getAllDeliverySlots(DatabaseHelper.sharedInstance.mainManagedObjectContext, forGroceryID: self.currentGrocery?.dbID ?? "-1")
            self.activityIndication.stopAnimating()
            self.setSegmentControlAppearance()
            self.lblNoSlot.isHidden =  self.collectionData.count > 0
            FireBaseEventsLogger.trackCustomEvent(eventType: "DeliveryApiCall", action: "Filurerespone" , ["error" : "No delivery zone"])
            return
        }
        
        guard self.viewType == .default else {
            
            if let retailerID = Int(dbID), let deliveryZoneID = Int(zoneId) {
                let basketItems = ShoppingBasketItem.getBasketItemsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                var itemsCount = 0

                for item in basketItems {
                    itemsCount += item.count.intValue
                }
                
                ElGrocerApi.sharedInstance.getDeliverySlots(retailerID: retailerID, retailerDeliveryZondID: deliveryZoneID, orderID: nil, orderItemCount: itemsCount) { result in
                    switch result {
                        
                    case .success(let response):
                        self.saveResponseData(response, grocery: self.currentGrocery)
                        self.activityIndication.stopAnimating()
                        self.lblNoSlot.isHidden =  self.collectionData.count > 0
                        print("slots count >>> \(self.collectionData.count)")
                        if self.collectionData.count == 0 {
                            FireBaseEventsLogger.trackCustomEvent(eventType: "DeliveryApiCall", action: "Successrespone" , ["error" : response.description])
                        }
                        break
                        
                    case .failure(let error):
                        self.collectionData = DeliverySlot.getAllDeliverySlots(DatabaseHelper.sharedInstance.mainManagedObjectContext, forGroceryID: self.currentGrocery?.dbID ?? "-1")
                        self.activityIndication.stopAnimating()
                        self.setSegmentControlAppearance()
                        self.lblNoSlot.isHidden =  self.collectionData.count > 0
                        FireBaseEventsLogger.trackCustomEvent(eventType: "DeliveryApiCall", action: "Filurerespone" , ["error" : error.localizedMessage])
                        break
                    }
                }
            }
            return
        }
        
        
        ElGrocerApi.sharedInstance.getGroceryDeliverySlotsWithGroceryId(self.currentGrocery?.dbID, andWithDeliveryZoneId: self.currentGrocery?.deliveryZoneId, completionHandler: { (result) -> Void in
            
            switch result {
                
                case .success(let response):
                   elDebugPrint("SERVER Response:%@",response)
                    self.saveResponseData(response, grocery: self.currentGrocery)
                    self.activityIndication.stopAnimating()
                    self.lblNoSlot.isHidden =  self.collectionData.count > 0
                    if self.collectionData.count == 0 {
                        FireBaseEventsLogger.trackCustomEvent(eventType: "DeliveryApiCall", action: "Successrespone" , ["error" : response.description])
                    }
                case .failure(let error):
                   elDebugPrint("Error while getting Delivery Slots from SERVER:%@",error.localizedMessage)
                    self.collectionData = DeliverySlot.getAllDeliverySlots(DatabaseHelper.sharedInstance.mainManagedObjectContext, forGroceryID: self.currentGrocery?.dbID ?? "-1")
                 self.activityIndication.stopAnimating()
                 self.setSegmentControlAppearance()
                    self.lblNoSlot.isHidden =  self.collectionData.count > 0
                    FireBaseEventsLogger.trackCustomEvent(eventType: "DeliveryApiCall", action: "Filurerespone" , ["error" : error.localizedMessage])
            }
        })
    }
    
        // MARK: Data
    func saveResponseData(_ responseObject:NSDictionary, grocery : Grocery?) {
        
        let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
        self.collectionData = DeliverySlot.insertOrReplaceDeliverySlotsFromDictionary(responseObject, groceryObj: grocery, context: context)
        Grocery.updateActiveGroceryDeliverySlots(with: responseObject, context: context)
        self.collectionData = DeliverySlot.getAllDeliverySlots(DatabaseHelper.sharedInstance.mainManagedObjectContext, forGroceryID: self.currentGrocery?.dbID ?? "-1")
        if let slots =  UserDefaults.getEditOrderSelectedDeliverySlot()  {
            if UserDefaults.isOrderInEdit() {
                let alreadyOrderSlot = DeliverySlot.createDeliverySlotFromCustomDictionary(slots as! NSDictionary, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                let isSlot =   self.collectionData.filter { (slot) -> Bool in
                    return slot.dbID == alreadyOrderSlot.dbID
                }
                if isSlot.count == 0 {
                    self.collectionData.append(DeliverySlot.createDeliverySlotFromCustomDictionary(slots as! NSDictionary, context: DatabaseHelper.sharedInstance.mainManagedObjectContext))
                }
            }
        }
        self.collectionData = DeliverySlot.sortFilterA(self.collectionData)
        self.setSegmentControlAppearance()
        
    }
    
 
    func setSegmentControlAppearance() {
        
        var titlesArray = [String]()
        var descArray = [String]()
        
         if let _ = self.collectionData.first(where:{ $0.isInstant.boolValue }) {
            let date = Date.getCurrentDate()
            segmentOneDayNumber = NSNumber(value: date.weekday)
            segmentOneWeekNumber = NSNumber(value: date.weekOfYear)
            segmentOneDate = date
            let slotTimeStr = localizedString("today_title", comment: "")
            titlesArray.append(slotTimeStr)
            let dateString =  date.dataMonthDateInStringWithFormatDDMM() ?? ""
            descArray.append(dateString)
    
        }

        for slot in self.collectionData {
            
            guard titlesArray.count < 2 else { break }
            guard let startTime =  slot.start_time, let endTime =  slot.end_time else { continue }
            if slot.isInstant.boolValue && self.collectionData.count != 1 { continue }
            
            
            if titlesArray.count == 0 {
                
                
                segmentOneDayNumber = NSNumber(value: startTime.weekday)
                segmentOneWeekNumber = NSNumber(value: startTime.weekOfYear)
                segmentOneDate = startTime
                if slot.isToday() || slot.isInstant.boolValue {
                    let slotTimeStr = localizedString("today_title", comment: "")
                    titlesArray.append(slotTimeStr)
                    let dateString =  startTime.dataMonthDateInStringWithFormatDDMM()
                    descArray.append(dateString ?? "")
                }else if slot.isTomorrow() {
                    let slotTimeStr = localizedString("tomorrow_title", comment: "")
                    titlesArray.append(slotTimeStr)
                    let dateString =  startTime.dataMonthDateInStringWithFormatDDMM()
                    descArray.append(dateString ?? "")
                }else{
                    titlesArray.append(startTime.getDayNameFull() ?? "")
                    let dateString =  startTime.dataMonthDateInStringWithFormatDDMM()
                    descArray.append(dateString ?? "")
                }
                continue
            }
            
            if titlesArray.count == 1 {
      
                if slot.start_time?.weekday ==  segmentOneDayNumber.intValue && startTime.weekOfYear == segmentOneWeekNumber.intValue {  continue }
                if  startTime.isSameDate(segmentOneDate) { continue}
                
                segmentTwoDayNumber = NSNumber(value: startTime.weekday)
                segmentTwoWeekNumber = NSNumber(value: startTime.weekOfYear)
                segmentTwoDate = startTime
                if slot.isToday() {
                    let slotTimeStr = localizedString("today_title", comment: "")
                    titlesArray.append(slotTimeStr)
                    let dateString =  slot.start_time?.dataMonthDateInStringWithFormatDDMM()
                    descArray.append(dateString ?? "")
                }else if slot.isTomorrow() {
                    let slotTimeStr = localizedString("tomorrow_title", comment: "")
                    titlesArray.append(slotTimeStr)
                    let dateString =  slot.start_time?.dataMonthDateInStringWithFormatDDMM()
                    descArray.append(dateString ?? "")
                }else{
                    let dateString =  slot.start_time?.dataMonthDateInStringWithFormatDDMM()
                    descArray.append(dateString ?? "")
                    titlesArray.append(slot.start_time?.getDayNameFull() ?? "")
                }
                break
            }
        }
        
        
        func setSegmentOneSlots() {
            var filterData =  [DeliverySlot]()
            filterData.append(contentsOf: self.collectionData.filter { (slot) -> Bool in
                return slot.start_time?.isSameDate(segmentOneDate) ?? false || slot.isInstant.boolValue
            })
            filterData = DeliverySlot.sortFilterA(filterData)
            self.segmentOneSlots = filterData
        }
        func setSegmentTwoSlots() {
            let filterData = self.collectionData.filter { (slot) -> Bool in
                return slot.start_time?.isSameDate(segmentTwoDate) ?? false && !slot.isInstant.boolValue
            }
            self.segmentTwoSlots = DeliverySlot.sortFilterA(filterData)
        }
        
        
      
        if titlesArray.count == 0 {
            self.segmentHeights.constant = .leastNonzeroMagnitude
            return
        }else if titlesArray.count == 1 {
            self.segmentHeights.setMultiplier(multiplier: CGFloat(1.0))
            self.lblSegmentOneDate.text = descArray[0]
            self.lblSegmentOneDesc.text = titlesArray[0]
            self.segmentOneSelect("")
            self.slotDaySegmentView.isHidden = false
            self.setConfirmButtonState()
            Thread.OnMainThread {
                self.view.layoutIfNeeded()
            }
           
        }else{
            self.segmentHeights.setMultiplier(multiplier: CGFloat(0.5))
            self.lblSegmentOneDate.text = descArray[0]
            self.lblSegmentTwoDate.text = descArray[1]
            self.lblSegmentOneDesc.text = titlesArray[0]
            self.lblSegmentTwoDesc.text = titlesArray[1]
        }
        
        setSegmentOneSlots()
        setSegmentTwoSlots()
       
        let selectedSlotId = UserDefaults.getCurrentSelectedDeliverySlotId()
        if let _ = self.segmentTwoSlots.first(where: { $0.getdbID() == selectedSlotId }) {
            self.segmentTwoSelect("")
        }else{
            self.segmentOneSelect("")
        }
        self.slotDaySegmentView.isHidden = false
        self.setConfirmButtonState()
        
    }
    
    func getDayTitleAgainstSlot(_ dayNumber : NSNumber) -> String {
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let calendarComponents = (calendar as NSCalendar).components(.weekday, from:Date())
        let weekDay = calendarComponents.weekday
        let nextDay = weekDay! + 1 == 8 ? 1 : weekDay! + 1
        var dayTitle = localizedString("today_title", comment: "")
        if Int(truncating: (dayNumber)) == weekDay{
            dayTitle = localizedString("today_title", comment: "")
        }else if Int(truncating: (dayNumber)) == nextDay{
            dayTitle = localizedString("tomorrow_title", comment: "")
        }else{
            let formatter = DateFormatter()
            let daysA = formatter.standaloneWeekdaySymbols;
            var dayNumber = Int(truncating: (dayNumber)) - 1
            dayNumber = dayNumber < 0 ? 0 : dayNumber
            dayNumber = dayNumber > 6 ? 6 : dayNumber
            dayTitle  = daysA?[dayNumber] ?? "";
        }
        return dayTitle
    }
    
    @IBAction func segmentOneSelect(_ sender: Any) {
        
        self.configureData(segmentOneSlots)
        self.segmentOneIndicatorView.backgroundColor = UIColor.navigationBarColor() //.colorWithHexString(hexString: "59aa46")
        self.segmentTwoIndicatorView.backgroundColor = UIColor.colorWithHexString(hexString: "ffffff")
        self.lblSegmentOneDate.textColor = .navigationBarColor()
        self.lblSegmentOneDesc.textColor = .navigationBarColor()
        self.lblSegmentTwoDate.textColor = .selectionTabDark()
        self.lblSegmentTwoDesc.textColor = .selectionTabDark()
        
    }
        
    @IBAction func segmentTwoSelect(_ sender: Any) {
        
        self.configureData(segmentTwoSlots)
        self.segmentTwoIndicatorView.backgroundColor = UIColor.navigationBarColor() //.colorWithHexString(hexString: "59aa46")
        self.segmentOneIndicatorView.backgroundColor = UIColor.colorWithHexString(hexString: "ffffff")
        self.lblSegmentOneDate.textColor = .secondaryBlackColor()
        self.lblSegmentOneDesc.textColor = .secondaryBlackColor()
        self.lblSegmentTwoDate.textColor = .navigationBarColor()
        self.lblSegmentTwoDesc.textColor = .navigationBarColor()

    }
    
    func configureData (_ data : [DeliverySlot]) {
        self.slotsCollectionView.selectedIndex = -1
        self.slotsCollectionView.configureData(data)
    }

    @IBAction func crossAction(_ sender: Any) {
        MixpanelEventLogger.trackElWalletUnifiedClose()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmSlotAction(_ sender: Any) {
        
        defer {
             NotificationCenter.default.post(name: Notification.Name(rawValue: KUpdateGenericSlotView), object: nil)
        }
        let slots = DeliverySlot.getAllDeliverySlots(DatabaseHelper.sharedInstance.backgroundManagedObjectContext, forGroceryID: currentGrocery?.dbID ?? "-1")
        if let firstObj  = slots.first(where: {$0.dbID == self.slotsCollectionView.selectedSlotID }) {
            UserDefaults.setCurrentSelectedDeliverySlotId(firstObj.dbID)
            UserDefaults.setEditOrderSelectedDelivery(nil)
            MixpanelEventLogger.trackCheckoutDeliverySlotSelected(slot: firstObj, retailerID: currentGrocery?.dbID ?? "-1")
            if let clouser = self.changeSlot {
                clouser(firstObj)
            }
        }
        self.dismiss(animated: true) { }
        
    }
    
}
