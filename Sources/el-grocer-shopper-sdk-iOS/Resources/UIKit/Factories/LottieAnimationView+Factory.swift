//
//  LottieAnimationView+Factory.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 04/09/2023.
//

import Foundation
import Lottie
import UIKit

public extension UIFactory {
    static func makeLottieAnimationView(contentMode: UIView.ContentMode = .scaleAspectFit,
                                        loopMode: LottieLoopMode = .playOnce,
                                        backgroundColor: UIColor = .clear,
                                        animation: LottieAnimation? = nil) -> LottieAnimationView {
        
        let view = LottieAnimationView()
        view.contentMode = contentMode
        view.loopMode = loopMode
        view.animation = animation
        view.backgroundColor = backgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
