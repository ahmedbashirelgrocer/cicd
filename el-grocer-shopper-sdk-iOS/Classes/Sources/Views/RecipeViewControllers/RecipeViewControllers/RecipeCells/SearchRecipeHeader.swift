//
//  SearchRecipeHeader.swift
//  ElGrocerShopper
//
//  Created by Abubaker Majeed on 15/04/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit

let KSearchHeaderHeight = 250.0
class SearchRecipeHeader: UITableViewHeaderFooterView {

    var searchCharChanged: ((_ stringToFIltered : String)->Void)?
    @IBOutlet weak var bgContentView: UIView!
    @IBOutlet weak var textFieldSearch: UITextField!
    @IBOutlet weak var viewTextFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var chefListView: ChefListView!
    @IBOutlet weak var categoryListView: RecipeCategoriesList!
    
    var lastdate : Date = Date()
    
    override func awakeFromNib() {
        self.setUpApearance()
    }

    func setUpApearance() {

        self.textFieldSearch.delegate = self
        self.textFieldSearch.placeholder = localizedString("search_Field_PlaceHolder", comment: "")
        self.textFieldSearch.attributedPlaceholder = NSAttributedString.init(string: self.textFieldSearch.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldPlaceholderTextColor()])
        
    }
    
    func startSearchProcess () {
        if let availableClouser = self .searchCharChanged  {
            availableClouser(self.textFieldSearch.text ?? "")
        }
    }
}
extension SearchRecipeHeader : UITextFieldDelegate {


    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {

        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        NSObject.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(SearchRecipeHeader.performSearch),
            object: textField)
        self.perform(
            #selector(SearchRecipeHeader.performSearch),
            with: textField,
            afterDelay: 0.35)
        defer {
        }
        let newText = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        self.textFieldSearch.text = newText
        return false

    }
    @objc
    func performSearch(textField: UITextField) {
       elDebugPrint("Hints for textField: \(textField)")
        if self.textFieldSearch.text?.count ?? 0 > 1 {
           // if self.lastdate.timeIntervalSinceNow < -0.5 {
             //   self.lastdate = Date()
                self.startSearchProcess()
           // }
            
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.count ?? 0 == 0 {
            self.startSearchProcess()
        }
        textField.resignFirstResponder()
        return true
    }
    


}
