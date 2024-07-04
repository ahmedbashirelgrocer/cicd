//
//  SingleStoreSlotAndAddressView.swift
//  
//
//  Created by saboor Khan on 27/05/2024.
//

import UIKit
extension UIFactory {
    static func makeSingleStoreSlotAndAddressView(delegate: SingleStoreSlotAndAddressViewDelegate)-> SingleStoreSlotAndAddressView {
        let view = SingleStoreSlotAndAddressView(delegate: delegate)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

protocol SingleStoreSlotAndAddressViewDelegate {
    func singleStoreSlotButtonTapped()
    func singleStoreAddressButtonTapped()
}
extension SingleStoreSlotAndAddressViewDelegate {
    func singleStoreSlotButtonTapped() {}
    func singleStoreAddressButtonTapped() {}
}

class SingleStoreSlotAndAddressView: UIView {
    
    private let bgView = UIFactory.makeView()
    private let slotBGView = UIFactory.makeView(cornerRadiusStyle: .radius(12))
    private let addressBGView = UIFactory.makeView()
    private let imgLocationPin = UIFactory.makeImageView(contentMode: .scaleToFill)
    private let imgAddressArrowDown = UIFactory.makeImageView(contentMode: .scaleToFill)
    private let imgSlotArrowDown = UIFactory.makeImageView(contentMode: .scaleToFill)
    private let lblSlot = UIFactory.makeLabel()
    private let lblAddress = UIFactory.makeLabel()
    
    var isArabic: Bool = ElGrocerUtility.sharedInstance.isArabicSelected()
    var delegate: SingleStoreSlotAndAddressViewDelegate!
    
    convenience init(delegate: SingleStoreSlotAndAddressViewDelegate) {
        // Call the designated initializer of the superclass (UIView)
        self.init(frame: .zero)
        // Set the custom value
        self.delegate = delegate
        addSubViewsAndSetContraints()
        self.setInitialAppearance()
    }
    
    
    
    func updateSlot(slot: String) {
        self.lblSlot.text = slot
    }
    
    func updateAddress(address: String) {
        self.lblAddress.text = address
    }
    
    func addSubViewsAndSetContraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.clipsToBounds = false
        
        addSubviews([bgView])
        bgView.addSubviews([addressBGView, slotBGView])
        addressBGView.addSubviews([imgLocationPin, lblAddress, imgAddressArrowDown])
        slotBGView.addSubviews([lblSlot, imgSlotArrowDown])
        
        NSLayoutConstraint.activate([
            //bg view
            bgView.topAnchor.constraint(equalTo: self.topAnchor),
            bgView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            bgView.leftAnchor.constraint(equalTo: self.leftAnchor),
            bgView.rightAnchor.constraint(equalTo: self.rightAnchor),
            //address bg view
            addressBGView.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 0),
            addressBGView.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: 0),
            addressBGView.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 16),
            addressBGView.heightAnchor.constraint(equalToConstant: 24),
            addressBGView.rightAnchor.constraint(lessThanOrEqualToSystemSpacingAfter: bgView.centerXAnchor, multiplier: 1),
            // img pin in address bg view
            imgLocationPin.leftAnchor.constraint(equalTo: addressBGView.leftAnchor),
            imgLocationPin.centerYAnchor.constraint(equalTo: addressBGView.centerYAnchor),
            imgLocationPin.widthAnchor.constraint(equalToConstant: 16),
            imgLocationPin.heightAnchor.constraint(equalToConstant: 16),
            // img address arrow down
            imgAddressArrowDown.rightAnchor.constraint(equalTo: addressBGView.rightAnchor),
            imgAddressArrowDown.centerYAnchor.constraint(equalTo: addressBGView.centerYAnchor),
            imgAddressArrowDown.widthAnchor.constraint(equalToConstant: 16),
            imgAddressArrowDown.heightAnchor.constraint(equalToConstant: 16),
            // address label and arrow down
            lblAddress.leftAnchor.constraint(equalTo: imgLocationPin.rightAnchor, constant: 4),
            lblAddress.centerYAnchor.constraint(equalTo: addressBGView.centerYAnchor),
            lblAddress.rightAnchor.constraint(equalTo: imgAddressArrowDown.leftAnchor, constant: -4),
            //address bg view
            slotBGView.leftAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: bgView.centerXAnchor, multiplier: 1),
            slotBGView.heightAnchor.constraint(equalToConstant: 24),
            slotBGView.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -16),
            slotBGView.centerYAnchor.constraint(equalTo: addressBGView.centerYAnchor),
            // address label and arrow down
            lblSlot.leftAnchor.constraint(equalTo: slotBGView.leftAnchor, constant: 4),
            lblSlot.centerYAnchor.constraint(equalTo: slotBGView.centerYAnchor),
            lblSlot.rightAnchor.constraint(equalTo: imgSlotArrowDown.leftAnchor, constant: -4),
            // img slot arrow down
            imgSlotArrowDown.rightAnchor.constraint(equalTo: slotBGView.rightAnchor, constant: -4),
            imgSlotArrowDown.centerYAnchor.constraint(equalTo: slotBGView.centerYAnchor),
            imgSlotArrowDown.widthAnchor.constraint(equalToConstant: 16),
            imgSlotArrowDown.heightAnchor.constraint(equalToConstant: 16),
            
        ])
    }
    
    func setInitialAppearance() {
        
        self.lblSlot.text = "🛵 Today 2pm-3pm"
        self.lblAddress.text = "Home: JLT, Cluster D, Indig..."
        // address
        imgLocationPin.image = UIImage(name: "homeHeadeerLocationPin")
        imgAddressArrowDown.image = UIImage(name: "singleStoreHeaderAddressDownArrow")
        lblAddress.setCaptionOneRegDarkStyle()
        lblAddress.numberOfLines = 1
        lblAddress.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.addressButtonPressed(_:))))
        lblAddress.isUserInteractionEnabled = true
        //slot
        imgSlotArrowDown.image = UIImage(name: "singleStoreHeaderSlotArrowDown")
        lblSlot.setCaptionOneRegDarkStyle()
        slotBGView.backgroundColor = ApplicationTheme.currentTheme.tableViewBackgroundColor
        lblSlot.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.slotButtonPressed(_:))))
        lblSlot.isUserInteractionEnabled = true
    }
    
    @objc func slotButtonPressed(_ sender: UITapGestureRecognizer) {
        self.delegate.singleStoreSlotButtonTapped()
    }
    @objc func addressButtonPressed(_ sender: UITapGestureRecognizer) {
        self.delegate.singleStoreAddressButtonTapped()
    }
}
