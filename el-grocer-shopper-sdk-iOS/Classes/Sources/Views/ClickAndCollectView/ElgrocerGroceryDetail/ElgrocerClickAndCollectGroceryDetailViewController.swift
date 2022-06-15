//
//  ElgrocerClickAndCollectGroceryDetailViewController.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 19/02/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

class ElgrocerClickAndCollectGroceryDetailViewController: UIViewController {
    
    var shopClicked: ((_ grocery : Grocery?)->Void)?
    @IBOutlet var iconDistance: UIImageView!
    @IBOutlet var iconDeliverySlot: UIImageView!
    @IBOutlet var iconMinOrder: UIImageView!
    
    @IBOutlet var backGroundView: AWView!
    @IBOutlet var groceryImgView: UIImageView!
    @IBOutlet var lblGroceryName: UILabel!
    @IBOutlet var lblGroceryType: UILabel!
    @IBOutlet var lblGroceryTimeDistance: UILabel!
    @IBOutlet var btnShop: UIButton! {
        didSet{
            btnShop.setTitle(NSLocalizedString("shop_btn_title", comment: ""), for: UIControl.State())
        }
    }
    @IBOutlet var lblDeliverySlotDay: UILabel!
    @IBOutlet var lblDeliverySlotTime: UILabel!
    @IBOutlet var deliverySlotBGView: UIView!
    @IBOutlet var minOrderBGView: UIView!
    @IBOutlet var lblMinOrder: UILabel! {
        didSet{
            lblMinOrder.text = NSLocalizedString("lbl_MinOrder", comment: "")
        }
    }
    @IBOutlet var lblMinOrderValue: UILabel!
    @IBOutlet var activtiyLoader: UIActivityIndicatorView!
    var storeType : StoreType?
    var grocery : Grocery? {
        didSet{
            self.isDataLableNeedsToDisplay(grocery != nil)
            if grocery != nil {
                if self.activtiyLoader != nil {
                    if grocery?.genericSlot?.count ?? 0 > 0 {
                        self.activtiyLoader.stopAnimating()
                    }else{
                        self.activtiyLoader.startAnimating()
                    }
                }
            }else{
                if self.activtiyLoader != nil {
                    self.activtiyLoader.startAnimating()
                }
            }
        }
    }
    var isCornderRadiusSet : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isDataLableNeedsToDisplay()
        self.setUpFontAndLable()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        if !isCornderRadiusSet {
            isCornderRadiusSet = !isCornderRadiusSet
            self.setUpUIAppearance()
        }
    }
    
    func setUpUIAppearance() {
        self.view.roundCorners(corners: [.topLeft, .topRight], radius: 8.0)
    }
    func setUpFontAndLable(){
        self.activtiyLoader.startAnimating()
        self.lblGroceryName.setBody2BoldDarkStyle()
        self.lblGroceryType.setCaptionOneRegLightStyle()
        self.lblGroceryTimeDistance.setCaptionOneRegLightStyle()
        self.lblDeliverySlotDay.setCaptionOneRegLightStyle()
        self.lblMinOrder.setCaptionOneRegLightStyle()
        self.lblDeliverySlotTime.setCaptionOneBoldDarkStyle()
        self.lblMinOrderValue.setCaptionOneBoldDarkStyle()
        self.btnShop.setH4SemiBoldWhiteStyle()
        self.btnShop.setCornerRadiusStyle()
    }
    
    func isDataLableNeedsToDisplay(_ isGroceryLoaded : Bool = false){
        
        guard self.activtiyLoader != nil , self.lblGroceryName != nil , self.lblGroceryType != nil , self.lblGroceryTimeDistance != nil , self.lblDeliverySlotDay != nil , self.btnShop != nil else {
            return
        }
        
        self.groceryImgView.isHidden = !isGroceryLoaded
        self.activtiyLoader.isHidden = self.grocery?.deliverySlots.count ?? 0 > 0
        self.lblGroceryName.isHidden = !isGroceryLoaded
        self.lblGroceryType.isHidden = !isGroceryLoaded
        self.lblDeliverySlotDay.isHidden = !isGroceryLoaded
        self.lblMinOrder.isHidden = true//!isGroceryLoaded
        self.lblDeliverySlotTime.isHidden = !isGroceryLoaded
        self.lblMinOrderValue.isHidden = true//!isGroceryLoaded
        self.btnShop.isHidden = !isGroceryLoaded
        self.iconDistance.isHidden = !isGroceryLoaded
        self.lblGroceryTimeDistance.isHidden = !isGroceryLoaded
        self.iconMinOrder.isHidden = true//!isGroceryLoaded
        self.iconDeliverySlot.isHidden = !isGroceryLoaded
        self.minOrderBGView.visibility = .goneX
        
        if isGroceryLoaded {
            self.lblGroceryName.text = self.grocery?.name
            if self.storeType != nil {
                self.lblGroceryType.text = ElGrocerUtility.sharedInstance.isArabicSelected() ? self.storeType?.nameAr : self.storeType?.name
            }else{
                self.lblGroceryType.text = NSLocalizedString("lbl_Other", comment: "")
            }
            self.lblMinOrderValue.text = CurrencyManager.getCurrentCurrency() + " "  + String(self.grocery?.minBasketValue ?? 0)
            self.lblGroceryTimeDistance.text = ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: (self.grocery?.distance.stringValue ?? "0")) + " " + NSLocalizedString("lbl_prep_time_min", comment: "")
            self.setImage(self.grocery?.smallImageUrl)
        }
        
        
        guard self.grocery != nil else {return}
        
        if  self.grocery!.deliverySlots.count  > 0  {
            
            if var slotsA = self.grocery!.deliverySlots.allObjects as? [DeliverySlot] {
                
                slotsA =  DeliverySlot.sortFilterA(slotsA)
                
                let slotString = slotsA[0].getSlotFormattedWithNewLineString(true, isDeliveryMode: self.grocery?.isDelivery.boolValue ?? false)
                let t1 = slotString.components(separatedBy: CharacterSet.newlines)
                let t2 = t1.filter{ $0 != "" }
                let finalSlotString = t2.filter{ !$0.isEmpty }
                if finalSlotString.count == 1 {
                    self.lblDeliverySlotDay.text =  finalSlotString[0]
                    self.lblDeliverySlotDay.isHidden = true
                    return
                }
                if finalSlotString.count > 1 {
                    self.lblDeliverySlotDay.text =  finalSlotString[0]
                    self.lblDeliverySlotTime.text =  finalSlotString[1]
                    self.lblDeliverySlotTime.isHidden = false
                    self.lblDeliverySlotDay.isHidden = false
                    return
                }
                if finalSlotString.count > 0 {
                    self.lblDeliverySlotDay.text =  finalSlotString[0]
                    self.lblDeliverySlotDay.isHidden = false
                    return
                }
            }
        } else if self.grocery!.genericSlot != nil {
            
            let slotString = self.grocery!.genericSlot!
            let t1 = slotString.components(separatedBy: CharacterSet.newlines)
            let t2 = t1.filter{ $0 != "" }
            let finalSlotString = t2.filter{ !$0.isEmpty }
            if finalSlotString.count == 1 {
                self.lblDeliverySlotDay.text =  finalSlotString[0]
                self.lblDeliverySlotDay.isHidden = true
                return
            }
            if finalSlotString.count > 1 {
                self.lblDeliverySlotDay.text =  finalSlotString[0]
                self.lblDeliverySlotTime.text =  finalSlotString[1]
                self.lblDeliverySlotTime.isHidden = false
                self.lblDeliverySlotDay.isHidden = false
                return
            }
            if finalSlotString.count > 0 {
                self.lblDeliverySlotDay.text =  finalSlotString[0]
                self.lblDeliverySlotDay.isHidden = false
                return
            }
            
        }
        
        self.lblDeliverySlotDay.isHidden = true
        self.lblDeliverySlotTime.isHidden = true
    }
    
    func setImage(_ url : String?  ) {
        if url != nil && url?.range(of: "http") != nil {
            self.groceryImgView.sd_setImage(with: URL(string: url!), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 0) , completed: {[weak self] (image, error, cacheType, imageURL) in
                guard image != nil else {return}
                if cacheType == SDImageCacheType.none {
                    self?.groceryImgView.image = image
                }
            })
        }else{
            self.groceryImgView.image = productPlaceholderPhoto
        }
    }
    
    
    
  
    @IBAction func btnShopActionHandler(_ sender: Any) {
        
        if let clouser = self.shopClicked {
            clouser(grocery)
        }
        self.dismiss(animated: true, completion: nil)
  
    }
    
}
