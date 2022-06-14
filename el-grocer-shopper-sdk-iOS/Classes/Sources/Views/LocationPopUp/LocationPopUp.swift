//
//  LocationPopUp.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 19/03/2018.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit

protocol LocationPopUpProtocol : class {
    
    func enableLocationServices()
}


class LocationPopUp: UIView {
    
    //MARK: Outlets
    
    @IBOutlet var notificationImgView: UIImageView!
    
    @IBOutlet var bgView: UIView!
    @IBOutlet var popupInnerView: UIView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var doneButton: UIButton!
    
    weak var delegate:LocationPopUpProtocol?
    
    override func awakeFromNib() {
        
        self.addTapGesture()
        
        self.setButtonAppearance()
        self.setUpLabelAppearance()
        self.setInnerViewAppearence()
        self.setUpNotificationImageViewApperance()
    }
    
    // MARK: TAP Gesture
    
    private func addTapGesture() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapBlured))
        self.bgView.addGestureRecognizer(tapGesture)
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
        
        self.titleLabel.font = UIFont.SFProDisplayBoldFont(17.0)
        self.titleLabel.textColor = UIColor.black
        self.titleLabel.text = NSLocalizedString("location_services_title", comment: "")
        self.titleLabel.sizeToFit()
        self.titleLabel.numberOfLines = 1
        
        self.descriptionLabel.font = UIFont.SFProDisplaySemiBoldFont(15.0)
        self.descriptionLabel.textColor = UIColor.darkTextGrayColor()
        self.descriptionLabel.text = NSLocalizedString("location_services_message", comment: "")
        self.descriptionLabel.sizeToFit()
        self.descriptionLabel.numberOfLines = 3
    }
    
    private func setUpNotificationImageViewApperance(){
        
        self.notificationImgView.image = UIImage(named: "location-enable")
        self.notificationImgView.image = self.notificationImgView.image!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.notificationImgView.tintColor = UIColor.navigationBarColor()
    }
    
    private func setButtonAppearance(){
        
        self.doneButton.setBackgroundColor(UIColor.navigationBarColor(), forState: UIControl.State())
        self.doneButton.setTitle(NSLocalizedString("enable_location_services_title", comment: ""), for: UIControl.State())
        self.doneButton.setTitleColor(UIColor.white, for: UIControl.State())
        self.doneButton.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(15.0)
        
        self.cancelButton.setBackgroundColor(UIColor.lightGrayBGColor(), forState: UIControl.State())
        self.cancelButton.setTitle(NSLocalizedString("not_now_button_title", comment: ""), for: UIControl.State())
        self.cancelButton.setTitleColor(UIColor.gray, for: UIControl.State())
        self.cancelButton.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(15.0)
        
        if (UIScreen.main.bounds.size.height <= 568){
            self.doneButton.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(13.0)
            self.cancelButton.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(13.0)
        }
    }
    
    // MARK: ShowPopUp
    
    class func showLocationPopUp(_ delegate:LocationPopUpProtocol?, withView topView:UIView) -> LocationPopUp? {
        
        
        
        let view = Bundle(for: self).loadNibNamed("LocationPopUp", owner: nil, options: nil)![0] as! LocationPopUp
        view.delegate = delegate
        view.alpha = 0
        
        topView.addSubviewFullscreen(view)
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            view.alpha = 1
        })
        
        return view
    }
    
    //MARK: Button Actions
    
    @IBAction func enableNotificationHandler(_ sender: Any) {

        self.delegate?.enableLocationServices()
        self.tapBlured()
    }
    @IBAction func cancelNotificationHandler(_ sender: Any) {
        self.tapBlured()
    }
}
