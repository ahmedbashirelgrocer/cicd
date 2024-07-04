//
//  StoreHeaderSearchView.swift
//  
//
//  Created by saboor Khan on 27/05/2024.
//

import UIKit

extension UIFactory {
    static func makeStoreHeaderSearchView(delegate: SingleStoreHeaderSearchViewDelegate)-> StoreHeaderSearchView {
        let view = StoreHeaderSearchView(delegate: delegate)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

protocol SingleStoreHeaderSearchViewDelegate {
    func singleStoreSearchTapped()
    func singleStoreShoppingListTapped()
}
extension SingleStoreHeaderSearchViewDelegate {
    func singleStoreSearchTapped() {}
    func singleStoreShoppingListTapped() {}
}

class StoreHeaderSearchView: UIView {
    
    private let bgView = UIFactory.makeView()
    private let imgSearch = UIFactory.makeImageView(contentMode: .scaleToFill)
    private let searchBGView = UIFactory.makeView(cornerRadiusStyle: .radius(22), borderColor: ApplicationTheme.currentTheme.borderLightGrayColor, borderWidth: 1)
    private let lblSearchPlaceHoledr = UIFactory.makeLabel()
    private let btnShoppingList = UIFactory.makeButton(with: "btnShoppingListSingleStore", in: .resource, cornerRadiusStyle: .radius(18))
    
    var delegate: SingleStoreHeaderSearchViewDelegate!
    
    convenience init(delegate: SingleStoreHeaderSearchViewDelegate) {
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
        bgView.addSubviews([searchBGView, imgSearch, lblSearchPlaceHoledr, btnShoppingList])
        
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: self.topAnchor),
            bgView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            bgView.leftAnchor.constraint(equalTo: self.leftAnchor),
            bgView.rightAnchor.constraint(equalTo: self.rightAnchor),
            
            searchBGView.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 16),
            searchBGView.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -16),
            searchBGView.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 8),
            searchBGView.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -8),
            searchBGView.heightAnchor.constraint(equalToConstant: 44),
            
            imgSearch.leftAnchor.constraint(equalTo: searchBGView.leftAnchor, constant: 16),
            imgSearch.centerYAnchor.constraint(equalTo: searchBGView.centerYAnchor, constant: 0),
            imgSearch.heightAnchor.constraint(equalToConstant: 24),
            imgSearch.widthAnchor.constraint(equalToConstant: 24),
            
            lblSearchPlaceHoledr.leftAnchor.constraint(equalTo: imgSearch.rightAnchor, constant: 8),
            lblSearchPlaceHoledr.centerYAnchor.constraint(equalTo: searchBGView.centerYAnchor, constant: 2),
            
            btnShoppingList.rightAnchor.constraint(equalTo: searchBGView.rightAnchor, constant: -4),
            btnShoppingList.centerYAnchor.constraint(equalTo: searchBGView.centerYAnchor, constant: 0),
            btnShoppingList.heightAnchor.constraint(equalToConstant: 36),
            btnShoppingList.widthAnchor.constraint(equalToConstant: 110),
            
            
            
        ])
    }
    
    func setInitialAppearance() {
        
        self.imgSearch.image = UIImage(name: "search-SearchBar")
        
        self.btnShoppingList.addTarget(self, action: #selector(shoppingListTapped), for: .touchUpInside)
        //search
        lblSearchPlaceHoledr.text =  localizedString("search_products", comment: "")
        lblSearchPlaceHoledr.setBody3RegDarkGreyStyle()
        searchBGView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.searchTapped(_:))))
        lblSearchPlaceHoledr.isUserInteractionEnabled = false
        //shopping list
        btnShoppingList.setCaptionBoldDarkStyle()
        btnShoppingList.backgroundColor = ApplicationTheme.currentTheme.buttonShoppingListBGColor
        btnShoppingList.setTitle(localizedString("Shopping_list_Titile", comment: ""), for: UIControl.State())
    }
    
    @objc func searchTapped(_ sender: UITapGestureRecognizer) {
        self.delegate.singleStoreSearchTapped()
    }
    @objc func shoppingListTapped() {
        self.delegate.singleStoreShoppingListTapped()
    }
    
    
}
