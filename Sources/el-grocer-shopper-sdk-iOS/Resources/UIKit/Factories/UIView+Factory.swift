//
//  LottieAnimationView.swift
//  Adyen
//
//  Created by Sarmad Abbas on 04/09/2023.
//

import Foundation
import Lottie
import UIKit

public struct UIFactory {}

extension UIFactory {
    static func makeView(with backgroundColor: UIColor = .clear,
                         alpha: CGFloat = 1,
                         cornerRadiusStyle: CornerRadiusStyle = .none,
                         borderColor: UIColor = .clear,
                         borderWidth: CGFloat = 0 ) -> UIView {
        
        let view = View()
        view.alpha = alpha
        view.backgroundColor = backgroundColor
        view.layer.borderColor = borderColor.cgColor
        view.layer.borderWidth = borderWidth
        view.cornerRadiusStyle = cornerRadiusStyle
        return view
    }
    
    static func makeViews(with backgroundColor: UIColor = .clear,
                          alpha: CGFloat = 1,
                          cornerRadiusStyle: CornerRadiusStyle = .none,
                          borderColor: UIColor = .clear,
                          borderWidth: CGFloat = 0,
                          count: Int) -> [UIView] {
        
        (0..<count)
            .map{ _ in self.makeView(with: backgroundColor,
                                     alpha: alpha,
                                     cornerRadiusStyle: cornerRadiusStyle,
                                     borderColor: borderColor,
                                     borderWidth: borderWidth) }
    }
}
