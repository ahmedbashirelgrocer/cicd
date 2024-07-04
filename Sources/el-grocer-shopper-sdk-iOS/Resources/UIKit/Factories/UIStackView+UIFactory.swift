//
//  UIStackView+Factory.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 26/10/2023.
//

import UIKit

extension UIFactory {
    static func makeStackView(axis: NSLayoutConstraint.Axis,
                              alignment: UIStackView.Alignment = .leading,
                              distribution: UIStackView.Distribution = .fillProportionally,
                              layoutMargins: UIEdgeInsets? = nil,
                              spacing: CGFloat = 0,
                              cornerRadiusStyle: CornerRadiusStyle = .none,
                              borderWidth: CGFloat? = nil,
                              arrangedSubviews: [UIView] = []) -> UIStackView {
        
        let stackView = StackView.init(arrangedSubviews: arrangedSubviews)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = axis
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.spacing = spacing
        if let layoutMargins = layoutMargins {
            stackView.layoutMargins = layoutMargins
            stackView.isLayoutMarginsRelativeArrangement = true
        }
        stackView.cornerRadiusStyle = cornerRadiusStyle
        if let borderWidth = borderWidth { stackView.layer.borderWidth = borderWidth }

        return stackView
    }
}

class StackView: UIStackView, CornerRadiusStyleType {
    var cornerRadiusStyle: CornerRadiusStyle? { didSet { didSetCornerRadius() }}
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.configureCapsule()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
    }
}
