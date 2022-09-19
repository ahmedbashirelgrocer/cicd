//
//  AdditionalInstructionsView.swift
//  ElGrocerShopper
//
//  Created by Rashid Khan on 25/08/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit
import GrowingTextView

protocol AdditionalInstructionsViewDelegate: AnyObject {
    func textViewTextChangeDone(text: String)
}

class AdditionalInstructionsView: UIView {
    @IBOutlet weak var tfAdditionalNote: GrowingTextView! {
        didSet{
            tfAdditionalNote.isScrollEnabled = true
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                tfAdditionalNote.textAlignment = .right
            }
        }
    }
    
    @IBOutlet weak var lblRemainingText: UILabel! {
        didSet {
            self.lblRemainingText.text = ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: "0/100")
        }
    }
    
    @IBOutlet weak var crossButton: UIButton!
    @IBOutlet weak var viewBG: AWView!
    
    weak var delegate: AdditionalInstructionsViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.tfAdditionalNote.placeholder = localizedString("lbl_placeholder_text", comment: "type to leave us")
        self.tfAdditionalNote.delegate = self
        self.crossButton.isHidden = true
    }
    
    @IBAction func crossButtonTapHandler(_ sender: Any) {
        self.tfAdditionalNote.text = ""
        self.crossButton.isHidden = true
        self.lblRemainingText.text = ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: "0/100")
    }
}

extension AdditionalInstructionsView: GrowingTextViewDelegate {
    func textViewDidBeginEditing (_ textView: UITextView) {
//        defer {
//            self.delegate?.textViewTextChangeDone(text: textView.text)
//        }
        
        let charCount = textView.text.count
        var charRemaining = 100 - charCount
        if charCount == 0 {
            charRemaining = 0
        }
        
        let attributeTxt = NSMutableAttributedString(string: "\(charRemaining)/100")
        
        
        let range: NSRange = attributeTxt.mutableString.range(of: "\(charRemaining)", options: .caseInsensitive)
        
        attributeTxt.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black , range: range)
        attributeTxt.addAttribute(NSAttributedString.Key.font, value: UIFont.SFProDisplayNormalFont(10), range: range)
        
        self.lblRemainingText.text = ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: "\(charRemaining)/100")
        if charCount > 0{
            self.lblRemainingText.highlight(searchedText: ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: "\(charRemaining)"), color: UIColor.black , size: 12)
        }
        self.crossButton.isHidden = (self.tfAdditionalNote.text?.count == 0)
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
//        self.delegate?.textViewTextChangeDone(text: textView.text)
    }
    
    func textViewDidEndEditing (_ textView: UITextView) {
        self.delegate?.textViewTextChangeDone(text: textView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        
        // show/hide cross button on the base of text in text view
        self.crossButton.isHidden = newText.count == 0 ? true : false
        
        // update count value and text style
        self.lblRemainingText.text = ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: "\(newText.count)/100")
        
        if newText.count > 0 {
            self.lblRemainingText.highlight(searchedText: ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: "\(newText.count)"), color: UIColor.black , size: 12)
        }
        
        //
//        if newText.count < 100 {
//            self.delegate?.textViewTextChangeDone(text: newText)
//        }
        
        return newText.count < 100
    }
    
    func adjustUITextViewHeight(arg : UITextView) {
//        self.crossButton.isHidden = (arg.text?.count == 0)
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
        arg.isScrollEnabled = false
        self.tfAdditionalNote.text = arg.text
    }
    
}
