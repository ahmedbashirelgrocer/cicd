//
//  SingleStoreHeaderNavBar.swift
//  
//
//  Created by saboor Khan on 27/05/2024.
//

import UIKit

extension UIFactory {
    static func makeSingleStoreHeaderNavBar(delegate: SingleStoreHeaderNavBarDelegate)-> SingleStoreHeaderNavBar {
        let view = SingleStoreHeaderNavBar(delegate: delegate)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

protocol SingleStoreHeaderNavBarDelegate {
    func navBackButtonPressed()
    func navHelpButtonPressed()
    func navMenuButtonPressed()
}
extension SingleStoreHeaderNavBarDelegate {
    func navBackButtonPressed() {}
    func navHelpButtonPressed() {}
    func navMenuButtonPressed() {}
}

class SingleStoreHeaderNavBar: UIView {
    
    private let bgView = UIFactory.makeView()
    private let imgLogo = UIFactory.makeImageView(contentMode: .scaleToFill)
    private let btnBack = UIFactory.makeButton(with: "backPinPurple", in: .resource, cornerRadiusStyle: .radius(14.5))
    private let btnHelp = UIFactory.makeButton(with: "icon_help_Purple", in: .resource, cornerRadiusStyle: .radius(14.5))
    private let btnMenu = UIFactory.makeButton(with: "menu", in: .resource, cornerRadiusStyle: .radius(14.5))
    
    var delegate: SingleStoreHeaderNavBarDelegate!
    
    convenience init(delegate: SingleStoreHeaderNavBarDelegate) {
        // Call the designated initializer of the superclass (UIView)
        self.init(frame: .zero)
        // Set the custom value
        self.delegate = delegate
        addSubViewsAndSetContraints()
        self.setInitialAppearance()
    }
    
    func addSubViewsAndSetContraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.clipsToBounds = false
        
        self.addSubviews([bgView])
        bgView.addSubviews([btnBack, imgLogo, btnHelp, btnMenu])
        
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: self.topAnchor),
            bgView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            bgView.leftAnchor.constraint(equalTo: self.leftAnchor),
            bgView.rightAnchor.constraint(equalTo: self.rightAnchor),
            
            btnBack.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 16),
            btnBack.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 12),
            btnBack.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -12),
            btnBack.heightAnchor.constraint(equalToConstant: 24),
            btnBack.widthAnchor.constraint(equalToConstant: 24),
        
            btnMenu.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -16),
            btnMenu.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 12),
            btnMenu.heightAnchor.constraint(equalToConstant: 24),
            btnMenu.widthAnchor.constraint(equalToConstant: 24),
            
            btnHelp.rightAnchor.constraint(equalTo: btnMenu.leftAnchor, constant: -16),
            btnHelp.centerYAnchor.constraint(equalTo: btnMenu.centerYAnchor, constant: 0),
            btnHelp.heightAnchor.constraint(equalToConstant: 24),
            btnHelp.widthAnchor.constraint(equalToConstant: 24),
            
            imgLogo.centerXAnchor.constraint(equalTo: bgView.centerXAnchor),
            imgLogo.centerYAnchor.constraint(equalTo: btnBack.centerYAnchor),
            
        ])
    }
    
    func setInitialAppearance() {
        
        self.imgLogo.image = UIImage(name: "singleStoreHeaderLogo")
        
        self.btnBack.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        self.btnHelp.addTarget(self, action: #selector(helpButtonPressed), for: .touchUpInside)
        self.btnMenu.addTarget(self, action: #selector(menuButtonPressed), for: .touchUpInside)
    }
    
    @objc func backButtonPressed() {
        self.delegate.navBackButtonPressed()
    }
    @objc func helpButtonPressed() {
        self.delegate.navHelpButtonPressed()
    }
    @objc func menuButtonPressed() {
        self.delegate.navMenuButtonPressed()
    }
    
    
}
