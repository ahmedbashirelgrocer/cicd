//
//  CategoryHeaderView.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 13/03/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

let kCategoryHeaderViewIdentifier = "CategoryHeaderView"
let kCategoryHeaderViewHeight: CGFloat = 150

class CategoryHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var groceryView: UIView!
    @IBOutlet weak var groceryImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var deliveryLabel: UILabel!
    @IBOutlet weak var paymentLabel: UILabel!
    
    @IBOutlet weak var searchView: UIView!
    
    var placeholderPhoto = UIImage(name: "brand_placeholder")!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.searchView.layer.cornerRadius = 10
        self.searchView.isUserInteractionEnabled = true
        
        self.groceryImage.isUserInteractionEnabled = true
        
        self.groceryView.isUserInteractionEnabled = true
        
        self.timeLabel.sizeToFit()
        self.timeLabel.numberOfLines = 0
        
        self.deliveryLabel.sizeToFit()
        self.deliveryLabel.numberOfLines = 0
        
        self.paymentLabel.sizeToFit()
        self.paymentLabel.numberOfLines = 0
    }
    
    // MARK: Data
    
    func configureWithGrocery(_ grocery:Grocery) {
        /* ---------- Set Grocery Image ---------- */
        if grocery.smallImageUrl != nil && grocery.smallImageUrl?.range(of: "http") != nil {
            
            self.groceryImage.sd_setImage(with: URL(string: grocery.smallImageUrl!), placeholderImage: self.placeholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.groceryImage, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.groceryImage.image = image
                        
                    }, completion: nil)
                }
            })
            
           /* self.groceryImage.sd_setImage(with: URL(string: grocery.imageUrl!), placeholderImage: self.placeholderPhoto, completed: { (image:UIImage!, error:NSError!, cache:SDImageCacheType, url:URL!) -> Void in
                
                if cache == SDImageCacheType.none {
                    
                    UIView.transition(with: self.groceryImage, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.groceryImage.image = image
                        
                        }, completion: nil)
                }
            })*/
        }
    }
}
    
    //---------------- Comment the following code as we revert the design of header view to previous ---------------
    
   /* private func getAttributedString(title:String, description:String) -> NSMutableAttributedString {
        
        let dict1 = [NSForegroundColorAttributeName: UIColor.lightTextGrayColor(),NSFontAttributeName:UIFont.mediumFont(10.0)]
        
        let dict2 = [NSForegroundColorAttributeName: UIColor.blackColor(),NSFontAttributeName:UIFont.mediumFont(8.0)]
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3.0
        
        let titlePart = NSMutableAttributedString(string:String(format:"%@\n",title), attributes:dict1)
        titlePart.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, titlePart.length))
        
        let descriptionPart = NSMutableAttributedString(string:description, attributes:dict2)
        
        let attttributedText = NSMutableAttributedString()
        
        attttributedText.appendAttributedString(titlePart)
        attttributedText.appendAttributedString(descriptionPart)
        
        return attttributedText
    }
    
    func configureWithGrocery(grocery:Grocery) {
        
        /*"timing_title" = "Timing";*/
        
        if grocery.openingTime != nil {
            let groceryTime = self.getGroceryTimeString(grocery.openingTime!)
            let timeStr = self.getAttributedString(NSLocalizedString("timing_title", comment: ""), description:groceryTime)
            self.timeLabel.attributedText = timeStr
        }
        
        /* ---------- Set View for available delivery types ---------- */
        var deliveryDescription = ""
        if grocery.deliveryTypeId == "0"{
            //Instant
            deliveryDescription = NSLocalizedString("instant_title", comment: "")
        }else if grocery.deliveryTypeId == "1"{
            //Schedule
            deliveryDescription = NSLocalizedString("schedule_title", comment: "")
        }else if grocery.deliveryTypeId == "2"{
            //Both Instant & Schedule
            deliveryDescription = NSLocalizedString("instant_schedule_title", comment: "")
        }
        
        let deliveryStr = self.getAttributedString(NSLocalizedString("delivery_title", comment: ""), description:deliveryDescription)
        self.deliveryLabel.attributedText = deliveryStr
        
        /* ---------- Set View for available payment types ---------- */
        var paymentDescription = ""
        if grocery.availablePayments.unsignedIntValue & PaymentOption.Cash.rawValue > 0 && grocery.availablePayments.unsignedIntValue & PaymentOption.Card.rawValue > 0 {
            
            //both payments are available
            paymentDescription = NSLocalizedString("cash_card_delivery", comment: "")
            
        } else if grocery.availablePayments.unsignedIntValue & PaymentOption.Cash.rawValue > 0 && grocery.availablePayments.unsignedIntValue & PaymentOption.Card.rawValue == 0 {
            
            //only Cash
            paymentDescription = NSLocalizedString("cash_delivery", comment: "")
            
        } else if grocery.availablePayments.unsignedIntValue & PaymentOption.Cash.rawValue == 0 && grocery.availablePayments.unsignedIntValue & PaymentOption.Card.rawValue > 0 {
            
            //only Card
           paymentDescription = NSLocalizedString("card_delivery", comment: "")
        }
        
        let paymentStr = self.getAttributedString(NSLocalizedString("payment_title", comment: ""), description:paymentDescription)
        self.paymentLabel.attributedText = paymentStr
        
        /* ---------- Set Grocery Image ---------- */
        if grocery.imageUrl != nil && grocery.imageUrl?.rangeOfString("http") != nil {
            
            self.groceryImage.sd_setImageWithURL(NSURL(string: grocery.imageUrl!), placeholderImage: self.placeholderPhoto, completed: { (image:UIImage!, error:NSError!, cache:SDImageCacheType, url:NSURL!) -> Void in
                
                if cache == SDImageCacheType.None {
                    
                    UIView.transitionWithView(self.groceryImage, duration: 0.33, options: UIView.AnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                        
                        self.groceryImage.image = image
                        
                        }, completion: nil)
                }
            })
        }
    }
    
    
    func getGroceryTimeString(openingTime:String) -> String {
        
        var timeStr = String()
        
        if let data = openingTime.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                
                let timeDict = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
                
                let openingHours: NSArray = timeDict!["opening_hours"] as! NSArray
                let closingHours: NSArray = timeDict!["closing_hours"] as! NSArray
                
                /*1 = Sunday,2 = Monday,3 = Tuesday,4 = Wednesday,5 = Thursday,6 = Friday,7 = Saturday*/
                
                let weekDays = ["1","2","3","4","7"]
                
                let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
                let myComponents = myCalendar.components(.Weekday, fromDate:NSDate())
                let weekDay = myComponents.weekday
                
                print("WeekDay:%d",weekDay)
                
                var openingStr:String = ""
                var closingStr:String = ""
                
                let weekdayStr = String(format:"%d",myComponents.weekday)
                
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
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                let openingTime = dateFormatter.dateFromString(openingStr)
                let closingTime = dateFormatter.dateFromString(closingStr)
                
                dateFormatter.dateFormat = "hh:mm a"
                let openTimeStr = dateFormatter.stringFromDate(openingTime!)
                let closeTimeStr = dateFormatter.stringFromDate(closingTime!)
                
                timeStr = String(format: "%@ - %@",openTimeStr,closeTimeStr)
                
            } catch let error as NSError {
                print(error)
            }
        }
        
        return timeStr
    }*/
