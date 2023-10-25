//
//  SmilesNavigationViewEn.swift
//  ElGrocerShopper
//
//  Created by Sarmad Abbas on 11/10/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

class SmilesNavigationViewEn: UIView, SmilesNavigationView {
    
    lazy var profileButton: UIButton = {
        let button = UIButton()
        let image = UIImage(name: "menu")
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
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var logoView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.image = UIImage(name: "elGrocerLogo")
        return view
    }()
    
    lazy var smilesPointsView: SmilesPointsView = {
        let view = SmilesPointsViewEn()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(smilesViewTapped)))
        return view
    }()
    
    @objc func smilesViewTapped() {
        print("Smiles View Tapped")
    }
    
    func setSmilesPoints(_ points: Int) { smilesPointsView.setSmilesPoints(points) }
    func clearSmilesPoints() { smilesPointsView.titleLabel.text = "" }
    
    func initialSetup() {
        
        backgroundColor = #colorLiteral(red: 0, green: 0.7365624905, blue: 0.4026013613, alpha: 1)
        
        addSubview(profileButton)
        addSubview(cartButton)
        addSubview(titleView)
        titleView.addSubview(smilesPointsView)
        titleView.addSubview(logoView)
        
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
            titleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleView.topAnchor.constraint(equalTo: topAnchor),
            titleView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            logoView.topAnchor.constraint(equalTo: titleView.topAnchor),
            logoView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
            logoView.widthAnchor.constraint(equalTo: logoView.heightAnchor, multiplier: 5),
            logoView.heightAnchor.constraint(equalTo: smilesPointsView.heightAnchor, multiplier: 1),
        ])
        
        NSLayoutConstraint.activate([
            smilesPointsView.topAnchor.constraint(equalTo: logoView.bottomAnchor, constant: 2),
            smilesPointsView.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
            smilesPointsView.leftAnchor.constraint(equalTo: titleView.leftAnchor),
            smilesPointsView.rightAnchor.constraint(equalTo: titleView.rightAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let frame = self.superview?.bounds {
            self.frame = frame
        }
    }
    
    convenience init () {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    internal required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialSetup()
    }
}
