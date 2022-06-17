//
//  LoadingBarView.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 17.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

let kLoadingBarViewHeight: CGFloat = 12
let kLoadingBarAnimationKey = "LoadingBarAnimation"

class LoadingBarView : UIView {
    
    var animation:CABasicAnimation!
    var patternImage:UIImage!
    var patternLayer:CALayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        createPatternLayer()
        createPatternAnimation()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.patternLayer.frame = CGRect(x: -self.patternImage.size.width / 2, y: 0, width: self.frame.size.width + 2 * self.patternImage.size.width / 2, height: self.frame.size.height);
    }
    
    // MARK: SetUp
    
    fileprivate func createPatternLayer() {
        
        self.patternImage = UIImage(name: "loader")!
        
        if #available(iOS 13.0, *) {
            self.patternImage = self.patternImage.withTintColor(UIColor.navigationBarColor())
        } else {
            // Fallback on earlier versions
        }
        let patternColor = UIColor(patternImage: self.patternImage)
        
        self.patternLayer = CALayer()
        self.patternLayer.backgroundColor = patternColor.cgColor
        self.patternLayer.transform = CATransform3DMakeScale(1, -1, 1)
        self.patternLayer.anchorPoint = CGPoint(x: 0, y: 1)
        
        self.layer.addSublayer(self.patternLayer)
    }
    
    fileprivate func createPatternAnimation() {
        
        self.animation = CABasicAnimation(keyPath: "position")
        self.animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.animation.fromValue = NSValue(cgPoint: CGPoint(x: -self.patternImage.size.width, y: 0))
        self.animation.toValue = NSValue(cgPoint: CGPoint.zero)
        self.animation.repeatCount = Float(CGFloat.greatestFiniteMagnitude)
        self.animation.duration = 1.4
    }
    
    // MARK: Animations
    
    func startAnimation() {
        
        self.patternLayer.add(self.animation, forKey: kLoadingBarAnimationKey)
    }
    
    func stopAnimation() {
        
        self.patternLayer.removeAnimation(forKey: kLoadingBarAnimationKey)
    }
}
