//
//  UIButton+EnableWithAnimation.swift
//  ElGrocerShopper
//
//  Created by PiotrGorzelanyMac on 02/02/16.
//  Copyright © 2016 RST IT. All rights reserved.
//

extension UIButton {
    
    /** Enables or disables button with animation */
    func enableWithAnimation(_ enabled: Bool, animationDuration duration: TimeInterval = 0.33) {
        
        self.isEnabled = enabled
        self.alpha = enabled ? 1 : 1.0
        self.isUserInteractionEnabled = enabled
        if enabled {
            self.setBackgroundColor(ApplicationTheme.currentTheme.buttonEnableBGColor, forState: self.state)
        }else{
            self.setBackgroundColor(ApplicationTheme.currentTheme.buttonDisableBGColor , forState: self.state)
        }
        
        
//        UIView.animate(withDuration: duration, animations: { () -> Void in
//            self.alpha = enabled ? 1 : 0.3
//        })
        
      
    }
    
    func setBackgroundColor(_ color: UIColor, forState: UIControl.State) {
        
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(colorImage, for: forState)
    }
    
    
    func setBackgroundColorForAllState(_ color: UIColor) {
        
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        self.setBackgroundImage(colorImage, for: UIControl.State.normal)
        self.setBackgroundImage(colorImage, for: UIControl.State.disabled)
        self.setBackgroundImage(colorImage, for: UIControl.State.highlighted)
        self.setBackgroundImage(colorImage, for: UIControl.State.disabled)
    }
    
}
