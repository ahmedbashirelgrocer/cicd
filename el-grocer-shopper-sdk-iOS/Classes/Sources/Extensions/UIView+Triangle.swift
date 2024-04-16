//
//  UIView+Triangle.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 12/02/2024.
//

import UIKit

extension UIView {
    func addTriangleLayerToView(x: CGFloat, y: CGFloat, height: CGFloat = 16, width: CGFloat = 24) {
        let triangleLayer = CAShapeLayer()
        let trianglePath = UIBezierPath()
        
        let startPoint = CGPoint(x: x - width / 2, y: y)
        let topPoint = CGPoint(x: x, y: y - height)
        let endPoint = CGPoint(x: x + width / 2, y: y)
        
        // Construct the triangle path
        trianglePath.move(to: startPoint)
        trianglePath.addLine(to: topPoint)
        trianglePath.addLine(to: endPoint)
        trianglePath.close()
        
        // Apply the path to the layer
        triangleLayer.path = trianglePath.cgPath
        triangleLayer.fillColor = UIColor.newBlackColor().cgColor
        
        // Add the triangle layer to the view's layer
        self.layer.addSublayer(triangleLayer)
    }
}
