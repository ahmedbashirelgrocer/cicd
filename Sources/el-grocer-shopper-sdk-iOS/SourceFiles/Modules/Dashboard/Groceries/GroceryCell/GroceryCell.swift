//
//  GroceryCell.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 08.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

let kGroceryCellIdentifier = "GroceryCell"
//let kGroceryCellHeight: CGFloat = 164
//let kGroceryCellHeightWithInfo: CGFloat = 295
let kGroceryCellHeight: CGFloat = 154
let kGroceryCellHeightWithInfo: CGFloat = 205
//let kGroceryCellHeightWithInfo: CGFloat = 265

protocol GroceryCellProtocol : class {
    func didTapInfoButtonForCell(_ cell:GroceryCell, isDetailShowing:Bool)
    func groceryCellDidTouchFavourite(_ groceryCell:GroceryCell, grocery:Grocery) -> Void
    func groceryCellDidTouchScore(_ groceryCell:GroceryCell, grocery:Grocery) -> Void
}

class GroceryCell : UITableViewCell {

    @IBOutlet weak var imageGrocery: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblIsOpen: UILabel!
    @IBOutlet weak var isOpenStatusColorView: UIView!
    
    @IBOutlet weak var lblIsScheduledDelivery: UILabel!
    
    @IBOutlet weak var lblIsScheduleDeliveryConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewTiming: UIView!
    @IBOutlet weak var lblTiming: UILabel!
    
    @IBOutlet weak var btnInfo: UIButton!
    
    // More Store Details
    @IBOutlet weak var viewDetails: UIView!
    
    // Minimum Order Amount View
    @IBOutlet weak var viewMinOrderAmount: UIView!
    @IBOutlet weak var labelMinOrderAmount: UILabel!
    @IBOutlet weak var lblMinOrderAmount: UILabel!
    
    // Delivery Hours View
    @IBOutlet weak var viewDeliveryHours: UIView!
    @IBOutlet weak var labelDeliveryHours: UILabel!
    @IBOutlet weak var lblDeliveryHours: UILabel!
    
    // Delivery WithIn View
    @IBOutlet weak var viewDeliveryWithin: UIView!
    @IBOutlet weak var labelDeliveryWithin: UILabel!
    @IBOutlet weak var lblDeliveryWithin: UILabel!
    
    // Payment Method View
    @IBOutlet weak var viewPaymentMethod: UIView!
    @IBOutlet weak var labelPaymentMethod: UILabel!
    @IBOutlet weak var lblPaymentMethod: UILabel!

    
    
    var detailShowing   = false
    //category_placeholder
    var placeholderImage = UIImage.init()
    
    weak var grocery:Grocery!
    weak var delegate:GroceryCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setUpAppearance()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageGrocery.sd_cancelCurrentImageLoad()
        self.imageGrocery.image = self.placeholderImage
    }
    
    // MARK: Appearance
    
    private func setUpAppearance() {
        
        self.lblName.font                   = UIFont.SFProDisplayBoldFont(17.0)
        self.lblIsOpen.font                 = UIFont.SFProDisplaySemiBoldFont(13.0)
        self.lblIsScheduledDelivery.font    = UIFont.SFProDisplaySemiBoldFont(12.0)
        self.lblTiming.font                 = UIFont.SFProDisplaySemiBoldFont(11.0)
        
        self.labelMinOrderAmount.text   = localizedString("min_order_amount", comment: "")
        // self.labelDeliveryHours.text    = localizedString("delivery_hours", comment: "")
        
        self.labelDeliveryHours.text    = localizedString("Next_Delivery_Slot", comment: "")
    
        self.labelDeliveryWithin.text   = localizedString("service_price_title", comment: "")
        self.labelPaymentMethod.text    = localizedString("payment_method", comment: "")
        
        self.setupDetailViewAppearance()
    }
    
    func setupDetailViewAppearance() {
        
    if LanguageManager.sharedInstance.getSelectedLocale().caseInsensitiveCompare("ar") == ComparisonResult.orderedSame {
            
            let alignment  = NSTextAlignment.left
            
            self.labelMinOrderAmount.textAlignment   = alignment
            self.lblMinOrderAmount.textAlignment     = alignment
            
            self.labelDeliveryHours.textAlignment    = alignment
            self.lblDeliveryHours.textAlignment      = alignment
            
            self.labelDeliveryWithin.textAlignment   = alignment
            self.lblDeliveryWithin.textAlignment     = alignment
            
            self.labelPaymentMethod.textAlignment    = alignment
            self.lblPaymentMethod.textAlignment      = alignment
        }
        
        self.labelMinOrderAmount.font   = UIFont.SFProDisplaySemiBoldFont(12.0)
        self.lblMinOrderAmount.font     = UIFont.SFProDisplayNormalFont(12.0)
        
        self.labelDeliveryHours.font    = UIFont.SFProDisplaySemiBoldFont(12.0)
        self.lblDeliveryHours.font      = UIFont.SFProDisplayNormalFont(12.0)
        
        self.labelDeliveryWithin.font   = UIFont.SFProDisplaySemiBoldFont(12.0)
        self.lblDeliveryWithin.font     = UIFont.SFProDisplayNormalFont(12.0)
        
        self.labelPaymentMethod.font    = UIFont.SFProDisplaySemiBoldFont(12.0)
        self.lblPaymentMethod.font      = UIFont.SFProDisplayNormalFont(12.0)
    }
    
    //MARK: Button Action Methods
    
    @IBAction func btnInfo_Action(_ sender: AnyObject) {
        if self.detailShowing {
            self.btnInfo.setImage(UIImage.init(named: "icInfo"), for: UIControl.State())
            UIView.animate(withDuration: 0.35, animations: {
                self.viewTiming.alpha  = 1.0
            })
            if (self.delegate != nil) {
                self.delegate?.didTapInfoButtonForCell(self, isDetailShowing: false)
            }
        }else{
            self.btnInfo.setImage(UIImage.init(named: "icClose"), for: UIControl.State())
            UIView.animate(withDuration: 0.35, animations: {
                self.viewTiming.alpha  = 0.0
            })
            if (self.delegate != nil) {
                self.delegate?.didTapInfoButtonForCell(self, isDetailShowing: true)
            }
        }
    }
    
    
    // MARK: Data

    func configureWithGrocery(_ grocery:Grocery, isDetailsShown:Bool) {
        
        self.grocery            = grocery
        self.detailShowing      = isDetailsShown
        
        if self.detailShowing {
            self.btnInfo.setImage(UIImage.init(named: "icClose"), for: UIControl.State())
            self.viewTiming.alpha = 0.0
        }else{
            self.btnInfo.setImage(UIImage.init(named: "icInfo"), for: UIControl.State())
            self.viewTiming.alpha = 1.0
        }
        
        // Setting Image
        self.imageGrocery.backgroundColor = UIColor.clear
        self.imageGrocery.subviews.forEach { $0.removeFromSuperview() }
        
        if grocery.smallImageUrl != nil && grocery.smallImageUrl?.range(of: "http") != nil {
            
            self.imageGrocery.sd_setImage(with: URL(string: grocery.smallImageUrl!), placeholderImage: self.placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.imageGrocery, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.imageGrocery.image = image
                        
                    }, completion: nil)
                }
            })
        }

        // Name
        self.lblName.text = grocery.name
        // self.lblTiming.text         = self.getDeliveryHours(grocery)
        
        self.lblMinOrderAmount.text = String(format: "%@ %.0f",CurrencyManager.getCurrentCurrency(),grocery.minBasketValue)
        self.lblDeliveryHours.text  = grocery.genericSlot
        self.lblDeliveryWithin.text = String(format: "%@ %.2f",CurrencyManager.getCurrentCurrency(),grocery.serviceFee)
        self.lblPaymentMethod.text  = ElGrocerUtility.sharedInstance.getPaymentMethod(grocery) //self.getPaymentMethod(grocery)
        
        if grocery.isOpen.boolValue {
            self.lblIsOpen.text = localizedString("open_now", comment: "")
            self.isOpenStatusColorView.backgroundColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
            
        }else{
            self.lblIsOpen.text = localizedString("closed_Now", comment: "")
            self.isOpenStatusColorView.backgroundColor = UIColor.redInfoColor()
        }
        
        self.lblIsScheduleDeliveryConstraint.constant = 0.0
    }
    
    func getDeliveryHours(_ myGrocery:Grocery) -> String {
        var deliveryHours = "-- AM - -- PM"
        
        if myGrocery.openingTime != nil {
            deliveryHours = self.getGroceryTimeString(myGrocery.openingTime!)
        }
        return deliveryHours
    }
    
    
    func getGroceryTimeString(_ openingTime:String) -> String {
        
        var timeStr = String()
        
        if let data = openingTime.data(using: String.Encoding.utf8) {
            do {
                
                let timeDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
                
                let openingHours: NSArray = timeDict!["opening_hours"] as! NSArray
                let closingHours: NSArray = timeDict!["closing_hours"] as! NSArray
                
                /*1 = Sunday,2 = Monday,3 = Tuesday,4 = Wednesday,5 = Thursday,6 = Friday,7 = Saturday*/
                
                let weekDays = ["1","2","3","4","7"]
                
                let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                let myComponents = (myCalendar as NSCalendar).components(.weekday, from:Date())
                let weekDay = myComponents.weekday
                
                var openingStr:String = ""
                var closingStr:String = ""
                
                let weekdayStr = String(format:"%d",myComponents.weekday!)
                
                if weekDays.contains(weekdayStr) {
                   elDebugPrint("Today is weekday")
                    openingStr = openingHours[0] as! String
                    closingStr = closingHours[0] as! String
                    
                }else if (weekDay == 5){
                   elDebugPrint("Today is Thursday")
                    openingStr = openingHours[1] as! String
                    closingStr = closingHours[1] as! String
                }else{
                   elDebugPrint("Today is Friday")
                    openingStr = openingHours[2] as! String
                    closingStr = closingHours[2] as! String
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                let phoneLanguage = UserDefaults.getCurrentLanguage()
                if phoneLanguage == "ar" {
                    dateFormatter.locale = Locale(identifier: "ar")
                }
                let openingTime = dateFormatter.date(from: openingStr)
                let closingTime = dateFormatter.date(from: closingStr)
                
                if openingTime != nil && closingTime != nil {
                    
                    dateFormatter.dateFormat = "hh:mm a"
                    let openTimeStr = dateFormatter.string(from: openingTime!)
                    let closeTimeStr = dateFormatter.string(from: closingTime!)
                    
                    timeStr = String(format: "%@ - %@",openTimeStr,closeTimeStr)
                }else{
                    timeStr = String(format: "%@ - %@",openingStr,closingStr)
                }
                
            } catch let error as NSError {
              //  NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
               elDebugPrint(error)
            }
        }
        
        return timeStr
    }
    
    func getPaymentMethod(_ myGrocery:Grocery) -> String {
        
        var paymentDescription = "---"
        if myGrocery.availablePayments.uint32Value & PaymentOption.cash.rawValue > 0 && myGrocery.availablePayments.uint32Value & PaymentOption.card.rawValue > 0 && myGrocery.availablePayments.uint32Value & PaymentOption.creditCard.rawValue > 0 {
            
            //both payments are available
            paymentDescription = localizedString("cash_card_creditCard_delivery", comment: "")
            
        } else  if myGrocery.availablePayments.uint32Value & PaymentOption.cash.rawValue > 0 && myGrocery.availablePayments.uint32Value & PaymentOption.card.rawValue > 0 {
            
            //both payments are available
            paymentDescription = localizedString("cash_card_delivery", comment: "")
            
        } else if myGrocery.availablePayments.uint32Value & PaymentOption.cash.rawValue > 0 && myGrocery.availablePayments.uint32Value & PaymentOption.card.rawValue == 0 {
            
            //only Cash
            paymentDescription = localizedString("cash_delivery", comment: "")
            
        } else if myGrocery.availablePayments.uint32Value & PaymentOption.cash.rawValue == 0 && myGrocery.availablePayments.uint32Value & PaymentOption.card.rawValue > 0 {
            
            //only Card
            paymentDescription = localizedString("card_delivery", comment: "")
        }
        return paymentDescription
    }
    
    
   

    // MARK: Actions
    func onFavouriteButtonClick() {
        
        if UserDefaults.isUserLoggedIn() {
            self.grocery.isFavourite = NSNumber(value: !self.grocery.isFavourite.boolValue as Bool)
            DatabaseHelper.sharedInstance.saveDatabase()
            self.delegate?.groceryCellDidTouchFavourite(self, grocery: self.grocery)
        }else{
            
            ElGrocerAlertView.createAlert(localizedString("store_favourite_alert_title", comment: ""),
                                          description: localizedString("store_favourite_alert_description", comment: ""),
                                          positiveButton: localizedString("store_favourite_alert_yes", comment: ""),
                                          negativeButton: localizedString("store_favourite_alert_no", comment: ""),
                                          buttonClickCallback: { (buttonIndex:Int) -> Void in
                                            
                                            if buttonIndex == 0 {
                                                
                                                let SDKManager: SDKManagerType! = sdkManager
                                                SDKManager.showEntryView()
                                            }
            }).show()
            
        }
    }
    
    @IBAction func onScoreButtonClick(sender: AnyObject) {
        
        self.delegate?.groceryCellDidTouchScore(self, grocery: self.grocery)
    }
}
