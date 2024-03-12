//
//  LottieAniamtionViewUtil.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 01/02/2023.
//

import Foundation
import Lottie
import UIKit

class LottieAniamtionViewUtil{
    
    //MARK: - GenericAnimationMethod
    class func showAnimation(onView animationBackgroundView: UIView,
                             contentMode:  UIView.ContentMode? = nil,
                             withJsonFileName animationPath: String,
                             removeFromSuper: Bool = true,
                             loopMode: LottieLoopMode = .playOnce,
                             completion: @escaping (Bool) -> ()) {
          
          let animationView = LottieAnimationView()
          animationView.animation = LottieAnimation.named(animationPath, bundle: .resource)
          if animationView.animation != nil {
              if let contentMode = contentMode {
                  animationView.contentMode = contentMode
              }
              animationView.backgroundBehavior = .pauseAndRestore
              animationView.loopMode = loopMode
              //  animationView.frame.size = animationBackgroundView.frame.size
              animationBackgroundView.addSubview(animationView)
              animationView.translatesAutoresizingMaskIntoConstraints = false
              animationView.topAnchor.constraint(equalTo: animationBackgroundView.topAnchor).isActive = true
              animationView.bottomAnchor.constraint(equalTo: animationBackgroundView.bottomAnchor).isActive = true
              animationView.leadingAnchor.constraint(equalTo: animationBackgroundView.leadingAnchor).isActive = true
              animationView.trailingAnchor.constraint(equalTo: animationBackgroundView.trailingAnchor).isActive = true
              //            animationView.centerXAnchor.constraint(equalTo: animationBackgroundView.superview!.centerXAnchor).isActive = true
              
              animationView.play { _ in
                  if removeFromSuper {
                      animationView.removeFromSuperview()
                  }
                  completion(true)
              }
          }
          else {
              completion(false)
          }
      }
    
}
