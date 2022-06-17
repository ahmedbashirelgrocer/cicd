//
//  TobbacoPopup.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 14/01/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

let KtobbacoViewTag = -12001
class TobbacoPopup: UIView {
    var TobbacobuttonClickCallback:((_ buttonIndex:Int) -> Void)?
    @IBOutlet var srimView: UIView!
    @IBOutlet var imgPopUp: UIImageView!
    @IBOutlet var lblMessage: UILabel!
    @IBOutlet var btnFirstIndex: UIButton!
    @IBOutlet var btnSecondIndex: UIButton!
    
    
    
    override func awakeFromNib() {
        self.addTapGesture()
    }
    
    // MARK: TAP Gesture
    
    private func addTapGesture() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapBlured))
        self.srimView.addGestureRecognizer(tapGesture)
    }
    
    //MARK: Remove PopUp
    @objc func tapBlured() {
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            self.alpha = 0
            
        }, completion: { (result:Bool) -> Void in
            
            self.removeFromSuperview()
        })
    }
    
    
  
    @IBAction func firstIndexHandler(_ sender: Any) {
        self.TobbacobuttonClickCallback?(0)
        self.tapBlured()
    }
    @IBAction func secondIndexHandler(_ sender: Any) {
        self.TobbacobuttonClickCallback?(1)
        self.tapBlured()
    }
    class func showNotificationPopup(topView:UIView , msg : String , buttonOneText : String = "" , buttonTwoText : String = "") -> TobbacoPopup{
        
        
        let view = Bundle.resource.loadNibNamed("TobbacoPopup", owner: nil, options: nil)![0] as! TobbacoPopup
        view.lblMessage.text = msg
        view.tag = KtobbacoViewTag
        view.alpha = 0
        topView.addSubviewFullscreen(view)
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            view.alpha = 1
        })
        view.btnFirstIndex.setTitle(buttonOneText, for: .normal)
        view.btnSecondIndex.setTitle(buttonTwoText, for: .normal)
       
        return view
    }
    
}
