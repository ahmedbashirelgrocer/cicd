//
//  ElGrocerAlertView.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 14.11.2015.
//  Copyright © 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit
import KLCPopup
import PMAlertController
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

class ElGrocerAlertView : UIView {
    
    let kTextSpacingHeight: CGFloat = 24
    let kTextButtonSpacingHeight: CGFloat = 32
    let kButtonHeight: CGFloat = 40
    
    var isMinimumBasketAlert = false
    
    @IBOutlet var lineView1: UIView!
    @IBOutlet var lineView2: UIView!
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerShadowView: UIView!
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var positiveButton: UIButton!{
        didSet{
            positiveButton.setTitleColor(.newBlackColor(), for: .normal)
        }
    }
    @IBOutlet weak var negativeButton: UIButton!{
        didSet{
            negativeButton.setTitleColor(.newBlackColor(), for: .normal)
        }
    }
   // @IBOutlet weak var buttonsTopSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var positiveButtonCenterConstraint: NSLayoutConstraint!
    
    fileprivate var buttonClickCallback:((_ buttonIndex:Int) -> Void)?
    
    var innerViewYPositionConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var viewYPosition: NSLayoutConstraint!
    
    // MARK: Instance
    
    class func createAlert(_ title:String, description:String?, positiveButton:String?, negativeButton:String?, buttonClickCallback:((_ buttonIndex:Int) -> Void)?) -> ElGrocerAlertView {
        
        let alert = Bundle(for: self).loadNibNamed("ElGrocerAlertView", owner: nil, options: nil)![0] as! ElGrocerAlertView
        alert.buttonClickCallback = buttonClickCallback
        alert.setDataInView(title, description: description, positiveButton: positiveButton, negativeButton: negativeButton)
        
        return alert
    }
    
    // MARK: Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpContainerViewAppearance()
        setUpTitleLabelAppearance()
        setUpDescriptionLabelAppearance()
        setUpButtonsAppearance()
        
        addTapGesture()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let shadowPath = UIBezierPath(rect: self.containerView.bounds)
        self.containerShadowView.layer.shadowPath = shadowPath.cgPath
    }
    
    fileprivate func addTapGesture() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissOnViewTap))
        self.addGestureRecognizer(tapGesture)
    }
    
    func show() {
        
        
        
        if let textMessage = self.descriptionLabel.text {
            FireBaseEventsLogger.trackMessageEvents(message: textMessage)
        }else if let textMessage = self.titleLabel.text {
            FireBaseEventsLogger.trackMessageEvents(message: textMessage)
        }

       /* let alertVC = PMAlertController(title: nil , description: self.descriptionLabel.text , image: UIImage(named: "delete-PopUp"), style: .alert)
        
        
        alertVC.alertDescription.textColor = .colorWithHexString(hexString: "333333")
        alertVC.alertDescription.font = .SFProDisplaySemiBoldFont(17)
        alertVC.headerViewHeightConstraint.constant = 48
      
        
        
        if self.positiveButton.titleLabel?.text?.count ?? 0 > 0 {
            alertVC.addAction(PMAlertAction(title: self.positiveButton.titleLabel?.text , style: .cancel, action: { () -> Void in
                self.onPositiveButtonClick(self.positiveButton)
            }))
        }
        
        if self.negativeButton.titleLabel?.text?.count ?? 0 > 0 {
            alertVC.addAction(PMAlertAction(title: self.negativeButton.titleLabel?.text , style: .default, action: { () in
                self.onNegativeButtonClick(self.negativeButton)
            }))
        }
        
        if let topVC = UIApplication.topViewController() {
            topVC.present(alertVC, animated: true, completion: nil)
        }
       
        self.frame = UIScreen.main.bounds
        self.alpha = 0
        */
        
        self.frame = UIScreen.main.bounds
        self.alpha = 0
        UIApplication.shared.keyWindow?.addSubview(self)

        UIView.animate(withDuration: 0.33, animations: { () -> Void in

            self.alpha = 1
        })
    }
    
    @objc func dismissOnViewTap() {
        
        self.buttonClickCallback?(1000)
        dismiss()
    }
    
    func dismiss() {
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            self.alpha = 0
            
        }, completion: { (result:Bool) -> Void in
            
            self.removeFromSuperview()
        }) 
    }
    
    // MARK: Appearance
    
    fileprivate func setUpContainerViewAppearance() {
        
        self.containerView.layer.cornerRadius = 8
        
        self.containerShadowView.layer.shadowColor = UIColor.black.cgColor
        self.containerShadowView.layer.shadowRadius = 5
        self.containerShadowView.layer.shadowOpacity = 0.7
    }
    
    fileprivate func setUpTitleLabelAppearance() {
        
        self.titleLabel.setH4SemiBoldStyle()
    }
    
    fileprivate func setUpDescriptionLabelAppearance() {
        
        self.descriptionLabel.setBody2RegDarkStyle()
    }
    
    
    fileprivate func setUpButtonsAppearance() {
        
        self.positiveButton.layer.cornerRadius = 3
        self.negativeButton.layer.cornerRadius = 3
        
       
        
        self.positiveButton.setBody2SemiBoldDarkStyle()
        self.negativeButton.setBody2SemiBoldDarkStyle()
        
        
        self.positiveButton.setTitleColor(.newBlackColor(), for: self.positiveButton.state)
        self.negativeButton.setTitleColor(.newBlackColor(), for: self.negativeButton.state)
        
      //  self.positiveButton.titleLabel?.textColor = .navigationBarColor()
      //  self.negativeButton.titleLabel?.textColor  = .colorWithHexString(hexString: "333333")
        

        self.negativeButton.backgroundColor = .white
        self.negativeButton.backgroundColor = .white
        
        
        self.positiveButton.tag = 0
        self.negativeButton.tag = 1
        
        self.positiveButton.titleLabel?.textAlignment = NSTextAlignment.center
        self.positiveButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.positiveButton.titleLabel?.minimumScaleFactor = 0.5
        self.negativeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.negativeButton.titleLabel?.minimumScaleFactor = 0.7
    }
    
    // MARK: Layout
    
    fileprivate func calculateViewLayout() {
        
        calculateViewHeight()
        calculateViewsSpacing()
        
        self.layoutIfNeeded()
    }
    
    fileprivate func calculateViewHeight() {
        
        var viewHeight = kTextSpacingHeight
        
        //title
        let titleHeight = self.titleLabel.font.sizeOfString(self.titleLabel.text!, constrainedToWidth: Double(self.titleLabel.frame.size.width)).height
        viewHeight += kTextSpacingHeight + titleHeight
        
        //description
        if let description = self.descriptionLabel.text {
            
           let descriptionHeight = self.descriptionLabel.font.sizeOfString(description, constrainedToWidth: Double(self.descriptionLabel.frame.size.width)).height
            
            let currentLanguage = UserDefaults.getCurrentLanguage()
            if (description == NSLocalizedString("request_alert_description", comment: "") && UIScreen.main.bounds.size.height <= 568 && currentLanguage != "ar"){
                viewHeight += 30
            }
            
            viewHeight += kTextSpacingHeight + descriptionHeight
        }
        
        if self.positiveButton.isHidden == false || self.negativeButton.isHidden == false {
            viewHeight +=  kButtonHeight  //kTextSpacingHeight +
        }
        
        
        if self.positiveButton.isHidden == true || self.negativeButton.isHidden == true {
            lineView1.isHidden = true
            lineView2.isHidden = true
        }
        
        if self.positiveButton.isHidden == false || self.negativeButton.isHidden == false {
            lineView1.isHidden = false
        }
        
        
        
        self.containerHeightConstraint.constant = viewHeight
    }
    
    fileprivate func calculateViewsSpacing() {
        
        if self.descriptionLabel.text == nil {
            
         //   self.buttonsTopSpaceConstraint.constant = 0
        }
        
        if self.negativeButton.titleLabel?.text == nil {
            
            //center positive button
            self.containerView.removeConstraint(self.positiveButtonCenterConstraint)
            
            if let possitiveButton =  self.positiveButton {
                self.positiveButtonCenterConstraint = NSLayoutConstraint(item: possitiveButton , attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.containerView, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
                self.containerView.addConstraint(self.positiveButtonCenterConstraint)
            }
            
           
        }
    }
    
    // MARK: Data
    
    fileprivate func setDataInView(_ title:String, description:String?, positiveButton:String?, negativeButton:String?) {
        
        self.titleLabel.text = title
        
        self.descriptionLabel.text = description
        
        if description != nil {
            let range = (description! as NSString).range(of: NSLocalizedString("cardErrorDefaultMsg", comment: ""))
            if range.length > 0 {
                let attributedString = NSMutableAttributedString(string:description ?? "")
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red , range: range)
                self.descriptionLabel.attributedText = attributedString
            }
        }
       
        
        self.positiveButton.setTitle(positiveButton, for: UIControl.State())
        self.negativeButton.setTitle(negativeButton, for: UIControl.State())
        
        if positiveButton?.count <= 0 {
            self.positiveButton.isHidden = true
        }else{
            self.positiveButton.isHidden = false
        }
        
        if negativeButton?.count <= 0 {
            self.negativeButton.isHidden = true
        }else{
            self.negativeButton.isHidden = false
        }
        
        if positiveButton == nil && negativeButton == nil {
            self.viewYPosition.constant = -1000
            self.layoutIfNeeded()
        }
        
        Thread.OnMainThread { [weak self] in
            self?.calculateViewLayout()
        }
       
 
    }
    
    // MARK: Actions
    
    @IBAction func onPositiveButtonClick(_ sender: AnyObject) {
        
        self.buttonClickCallback?(sender.tag!)
        
        dismiss()
    }
    
    @IBAction func onNegativeButtonClick(_ sender: AnyObject) {
     
        self.buttonClickCallback?(sender.tag!)
        
        dismiss()
    }
    
    // MARK: ShowPopUp Helper
    func removeInnerViewYPositionConstraint() {
        if innerViewYPositionConstraint != nil {
            self.removeConstraint(self.innerViewYPositionConstraint!)
            self.innerViewYPositionConstraint = nil
        }
    }
    
    // MARK: ShowPopUp
    func showPopUp() {
        
        
        if let textMessage = self.descriptionLabel.text {
            FireBaseEventsLogger.trackMessageEvents(message: textMessage)
        }else if let textMessage = self.titleLabel.text {
            FireBaseEventsLogger.trackMessageEvents(message: textMessage)
        }
        
         DispatchQueue.main.async {
        self.frame = UIScreen.main.bounds
        UIApplication.shared.keyWindow?.addSubview(self)
        
        self.showInnerViewAnimated(true)
        }
    }
    
    func showInnerViewAnimated(_ animated: Bool) {
        //remove current constraint
        self.removeInnerViewYPositionConstraint()
        
        let centerYConstraint = NSLayoutConstraint(item: self.containerView,
                                                   attribute: .centerY,
                                                   relatedBy: .equal,
                                                   toItem: self,
                                                   attribute: .centerY,
                                                   multiplier: 1,
                                                   constant: 0)
        self.innerViewYPositionConstraint = centerYConstraint
        self.addConstraint(centerYConstraint)
        
        //animation
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping:0.8, initialSpringVelocity: 0.8, options: .curveEaseIn, animations: {
            self.layoutIfNeeded()
        }) { (isCompleted) in
            self.perform(#selector(self.dismissWithAnimation), with: nil, afterDelay: 5.0)
        }
    }
    
    @objc func dismissWithAnimation() {
        self.hideInnerViewAnimated(true)
    }
    
    func hideInnerViewAnimated(_ animated: Bool) {
        //remove current constraint
        self.removeInnerViewYPositionConstraint()
        let hideConstraint = NSLayoutConstraint(item: self.containerView,
                                                attribute: .bottom,
                                                relatedBy: .equal,
                                                toItem: self,
                                                attribute: .bottom,
                                                multiplier: 1,
                                                constant: 1000)
        self.innerViewYPositionConstraint = hideConstraint
        self.addConstraint(hideConstraint)
        
        //animation
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
            self.layoutIfNeeded()
        }) { (isCompleted) in
            self.removeFromSuperview()
            self.alpha = 0
        }
    }
}
