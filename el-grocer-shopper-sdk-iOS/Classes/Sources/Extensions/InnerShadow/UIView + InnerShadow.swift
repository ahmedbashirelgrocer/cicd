//
//  UIView.swift
//  SwiftyShadow
//
//  Created by luan on 7/23/17.
//
//

import UIKit

extension UIView {
    
    open func generateOuterShadow() {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = layer.cornerRadius
        view.layer.shadowRadius = layer.shadowRadius
        view.layer.shadowOpacity = layer.shadowOpacity
        view.layer.shadowColor = layer.shadowColor
        view.layer.shadowOffset = CGSize.zero
        view.clipsToBounds = false
        view.backgroundColor = .white
        
        superview?.insertSubview(view, belowSubview: self)
        
        let constraints = [
            NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
        ]
        superview?.addConstraints(constraints)
    }
    
    open func generateInnerShadow() {
        let view = SwiftyInnerShadowView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.shadowLayer.cornerRadius = layer.cornerRadius
        view.shadowLayer.shadowRadius = layer.shadowRadius
        view.shadowLayer.shadowOpacity = layer.shadowOpacity
        view.shadowLayer.shadowColor = layer.shadowColor
        view.shadowLayer.shadowOffset = CGSize.zero
        view.clipsToBounds = false
        view.backgroundColor = .clear
        
        superview?.insertSubview(view, aboveSubview: self)
        
        let constraints = [
            NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            ]
        superview?.addConstraints(constraints)
    }
    
    open func generateEllipticalShadow() {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = layer.cornerRadius
        view.layer.shadowRadius = layer.shadowRadius
        view.layer.shadowOpacity = layer.shadowOpacity
        view.layer.shadowColor = layer.shadowColor
        view.layer.shadowOffset = CGSize.zero
        view.clipsToBounds = false
        view.backgroundColor = .white
        
        let ovalRect = CGRect(x: 0, y: frame.size.height + 10, width: frame.size.width, height: 15)
        let path = UIBezierPath(ovalIn: ovalRect)
        
        view.layer.shadowPath = path.cgPath
        
        superview?.insertSubview(view, belowSubview: self)
        
        let constraints = [
            NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            ]
        superview?.addConstraints(constraints)
    }
    open func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func addDashedBorder() {
        //Create a CAShapeLayer
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.colorWithHexString(hexString: "f3f3f3").cgColor
        shapeLayer.lineWidth = 1
        // passing an array with the values [2,3] sets a dash pattern that alternates between a 2-user-space-unit-long painted segment and a 3-user-space-unit-long unpainted segment
        shapeLayer.lineDashPattern = [2,3]
        
        let path = CGMutablePath()
        path.addLines(between: [CGPoint(x: 0, y: 0),
                                CGPoint(x: self.frame.width, y: 0)])
        shapeLayer.path = path
        layer.addSublayer(shapeLayer)
    }
    func addDashedBorderAroundView(color: UIColor) {
        
        
        
        let color = color.cgColor
        var shapeLayer : CAShapeLayer?
        if let layersA = self.layer.sublayers {
            for shape in layersA {
                if shape is CAShapeLayer {
                    shapeLayer = shape as? CAShapeLayer
                    break
                }
            }
        }
        if shapeLayer == nil {
            shapeLayer = CAShapeLayer()
        }
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)

        shapeLayer?.bounds = shapeRect
        shapeLayer?.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer?.fillColor = UIColor.clear.cgColor
        shapeLayer?.strokeColor = color
        shapeLayer?.lineWidth = 1
        shapeLayer?.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer?.lineDashPattern = [6,3]
        shapeLayer?.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 5).cgPath
        
        if let layerIs = shapeLayer {
            self.layer.addSublayer(layerIs)
        }
       
    }
    
    open func roundTopWithTopShadow(radius : CGFloat){
        self.layer.shadowOffset = CGSize(width: 0, height: -2)
        self.layer.shadowOpacity = 0.16
        self.layer.shadowRadius = 1
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = [.layerMaxXMinYCorner , .layerMinXMinYCorner]
      }
    
    open func roundWithShadow(corners : CACornerMask, radius : CGFloat , withShadow : Bool = false){
        //CACornerMask
        if withShadow{
          self.layer.shadowOffset = CGSize(width: 0, height: 2)
          self.layer.shadowOpacity = 0.16
          self.layer.shadowRadius = 1
        }
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = corners
      }
    
    func createDottedLine(width: CGFloat, color: CGColor) {
        let caShapeLayer = CAShapeLayer()
        caShapeLayer.strokeColor = color
        caShapeLayer.lineWidth = width
        caShapeLayer.lineDashPattern = [2,3]
        let cgPath = CGMutablePath()
        let cgPoint = [CGPoint(x: 0, y: 0), CGPoint(x: self.frame.width, y: 0)]
        cgPath.addLines(between: cgPoint)
        caShapeLayer.path = cgPath
        layer.addSublayer(caShapeLayer)
    }
    
    
}
extension UIView {
    class func loadFromNib<T>(withName nibName: String) -> T? {
        let nib  = UINib.init(nibName: nibName, bundle: .resource)
        let nibObjects = nib.instantiate(withOwner: nil, options: nil)
        for object in nibObjects {
            if let result = object as? T {
                return result
            }
        }
        return nil
    }
}
