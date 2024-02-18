//
//  FAQSearchView.swift
//  ElGrocerShopper
//
//  Created by Salman on 13/01/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

protocol searchBarDelegate : class {
    func performSerach(searchString: String)
}

class FAQSearchView: UIView {

    weak var delegate: searchBarDelegate?

    @IBOutlet weak var searchFieldContainerView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    var searchString : String = ""
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        searchTextField.delegate = self
        self.setUpSearchViewAppearance()
    }
    
    func setUpSearchViewAppearance() {
        self.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
        searchTextField.setPlaceHolder(text: localizedString("FAQ_search_placeholder", comment: ""))
        searchFieldContainerView.layer.borderWidth = 1
        searchFieldContainerView.layer.borderColor = ApplicationTheme.currentTheme.borderGrayColor.cgColor
    }
}

// MARK:- UITextFieldDelegate Extension
extension FAQSearchView: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.searchFieldContainerView.layer.borderColor = ApplicationTheme.currentTheme.textFieldBorderActiveColor.cgColor
//        if self.searchFor == .isForStoreSearch {
//            self.tableView.backgroundView = nil
//            self.showCollectionView(false)
//        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.searchFieldContainerView.layer.borderColor = ApplicationTheme.currentTheme.borderGrayColor.cgColor
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        delegate?.performSerach(searchString: textField.text ?? "")
        return true
        
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        // searched tapped
        let searchString = textField.text ?? ""
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        delegate?.performSerach(searchString: "")
        return true
    }
    
    
}
