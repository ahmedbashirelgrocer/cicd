//
//  ElgrocerPopup.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 19/12/2017.
//  Copyright © 2017 elGrocer. All rights reserved.
//

import UIKit
import KLCPopup

class ElgrocerPopup: UIView {
    
    //MARK: Outlets
    @IBOutlet var popupInnerView: UIView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    @IBOutlet weak var viewYPosition: NSLayoutConstraint!
    
    var innerViewYPositionConstraint: NSLayoutConstraint?
    
    // MARK: Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpContainerViewAppearance()
        setUpTitleLabelAppearance()
        setUpDescriptionLabelAppearance()
        
        self.addTapGesture()
        
        self.viewYPosition.constant = -1000
        self.layoutIfNeeded()
    }
    
    
    // MARK: Appearance
    
    private func setUpContainerViewAppearance() {
        
        self.popupInnerView.layer.cornerRadius = 5
    }
    
    private func setUpTitleLabelAppearance() {
        
        self.titleLabel.textColor = UIColor.black
    }
    
    private func setUpDescriptionLabelAppearance() {
        
        self.descriptionLabel.textColor = UIColor.black
    }
    
    // MARK: Instance
    
    class func createAlert(_ title:String, description:String?) -> ElgrocerPopup {
        
        let elGrocerPopup = Bundle(for: self).loadNibNamed("ElgrocerPopup", owner: nil, options: nil)![0] as! ElgrocerPopup
        elGrocerPopup.setDataInView(title, description: description)
        
        return elGrocerPopup
    }
    
    // MARK: Data
    
    private func setDataInView(_ title:String, description:String?) {
        
        self.titleLabel.numberOfLines = 0
        self.titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.titleLabel.font = UIFont.SFProDisplaySemiBoldFont(19.0)
        self.titleLabel.text = title
        self.titleLabel.sizeToFit()
        
        self.descriptionLabel.numberOfLines = 0
        self.descriptionLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.descriptionLabel.font = UIFont.SFProDisplayNormalFont(17.0)
        self.descriptionLabel.text = description
        self.descriptionLabel.sizeToFit()
    }
    
    fileprivate func addTapGesture() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismiss))
        self.addGestureRecognizer(tapGesture)
    }
    // MARK: DismissPopUp
    @objc func dismiss() {
        
        /*UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions(rawValue: UIView.AnimationOptions.RawValue(kAnimationOptionCurveIOS7)), animations: {
            print("View Center Y Point:%f",self.center.y)
            self.centerYConstraint.constant = 1000
            self.layoutIfNeeded()
        }) { (isAnimation) in
            print("Animation is Done")
            self.removeFromSuperview()
            self.alpha = 0
        }*/
        
        self.hideInnerViewAnimated(true)
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
        
        
        
        /*UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions(rawValue: UIView.AnimationOptions.RawValue(kAnimationOptionCurveIOS7)), animations: {
            print("View Center Y Point:%f",self.center.y)
             self.popupInnerView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            self.layoutIfNeeded()
        }) { (isAnimation) in
            print("Animation is Done")
        }*/
    }
    
    func hideInnerViewAnimated(_ animated: Bool) {
        //remove current constraint
        self.removeInnerViewYPositionConstraint()
        
        guard let popUpView = self.popupInnerView else {return}
        
        let hideConstraint = NSLayoutConstraint(item: popUpView ,
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
    
    func showInnerViewAnimated(_ animated: Bool) {
        //remove current constraint
        self.removeInnerViewYPositionConstraint()
        
         guard let popUpView = self.popupInnerView else {return}
        
        let centerYConstraint = NSLayoutConstraint(item: popUpView  ,
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
