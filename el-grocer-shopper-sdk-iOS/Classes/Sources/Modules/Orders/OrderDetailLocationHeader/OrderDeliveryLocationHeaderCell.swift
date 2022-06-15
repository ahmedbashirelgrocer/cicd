//
//  OrderDeliveryLocationHeaderCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 28/12/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit
import QuartzCore
import SDWebImage

let KOrderDeliveryLocationCellIdentifier = "OrderDeliveryLocationHeaderCell"

let KOrderDeliveryLocationCellHeight : CGFloat = 246.0
class OrderDeliveryLocationHeaderCell: UITableViewCell {

    
    @IBOutlet weak var groceryIcon: UIImageView!
    @IBOutlet weak var groceryName: UILabel!
    @IBOutlet weak var groceryAddress: UILabel!
    
    @IBOutlet weak var dataLable: UILabel!
    @IBOutlet weak var orderDate: UILabel!
    
    
    @IBOutlet weak var orderNumberLable: UILabel!
    @IBOutlet weak var orderNUmber: UILabel!
    
    
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemQuantityLabel: UILabel!
    @IBOutlet weak var itemCurrencyLabel: UILabel!
    @IBOutlet weak var productHeaderLablesView: UIView!
    
    
    @IBOutlet weak var deliverySlotTitle: UILabel!
    @IBOutlet weak var deliverySlotDate: UILabel!
    @IBOutlet weak var deliveryIcon: UIImageView!
    
    @IBOutlet weak var dataYConstraints: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setUpHeaderView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    fileprivate func setUpHeaderView () {
        
        setUpShadowView()
        setUpLableApearance()

    }
    
    fileprivate func setUpShadowView (){
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: 500 , height: self.productHeaderLablesView.frame.size.height)
       gradient.colors = [UIColor.colorWithHexString(hexString: "ebedee").cgColor, UIColor.colorWithHexString(hexString: "feffff").cgColor]
        gradient.locations = [0.0 , 1.0]
       
         self.productHeaderLablesView.layer.insertSublayer(gradient, at: 0)
        
    }
    
    fileprivate func setUpLableApearance() {
        
        self.groceryName.font = UIFont.SFProDisplayBoldFont(17.0)
        self.groceryAddress.font = UIFont.SFProDisplayNormalFont(15.0)
        
        
        self.orderDate.font = UIFont.SFProDisplayBoldFont(13.0)
        self.dataLable.font = UIFont.SFProDisplaySemiBoldFont(13.0)
        
        
        self.orderNumberLable.font = UIFont.SFProDisplaySemiBoldFont(13.0)
        self.orderNUmber.font = UIFont.SFProDisplaySemiBoldFont(13.0)
        
        
        self.itemNameLabel.font = UIFont.SFProDisplayNormalFont(12.0)
        self.itemQuantityLabel.font = UIFont.SFProDisplayNormalFont(12.0)
        self.itemCurrencyLabel.font = UIFont.SFProDisplayNormalFont(12.0)
        
        self.itemNameLabel.text = NSLocalizedString("brand_items_count_label", comment: "")
        self.itemQuantityLabel.text = NSLocalizedString("shopping_basket_quantity_label", comment: "")
        self.itemCurrencyLabel.text = NSLocalizedString("aed", comment: "")
        
        self.orderNumberLable.text = NSLocalizedString("order_number_label_Full", comment: "")
        self.dataLable.text = NSLocalizedString("order_date_label", comment: "")
        
        
        self.setUpDeliverySlotLabelAndDateAppearance()
    }
    
    func setUpDeliverySlotLabelAndDateAppearance() {
        
        self.deliverySlotTitle.textColor = UIColor.colorWithHexString(hexString: "8E8D8F")
        self.deliverySlotTitle.font = UIFont.SFProDisplaySemiBoldFont(13.0)
        
        self.deliverySlotDate.textColor = UIColor.black
        self.deliverySlotDate.font = UIFont.SFProDisplaySemiBoldFont(13.0)
    }
    
    func configureData (product : Product , item : ShoppingBasketItem? , order : Order) {
        
        self.setGroceryImage(order.grocery)
        self.groceryName.text = order.grocery.name
        self.groceryAddress.text = ElGrocerUtility.sharedInstance.getFormattedAddress(order.deliveryAddress)
        
        
        
        self.orderNUmber.text =  " \(order.dbID.intValue)"
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let phoneLanguage = UserDefaults.getCurrentLanguage()
        if phoneLanguage == "ar" {
            formatter.locale = Locale(identifier: "ar_DZ")
        }
        self.orderDate.text =  formatter.string(from: order.orderDate)
        
        
        // Here making decision to hide/unhide Delivery Slot View
        if order.deliverySlot != nil {
            
            self.hideOrderDeliverySlotView(false)
            self.deliverySlotTitle.text = NSLocalizedString("schedule_title", comment: "") + ": "
            var slotTimeStr = ""
            if let selectedSlot = order.deliverySlot {
                slotTimeStr = selectedSlot.getSlotFormattedString(isDeliveryMode: order.isDeliveryOrder())
                if  selectedSlot.isToday() {
                    let name =    NSLocalizedString("today_title", comment: "") // + " " + ( selectedSlot.estimatedDeliveryDate!.dataMonthDateInUTCString() ?? "")
                    slotTimeStr = String(format: "%@ (%@)", name ,slotTimeStr)
                }else if selectedSlot.isTomorrow()  {
                    
                    let name =    NSLocalizedString("tomorrow_title", comment: "") // + " " + ( selectedSlot.estimatedDeliveryDate!.dataMonthDateInUTCString() ?? "")
                    slotTimeStr = String(format: "%@ (%@)", name,slotTimeStr)
                }else{
                    slotTimeStr = String(format: "%@ (%@)", selectedSlot.start_time?.getDayName() ?? "" ,slotTimeStr)
                }
            }
            self.deliverySlotDate.text = String(format: "%@",slotTimeStr)

        }else{
            self.hideOrderDeliverySlotView(true)
        }
   
        
    }
    
    fileprivate func hideOrderDeliverySlotView(_ isHidden : Bool) {
        
        self.deliverySlotDate.isHidden = isHidden
        self.deliverySlotTitle.isHidden = isHidden
        self.deliveryIcon.isHidden = isHidden
        
        if isHidden {
            self.dataYConstraints.constant = 35
        }else{
            self.dataYConstraints.constant = 10
        }
        
    }
    
    
    func setGroceryImage(_ grocery : Grocery) {
        
        self.groceryIcon.backgroundColor = UIColor.clear
        self.groceryIcon.subviews.forEach { $0.removeFromSuperview() }
        if grocery.smallImageUrl != nil && grocery.smallImageUrl?.range(of: "http") != nil {
            
            self.groceryIcon.sd_setImage(with: URL(string: grocery.smallImageUrl!), placeholderImage:  UIImage.init() , options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.groceryIcon, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.groceryIcon.image = image
                        
                    }, completion: nil)
                }
            })
        }
        
    }

}
