//
//  FilterSheetSearchView.swift
//  
//
//  Created by saboor Khan on 05/06/2024.
//

import UIKit

extension UIFactory {
    static func makeFilterSheetSearchViewView(delegate: FilterSheetSearchViewDelegate)-> FilterSheetSearchView {
        let view = FilterSheetSearchView(delegate: delegate)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

protocol FilterSheetSearchViewDelegate {
    func searchDidEnd(text: String)
}
extension FilterSheetSearchViewDelegate {
    func searchDidEnd(text: String) {}
}

class FilterSheetSearchView: UIView {

    private let bgView: UIView = UIFactory.makeView()
    private let btnCross: UIButton = UIFactory.makeButton(with: "cross", in: .resource)
    private let imgSearch = UIFactory.makeImageView(contentMode: .scaleToFill)
    private let searchBGView = UIFactory.makeView(cornerRadiusStyle: .radius(22), borderColor: ApplicationTheme.currentTheme.themeBasePrimaryColor, borderWidth: 1)
    private let txtSearch = UIFactory.makeTextField(font: UIFont.SFProDisplayNormalFont(14))
    
    private var delegate: FilterSheetSearchViewDelegate!
    
    convenience init(delegate: FilterSheetSearchViewDelegate) {
        self.init(frame: .zero)
        self.delegate = delegate
        self.txtSearch.delegate = self
        
        addViewsAndSetUpConstraints()
        setUpInitialAppearance()
    }
    
    private func addViewsAndSetUpConstraints() {
        addSubviews([bgView])
        bgView.addSubviews([searchBGView])
        searchBGView.addSubviews([imgSearch, txtSearch, btnCross])
        
        NSLayoutConstraint.activate([
            //bgView
            bgView.topAnchor.constraint(equalTo: topAnchor),
            bgView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bgView.bottomAnchor.constraint(equalTo: bottomAnchor),
            //search bgView
            searchBGView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 16),
            searchBGView.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -16),
            searchBGView.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -12),
            searchBGView.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 12),
            searchBGView.heightAnchor.constraint(equalToConstant: 44),
            // img search
            imgSearch.heightAnchor.constraint(equalToConstant: 24),
            imgSearch.widthAnchor.constraint(equalToConstant: 24),
            imgSearch.leadingAnchor.constraint(equalTo: searchBGView.leadingAnchor, constant: 16),
            imgSearch.centerYAnchor.constraint(equalTo: searchBGView.centerYAnchor),
            // txt search
            txtSearch.leadingAnchor.constraint(equalTo: imgSearch.trailingAnchor, constant: 8),
            txtSearch.centerYAnchor.constraint(equalTo: imgSearch.centerYAnchor),
            // btn cross
            btnCross.trailingAnchor.constraint(equalTo: searchBGView.trailingAnchor, constant: -16),
            btnCross.centerYAnchor.constraint(equalTo: txtSearch.centerYAnchor),
            btnCross.leadingAnchor.constraint(equalTo: txtSearch.trailingAnchor, constant: 8),
            btnCross.heightAnchor.constraint(equalToConstant: 16),
            btnCross.widthAnchor.constraint(equalToConstant: 16),
        ])
    }
    
    func setUpInitialAppearance() {
        imgSearch.image = UIImage(name: "search-SearchBar")
        txtSearch.setPlaceHolder(text: localizedString("search_products", comment: ""), color: ApplicationTheme.currentTheme.newBlackColor)
        txtSearch.textAlignment = ElGrocerUtility.sharedInstance.isArabicSelected() ? .right : .left
        
        btnCross.isHidden = true
        btnCross.addTarget(self, action: #selector(btnCrossTapHandler), for: .touchUpInside)
    }
    
    @objc func btnCrossTapHandler() {
        txtSearch.text = ""
        btnCross.isHidden = true
    }
    
    func setSearchText(text: String) {
        txtSearch.text = text
    }
    
}
extension FilterSheetSearchView: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        btnCross.isHidden = (textField.text == nil) && (textField.text == "")
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let newText = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        txtSearch.text = newText
        btnCross.isHidden = newText.count == 0
        self.delegate.searchDidEnd(text: textField.text ?? "")
        return false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.count ?? 0 == 0 {
            btnCross.isHidden = true
        }
        textField.resignFirstResponder()
        return true
    }
}
