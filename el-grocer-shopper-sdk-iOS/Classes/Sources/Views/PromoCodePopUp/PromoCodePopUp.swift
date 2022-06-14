//
//  PromoCodePopUp.swift
//  ElGrocerShopper
//
//  Created by Abubaker on 24/01/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import UIKit

protocol PromoCodePopUpViewProtocol : class {
    func promoCodeViewDidSaveCode(_ promoCodePopUp: PromoCodePopUp? , code:String) -> Void
}

class PromoCodePopUp: UIView,UITextFieldDelegate {

    //MARK: Outlets
    @IBOutlet var imgBlured: UIImageView!
    
    @IBOutlet var txtPromoCode: UITextField!
    @IBOutlet var viewPromoPopUp: UIView!
    @IBOutlet var btnSave: UIButton!
    @IBOutlet var promoTitle: UILabel!
    
    weak var delegate:PromoCodePopUpViewProtocol?
    
    @IBOutlet var popTopConstraint: NSLayoutConstraint!
    
    // MARK: Life cycle
    override func awakeFromNib() {
        
        addTapGesture()
        setButtonAppearance()
        NotificationCenter.default.addObserver(self, selector: #selector(self
            .keyboardWillShow(_:)), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        self.txtPromoCode.delegate = self
        
        self.promoTitle.text = NSLocalizedString("promo_code_title", comment: "")
        self.txtPromoCode.placeholder = NSLocalizedString("enter_promo_code", comment: "")
    }
    
    fileprivate func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapBlured))
        self.imgBlured.addGestureRecognizer(tapGesture)
    }
    
    // MARK: Show view
    
    class func showPromoCodePopUp(_ delegate:PromoCodePopUpViewProtocol?, topView:UIView) -> PromoCodePopUp {
        
        let view = Bundle(for: self).loadNibNamed("PromoCodePopUp", owner: nil, options: nil)![0] as! PromoCodePopUp
        view.delegate = delegate
        view.imgBlured.image = topView.createBlurredSnapShot()
        view.alpha = 0
        
        topView.addSubviewFullscreen(view)
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            view.alpha = 1
            
        }, completion: { (result:Bool) -> Void in
            
        }) 
        return view
        
    }
    
    // MARK: Appearance
    
    fileprivate func setButtonAppearance(){
        self.btnSave.layer.cornerRadius = 5
        self.btnSave.setTitle(NSLocalizedString("save_button_title", comment: ""), for: UIControl.State())
    }
    
    //MARK: Remove PopUp
    @objc func tapBlured() {
        
        //UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            self.alpha = 0
            
        }, completion: { (result:Bool) -> Void in
            
            self.removeFromSuperview()
        }) 
    }
    
    
    //MARK: Actions
    
    @IBAction func btnCloseAction(_ sender: AnyObject) {
        tapBlured()
    }
    
    @IBAction func btnSaveAction(_ sender: AnyObject) {
        self.delegate?.promoCodeViewDidSaveCode(self, code: self.txtPromoCode.text!)
        tapBlured()
    }
    
    //MARK: Key Board
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        UIView.animate(withDuration: 0.5, delay:0.0, options:UIView.AnimationOptions.transitionFlipFromTop, animations: {
            self.popTopConstraint.constant = self.frame.height - self.viewPromoPopUp.frame.height - keyboardHeight - 10
            }, completion: { finished in
        })
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        UIView.animate(withDuration: 0.5, delay:0.0, options:UIView.AnimationOptions.transitionFlipFromTop, animations: {
            self.popTopConstraint.constant = 180
            }, completion: { finished in
        })
    }
    
    //MARK: TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.txtPromoCode.resignFirstResponder()
        return true
    }
}
