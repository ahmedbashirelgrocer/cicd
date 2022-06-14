//
//  CurrentOrderCollectionCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 16/06/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

let KCurrentOrderCollectionViewHeight : CGFloat = 78

class CurrentOrderCollectionCell: UICollectionViewCell {
    @IBOutlet var trackingView: UIView!
    @IBOutlet var lblOrderTracking: UILabel! {
        didSet{
            lblOrderTracking.text = NSLocalizedString("lbl_Order_tracking", comment: "")
            lblOrderTracking.setBody3RegWhiteStyle()
        }
        
    }
    @IBOutlet var lblTrackYourOrder: UILabel!{
        didSet{
            lblTrackYourOrder.text = NSLocalizedString("lbl_Track_your_order", comment: "")
        }
    }
    
    
    var trackingUrl : String = ""
    var orderId : String = ""
    var statusId : String = ""
    @IBOutlet var spinnerView: AnimatedSpinnerView!
    @IBOutlet var bGView: AWView!{
        didSet{
            bGView.layer.cornerRadius = 8
            bGView.layer.maskedCorners = [.layerMinXMinYCorner , .layerMaxXMinYCorner]
            bGView.clipsToBounds = true
        }
    }
    @IBOutlet var statusImageView: UIImageView!
    @IBOutlet var lblStoreName: UILabel!{
        didSet{
            lblStoreName.setBody3RegWhiteStyle()
        }
    }
    @IBOutlet var lblStatus: UILabel!{
        didSet{
            lblStatus.setSubHead2BoldWhiteStyle()
        }
    }
    @IBOutlet var lblDate: UILabel!{
        didSet{
            lblDate.setBody3BoldUpperWhiteStyle()
        }
    }
    @IBOutlet var lblOrderType: UILabel!{
        didSet{
            lblOrderType.setBody3RegWhiteStyle()
        }
    }
    @IBOutlet var ordersPageControl: UIPageControl!{
        didSet{
            ordersPageControl.numberOfPages = 3
            if #available(iOS 14.0, *) {
                ordersPageControl.preferredIndicatorImage  = UIImage(named: "selectedPageControl")
                ordersPageControl.currentPageIndicatorTintColor = UIColor.navigationBarColor()
                ordersPageControl.pageIndicatorTintColor = UIColor.unselectedPageControl()
                //ordersPageControl.page
                //ordersPageControl.setIndicatorImage(UIImage(named: "selectedPageControl"), forPage: 0)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
        //loadOrderStatusLabel(order).uppercased()
    }
    
    func loadOrderStatusLabel(status : Int , orderDict : NSDictionary) {
        guard ElGrocerUtility.sharedInstance.appConfigData != nil else {
            return
        }
        
      
        if let orderId = orderDict["id"] as? NSNumber {
            self.orderId = orderId.stringValue
        }
       
        
        var orderType : OrderType = .delivery
        if let type = orderDict["retailer_service_id"] as? NSNumber {
            orderType = type.stringValue == OrderType.CandC.rawValue ? .CandC : .delivery
        }
        
        if orderType == .delivery{
            self.lblOrderType.text = NSLocalizedString("title_Estimated_delivery", comment: "")
        }else{
            self.lblOrderType.text = NSLocalizedString("lbl_self_collection_time", comment: "")
        }
        
        self.lblStoreName.text = orderDict["retailer_company_name"] as? String
        
        self.statusId = (orderDict["status_id"] as? NSNumber ?? -1000).stringValue
        let key = DynamicOrderStatus.getKeyFrom(status_id: orderDict["status_id"] as? NSNumber ?? -1000, service_id: orderDict["retailer_service_id"]  as? NSNumber ?? -1000 , delivery_type: orderDict["delivery_type_id"]  as? NSNumber ?? -1000)
        let status_id : DynamicOrderStatus? = ElGrocerUtility.sharedInstance.appConfigData.orderStatus[key]
        
        if ElGrocerUtility.sharedInstance.isArabicSelected(){
            self.lblStatus.text = status_id?.nameAr
        }else{
            self.lblStatus.text = status_id?.nameEn.uppercased()
        }
        
        
        if let slot = orderDict["delivery_slot"] as? NSDictionary {
            self.lblDate.text = self.getDeliverySlotFormatterTimeStringWithDictionary(slot, isDelivery: orderType == .delivery)
        }else if let _  = orderDict["delivery_slot"] as? NSNull {
            self.lblDate.text = NSLocalizedString("today_title", comment: "") + " " +  NSLocalizedString("60_min", comment: "")
        } else{
            self.lblDate.text = ""
        }
        
        if let trackingUrl =  orderDict["tracking_url"] as? String {
            trackingView.isHidden = trackingUrl.count == 0
            self.trackingUrl = trackingUrl
            self.lblDate.text = trackingUrl.count == 0 ? self.lblDate.text : ""
        }else {
            trackingView.isHidden = true
            self.trackingUrl = ""
        }
        
        
        
      let data =  status_id?.getImageName()
        if let image = data?.0 {
            self.statusImageView.image = UIImage(named: image)
        }
        
        DispatchQueue.main.async {
            
            switch status_id?.getStatusKeyLogic().status_id.intValue {
                
                case OrderStatus.delivered.rawValue:
                    
                    self.lblOrderType.isHidden = false
                    self.lblDate.isHidden = false
                    self.spinnerView.isHidden = false
                    self.lblStatus.textColor = .navigationBarWhiteColor()
                    self.lblOrderType.textColor = .navigationBarWhiteColor()
                    self.spinnerView.animationColor = .navigationBarWhiteColor()
                    self.spinnerView.animate(true)
                    
                    if orderType == .delivery{
                        self.lblOrderType.text = NSLocalizedString("title_delivered", comment: "")
                    }else{
                        self.lblOrderType.text = NSLocalizedString("title_collected", comment: "")
                    }
                    
                case OrderStatus.canceled.rawValue:
                    
                    self.lblOrderType.isHidden = true
                    self.lblDate.isHidden = true
                    self.lblStatus.textColor = .navigationBarWhiteColor()
                    self.spinnerView.animationColor = .navigationBarWhiteColor()
                    self.spinnerView.animate(true)
                //self.spinnerView.layer.removeAllAnimations()
                //self.spinnerView.isHidden = true
                
                case OrderStatus.enRoute.rawValue:
                    self.lblOrderType.isHidden = false
                    self.lblDate.isHidden = false
                    self.spinnerView.isHidden = false
                    // self.lblOrderType.text = NSLocalizedString("title_updated_delivery", comment: "")
                    self.lblStatus.textColor = .navigationBarWhiteColor()
                    self.lblOrderType.textColor = .navigationBarWhiteColor()
                    self.spinnerView.animationColor = .navigationBarWhiteColor()
                    self.spinnerView.animate()
                    
                case OrderStatus.inSubtitution.rawValue:
                    self.lblOrderType.isHidden = false
                    self.lblDate.isHidden = false
                    self.spinnerView.isHidden = false
                    self.lblStatus.textColor = .elGrocerYellowColor()
                    self.lblOrderType.textColor = .navigationBarWhiteColor()
                    self.spinnerView.animationColor = .elGrocerYellowColor()
                    self.spinnerView.animate()
                default:
                    print("default")
                    self.lblOrderType.isHidden = false
                    self.lblDate.isHidden = false
                    self.spinnerView.isHidden = false
                    self.lblStatus.textColor = .navigationBarWhiteColor()
                    self.lblOrderType.textColor = .navigationBarWhiteColor()
                    self.spinnerView.animationColor = .navigationBarWhiteColor()
                    self.spinnerView.animate()
            }
            
        }
        
    }
    
    @IBAction func trackOrderAction(_ sender: Any) {
        
        TrackingNavigator.presentTrackingViewWith(self.trackingUrl, orderId: self.orderId, statusId: self.statusId)
        
    }
    
    
    //MARK: Date helper
    
    func getDeliverySlotFormatterTimeStringWithDictionary (_ slotDict : NSDictionary ,  isDelivery : Bool ) -> String {
        var groceryNextDeliveryString =  NSLocalizedString("lbl_no_timeSlot_available", comment: "")
        if (slotDict["id"] as? String) == "0" {
            groceryNextDeliveryString =  NSLocalizedString("today_title", comment: "") + "\n"  +  NSLocalizedString("60_min", comment: "")
        } else {
            
            var dayTitle = ""
            if let startDate = (slotDict["start_time"] as? String)?.convertStringToCurrentTimeZoneDate() {
                if let endDate = (slotDict["end_time"] as? String)?.convertStringToCurrentTimeZoneDate() {
                    
                    if startDate.isToday {
                        dayTitle = NSLocalizedString("today_title", comment: "")
                        let timeSlot = ( isDelivery ?  startDate.formatDateForDeliveryHAFormateString() : startDate.formatDateForCandCFormateString() ) + " - " + ( isDelivery ?  endDate.formatDateForDeliveryHAFormateString() : endDate.formatDateForCandCFormateString())
                        groceryNextDeliveryString =  "\(dayTitle)" + " " + "\(timeSlot)"
                    }else if startDate.isTomorrow {
                        dayTitle = NSLocalizedString("s_tomorrow_title", comment: "")
                        let timeSlot = ( isDelivery ?  startDate.formatDateForDeliveryHAFormateString() : startDate.formatDateForCandCFormateString() ) + " - " + ( isDelivery ?  endDate.formatDateForDeliveryHAFormateString() : endDate.formatDateForCandCFormateString())
                        groceryNextDeliveryString =  "\(dayTitle)" + " " + "\(timeSlot)"
                    }else {
                        groceryNextDeliveryString =  startDate.formatDateForOpenOrderComponentMonthYearFormateString()
                    }
                    
                }
            }
        }
        return groceryNextDeliveryString
    }
    
    
}
