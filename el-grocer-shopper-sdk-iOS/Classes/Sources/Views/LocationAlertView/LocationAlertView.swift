//
//  LocationAlertView.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 21/12/2016.
//  Copyright © 2016 RST IT. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

protocol LocationAlertViewProtocol : class {
    func customLocationAlertViewButtonDidTouch(_ shoppingBasketView:LocationAlertView, isAllow:Bool) -> Void
}

class LocationAlertView: UIView {

    //MARK: Outlets
    @IBOutlet weak var imgBG: UIImageView!
    //@IBOutlet weak var viewAlert: UIView!
    
    //MARK: Delegate
    weak var delegate:LocationAlertViewProtocol?
    
    //MARK: Properties
    
    //MARK: Actions
    @IBAction func btnDontAllowTapAction(_ sender: AnyObject) {
        self.delegate?.customLocationAlertViewButtonDidTouch(self, isAllow: false)
        self.hideAlertView()
    }
    
    @IBAction func btnAllowTapAction(_ sender: AnyObject) {
        self.delegate?.customLocationAlertViewButtonDidTouch(self, isAllow: true)
        self.hideAlertView()
    }
    
    
    // MARK: Show view
    class func showLocationAlert(_ delegate:LocationAlertViewProtocol?) -> LocationAlertView {
        let SDKManager = SDKManager.shared
        let topView = SDKManager.rootViewController!.view
        
        let view = Bundle.resource.loadNibNamed("LocationAlertView", owner: nil, options: nil)![0] as! LocationAlertView
        
        view.imgBG.image = topView?.createBlurredSnapShot()
        view.delegate = delegate
        
        topView?.addSubviewFullscreen(view)
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            view.alpha = 1
            
        }, completion: { (result:Bool) -> Void in
            
            
            //UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
        }) 
        
        return view
        
    }
    
    // MARK: Hide view
    
    @objc func hideAlertView() {
        
        //UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            self.alpha = 0
            
        }, completion: { (result:Bool) -> Void in
            
            self.removeFromSuperview()
        }) 
    }
    
    // MARK: Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addTapGesture()
        setUpAppearance()
    }
    
    fileprivate func addTapGesture() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LocationAlertView.hideAlertView))
        self.imgBG.addGestureRecognizer(tapGesture)
    }
    
    // MARK: Appearance
    
    fileprivate func setUpAppearance() {
        
        /*self.viewAlert.layer.cornerRadius = 12
        self.viewAlert.layer.shadowOffset = CGSizeMake(0.75, 0.75)
        self.viewAlert.layer.shadowRadius = 1
        self.viewAlert.layer.shadowOpacity = 0.3*/
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
