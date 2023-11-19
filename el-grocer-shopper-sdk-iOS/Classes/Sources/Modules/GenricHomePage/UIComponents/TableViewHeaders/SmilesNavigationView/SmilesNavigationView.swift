//
//  SmilesNavigationView.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 19/11/2023.
//

import Foundation

class SmilesNavigationView: UIView {
    lazy var profileButton: UIButton = {
        let button = UIButton()
        let image = UIImage(name: "menu")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var cartButton: UIButton = {
        let button = UIButton()
        let imageNormal = UIImage(name: "Cart-Inactive-icon")
        let imageSelected = UIImage(name: "Cart-Active-icon")
        button.setImage(imageNormal, for: .normal)
        button.setImage(imageSelected, for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var titleView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var elGrocerLogo: UIImageView = {
        let view = UIImageView(image: UIImage(name: "el_logo"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var smilesLogo: UIImageView = {
        let view = UIImageView(image: UIImage(name: "smiles_logo_white"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var smilesPointsView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.colorWithHexString(hexString: "423B79")
        view.layer.cornerRadius = 16.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emojiView: UIImageView = {
        let view = UIImageView(image: UIImage(name: "smiles_face"))
        view.backgroundColor = .clear
        view.contentMode = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var lblSmilesPoint: UILabel = {
        let label = UILabel()
        label.text = localizedString("earn_rewards_now", comment: "")
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    convenience init () {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addViews()
        self.setupConstraint()
    }
    
    internal required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.addViews()
        self.setupConstraint()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let frame = self.superview?.bounds {
            self.frame = frame
        }
    }
    
    private func addViews() {
        self.addSubview(self.profileButton)
        self.addSubview(self.cartButton)
        self.addSubview(self.titleView)
        
        self.titleView.addSubview(self.elGrocerLogo)
        self.titleView.addSubview(self.smilesLogo)
        self.titleView.addSubview(self.smilesPointsView)
        
        self.smilesPointsView.addSubview(self.emojiView)
        self.smilesPointsView.addSubview(self.lblSmilesPoint)
    }
    
    private func setupConstraint() {
        NSLayoutConstraint.activate([
            profileButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            profileButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 6),
            profileButton.heightAnchor.constraint(equalToConstant: 45),
            profileButton.widthAnchor.constraint(equalTo: profileButton.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            cartButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            cartButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -6),
            cartButton.heightAnchor.constraint(equalToConstant: 55),
            cartButton.widthAnchor.constraint(equalTo: cartButton.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleView.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleView.heightAnchor.constraint(equalToConstant: 55),
        ])
        
        NSLayoutConstraint.activate([
            elGrocerLogo.centerYAnchor.constraint(equalTo: centerYAnchor),
            elGrocerLogo.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            elGrocerLogo.heightAnchor.constraint(equalToConstant: 22),
            elGrocerLogo.widthAnchor.constraint(equalToConstant: 20)
        ])
        
        NSLayoutConstraint.activate([
            smilesLogo.centerYAnchor.constraint(equalTo: centerYAnchor),
            smilesLogo.leadingAnchor.constraint(equalTo: elGrocerLogo.trailingAnchor, constant: 8),
            smilesLogo.heightAnchor.constraint(equalToConstant: 22),
            smilesLogo.widthAnchor.constraint(equalTo: smilesLogo.heightAnchor, multiplier: 116 / 48)
        ])
        
        NSLayoutConstraint.activate([
            emojiView.centerYAnchor.constraint(equalTo: centerYAnchor),
            emojiView.leadingAnchor.constraint(equalTo: smilesPointsView.leadingAnchor, constant: 0.63),
            emojiView.heightAnchor.constraint(equalToConstant: 32),
            emojiView.widthAnchor.constraint(equalToConstant: 33),
        ])
        
        NSLayoutConstraint.activate([
            lblSmilesPoint.centerYAnchor.constraint(equalTo: centerYAnchor),
            lblSmilesPoint.leadingAnchor.constraint(equalTo: emojiView.trailingAnchor, constant: 6),
            lblSmilesPoint.trailingAnchor.constraint(equalTo: self.smilesPointsView.trailingAnchor, constant: -6),
        ])
        
        NSLayoutConstraint.activate([
            smilesPointsView.centerYAnchor.constraint(equalTo: centerYAnchor),
            smilesPointsView.leadingAnchor.constraint(equalTo: smilesLogo.trailingAnchor, constant: 8),
            smilesPointsView.heightAnchor.constraint(equalToConstant: 34),
            smilesPointsView.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -8),
        ])
    }
    
    func setSmilesPoints(_ points: Int) {
        self.lblSmilesPoint.text = points == -1 ? localizedString("earn_rewards_now", comment: "") : String(points)
    }
}
