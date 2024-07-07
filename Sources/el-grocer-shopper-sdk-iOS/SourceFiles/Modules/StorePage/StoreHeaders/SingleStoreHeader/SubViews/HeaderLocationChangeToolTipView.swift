//
//  HeaderLocationChangeToolTipView.swift
//  
//
//  Created by saboor Khan on 30/05/2024.
//

import UIKit

extension UIFactory {
    static func makeHeaderLocationChangeToolTipView(delegate: HeaderLocationChangeToolTipViewDelegate)-> HeaderLocationChangeToolTipView {
        let view = HeaderLocationChangeToolTipView(delegate: delegate)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

protocol HeaderLocationChangeToolTipViewDelegate {
    func toolTipChangeLocationHandler()
}
extension HeaderLocationChangeToolTipViewDelegate {
    func toolTipChangeLocationHandler() {}
}

class HeaderLocationChangeToolTipView: UIView {
    
    
    private let bgView = UIFactory.makeView(cornerRadiusStyle: .radius(8))
    private let imgWarning = UIFactory.makeImageView(contentMode: .scaleToFill)
    private let lblToolTipMsg = UIFactory.makeLabel()
    private let btnChangeLocation = UIFactory.makeButton(with: "btnViewAllArrowForward", in: .resource,title: localizedString("changelocation_button", comment: "") + "  ")
    
    private let isArabic = ElGrocerUtility.sharedInstance.isArabicSelected()
    var delegate: HeaderLocationChangeToolTipViewDelegate!
    
    
    convenience init(delegate: HeaderLocationChangeToolTipViewDelegate) {
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
        bgView.addSubviews([imgWarning, lblToolTipMsg, btnChangeLocation])
        
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            bgView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            bgView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            bgView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            
            imgWarning.heightAnchor.constraint(equalToConstant: 20),
            imgWarning.widthAnchor.constraint(equalToConstant: 20),
            imgWarning.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 8),
            imgWarning.centerYAnchor.constraint(equalTo: bgView.centerYAnchor, constant: 0),
            imgWarning.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 10),
            imgWarning.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -10),
            
            lblToolTipMsg.leadingAnchor.constraint(equalTo: imgWarning.trailingAnchor, constant: 8),
            lblToolTipMsg.centerYAnchor.constraint(equalTo: imgWarning.centerYAnchor, constant: 0),
            lblToolTipMsg.trailingAnchor.constraint(equalTo: btnChangeLocation.leadingAnchor, constant: -8),
            
            btnChangeLocation.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -16),
            btnChangeLocation.centerYAnchor.constraint(equalTo: bgView.centerYAnchor, constant: 0),

        ])
        self.addTriangleLayerToView(x: self.bgView.frame.origin.x + 24 + 35, y: self.bgView.frame.origin.y + 16 + 10 )
        self.bringSubviewToFront(bgView)
    }
    
    func setInitialAppearance() {
        
        bgView.backgroundColor = ApplicationTheme.currentTheme.newBlackColor
        
        imgWarning.image = UIImage(name: "ic_warning")
        lblToolTipMsg.text = localizedString("lbl_location_change_tool_tip_msg", comment: "")
        lblToolTipMsg.textAlignment = isArabic ? .right : .left
        lblToolTipMsg.setCaptionOneSemiBoldWhiteStyle()
        
        btnChangeLocation.setSubHead2BoldWhiteStyle()
        btnChangeLocation.semanticContentAttribute = isArabic ? .forceLeftToRight : .forceRightToLeft
        btnChangeLocation.addTarget(self, action: #selector(changeLocationPressed), for: .touchUpInside)
        btnChangeLocation.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
    }
    
    @objc func changeLocationPressed() {
        self.delegate.toolTipChangeLocationHandler()
    }
    
    
}
