//
//  HyperMarketGroceryTableCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 31/10/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

class HyperMarketGroceryTableCell: UITableViewCell {

    @IBOutlet var cellBGView: UIView!{
        didSet{
            cellBGView.backgroundColor = ApplicationTheme.currentTheme.viewWhiteBGColor
            cellBGView.layer.borderColor = ApplicationTheme.currentTheme.borderLightGrayColor.cgColor
            cellBGView.layer.borderWidth = 1.0
            cellBGView.roundWithShadow(corners: [.layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner], radius: 4, withShadow: false)
        }
    }
    @IBOutlet var imgGrocery: UIImageView!
    @IBOutlet var imgDeliveryType: UIImageView!{
        didSet{
            imgDeliveryType.backgroundColor = .navigationBarWhiteColor()
        }
    }
    @IBOutlet var lblGroceryName: UILabel!{
        didSet{
            lblGroceryName.numberOfLines = 1
            lblGroceryName.setBody2SemiboldDarkStyle()
        }
    }
    @IBOutlet var lblSlot: UILabel!{
        didSet{
            lblSlot.setSubHead2SemiBoldDarkStyle()
        }
    }
    @IBOutlet var newBGView: UIView!{
        didSet{
            newBGView.backgroundColor = ApplicationTheme.currentTheme.viewStoreCardNewTagBGView
            newBGView.roundWithShadow(corners: [.layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner], radius: 8, withShadow: false)
        }
    }
    @IBOutlet var lblNew: UILabel!{
        didSet{
            lblNew.setCaptionTwoBoldWhiteStyle()
            lblNew.text = localizedString("lbl_new_tag", comment: "")
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpInitialAppearence()
    }
    
    func setUpInitialAppearence(){
        self.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
        self.selectionStyle = .none
    }
    
    func configureCell(grocery: Grocery, isFeatured: Bool){
        if grocery.smallImageUrl != nil{
            AssignImage(imageUrl: grocery.smallImageUrl!)
        }
        self.lblGroceryName.text = grocery.name
        self.newBGView.isHidden = !(grocery.isNewRetailer?.boolValue ?? false)
//        self.setDeliveryDate(grocery.genericSlot ?? "")
        self.getDeliverySlotString(grocery: grocery)
        
        if isFeatured {
            self.cellBGView.backgroundColor = ApplicationTheme.currentTheme.viewFeaturedStoreBGView
            self.cellBGView.layer.borderWidth = 0.0
        }else {
            self.cellBGView.backgroundColor = ApplicationTheme.currentTheme.viewWhiteBGColor
            self.cellBGView.layer.borderWidth = 1.0
        }
    }
    
    func AssignImage(imageUrl: String){
        if imageUrl != nil && imageUrl.range(of: "http") != nil {
            
            self.imgGrocery.sd_setImage(with: URL(string: imageUrl), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.imgGrocery, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.imgGrocery.image = image
                        
                    }, completion: nil)
                }
            })
        }
    }
    
    fileprivate func hideSlotImage (isHidden: Bool = false) {
        if isHidden {
            self.imgDeliveryType.visibility = .goneX
        }else {
            self.imgDeliveryType.visibility = .visible
        }
    }
    func getDeliverySlotString(grocery: Grocery) {
        let scheduledEmoji = "🚛 "
        if  (grocery.isOpen.boolValue && (grocery.isInstant() || grocery.isInstantSchedule())) {
            let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(11) , NSAttributedString.Key.foregroundColor : self.lblSlot.textColor]
            let instantSlotString = "🛵 " + localizedString("today_title", comment: "") + " " + localizedString("60_min", comment: "")
            let attributedString2 = NSMutableAttributedString(string: instantSlotString, attributes:attrs2 as [NSAttributedString.Key : Any])
            self.lblSlot.attributedText = attributedString2
            hideSlotImage(isHidden: true)
        }else if let jsonSlot = grocery.initialDeliverySlotData {
            if let dict = grocery.convertToDictionary(text: jsonSlot) {
                
                let slotString = DeliverySlotManager.getStoreGenericSlotFormatterTimeStringWithDictionary(dict, isDeliveryMode: grocery.isDelivery.boolValue)
                
                setDeliveryDate(scheduledEmoji + slotString)
                hideSlotImage(isHidden: true)
                
            }else {
                setDeliveryDate(scheduledEmoji + (grocery.genericSlot ?? ""))
                hideSlotImage(isHidden: true)
            }
        }else {
            setDeliveryDate(scheduledEmoji + (grocery.genericSlot ?? ""))
            hideSlotImage(isHidden: true)
        }
        
    }
    func setDeliveryDate (_ data : String) {
        
        let dataA = data.components(separatedBy: CharacterSet.newlines)
        var attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(11) , NSAttributedString.Key.foregroundColor : self.lblSlot.textColor ]
        if dataA.count == 1 {
            if self.lblSlot.text?.count ?? 0 > 13 {
                attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(11) , NSAttributedString.Key.foregroundColor : self.lblSlot.textColor ]
                 let attributedString1 = NSMutableAttributedString(string: dataA[0], attributes:attrs1 as [NSAttributedString.Key : Any])
                 self.lblSlot.attributedText = attributedString1
                return
            }
        }
        let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(11) , NSAttributedString.Key.foregroundColor : self.lblSlot.textColor]
        
        let attributedString1 = NSMutableAttributedString(string:dataA[0], attributes:attrs1 as [NSAttributedString.Key : Any])
        let timeText = dataA.count > 1 ? dataA[1] : ""
        let attributedString2 = NSMutableAttributedString(string:" \(timeText)", attributes:attrs2 as [NSAttributedString.Key : Any])
        
        attributedString1.append(attributedString2)
        self.lblSlot.attributedText = attributedString1
        
        self.lblSlot.minimumScaleFactor = 0.5;
        
    }
    func setDeliveryTypeImage(isInstant: Bool = false) {
        if isInstant {
            self.imgDeliveryType.image = UIImage(name: "instatntDeliveryBolt")
        }else {
            self.imgDeliveryType.image = UIImage(name: "clockGreen")
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
