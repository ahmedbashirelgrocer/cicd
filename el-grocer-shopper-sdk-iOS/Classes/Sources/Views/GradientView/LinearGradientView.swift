//
//  LinearGradientView.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 22/02/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

class LinearGradientView: UIView {

    override public class var layerClass: Swift.AnyClass {
        return CAGradientLayer.self
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        setUpGradient()
    }
    
    func setUpGradient(start: CAGradientLayer.Point = .topCenter,end: CAGradientLayer.Point = .bottomCenter, colors: [CGColor] = [UIColor.navigationBarColor().cgColor,UIColor.navigationBarWhiteColor().cgColor]){
        guard let gradientLayer = self.layer as? CAGradientLayer else { return }
        
        let colors = colors
        
        gradientLayer.startPoint = start.point//CAGradientLayer.Point.topCenter.point
        gradientLayer.endPoint = end.point
        gradientLayer.colors = colors
        gradientLayer.locations = (0..<colors.count).map(NSNumber.init)
        gradientLayer.type = .axial
        gradientLayer.colors = colors

    }

}
