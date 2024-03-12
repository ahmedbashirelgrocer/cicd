//
//  animatedSpinnerView.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 01/07/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

@IBDesignable
class AnimatedSpinnerView : UIView {
    
    var animationColor : UIColor = .white
    var isAnimating : Bool = true
    var isFilled : Bool = true

    override var layer: CAShapeLayer {
        get {
            return super.layer as! CAShapeLayer
        }
    }

    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.fillColor = nil
        layer.strokeColor = UIColor.black.cgColor
        layer.lineWidth = 3
        setPath()
        NotificationCenter.default.addObserver(
          self,
            selector: #selector(cameBackFromSleep(sender:)),
            name: UIApplication.didBecomeActiveNotification,
          object: nil
        )
        
    }

    override func didMoveToWindow() {
        if self.isFilled{
            self.animate(true)
        }else{
            self.animate()
        }
    }
    
    

    @objc func cameBackFromSleep(sender : AnyObject) {
        if self.isFilled{
            self.animate(true)
        }else{
            self.animate()
        }
        
    }

    private func setPath() {
        layer.path = UIBezierPath(ovalIn: bounds.insetBy(dx: layer.lineWidth / 2, dy: layer.lineWidth / 2)).cgPath
    }

    struct Pose {
        let secondsSincePriorPose: CFTimeInterval
        let start: CGFloat
        let length: CGFloat
        init(_ secondsSincePriorPose: CFTimeInterval, _ start: CGFloat, _ length: CGFloat) {
            self.secondsSincePriorPose = secondsSincePriorPose
            self.start = start
            self.length = length
        }
    }

    var poses: [Pose] {
        get {
            if self.isFilled{
                return [
                    Pose(0.0, 0.000, 1.5),
                    Pose(0.6, 0.000, 1.5),
                    Pose(0.6, 0.500, 1.5),
                    Pose(0.3, 1.00, 1.5),
                    Pose(0.0, 2.000, 1.5),
                    Pose(0.0, 3.000, 1.5),
                ]
            }else{
                return [
                    Pose(0.0, 0.000, 0.0),
                    Pose(0.6, 0.000, 0.5),
                    Pose(0.6, 0.500, 0.5),
                    Pose(0.3, 1.00, 0.0)
                ]
            }
            
        }
    }

    func animate(_ filled : Bool = false) {
        
        
        var time: CFTimeInterval = 0
        var times = [CFTimeInterval]()
        var start: CGFloat = 0
        var rotations = [CGFloat]()
        var strokeEnds = [CGFloat]()
        
        self.isFilled = filled
        //var posed = [Pose]()//self.poses//type(of: self).poses
        let posed = self.poses
//        if filled{
//            self.isFilled = true
//            posed = self.poses
////          posed =  [
////                    Pose(0.0, 0.000, 1.0),
////                    Pose(0.0, 0.000, 1.0),
////                ]
//
//        }else{
//            self.isFilled = false
//            posed = self.poses
//        }

        
        let totalSeconds = posed.reduce(0) { $0 + $1.secondsSincePriorPose }

        for pose in posed {
            time += pose.secondsSincePriorPose
            times.append(time / totalSeconds)
            start = pose.start
            rotations.append(start * 2 * .pi)
            strokeEnds.append(pose.length)
        }

        times.append(times.last!)
        rotations.append(rotations[0])
        strokeEnds.append(strokeEnds[0])

        animateKeyPath(keyPath: "strokeEnd", duration: totalSeconds, times: times, values: strokeEnds)
        animateKeyPath(keyPath: "transform.rotation", duration: totalSeconds, times: times, values: rotations)

        animateStrokeHueWithDuration(duration: totalSeconds * 5)
    }

    func animateKeyPath(keyPath: String, duration: CFTimeInterval, times: [CFTimeInterval], values: [CGFloat]) {
        let animation = CAKeyframeAnimation(keyPath: keyPath)
        animation.keyTimes = times as [NSNumber]?
        animation.values = values
        animation.calculationMode = .linear
        animation.duration = duration
        animation.repeatCount = Float.infinity
        layer.add(animation, forKey: animation.keyPath)
    }

    func animateStrokeHueWithDuration(duration: CFTimeInterval) {
        let count = 36
        let animation = CAKeyframeAnimation(keyPath: "strokeColor")
        animation.keyTimes = (0 ... count).map { NSNumber(value: CFTimeInterval($0) / CFTimeInterval(count)) }
        animation.values = (0 ... count).map {_ in
            animationColor.cgColor
        }
        //animation.values = UIColor.white
        animation.duration = duration
        animation.calculationMode = .linear
        animation.repeatCount = Float.infinity
        layer.add(animation, forKey: animation.keyPath)
    }

}
