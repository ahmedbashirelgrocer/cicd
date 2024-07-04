//
//  BulletView+UIFactory.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 25/09/2023.
//

import UIKit

extension UIFactory {
    static func makeBullet<ListItem: UIView>(with icon: UIImageView,
                                             and item: ListItem,
                                             of bulletSize: CGFloat = 24,
                                             ident: CGFloat = 16,
                                             cornerRadiusStyle: CornerRadiusStyle = .none,
                                             borderWidth: CGFloat? = nil) -> BulletView<ListItem> {
        
        let view = BulletView(icon: icon, item: item, bulletSize: bulletSize, ident: ident)
        view.cornerRadiusStyle = cornerRadiusStyle
        if let borderWidth = borderWidth { view.layer.borderWidth = borderWidth }
        return view
    }
}

class BulletView<ListItem: UIView>: UIView, CornerRadiusStyleType {
    var cornerRadiusStyle: CornerRadiusStyle? { didSet { didSetCornerRadius() }}
    
    private(set) var icon: UIImageView!
    private(set) var item: ListItem!
    private(set) var bulletSize: CGFloat!
    private(set) var ident: CGFloat?
    
    convenience init(icon: UIImageView,
                     item: ListItem,
                     bulletSize: CGFloat,
                     ident: CGFloat? = nil) {
        self.init(frame: .zero)
        
        self.icon = icon
        self.item = item
        self.bulletSize = bulletSize
        self.ident = ident
        
        self.configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.configureCapsule()
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        
        let spacer = UIFactory.makeViews(count: 2)
        addSubviews(spacer)
        addSubviews([icon, item])
        
        NSLayoutConstraint.activate([
            spacer[0].centerYAnchor.constraint(equalTo: centerYAnchor),
            spacer[0].widthAnchor.constraint(equalTo: heightAnchor, multiplier: 1/4),
            spacer[0].heightAnchor.constraint(equalToConstant: 1),
            
            icon.leftAnchor.constraint(equalTo: spacer[0].rightAnchor),
            icon.centerYAnchor.constraint(equalTo: centerYAnchor),
            icon.widthAnchor.constraint(equalTo: icon.heightAnchor, multiplier: 1),
            icon.heightAnchor.constraint(equalToConstant: bulletSize),
            
            spacer[1].leftAnchor.constraint(equalTo: icon.rightAnchor),
            spacer[1].centerYAnchor.constraint(equalTo: centerYAnchor),
            spacer[1].widthAnchor.constraint(equalTo: heightAnchor, multiplier: 1/6),
            spacer[1].heightAnchor.constraint(equalToConstant: 1),
            
            item.centerYAnchor.constraint(equalTo: centerYAnchor),
            item.leftAnchor.constraint(equalTo: spacer[1].rightAnchor),
            item.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -5)
        ])
        
        if ident == nil {
            spacer[0].leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        } else {
            spacer[0].rightAnchor.constraint(equalTo: leftAnchor, constant: ident!).isActive = true
        }
    }
}
