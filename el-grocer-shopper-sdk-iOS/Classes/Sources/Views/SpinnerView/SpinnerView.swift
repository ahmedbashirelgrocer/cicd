//
//  SpinnerView.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 13.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

let kSpinnerViewTag = 12345

class SpinnerView : UIView {
    
    @IBOutlet weak var blurredBackground: UIImageView!
    @IBOutlet weak var activityIndicatorImageView: ElGrocerActivityIndicatorView!
    @IBOutlet weak var activityContainerView: UIView!
    
    
    // MARK: Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.activityContainerView.layer.cornerRadius = activityContainerView.bounds.size.width / 2.0
        //self.activityContainerView.layer.cornerRadius = activityContainerView.frame.size.width / 2.0
        self.activityIndicatorImageView.startAnimating()
        
    }
    
    // MARK: Show / hide
    class func showSpinnerViewOutBlurEffect(_ view : UIView) -> Bool {
        
        if UIApplication.shared.keyWindow?.viewWithTag(kSpinnerViewTag) == nil && ReachabilityManager.sharedInstance.isNetworkAvailable(false) {
            
            let spinnerView = Bundle.resource.loadNibNamed("SpinnerView", owner: nil, options: nil)![0] as! SpinnerView
            spinnerView.frame = UIScreen.main.bounds
            spinnerView.tag = kSpinnerViewTag
            spinnerView.alpha = 0.9
            
            //add blur background
            //let SDKManager = SDKManager.shared
           // let topView = SDKManager.window!.rootViewController!.view
           // spinnerView.blurredBackground.image = view.createBlurredSnapShot()
            
            UIApplication.shared.keyWindow?.addSubview(spinnerView)
            
            UIView.animate(withDuration: 0.33, animations: { () -> Void in
                
                spinnerView.alpha = 1
            })
            
            return true
        }
        
        return false
    }
    
    class func showSpinnerView() -> Bool {
        
        if UIApplication.shared.keyWindow?.viewWithTag(kSpinnerViewTag) == nil && ReachabilityManager.sharedInstance.isNetworkAvailable(false) {
            
            let spinnerView = Bundle.resource.loadNibNamed("SpinnerView", owner: nil, options: nil)![0] as! SpinnerView
            spinnerView.frame = UIScreen.main.bounds
            spinnerView.tag = kSpinnerViewTag
            spinnerView.alpha = 0
            
            //add blur background
            let SDKManager = SDKManager.shared
            let topView = SDKManager.rootViewController!.view
            spinnerView.blurredBackground.image = topView?.createBlurredSnapShot()
            
            UIApplication.shared.keyWindow?.addSubview(spinnerView)
            
            UIView.animate(withDuration: 0.33, animations: { () -> Void in
                
                spinnerView.alpha = 1
            })
            
            return true
        }
        
        return false
    }
    
    class func showSpinnerViewInView(_ view:UIView) -> SpinnerView? {
        
        guard DispatchQueue.isRunningOnMainQueue else {
           return nil
        }
        
        if UIApplication.shared.keyWindow?.viewWithTag(kSpinnerViewTag) == nil {
            
            let spinnerView = Bundle.resource.loadNibNamed("SpinnerView", owner: nil, options: nil)![0] as! SpinnerView
            spinnerView.frame = view.bounds
            spinnerView.tag = kSpinnerViewTag
            spinnerView.alpha = 0
            
            //add blur background
            //spinnerView.blurredBackground.image = view.createBlurredSnapShot()
            
            view.addSubview(spinnerView)
            
            UIView.animate(withDuration: 0.33, animations: { () -> Void in
                
                spinnerView.alpha = 1
            })
            
            view.bringSubviewToFront(spinnerView)
            return spinnerView
        }
        
        return nil
    }
    
    class func hideSpinnerView() {
        
        if DispatchQueue.isRunningOnMainQueue {
            
            if let spinnerView = UIApplication.shared.keyWindow?.viewWithTag(kSpinnerViewTag) as? SpinnerView {
                spinnerView.removeFromSuperview()
                self.hideSpinnerView()
            } else {
                return
            }
            
        }else{
            
            DispatchQueue.main.async {
                SpinnerView.hideSpinnerView()
            }
            
        }
        
        
    }

}
