//
//  ElGrocerActivityIndicatorView.swift
//  ElGrocerShopper
//
//  Created by PiotrGorzelanyMac on 10/02/16.
//  Copyright © 2016 RST IT. All rights reserved.
//

import UIKit

class ElGrocerActivityIndicatorView: UIImageView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if sdkManager.isShopperApp {
            self.animationImages = [
                UIImage(name: "elgrocer-activity-indicator-1")!,
                UIImage(name: "elgrocer-activity-indicator-2")!,
                UIImage(name: "elgrocer-activity-indicator-3")!,
                UIImage(name: "elgrocer-activity-indicator-4")!,
                UIImage(name: "elgrocer-activity-indicator-5")!,
                UIImage(name: "elgrocer-activity-indicator-6")!,
                UIImage(name: "elgrocer-activity-indicator-7")!,
            ]
        } else {
            self.animationImages = [
                UIImage(name: "smile-activity-indicator-1")!,
                UIImage(name: "smile-activity-indicator-2")!,
                UIImage(name: "smile-activity-indicator-3")!,
                UIImage(name: "smile-activity-indicator-4")!,
                UIImage(name: "smile-activity-indicator-5")!,
                UIImage(name: "smile-activity-indicator-6")!,
                UIImage(name: "smile-activity-indicator-7")!,
            ]
        }
        
        
        self.animationDuration = 1.5
        self.animationRepeatCount = 0
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.size.width / 2.0
    }

}


class ElGrocerLogoIndicatorView: UIImageView , CAAnimationDelegate {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        var imageA = [UIImage]()
        for index in 1...121 { // length is important
            let imageName = "ElgrocerLogoAnimation-" + "\(index)"
            if let imageNew = UIImage(name: imageName) {
                imageA.append(imageNew)
            }
            
        }
        self.animationImages = imageA
        self.animationDuration = 3.5
        self.animationRepeatCount = 1
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //self.layer.cornerRadius = self.bounds.size.width / 2.0
    }
    
    var completion: ((_ completed: Bool) -> Void)?
    
    func startAnimate(completion: ((_ completed: Bool) -> Void)?) {
        self.completion = completion
        if let animationImages = animationImages {
            
            DispatchQueue.main.async {
                let cgImages = animationImages.map({ $0.cgImage as AnyObject })
                let animation = CAKeyframeAnimation(keyPath: "contents")
                animation.values = cgImages
                animation.repeatCount = Float(self.animationRepeatCount)
                animation.duration = self.animationDuration
                animation.delegate = self
                
                self.layer.add(animation, forKey: nil)
            }
            
        } else {
            self.completion?(false)
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        completion?(flag)
    }
    
}
