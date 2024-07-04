//
//  Button.swift
//  iOSApp
//
//  Created by Abbas on 07/06/2021.
//

import UIKit

public class Button: UIButton, CornerRadiusStyleType {
    var cornerRadiusStyle: CornerRadiusStyle? { didSet { didSetCornerRadius() }}
    
    private var underlineView: UIView!
    
    public override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        super.setTitleColor(color, for: state)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }

    func makeUI() {
        layer.masksToBounds = true
        titleLabel?.lineBreakMode = .byWordWrapping
        updateUI()
    }

    func updateUI() {
        translatesAutoresizingMaskIntoConstraints = false
        setNeedsDisplay()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        underlineView?.backgroundColor = self.titleColor(for: self.state)
        self.configureCapsule()
    }
    
    func underlinedTitle() {
        underlineView = {
            let view: UIView! = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        addSubview(underlineView)
        
        guard let titleLabel = titleLabel else { return }
        NSLayoutConstraint.activate([
            underlineView.heightAnchor.constraint(equalToConstant: 1),
            underlineView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            underlineView.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
            underlineView.rightAnchor.constraint(equalTo: titleLabel.rightAnchor)
        ])
    }
}

