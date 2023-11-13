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
        let purple = UIColor.colorWithHexString(hexString: "423B79")
        let red = UIColor.colorWithHexString(hexString: "423B79")
        gradient.colors = [purple.cgColor, red.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        return gradient
    }()
    
    private let emojiImageView: UIImageView = {
        let view = UIImageView(image: UIImage(name: "smiles_face"))
        view.backgroundColor = .clear
        view.contentMode = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func initialSetup() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.font = .systemFont(ofSize: 14, weight: .bold)
        self.clipsToBounds = true
        self.backgroundColor = .clear
    }
    
    func layoutSetup() {
//        layer.insertSublayer(gradientLayer, at: 0)
        addSubview(emojiImageView)
        addSubview(label)
        NSLayoutConstraint.activate([
            emojiImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 4),
            emojiImageView.widthAnchor.constraint(equalToConstant: 30),
        ])
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            label.leftAnchor.constraint(equalTo: emojiImageView.rightAnchor, constant: 8)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = self.frame.size.height / 2
//        gradientLayer.frame = self.bounds
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
