//
//  View.swift
//  iOSApp
//
//  Created by Abbas on 07/06/2021.
//

import UIKit

enum CornerRadiusStyle: Hashable {
    case capsule, radius(CGFloat), none
}

protocol CornerRadiusStyleType: UIView {
    var cornerRadiusStyle: CornerRadiusStyle? { get set }
    /// Must be called with didSet of CornerRadiusStyle ()
    func didSetCornerRadius()
    /// Must be called with layoutSubviews()
    func configureCapsule()
}

extension CornerRadiusStyleType {
    func didSetCornerRadius() {
        guard let radius = self.cornerRadiusStyle else { return }
        switch radius {
        case .radius(let radius): self.layer.cornerRadius = radius
        case .none: self.layer.cornerRadius = 0
        case .capsule: self.layoutIfNeeded()
        }
    }
    func configureCapsule() {
        if self.cornerRadiusStyle == .capsule {
            self.layer.cornerRadius = self.frame.size.height / 2
        }
    }
}


open class View: UIView, CornerRadiusStyleType {
    
    var cornerRadiusStyle: CornerRadiusStyle? = .none { didSet { didSetCornerRadius() } }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        makeUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.configureCapsule()
    }
    
    func getCenter() -> CGPoint {
        return convert(center, from: superview)
    }

    func makeUI() {
        self.translatesAutoresizingMaskIntoConstraints = false
        // self.layer.masksToBounds = true
        self.backgroundColor = .clear
        self.setNeedsDisplay()
    }
}
