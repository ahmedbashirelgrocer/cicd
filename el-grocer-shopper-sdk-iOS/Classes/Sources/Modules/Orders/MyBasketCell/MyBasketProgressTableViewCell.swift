//
//  MyBasketProgressTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 05/11/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit

class MyBasketProgressTableViewCell: UITableViewCell {
    
    
    @IBOutlet var lblDeliveryDetails: UILabel! {
        didSet{
            lblDeliveryDetails.text =   NSLocalizedString("dashboard_location_navigation_bar_title", comment: "")
            lblDeliveryDetails.setH3SemiBoldDarkStyle()
        }
    }
    
    @IBOutlet var viewForProgress: UIView!
    @IBOutlet var imageGrocery: UIImageView!
    @IBOutlet var lblGrocery: UILabel!
    
    @IBOutlet var progressFullBar: UIImageView!
    @IBOutlet var progressHalfFilled: UIImageView!
    @IBOutlet var HalfFIllBucket: UIImageView!
    @IBOutlet var completeCheckOut: UIImageView!
    @IBOutlet var lblMessage: UILabel!
    @IBOutlet var continueShoppingBtn: AWButton! {
        didSet{
            continueShoppingBtn.setTitle(NSLocalizedString("lbl_Contnue_shopping", comment: "") , for: UIControl.State())
            continueShoppingBtn.setCaption3BoldGreenStyle()
            
        }
    }
    @IBOutlet var distanceFromCompletion: NSLayoutConstraint!
    var isMinReached : Bool = false
    var currentBasketController: MyBasketViewController?
    
    var minBasketConstant  = 0.01
    var maxBasketConstant  = 1
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    func setTopVC(basket : MyBasketViewController) {
        self.currentBasketController = basket
    }
    
    
    func setGrocery(grocery : Grocery?) {
        guard grocery != nil else {
            return
        }
        self.lblGrocery.text = grocery?.name ?? ""
        if grocery?.smallImageUrl != nil && grocery?.smallImageUrl?.range(of: "http") != nil {
            self.setGroceryImage(grocery!.smallImageUrl!)
        }else{
            self.imageGrocery.image = productPlaceholderPhoto
        }
    }
    
    fileprivate func setGroceryImage(_ urlString : String) {
        
        self.imageGrocery.sd_setImage(with: URL(string: urlString ), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: {[weak self] (image, error, cacheType, imageURL) in
            guard let self = self else {
                return
            }
            if cacheType == SDImageCacheType.none {
                
                UIView.transition(with: self.imageGrocery, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {[weak self] () -> Void in
                    guard let self = self else {
                        return
                    }
                    self.imageGrocery.image = image
                    }, completion: nil)
                
            }
        })
        
    }
    
    
    func configureHalfProgressState() {
        
        self.completeCheckOut.isHidden = true
        self.HalfFIllBucket.isHidden = false
        self.progressFullBar.image = UIImage(named: "MYBasketProgressNotFilled")
        
    }
    
    func configureCompleteProgressState() {
        self.HalfFIllBucket.isHidden = true
        self.completeCheckOut.isHidden = false
       // self.progressFullBar.image = UIImage(named: "MYBasketProgressNotFilled")
          self.progressFullBar.image = UIImage(named: "MYBasketProgressFilled")
      //  self.distanceFromCompletion.constant = 1.0
    }
    
    
    func setAnimationForProgress(minValue : Double , progressValue : Double) {
   
       let totalWidth = self.viewForProgress.frame.size.width
        var provalue = (minValue == 0 && progressValue == 0) ? 0 : (minValue - progressValue)
        provalue =  (minValue == 0 && provalue == 0) ? 0 : (minValue - provalue)
        if provalue >= 0 {
            provalue = provalue / minValue
            //provalue = 100 - provalue
            self.completeCheckOut.isHidden = true
            self.HalfFIllBucket.isHidden = false
        }else{
            provalue = 1.0
            self.HalfFIllBucket.isHidden = true
            self.completeCheckOut.isHidden = false
        }
        
        if provalue > 0.95 {
            provalue = 1.0
        }
        
        
        let constatnValue = totalWidth * CGFloat(provalue)
        
        let isNan = constatnValue.isNaN
        if isNan  {
            self.distanceFromCompletion.constant = 0.1
            self.completeCheckOut.isHidden = true
            self.HalfFIllBucket.isHidden = false
        }else{
            self.distanceFromCompletion.constant = constatnValue
            self.completeCheckOut.isHidden = constatnValue != 0 ? true : false
            self.HalfFIllBucket.isHidden = (constatnValue != 0 ? false : true)
            if constatnValue == totalWidth {
                self.completeCheckOut.isHidden = false
                self.HalfFIllBucket.isHidden = true
            }
            
        }
        
        if minValue == 0 {
            self.completeCheckOut.isHidden = false
            self.HalfFIllBucket.isHidden = true
        }
        
        if constatnValue == 0  {
            self.completeCheckOut.isHidden = true
            self.HalfFIllBucket.isHidden = false
        }
        
    
        
     //  self.distanceFromCompletion.setMultiplier(multiplier: CGFloat(provalue))
        UIView.animate(withDuration: 0.10) {
            self.progressHalfFilled.setNeedsLayout()
            self.progressHalfFilled.layoutIfNeeded()
            self.HalfFIllBucket.setNeedsLayout()
            self.HalfFIllBucket.layoutIfNeeded()
        } completion: { (isCompleted) in }

    }
    
    func setContinueshoppingEnable (_ isEnable : Bool) {
        if isEnable {
            self.continueShoppingBtn.isHidden = false
            configureHalfProgressState()
        }else{
            self.continueShoppingBtn.isHidden = true
            configureCompleteProgressState()
        }
    }
    
    func setMessageForShopper (_ isReadedMinLimit : Bool , minLimit : String , remainingLimit : String , storeName : String) {
        
        self.setContinueshoppingEnable(!isReadedMinLimit)
        if isReadedMinLimit {
            self.isMinReached = true
            self.lblMessage.textColor = UIColor.navigationBarColor()
            self.lblMessage.text =  NSLocalizedString("lbl_congrtz", comment: "")// "Congratulations! You reached the min order."
            self.configureCompleteProgressState()
            return
        }
        self.isMinReached = false
        self.configureHalfProgressState()
        let remaining = remainingLimit + " \(CurrencyManager.getCurrentCurrency()) "
        self.lblMessage.text = "\(NSLocalizedString("lbl_reach", comment: "")) " + minLimit + " \(CurrencyManager.getCurrentCurrency()) " + "\(NSLocalizedString("lbl_placeorder", comment: ""))\n" + "\(NSLocalizedString("lbl_Add", comment: "")) " + remaining + "\(NSLocalizedString("lbl_morefrom", comment: "")) "
        self.makeStringGreenAndBold(lbl: self.lblMessage, totalString: self.lblMessage.text ?? ""  , changeString: remaining)
   
    }
    
    func makeStringGreenAndBold (lbl : UILabel ,  totalString : String , changeString : String) {
        
        let attributedString = NSMutableAttributedString(string:totalString)
        let totalRange = NSRange(location: 0, length: totalString.count)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.newBlackColor() , range: totalRange)
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.SFProDisplayNormalFont(14) , range: totalRange)
        DispatchQueue.main.async {
            lbl.attributedText = attributedString
        }
        
        let range = (totalString as NSString).range(of: changeString)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.navigationBarColor() , range: range)
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.SFProDisplaySemiBoldFont(14) , range: range)
        DispatchQueue.main.async {
            lbl.attributedText = attributedString
        }
        
    }
    
    

    
    @IBAction func continueShoppingHandler(_ sender: Any) {
        if let topVC = UIApplication.topViewController() {
            if self.currentBasketController != nil {
                if let isEdit = self.currentBasketController?.orderToReplace  {
                    if isEdit {
                        self.currentBasketController?.didTapCategorySearchBar()
                        return
                    }
                }
            }
            topVC.tabBarController?.selectedIndex = 1
        }
    }
    
    
}
