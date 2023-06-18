//
//  SpecialtyStoresGroceryTableCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 31/10/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

class SpecialtyStoresGroceryTableCell: UITableViewCell {
    
    @IBOutlet var cellBGView: UIView!{
        didSet{
            cellBGView.backgroundColor = .navigationBarWhiteColor()
            cellBGView.layer.cornerRadius = 8
            cellBGView.clipsToBounds = true
        }
    }
    @IBOutlet var imgGrocery: UIImageView!
    @IBOutlet var imgGroceryBackground: UIImageView!{
        didSet{
            imgGroceryBackground.image = UIImage(name: "groceryBGView")
        }
    }
    @IBOutlet var runVideoBGView: UIView!{
        didSet{
            runVideoBGView.backgroundColor = ApplicationTheme.currentTheme.viewPrimaryBGColor
            runVideoBGView.roundWithShadow(corners: [.layerMinXMaxYCorner, .layerMaxXMinYCorner], radius: 8, withShadow: false)
        }
    }
    @IBOutlet var imgPlay: UIImageView!{
        didSet{
            imgPlay.image = UIImage(name: "playGroceryVideo")
        }
    }
    @IBOutlet var lblRunVideo: UILabel!{
        didSet{
            lblRunVideo.setSubHead2BoldWhiteStyle()
            lblRunVideo.text = localizedString("Run a store video", comment: "")
        }
    }
    @IBOutlet var bottomBGView: UIView!{
        didSet{
//            bottomBGView.backgroundColor = .replacementGreenBGColor()
//            bottomBGView.roundWithShadow(corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 8, withShadow: false)
//            bottomBGView.layer.opacity = 0.9
        }
    }
    @IBOutlet var lblGroceryName: UILabel!{
        didSet{
            lblGroceryName.setSubHead2SemiBoldDarkGreenStyle()
        }
    }
    @IBOutlet var imgSlotTime: UIImageView!
    @IBOutlet var lblSlotTime: UILabel!
    @IBOutlet weak var imgGroceryLeadingContstraint: NSLayoutConstraint!
    var placeholderPhoto = UIImage(name: "product_placeholder")!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setInitialAppearence()
    }
    
    func setInitialAppearence(){
        self.selectionStyle = .none
        self.backgroundColor = .tableViewBackgroundColor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imgGrocery.sd_cancelCurrentImageLoad()
        self.imgGrocery.image = self.placeholderPhoto
    }
    
    func configureCell(grocery: Grocery){
        if grocery.smallImageUrl != nil{
            assignGroceryImage(imageUrl: grocery.smallImageUrl!)
        }
        
        assignGroceryBgImage(imageUrl: grocery.featureImageUrl ?? "")
        self.lblGroceryName.text = grocery.name
        self.runVideoBGView.isHidden = true
//        self.setDeliveryDate(grocery.genericSlot ?? "")
        self.getDeliverySlotString(grocery: grocery)
    }
    
    func assignGroceryImage(imageUrl: String){
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
    
    func assignGroceryBgImage(imageUrl: String?){
        
        
        if let imageLink = imageUrl, imageLink.range(of: "http") != nil {
            
            self.imgGroceryBackground.sd_setImage(with: URL(string: imageLink), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.imgGroceryBackground, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.imgGroceryBackground.image = image
                        
                    }, completion: nil)
                }
            })
        }
    }
    
    func getDeliverySlotString(grocery: Grocery) {
        
        if  (grocery.isOpen.boolValue && (grocery.isInstant() || grocery.isInstantSchedule())) {
            setDeliveryDate(grocery.genericSlot ?? "")
        }else if let jsonSlot = grocery.initialDeliverySlotData {
            if let dict = grocery.convertToDictionary(text: jsonSlot) {
                
                let slotString = DeliverySlotManager.getStoreGenericSlotFormatterTimeStringWithDictionarySpecialityMarket(dict, isDeliveryMode: grocery.isDelivery.boolValue)
                setDeliveryDate(slotString)
                
            }else {
                setDeliveryDate(grocery.genericSlot ?? "")
            }
        }else {
            setDeliveryDate(grocery.genericSlot ?? "")
        }
        
    }
    
    func setDeliveryDate (_ data : String) {
        
        let dataA = data.components(separatedBy: CharacterSet.newlines)
        var attrs1 = [NSAttributedString.Key.font : UIFont(name: "SFProDisplay-Light", size: 11) , NSAttributedString.Key.foregroundColor : self.lblSlotTime.textColor ]
        if dataA.count == 1 {
            if self.lblSlotTime.text?.count ?? 0 > 13 {
                attrs1 = [NSAttributedString.Key.font : UIFont(name: "SFProDisplay-Light", size: 9) , NSAttributedString.Key.foregroundColor : self.lblSlotTime.textColor ]
                 let attributedString1 = NSMutableAttributedString(string: dataA[0], attributes:attrs1 as [NSAttributedString.Key : Any])
                 self.lblSlotTime.attributedText = attributedString1
                return
            }
        }
        let attrs2 = [NSAttributedString.Key.font : UIFont(name: "SFProDisplay-Semibold", size: 11) , NSAttributedString.Key.foregroundColor : self.lblSlotTime.textColor]
        
        let attributedString1 = NSMutableAttributedString(string:dataA[0], attributes:attrs1 as [NSAttributedString.Key : Any])
        let timeText = dataA.count > 1 ? dataA[1] : ""
        let attributedString2 = NSMutableAttributedString(string:" \(timeText)", attributes:attrs2 as [NSAttributedString.Key : Any])
        
        attributedString1.append(attributedString2)
        self.lblSlotTime.attributedText = attributedString1
        
        self.lblSlotTime.minimumScaleFactor = 0.5;
        
    }

}
// helper
extension SpecialtyStoresGroceryTableCell {
    
    func cellSetGroceryImagePlacement() {
        
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.imgGroceryLeadingContstraint.constant = self.frame.size.width - self.imgGrocery.frame.size.width - 36
        } else {
            self.imgGroceryLeadingContstraint.constant = 16
        }
        self.layoutIfNeeded()
    }
    
}
