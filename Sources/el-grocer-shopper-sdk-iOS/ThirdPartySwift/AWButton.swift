//
//  AWButton.swift
//  ElGrocerShopper
//
//  Created by Azeem Akram on 06/11/2017.
//  Copyright © 2017 elGrocer. All rights reserved.
//

import UIKit

@IBDesignable class AWButton: UIButton {

    @IBInspectable var cornarRadius:CGFloat = 0.0 {
        
        didSet {
            layer.cornerRadius = cornarRadius
        }
        
    }
    
    @IBInspectable var borderWidth:CGFloat = 0.0 {
        
        didSet {
            layer.borderWidth = borderWidth
            layer.borderColor = borderColor.cgColor
        }
        
    }
    
    @IBInspectable var borderColor:UIColor = UIColor.lightGray {
        
        didSet {
            layer.borderColor = borderColor.cgColor
            if borderWidth == 0 {borderWidth = 1.0}
        }
    }
    
    @IBInspectable var shadowColor: UIColor = UIColor.clear {
        
        didSet {
            layer.shouldRasterize = true
            layer.rasterizationScale = UIScreen.main.scale
            layer.shadowColor = shadowColor.cgColor
        }
    }
    
    @IBInspectable var shadowOffset: CGSize = CGSize.zero {
        
        didSet {
            layer.shouldRasterize = true
            layer.rasterizationScale = UIScreen.main.scale
            layer.shadowOffset = shadowOffset
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0.5 {
        
        didSet {
            layer.shouldRasterize = true
            layer.rasterizationScale = UIScreen.main.scale
            layer.shadowOpacity = shadowOpacity
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 5.0 {
        
        didSet {
            layer.shouldRasterize = true
            layer.rasterizationScale = UIScreen.main.scale
            layer.shadowRadius = shadowRadius
        }
    }
    
    
    // MARK: Setting button Title Appearance
    
    @IBInspectable var titleShadowColor: UIColor = UIColor.clear {
        
        didSet {
//            self.titleLabel?.shadowColor = titleShadowColor
            self.titleLabel?.layer.shadowColor = titleShadowColor.cgColor
        }
    }
    
    @IBInspectable var titleLabelShadowOffset: CGSize = CGSize.zero {
        
        didSet {
//            self.titleLabel?.shadowOffset = titleShadowOffset
            self.titleLabel?.layer.shadowOffset = titleLabelShadowOffset
        }
    }
    
    @IBInspectable var titleShadowOpacity: Float = 0.5 {
        
        didSet {
            
            self.titleLabel?.layer.shadowOpacity = titleShadowOpacity
        }
    }
    
    @IBInspectable var titleShadowRadius: CGFloat = 5.0 {
        
        didSet {
            self.titleLabel?.layer.shadowRadius = titleShadowRadius
        }
    }
    
    
    
    private var originalButtonText: String?
    var activityIndicator: UIActivityIndicatorView!
    
    func showLoading() {
        originalButtonText = self.titleLabel?.text
        self.setTitle("", for: .normal)
        
        if (activityIndicator == nil) {
            activityIndicator = createActivityIndicator()
        }
        
        showSpinning()
    }
    
    func hideLoading() {
        self.setTitle(originalButtonText, for: .normal)
        activityIndicator.stopAnimating()
        self.isUserInteractionEnabled = true
    }
    
    private func createActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        return activityIndicator
    }
    
    private func showSpinning() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator)
        centerActivityIndicatorInButton()
        activityIndicator.startAnimating()
        self.isUserInteractionEnabled = false
    }
    
    private func centerActivityIndicatorInButton() {
        let xCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraint(xCenterConstraint)
        
        let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
        self.addConstraint(yCenterConstraint)
    }
    
    
    
    

}
