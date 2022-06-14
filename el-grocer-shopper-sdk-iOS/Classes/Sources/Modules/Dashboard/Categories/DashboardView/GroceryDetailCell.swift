//
//  GroceryDetailCell.swift
//  ElGrocerShopper
//
//  Created by Azeem Akram on 15/10/2017.
//  Copyright © 2017 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage


let kGroceryDetailHeaderCell = "groceryDetail"


protocol GroceryDetailCellDelegate : class {
    func didTapOnGroceryImageToLoadGroceries()
    func didTapInfoButtonForGroceryDetailCell(_ cell:GroceryDetailCell, isDetailViewShowing:Bool)
     func didTapOnLocations()
}

class GroceryDetailCell: UICollectionViewCell {
    
    weak var delegate:GroceryDetailCellDelegate?

    @IBOutlet weak var infoButtonDistance: NSLayoutConstraint!
    @IBOutlet weak var imgMinOrder: UIImageView!
    @IBOutlet weak var imgDeliveryWithIn: UIImageView!

    // Basic Details
    @IBOutlet weak var imageviewStoreTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageviewStore: UIImageView!
    @IBOutlet weak var lblStoreName: UILabel!
    
    @IBOutlet weak var lblStoreStatus: UILabel!
    @IBOutlet weak var btnInfo: UIButton!
    @IBOutlet weak var btnChange: UIButton!

    // More Store Details
    @IBOutlet weak var viewDetails: UIView!
    @IBOutlet weak var viewDetailHeightConstraint: NSLayoutConstraint!
    
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
 
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var arrowImageView: UIImageView!
    
    @IBOutlet weak var lblLocationTitle: UILabel!
    @IBOutlet weak var lblLocationAddress: UILabel!
    
    
    // Constant Properties
    var placeholderImage = UIImage(named: "category_placeholder")!
    
    override func awakeFromNib() {
        super.awakeFromNib()

       self.backgroundColor = UIColor.blurLightProductColor()
       self.shadowView.backgroundColor = UIColor.navigationBarColor()
       self.btnChange.setBackgroundColor(UIColor.navigationBarColor(), forState: .normal)

        if LanguageManager.sharedInstance.getSelectedLocale().caseInsensitiveCompare("ar") != ComparisonResult.orderedSame {
            self.btnChange.imageEdgeInsets = UIEdgeInsets(top: 2, left: self.btnChange.frame.size.width - 11, bottom: 0, right: 5)
            self.btnChange.contentHorizontalAlignment = .left
            self.btnChange.titleLabel?.textAlignment =  .left
        }

//        self.shadowView.layer.shadowRadius = 10
//        self.shadowView.layer.shadowOpacity = 0.3
//        self.shadowView.layer.shadowColor = UIColor.black.cgColor
//        self.shadowView.layer.shadowOffset = CGSize.zero
//        self.shadowView.generateInnerShadow()
//        func createGradientLayer() {
//            let gradientLayer = CAGradientLayer()
//            gradientLayer.frame = self.shadowView.bounds
//            gradientLayer.colors = [UIColor.navigationBarColor().cgColor, UIColor.colorWithHexString(hexString: "e7f2e6").cgColor]
//            gradientLayer.locations = [0.0, 0.50]
//            self.shadowView.layer.addSublayer(gradientLayer)
//            self.shadowView.bringSubview(toFront: contentView)
//        }
//       createGradientLayer()

        self.setupAppearance()
        self.addTapGestureToGroceryNameLabelAndImage()
        self.addTapGestureToGroceryStatusLabel()

    }
    
    func setupAppearance() {
        
        self.lblStoreName.font          = UIFont.SFProDisplayBoldFont(12.0)
        self.lblStoreStatus.font        = UIFont.SFProDisplaySemiBoldFont(11.0)
        
        self.lblLocationTitle.font          = UIFont.SFProDisplayBoldFont(12.0)
        self.lblLocationAddress.font        = UIFont.SFProDisplayBoldFont(12.0) //UIFont.openSansSemiBoldFont(11.0)
        
        self.labelMinOrderAmount.font   = UIFont.SFProDisplayBoldFont(12.0)
        self.lblMinOrderAmount.font     = UIFont.SFProDisplaySemiBoldFont(12.0)
        
        self.labelDeliveryHours.font    = UIFont.SFProDisplayBoldFont(12.0)
        self.lblDeliveryHours.font      = UIFont.SFProDisplaySemiBoldFont(12.0)
        
        self.labelDeliveryWithin.font   = UIFont.SFProDisplayBoldFont(12.0)
        self.lblDeliveryWithin.font     = UIFont.SFProDisplaySemiBoldFont(12.0)
        
        self.labelPaymentMethod.font    = UIFont.SFProDisplayBoldFont(12.0)
        self.lblPaymentMethod.font      = UIFont.SFProDisplaySemiBoldFont(12.0)
        
        //
        self.lblLocationTitle.text   = NSLocalizedString("location_count_singular", comment: "")
      //  ElGrocerUtility.sharedInstance.addImageatEndLableText(self.lblLocationTitle, image: UIImage(named: "mcHomeDownArrow")!)
        
        self.labelMinOrderAmount.text   = NSLocalizedString("min_order_amount", comment: "")
        self.labelDeliveryHours.text    = NSLocalizedString("delivery_hours", comment: "")
        self.labelDeliveryWithin.text   = NSLocalizedString("service_price_title", comment: "")
        self.labelPaymentMethod.text    = NSLocalizedString("payment_method", comment: "")
        self.btnChange.setTitle(NSLocalizedString("Change", comment: ""), for: .normal)
        

         if LanguageManager.sharedInstance.getSelectedLocale().caseInsensitiveCompare("ar") == ComparisonResult.orderedSame {


            viewDetails.transform =  CGAffineTransform(scaleX: -1, y: 1)

            imgMinOrder.transform = CGAffineTransform(scaleX: -1, y: 1)
            labelMinOrderAmount.transform = CGAffineTransform(scaleX: -1, y: 1)
            lblMinOrderAmount.transform = CGAffineTransform(scaleX: -1, y: 1)



            imgDeliveryWithIn.transform = CGAffineTransform(scaleX: -1, y: 1)
            labelDeliveryHours.transform  = CGAffineTransform(scaleX: -1, y: 1)
            lblDeliveryHours.transform = CGAffineTransform(scaleX: -1, y: 1)


            labelDeliveryWithin.transform = CGAffineTransform(scaleX: -1, y: 1)
            lblDeliveryWithin.transform = CGAffineTransform(scaleX: -1, y: 1)


            labelPaymentMethod.transform  = CGAffineTransform(scaleX: -1, y: 1)
            lblPaymentMethod.transform  = CGAffineTransform(scaleX: -1, y: 1)
            
            self.infoButtonDistance.constant =  self.lblStoreName.frame.size.width * 2

           // imgMinOrder.transform =  CGAffineTransform(scaleX: -1, y: 1)


//            let alignment  = NSTextAlignment.left
//
//            self.labelMinOrderAmount.textAlignment   = alignment
//            self.lblMinOrderAmount.textAlignment     = alignment
//
//            self.labelDeliveryHours.textAlignment    = alignment
//            self.lblDeliveryHours.textAlignment      = alignment
//
//            self.labelDeliveryWithin.textAlignment   = alignment
//            self.lblDeliveryWithin.textAlignment     = alignment
//
//            self.labelPaymentMethod.textAlignment    = alignment
//            self.lblPaymentMethod.textAlignment      = alignment
        }


        
        
       

 }
    func addImageatEndLableText(_ lable : UILabel , image : UIImage) {

        let imageAttachment =  NSTextAttachment()
        imageAttachment.image = image
        //Set bound to reposition
        let imageOffsetY:CGFloat = 0.0;
        imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
        //Create string with attachment
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        //Initialize mutable string
        let completeText = NSMutableAttributedString(string: lable.text ?? "")
        completeText.append(NSMutableAttributedString(string: " "))
        //Add image to mutable string
        completeText.append(attachmentString)

        lable.attributedText = completeText;

    }
    
    func setupCellWithGrocer(_ myGrocery:Grocery) {
        
       // self.imageviewStore.sd_setImage(with: URL.init(string: myGrocery.smallImageUrl!), placeholderImage: placeholderImage)
        
        if myGrocery.smallImageUrl != nil && myGrocery.smallImageUrl?.range(of: "http") != nil {
            
            self.imageviewStore.sd_setImage(with: URL(string: myGrocery.smallImageUrl!), placeholderImage: self.placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: {[weak self] (image, error, cacheType, imageURL) in
                guard let  self = self else {return}
                if cacheType == SDImageCacheType.none {
                    UIView.transition(with: self.imageviewStore, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {() -> Void in
                        self.imageviewStore.image = image
                    }, completion: nil)
                }
            })
        }
        
        self.lblStoreName.text  = myGrocery.name ?? "" + "⌄"

        var open = NSLocalizedString("open", comment: "")
        var scheduled = NSLocalizedString("scheduled_delivery", comment: "")

        if !(myGrocery.isSchedule.boolValue) {
            scheduled = NSLocalizedString("instant_delivery", comment: "")
        }
        if !(myGrocery.isOpen.boolValue) {
            open    = NSLocalizedString("closed", comment: "")
        }
        self.lblStoreStatus.text    = open + "-" + scheduled
       // self.lblStoreStatus.sizeToFit()

        if(myGrocery.isOpen.boolValue && (myGrocery.isInstant() || myGrocery.isInstantSchedule())) {
             self.lblStoreStatus.text    =  NSLocalizedString("delivery_One_Hour_WithOutNext", comment: "")
        } else {
/*
            let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
            let calendarComponents = (calendar as NSCalendar).components(.weekday, from:Date())
            let weekDay = calendarComponents.weekday
            let nextDay = weekDay! + 1 == 8 ? 1 : weekDay! + 1
            var dayTitle = "" // NSLocalizedString("today_title", comment: "") remove today 
            let initailText =  NSLocalizedString("Delivery_Slot", comment: "")
            
            var currentSlots = myGrocery.getAllDeliverySlots()
           // var currentSlots: [DeliverySlot] = slotsA.compactMap({ $0 as? DeliverySlot })
            let newSlots = currentSlots.filter() {Int(truncating: $0.dayNumber) == weekDay}
            
            if(newSlots.count == 0){
                let nextDay = currentSlots.filter() {Int(truncating: $0.dayNumber) == nextDay}
                if nextDay.count == 0 {
                    
                }else{
                    currentSlots = nextDay
                }
                
            }else{
                currentSlots = newSlots
            }
            
    
                currentSlots.sort { (slotOne, slotTwo) -> Bool in
                    return slotStartTimeTime < slotSecondStartTime
                }
            
            for slots in currentSlots {
               // debugPrint(slots.dbID)
                if  truncating: slots.start_time.weekday  == nextDay {
                    dayTitle = NSLocalizedString("tomorrow_title", comment: "")
                }
                if let start = slots.startTime , let endT = slots.endTime {
                    let timeSlot = DeliverySlot.getFormatedTimeWithAmPmStringWithStartTime(start , andWithEndTime: endT)
                    self.lblStoreStatus.text = initailText + " " + "\(timeSlot)"  + "\(dayTitle)"
                }
                
                self.lblStoreStatus.text = "update logic here"
                
                // self.lblStoreStatus.sizeToFit()
                break
            }*/
            self.lblStoreStatus.text = "update logic here"

        }
        
        
        

        self.lblStoreStatus.setNeedsLayout()
        self.lblStoreStatus.layoutIfNeeded()

        self.lblMinOrderAmount.text = String(format: "%@ %.0f",CurrencyManager.getCurrentCurrency(),myGrocery.minBasketValue)
        self.lblDeliveryHours.text  = self.getDeliveryHours(myGrocery)
        
        self.lblDeliveryWithin.text = String(format: "%@ %.2f",CurrencyManager.getCurrentCurrency(),myGrocery.serviceFee)
        
        self.lblPaymentMethod.text  =  ElGrocerUtility.sharedInstance.getPaymentMethod(myGrocery) //self.getPaymentMethod(myGrocery)
        if (ElGrocerUtility.sharedInstance.isStoreDetailsShowing){
            self.viewDetails.alpha = 1.0
        }else{
            self.viewDetails.alpha = 0.0
        }
          self.setInfoButtonImage()
        
        guard let currentAddress = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress() else {return}
        
        
        
        
        self.lblLocationAddress.text   = ElGrocerUtility.sharedInstance.getFormattedAddress(currentAddress)
        if self.lblLocationAddress.text?.count ?? 0 == 0 {
            self.lblLocationAddress.text   = currentAddress.locationName
        }
      //  ElGrocerUtility.sharedInstance.addImageatEndLableText(self.lblLocationAddress, image: UIImage(named: "mcHomeDownArrow")!)
        
      
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
                    print("Today is weekday")
                    openingStr = openingHours[0] as! String
                    closingStr = closingHours[0] as! String
                    
                }else if (weekDay == 5){
                    print("Today is Thursday")
                    openingStr = openingHours[1] as! String
                    closingStr = closingHours[1] as! String
                }else{
                    print("Today is Friday")
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
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
                print(error)
            }
        }
        
        return timeStr
    }
    
    
    func getPaymentMethod(_ myGrocery:Grocery) -> String {
        var paymentDescription = "---"
        
        
        if myGrocery.availablePayments.uint32Value & PaymentOption.cash.rawValue > 0 && myGrocery.availablePayments.uint32Value & PaymentOption.card.rawValue > 0 && myGrocery.availablePayments.uint32Value & PaymentOption.creditCard.rawValue > 0 {
            
            //both payments are available
            paymentDescription = NSLocalizedString("cash_card_creditCard_delivery", comment: "")
            
        } else if myGrocery.availablePayments.uint32Value & PaymentOption.cash.rawValue > 0 && myGrocery.availablePayments.uint32Value & PaymentOption.card.rawValue > 0 {
            
            //both payments are available
            paymentDescription = NSLocalizedString("cash_card_delivery", comment: "")
            
        } else if myGrocery.availablePayments.uint32Value & PaymentOption.cash.rawValue > 0 && myGrocery.availablePayments.uint32Value & PaymentOption.card.rawValue == 0 {
            
            //only Cash
            paymentDescription = NSLocalizedString("cash_delivery", comment: "")
            
        } else if myGrocery.availablePayments.uint32Value & PaymentOption.cash.rawValue == 0 && myGrocery.availablePayments.uint32Value & PaymentOption.card.rawValue > 0 {
            
            //only Card
            paymentDescription = NSLocalizedString("card_delivery", comment: "")
        }
        return paymentDescription
    }
    
    // MARK: TAP Gesture
    private func addTapGestureToGroceryNameLabelAndImage() {
        
        let labelTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.navigateToGroceryView))
        self.lblStoreName.addGestureRecognizer(labelTapGesture)
        
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.navigateToGroceryView))
        self.imageviewStore.addGestureRecognizer(imageTapGesture)
        
      //  let arrowTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.navigateToGroceryView))
    //    self.arrowImageView.addGestureRecognizer(arrowTapGesture)
    }

    
    @IBAction func changeHandler(_ sender: Any) {
        self.navigateToGroceryView()
    }

    @objc func navigateToGroceryView() {
        self.delegate?.didTapOnGroceryImageToLoadGroceries()
    }

    
    private func addTapGestureToGroceryStatusLabel() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.infoTapHandler))
        self.lblStoreStatus.addGestureRecognizer(tapGesture)
    }
    
    @objc func infoTapHandler(){
        
        if delegate != nil {
            
            if ElGrocerUtility.sharedInstance.isStoreDetailsShowing == false {
                ElGrocerUtility.sharedInstance.isStoreDetailsShowing = true
                self.delegate?.didTapInfoButtonForGroceryDetailCell(self, isDetailViewShowing: true)
                
            }else{
                ElGrocerUtility.sharedInstance.isStoreDetailsShowing = false
                self.delegate?.didTapInfoButtonForGroceryDetailCell(self, isDetailViewShowing: false)
            }
            
            UIView.animate(withDuration: 0.25, animations: {
                if (ElGrocerUtility.sharedInstance.isStoreDetailsShowing){
                    self.viewDetails.alpha = 1.0
                }else{
                    self.viewDetails.alpha = 0.0
                }
                self.layoutIfNeeded()
            }, completion: { (isCompleted) in
                self.setInfoButtonImage()
            })
        }
    }
    
    func setInfoButtonImage() {
        DispatchQueue.main.async(execute: {
            let imageName    = ElGrocerUtility.sharedInstance.isStoreDetailsShowing ? "icClose" : "White-info"
            self.btnInfo.setImage(UIImage.init(named: imageName), for: UIControl.State())
        })
    }

    @IBAction func infoDetailHandler(_ sender: Any) {
        self.infoButtonHandler(sender)
    }
    // MARK: Button Action Handler
    @IBAction func infoButtonHandler(_ sender: Any) {
        // self.imageviewStoreTopConstraint.constant = 17.0
        self.infoTapHandler()
    }
    @IBAction func goToLocationHandler(_ sender: Any) {
        
         self.delegate?.didTapOnLocations()
    }
    
}
