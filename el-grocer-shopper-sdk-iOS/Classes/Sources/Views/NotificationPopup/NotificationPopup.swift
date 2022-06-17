//
//  NotificationPopup.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 27/11/2017.
//  Copyright © 2017 elGrocer. All rights reserved.
//

import UIKit

protocol NotificationPopupProtocol : class {
    
    func enableUserPushNotification()
}


class NotificationPopup: UIView {
      fileprivate var buttonClickCallback:((_ buttonIndex:Int) -> Void)?
    
    
    @IBOutlet var rightButtonWidth: NSLayoutConstraint!
    @IBOutlet var decrLableDistance: NSLayoutConstraint!
    @IBOutlet var heightConstraints: NSLayoutConstraint!
    @IBOutlet var topImageViewHeight: NSLayoutConstraint!
    //MARK: Outlets
    @IBOutlet var starsImgView: UIImageView!
    @IBOutlet var notificationImgView: UIImageView!
    
    @IBOutlet var bgView: UIView!
    @IBOutlet var popupInnerView: UIView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var doneButton: UIButton!
    
    @IBOutlet var btnCenterViewConstraint: NSLayoutConstraint!
    @IBOutlet var btnCenterView: UIView!
    
    weak var delegate:NotificationPopupProtocol?
    
    override func awakeFromNib() {
        
        self.addTapGesture()
        self.setButtonAppearance()
        self.setUpLabelAppearance()
        self.setInnerViewAppearence()
        self.setUpNotificationImageViewApperance()
        self.newCustimzation()
    }
    
    // MARK: TAP Gesture
    
    private func addTapGesture() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapBlured))
        self.bgView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: Button Hide Show
    
    private func showSingleButton (isSingle single : Bool) {
        self.btnCenterView.isHidden = single
        self.btnCenterViewConstraint.setMultiplier(multiplier: single ? 0.01 : 1)
        self.layoutIfNeeded()
    }
    
    //MARK: Remove PopUp
    @objc func tapBlured() {
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            self.alpha = 0
            
        }, completion: { (result:Bool) -> Void in
            
            self.removeFromSuperview()
        })
    }
    
    // MARK: Appearance
    
    private func setInnerViewAppearence(){
        
        self.popupInnerView.layer.cornerRadius = 7.0
        self.popupInnerView.layer.masksToBounds = true
    }
    
    private func setUpLabelAppearance(){
        
        self.titleLabel.font = UIFont.SFProDisplaySemiBoldFont(17.0)
        self.titleLabel.textColor = UIColor.black
        self.titleLabel.text = NSLocalizedString("stay_updated_title", comment: "")
        self.titleLabel.sizeToFit()
        self.titleLabel.numberOfLines = 1
        
        self.descriptionLabel.font = UIFont.SFProDisplaySemiBoldFont(14.0)
        self.descriptionLabel.textColor = UIColor.darkTextGrayColor()
        self.descriptionLabel.text = NSLocalizedString("enable_notifications_message", comment: "")
        self.descriptionLabel.sizeToFit()
        self.descriptionLabel.numberOfLines = 3
    }
    
    private func setUpNotificationImageViewApperance(){
        
        self.starsImgView.image = UIImage(name: "Stars-Icon")
        self.starsImgView.image = self.starsImgView.image!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.starsImgView.tintColor = UIColor.navigationBarColor()
        
        self.notificationImgView.image = UIImage(name: "Bell-Icon")
        self.notificationImgView.image = self.notificationImgView.image!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.notificationImgView.tintColor = UIColor.navigationBarColor()
    }
    
    private func setButtonAppearance(){
        
        
        
        
        
        
        
        
        self.doneButton.setBackgroundColor(UIColor.navigationBarColor(), forState: UIControl.State())
        self.doneButton.setTitle(NSLocalizedString("enable_notifications_button_title", comment: ""), for: UIControl.State())
        self.doneButton.setTitleColor(UIColor.white, for: UIControl.State())
        self.doneButton.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(15.0)
        
        self.cancelButton.setBackgroundColor(UIColor.lightGrayBGColor(), forState: UIControl.State())
        self.cancelButton.setTitle(NSLocalizedString("not_now_button_title", comment: ""), for: UIControl.State())
        self.cancelButton.setTitleColor(UIColor.gray, for: UIControl.State())
        self.cancelButton.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(15.0)
    }
    
    
    func newCustimzation() {
        
        self.cancelButton.setBackgroundColor(.white, forState: .normal)
        self.doneButton.setBackgroundColor(.white, forState: .normal)
        
        
        self.cancelButton.titleLabel?.font = .SFProDisplayBoldFont(16)
        self.cancelButton.titleLabel?.textColor = .colorWithHexString(hexString: "333333")
        self.cancelButton.setTitleColor(.colorWithHexString(hexString: "333333") , for: UIControl.State())
        
        
        self.doneButton.titleLabel?.font = .SFProDisplayBoldFont(16)
        self.doneButton.titleLabel?.textColor = .buttonSelectionColor()
        self.doneButton.setTitleColor(.buttonSelectionColor(), for: UIControl.State())
        
        
        self.descriptionLabel.textColor = .colorWithHexString(hexString: "333333")
        self.descriptionLabel.font = .SFProDisplayBoldFont(16)
        
        
    }
    
    // MARK: ShowPopUp
    
    class func showNotificationPopup(_ delegate:NotificationPopupProtocol?, withView topView:UIView) -> NotificationPopup? {
        
//        if Platform.isSimulator {
//            return nil
//        }
        let view = Bundle(for: self).loadNibNamed("NotificationPopup", owner: nil, options: nil)![0] as! NotificationPopup
        view.delegate = delegate
        view.alpha = 0
        view.topImageViewHeight.constant = 0
        topView.addSubviewFullscreen(view)
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            view.alpha = 1
        })
        
        return view
    }
    
    
    class func showNotificationPopupWithImage( image : UIImage? , header : String , detail : String , _ leftTitle : String = "No" , _ RightTitle : String = "YES" , withView topView:UIView , _ isBothButtonBlack : Bool = false , _ isSingleButton : Bool = false , buttonClickCallback:((_ buttonIndex:Int) -> Void)?) -> NotificationPopup? {
        
        let view = Bundle(for: self).loadNibNamed("NotificationPopup", owner: nil, options: nil)![0] as! NotificationPopup
        if let imag = image {
            view.notificationImgView.image = imag
        }
        
        DispatchQueue.main.async {
            if let image = view.notificationImgView.image?.withRenderingMode(.alwaysTemplate) {
                view.notificationImgView.image = image
                view.notificationImgView.tintColor = .navigationBarColor()
            }
        }
        
        view.buttonClickCallback = buttonClickCallback
        view.topImageViewHeight.constant = 0
        view.titleLabel.text = header
        view.descriptionLabel.text = detail
        
        view.cancelButton.setTitle(leftTitle, for: UIControl.State())
        view.doneButton.setTitle(RightTitle, for: UIControl.State())
        
        view.cancelButton.setBackgroundColor(.white, forState: .normal)
        view.doneButton.setBackgroundColor(.white, forState: .normal)
        
        
        view.cancelButton.titleLabel?.font = .SFProDisplayBoldFont(16)
        view.cancelButton.titleLabel?.textColor = .newBlackColor()
        view.cancelButton.setTitleColor(.newBlackColor() , for: UIControl.State())
        
        
        view.doneButton.titleLabel?.font = .SFProDisplayBoldFont(16)
        view.doneButton.titleLabel?.textColor = .buttonSelectionColor()
        if isBothButtonBlack {
            view.doneButton.setTitleColor(.newBlackColor(), for: UIControl.State())
        }else{
            view.doneButton.setTitleColor(.newBlackColor(), for: UIControl.State())
           
        }
      
        view.descriptionLabel.textColor = .colorWithHexString(hexString: "333333")
        view.descriptionLabel.font = .SFProDisplayNormalFont(16)
        view.descriptionLabel.numberOfLines = 0
        
        
        view.titleLabel.font = .SFProDisplayBoldFont(17)
        
        if detail == NSLocalizedString("order_history_cancel_alert_message", comment: "") {
            view.descriptionLabel.font = .SFProDisplayBoldFont(16)
        }
      
        view.decrLableDistance.constant = header.count > 0 ? 10 : 0
   
        
        view.alpha = 0
        topView.addSubviewFullscreen(view)
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            view.alpha = 1
        })
        
        if detail.count > 0 {
            
            let titleHeight = view.descriptionLabel.font.sizeOfString(view.descriptionLabel.text!, constrainedToWidth: Double(view.popupInnerView.frame.size.width)).height
            var currentHeight =  titleHeight //detail.height(withConstrainedWidth: view.popupInnerView.frame.size.width, font: .SFUISemiBoldFont(16))
            currentHeight += 20
            if let imag = image {
                currentHeight += imag.size.height
            }
            currentHeight += 60 // button height
            if header.count > 0 {
                currentHeight += 40
            }
            view.heightConstraints.constant = currentHeight
        }
        
        if isSingleButton {
            view.doneButton.setTitleColor(.navigationBarColor(), for: UIControl.State())
            view.showSingleButton(isSingle: isSingleButton)
        }
        
        view.layoutIfNeeded()
        view.setNeedsLayout()
        return view
    }
    
    
    
    
    
    
    //MARK: Button Actions
    
    @IBAction func enableNotificationHandler(_ sender: Any) {
        FireBaseEventsLogger.trackNotificationEnableClicked()
        self.delegate?.enableUserPushNotification()
        self.tapBlured()
        self.buttonClickCallback?(1)
        
    }
    @IBAction func cancelNotificationHandler(_ sender: Any) {
        FireBaseEventsLogger.trackNotificationLaterClicked()
        self.tapBlured()
        self.buttonClickCallback?(0)
    }
}
extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading] , attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}
