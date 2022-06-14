//
//  ReviewPopUp.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 2/14/18.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit

class ReviewPopUp: UIView {
    
    //MARK: Outlets
    @IBOutlet var popupInnerView: UIView!
    
    @IBOutlet var titleLabel: UILabel!{
        didSet{
            titleLabel.setH4SemiBoldStyle()
        }
    }
    @IBOutlet var descriptionLabel: UILabel!{
        didSet{
            descriptionLabel.setBody2RegDarkStyle()
        }
    }
    
    @IBOutlet weak var viewYPosition: NSLayoutConstraint!
    @IBOutlet var doneButton: UIButton! {
        didSet{
            doneButton.setTitle(NSLocalizedString("delivery_note_done_button_title", comment: ""), for: UIControl.State())
            doneButton.setButton2SemiBoldDarkStyle()
        }
    }
    
    var innerViewYPositionConstraint: NSLayoutConstraint?
    var onDoneBlock : ((Bool) -> Void)?
    
    override func awakeFromNib() {
        
        self.setUpLabelAppearance()
        self.setInnerViewAppearence()
        
        self.viewYPosition.constant = -1000
        self.layoutIfNeeded()
    }
    
    // MARK: Appearance
    private func setInnerViewAppearence(){
        self.popupInnerView.layer.cornerRadius = 7.0
    }
    
    private func setUpLabelAppearance(){
        
        self.titleLabel.setH4SemiBoldStyle()
        self.titleLabel.text = NSLocalizedString("feedback_thanks_title", comment: "")
        self.titleLabel.sizeToFit()
        self.titleLabel.numberOfLines = 1
        
        self.descriptionLabel.setBody2RegDarkStyle()
        self.descriptionLabel.text = NSLocalizedString("feedback_thanks_message", comment: "")
        self.descriptionLabel.sizeToFit()
        self.descriptionLabel.numberOfLines = 3
    }
    
    
    // MARK: CreatePopUp
    
    class func createReviewPopUp() -> ReviewPopUp {
        
        let view = Bundle(for: self).loadNibNamed("ReviewPopUp", owner: nil, options: nil)![0] as! ReviewPopUp
        return view
    }
    
    // MARK: DismissPopUp
    @objc func dismiss() {
        self.hideInnerViewAnimated(true)
    }
    
    func dissmissPopup(completion: @escaping () -> Void){
        self.hideInnerViewAnimated(true)
        completion()
    }
    
    @IBAction func doneButtonHandler(_ sender: Any) {
        
        self.dissmissPopup {}
        self.onDoneBlock!(true)
 
    }
    // MARK: ShowPopUp
    
    func showPopUp() {
        
         DispatchQueue.main.async {
        self.frame = UIScreen.main.bounds
        UIApplication.shared.keyWindow?.addSubview(self)
        
        self.showInnerViewAnimated(true)
        }
    }
    
    func hideInnerViewAnimated(_ animated: Bool) {
        //remove current constraint
        self.removeInnerViewYPositionConstraint()
        
        if let popInerView = self.popupInnerView {
            
            let hideConstraint = NSLayoutConstraint(item: popInerView ,
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
        
        if let popInerView = self.popupInnerView {
        
            let centerYConstraint = NSLayoutConstraint(item: popInerView ,
                                                       attribute: .centerY,
                                                       relatedBy: .equal,
                                                       toItem: self,
                                                       attribute: .centerY,
                                                       multiplier: 1,
                                                       constant: 0)
            self.innerViewYPositionConstraint = centerYConstraint
            self.addConstraint(centerYConstraint)
            
            
        }
        
     
        
        //animation
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping:0.8, initialSpringVelocity: 0.8, options: .curveEaseIn, animations: {
            self.layoutIfNeeded()
        }) { (isCompleted) in
            //self.perform(#selector(self.dismiss), with: nil, afterDelay: 3.0)
        }
    }
    
    func removeInnerViewYPositionConstraint() {
        if innerViewYPositionConstraint != nil {
            self.removeConstraint(self.innerViewYPositionConstraint!)
            self.innerViewYPositionConstraint = nil
        }
    }
}
