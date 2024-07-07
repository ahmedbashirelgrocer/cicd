//
//  SingleStoreHeader.swift
//  
//
//  Created by saboor Khan on 27/05/2024.
//

import UIKit

class SingleStoreHeader: UIView {
    
    private let bgView = UIFactory.makeView()
    private let stackView = UIFactory.makeStackView(axis: .vertical)
    private var navView: SingleStoreHeaderNavBar!
    private var addressSlotView: SingleStoreSlotAndAddressView!
    private var searchView: StoreHeaderSearchView!
    private var toolTipView: HeaderLocationChangeToolTipView!
    
    var presenter: SingleStoreHeaderType!
    
    convenience init(presenter: SingleStoreHeaderType) {
        // Call the designated initializer of the superclass (UIView)
        self.init(frame: .zero)
        // Set the custom value
        self.presenter = presenter
        self.presenter.delegateOutputs = self
        self.navView = UIFactory.makeSingleStoreHeaderNavBar(delegate: self)
        self.addressSlotView = UIFactory.makeSingleStoreSlotAndAddressView(delegate: self)
        self.searchView = UIFactory.makeStoreHeaderSearchView(delegate: self)
        self.toolTipView = UIFactory.makeHeaderLocationChangeToolTipView(delegate: self)
        addSubViewsAndSetContraints()
        setInitialAppearance()
    }
    
    func addSubViewsAndSetContraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.clipsToBounds = false
        
        self.addSubviews([bgView])
        self.bgView.addSubviews([stackView])
        stackView.addArrangedSubview(navView)
        stackView.addArrangedSubview(addressSlotView)
        stackView.addArrangedSubview(toolTipView)
        stackView.addArrangedSubview(searchView)
        
        NSLayoutConstraint.activate([
            //bgView
            bgView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bgView.topAnchor.constraint(equalTo: self.topAnchor),
            bgView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            //stack view
            stackView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: bgView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: bgView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bgView.bottomAnchor),
            //nav view
            navView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor),
            navView.trailingAnchor.constraint(equalTo: bgView.trailingAnchor),
            // address and slot view
            addressSlotView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor),
            addressSlotView.trailingAnchor.constraint(equalTo: bgView.trailingAnchor),
            // search view
            searchView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor),
            searchView.trailingAnchor.constraint(equalTo: bgView.trailingAnchor),
            // tool tip view
            toolTipView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor),
            toolTipView.trailingAnchor.constraint(equalTo: bgView.trailingAnchor),
            
        ])
    }
    
    func setInitialAppearance() {
        self.shouldShowToolTip(isHidden: true)
    }
}
extension SingleStoreHeader: SingleStoreHeaderOutputs {

    func setDeliverySlot(slot: String) {
        self.addressSlotView.updateSlot(slot: slot)
    }
    
    func setDeliveryAddress(address: String) {
        self.addressSlotView.updateAddress(address: address)
    }
    func shouldShowToolTip(isHidden: Bool) {
        self.toolTipView.isHidden = isHidden
    }
}
//MARK: nav view delegates
extension SingleStoreHeader: SingleStoreHeaderNavBarDelegate {
    func navBackButtonPressed() {
        self.presenter.inputs?.backButtonPressed()
    }
    
    func navHelpButtonPressed() {
        self.presenter.inputs?.helpButtonPressed()
    }
    
    func navMenuButtonPressed() {
        self.presenter.inputs?.menuTapped()
    }
}
//MARK: Address and slot view delegate

extension SingleStoreHeader: SingleStoreSlotAndAddressViewDelegate {
    func singleStoreSlotButtonTapped() {
        self.presenter.inputs?.slotButtonTpped()
    }
    func singleStoreAddressButtonTapped() {
        self.presenter.inputs?.addressTapped()
    }
}
//MARK: search bar and shopping list
extension SingleStoreHeader: SingleStoreHeaderSearchViewDelegate {
    func singleStoreSearchTapped() {
        self.presenter.inputs?.searchBarTapped()
    }
    func singleStoreShoppingListTapped() {
        self.presenter.inputs?.shoppingListTpped()
    }
}
//MARK: search bar and shopping list
extension SingleStoreHeader: HeaderLocationChangeToolTipViewDelegate {
    func toolTipChangeLocationHandler() {
        self.presenter.delegate?.singleStoreToolTipChangeLocationTpped()
    }
}
