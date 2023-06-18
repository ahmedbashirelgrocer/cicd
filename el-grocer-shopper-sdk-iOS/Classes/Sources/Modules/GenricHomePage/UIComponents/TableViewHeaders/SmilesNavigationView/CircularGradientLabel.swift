//
//  CircularGradientLabel.swift
//  SmilesNavigationBaar
//
//  Created by Sarmad Abbas on 10/10/2022.
//

import UIKit

class CircularGradientLabel: UIView {
    
    @IBInspectable var text: String? {
        set { label.text = newValue }
        get { label.text }
    }
    
    @IBInspectable var font: UIFont! {
        set { label.font = newValue }
        get { label.font }
    }
    
    @IBInspectable var textColor: UIColor! {
        set { label.textColor = newValue }
        get { label.textColor }
    }
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        self.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        let purple = #colorLiteral(red: 0.5440375805, green: 0.3271837234, blue: 0.6164366603, alpha: 1)
        let red = #colorLiteral(red: 0.875736475, green: 0.2409847379, blue: 0.1460545063, alpha: 1)
        gradient.colors = [purple.cgColor, red.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        return gradient
    }()
    
    func initialSetup() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.font = .systemFont(ofSize: 14, weight: .bold)
        self.clipsToBounds = true
        self.backgroundColor = .clear
    }
    
    func layoutSetup() {
        layer.insertSublayer(gradientLayer, at: 0)
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.rightAnchor.constraint(equalTo: rightAnchor),
            label.leftAnchor.constraint(equalTo: leftAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = self.frame.size.height / 2
        gradientLayer.frame = self.bounds
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
        layoutSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
