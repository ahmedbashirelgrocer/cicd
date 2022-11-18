//
//  SchedulePopUp.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 21/08/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import UIKit
import KLCPopup

class SchedulePopUp: UIView {
    
    //MARK: Outlets
    @IBOutlet var deliveryImgView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var popupInnerView: UIView!
    
    @IBOutlet weak var viewYPosition: NSLayoutConstraint!
    
    var innerViewYPositionConstraint: NSLayoutConstraint?
    
    var grocery:Grocery?

    // MARK: Life cycle
    
    override func awakeFromNib() {
        self.addTapGesture()
        
        self.viewYPosition.constant = -1000
        self.layoutIfNeeded()
    }
    
    // MARK: Data
    func setDataInView(){
        
        self.deliveryImgView.image = UIImage(name: "instant-delivery-icon")
        
        var message = localizedString("instant_delivery_message", comment: "")
        
        self.titleLabel.font = UIFont.SFProDisplaySemiBoldFont(13.0)
        self.titleLabel.textColor = UIColor.black
        
        if self.grocery != nil {
            
            if (self.grocery?.isOpen.boolValue == true){
                
                self.deliveryImgView.image = UIImage(name: "instant-delivery-icon")
                
                self.deliveryImgView.image = self.deliveryImgView.image!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                
                self.deliveryImgView.tintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
                
                message = localizedString("instant_delivery_message", comment: "")
                
            }else{
                
               self.deliveryImgView.image = UIImage(name: "schedule-delivery-icon")
               message = localizedString("scheduled_delivery_message", comment: "")
            }
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5.0
        paragraphStyle.alignment = NSTextAlignment.center
        
        let titleStr = NSMutableAttributedString(string:message)
        
        titleStr.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, titleStr.length))
        
        self.titleLabel.attributedText = titleStr
        self.titleLabel.sizeToFit()
        self.titleLabel.numberOfLines = 0
    }
    
    // MARK: CreatePopUp
    
    class func createSchedulePopUpWithGrocery(_ grocery:Grocery?) -> SchedulePopUp {
        
        let view = Bundle.resource.loadNibNamed("SchedulePopUp", owner: nil, options: nil)![0] as! SchedulePopUp
        view.grocery = grocery
        view.setDataInView()
       // let SDKManager = SDKManager.shared
       // SDKManager.window?.addSubviewFullscreen(view)
        return view
    }
    
    fileprivate func addTapGesture() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismiss))
        self.addGestureRecognizer(tapGesture)
    }
    
    // MARK: DismissPopUp
    @objc func dismiss() {
        self.hideInnerViewAnimated(true)
    }
    
    // MARK: ShowPopUp
    
    func showPopUp() {
         if let textMessage = self.titleLabel.text {
            FireBaseEventsLogger.trackMessageEvents(message: textMessage)
        }
        DispatchQueue.main.async {
            self.frame = UIScreen.main.bounds
            UIApplication.shared.keyWindow?.addSubview(self)
            self.showInnerViewAnimated(true)
        }
    }
    
    func hideInnerViewAnimated(_ animated: Bool) {
        //remove current constraint
        self.removeInnerViewYPositionConstraint()
        if let popInnerView = self.popupInnerView {
            let hideConstraint = NSLayoutConstraint(item: popInnerView ,
                                                    attribute: .bottom,
                                                    relatedBy: .equal,
                                                    toItem: self,
                                                    attribute: .bottom,
                                                    multiplier: 1,
                                                    constant: 1000)
            self.innerViewYPositionConstraint = hideConstraint
            self.addConstraint(hideConstraint)

        }
        
       
        
        //animation
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
            self.layoutIfNeeded()
        }) { (isCompleted) in
            self.removeFromSuperview()
            self.alpha = 0
        }
    }
    
    func showInnerViewAnimated(_ animated: Bool) {
        //remove current constraint
        self.removeInnerViewYPositionConstraint()
        
        let centerYConstraint = NSLayoutConstraint(item: self.popupInnerView,
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
            self.perform(#selector(self.dismiss), with: nil, afterDelay: 5.0)
        }
    }
    
    func removeInnerViewYPositionConstraint() {
        if innerViewYPositionConstraint != nil {
            self.removeConstraint(self.innerViewYPositionConstraint!)
            self.innerViewYPositionConstraint = nil
        }
    }

}
