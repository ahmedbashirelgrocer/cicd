//
//  NavigationBarSearchView.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 07.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

protocol NavigationBarSearchProtocol : class {
    
   func navigationBarSearchViewDidChangeText(_ navigationBarSearch:NavigationBarSearchView, searchString:String) -> Void
   func navigationBarSearchViewDidChangeCharIn(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Void
    func navigationBarSearchTapped()
}

class NavigationBarSearchView : UIView, UITextFieldDelegate {
    
    weak var delegate:NavigationBarSearchProtocol?
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchPlaceholder: UILabel!
    @IBOutlet weak var searchIconLeftSpaceConstraint: NSLayoutConstraint!
    
    var wasSearchIconPositionAdjusted:Bool = false
    var isSearchBarEdited:Bool = false
    
    // MARK: Instance
    
    class func loadViewFromNib() -> NavigationBarSearchView {
        
       return Bundle(for: self).loadNibNamed("NavigationBarSearchView", owner: nil, options: nil)![0] as! NavigationBarSearchView
    }
    
    // MARK: Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(red: 0.896, green: 0.896, blue: 0.896, alpha: 1).cgColor
      //  self.layer.borderColor = UIColor.white.cgColor
        
        setUpSearchAppearance()
    }
    
    override func layoutSubviews() {
        
        self.layer.cornerRadius = self.frame.size.height / 2
        
//        if !self.wasSearchIconPositionAdjusted {
//            adjustSearchIconAndPlaceholderPosition(false, animated:false)
//            self.wasSearchIconPositionAdjusted = true
//        }
         adjustSearchIconAndPlaceholderPosition(true, animated:false)
        
        super.layoutSubviews()
    }
    
    // MARK: Appearance
    
    func setUpSearchAppearance() {
       
        self.searchTextField.font = UIFont.SFProDisplayNormalFont(14)
        self.searchTextField.textColor = UIColor.black
        self.searchTextField.textAlignment = .justified
        self.searchPlaceholder.text = NSLocalizedString("search_products", comment: "")
        self.searchPlaceholder.font = UIFont.SFProDisplayNormalFont(14)
        self.searchPlaceholder.textColor = UIColor.searchPlaceholderTextColor()
        self.searchTextField.clearButtonMode = .unlessEditing
        self.searchTextField.clearButton?.setImage(UIImage(name: "sCross"), for: .normal)
    }
    
    func adjustSearchIconAndPlaceholderPosition(_ isEditing:Bool, animated:Bool) {
        
    //    let width = ScreenSize.SCREEN_WIDTH
        let notEditingWidth = self.frame.size.width * 0.55  // 206 in desgin so 375 *0.55 = 206 // (self.frame.size.width / 2) - 16 - self.searchPlaceholder.font.sizeOfString(self.searchPlaceholder.text!, constrainedToWidth: Double.greatestFiniteMagnitude).width / 2
        
      ///   let EditingWidth = width * 0.9
        
        self.searchIconLeftSpaceConstraint.constant = (isEditing || !self.searchTextField.text!.isEmpty) ? 8 : notEditingWidth
        self.searchPlaceholder.isHidden = self.searchTextField.text!.isEmpty ? false : true
        
        if animated {
            
            UIView.animate(withDuration: 0.33, animations: { () -> Void in
                
                self.layoutIfNeeded()
            })
        }
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        print("Tap on text field")
        if self.delegate is SearchViewController  {
            self.isSearchBarEdited = true
        }
        self.delegate?.navigationBarSearchTapped()
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newText = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        self.searchTextField.text = newText
        
        adjustSearchIconAndPlaceholderPosition(true, animated:false)
        
        self.delegate?.navigationBarSearchViewDidChangeText(self, searchString: self.searchTextField.text!)
        self.delegate?.navigationBarSearchViewDidChangeCharIn(textField, shouldChangeCharactersIn: range, replacementString: string)
        return false
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        self.searchTextField.text = ""
        self.endEditing(true)
        self.delegate?.navigationBarSearchViewDidChangeText(self, searchString: "")
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.isSearchBarEdited = false
        self.endEditing(true)
        self.delegate?.navigationBarSearchTapped()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.delegate?.navigationBarSearchTapped()
       // adjustSearchIconAndPlaceholderPosition(true, animated:true)
        return false
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
         self.isSearchBarEdited = false
        if self.delegate is SearchViewController {
             self.delegate?.navigationBarSearchTapped()
        }
        adjustSearchIconAndPlaceholderPosition(false, animated:true)
        return true
    }
    
}
