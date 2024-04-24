//
//  instructionsTableCell.swift
//  ElGrocerShopper
//
//  Created by saboor Khan on 11/08/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import GrowingTextView

class instructionsTableCell: UITableViewCell , GrowingTextViewDelegate {
    
    
    var instructionsText : ((_ text : String?) -> Void)?
    var controller: UIViewController?
    @IBOutlet var lblRemaining: UILabel! {
        didSet {
            self.lblRemaining.text = ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: "0/100")
        }
    }
    @IBOutlet var txtNoteView: GrowingTextView!{
        didSet{
            txtNoteView.isScrollEnabled = true
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                txtNoteView.textAlignment = .right
            }
        }
    }
    @IBOutlet var btnCross: UIButton!
    @IBOutlet var superBGView: AWView! {
        didSet {
            superBGView.backgroundColor = ApplicationTheme.currentTheme.tableViewBackgroundColor
        }
    }
    var tblView : UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.txtNoteView.placeholder = localizedString("lbl_placeholder_text", comment: "type to leave us")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setData(tableView : UITableView , placeHolder : String , _ text : String = "", isFromCart:Bool = false){
        self.tblView = tableView
        self.btnCross.isHidden = (self.txtNoteView.text?.count == 0)
        if placeHolder.count > 0 {
            self.txtNoteView.placeholder = placeHolder
            if !text.isEmpty {
                self.txtNoteView.text = text
            }
        }
        self.superBGView.borderWidth = isFromCart ? 1 : 0
        self.superBGView.borderColor = isFromCart ? ApplicationTheme.currentTheme.textFieldBorderActiveColor : UIColor.clear
    }
    
    @IBAction func crossAction(_ sender: Any) {
        
         self.txtNoteView.text = ""
        
        self.tblView.beginUpdates()
        self.tblView.endUpdates()
        self.textViewDidBeginEditing(self.txtNoteView)
    }
}
extension instructionsTableCell : UITextViewDelegate {
    
    
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.layoutIfNeeded()
                //self.reloadTableCell(tableView: self.tblView, cell: self.cell, section: self.section)
            }
        }
        
    }
    
   
    
    func textViewDidBeginEditing (_ textView: UITextView) {
        defer {
            if let clouser = self.instructionsText {
                clouser(textView.text)
            }
        }
        let charCount = textView.text.count
        var charRemaining = 100 - charCount
        if charCount == 0 {
            charRemaining = 0
        }
        
        let attributeTxt = NSMutableAttributedString(string: "\(charRemaining)/100")
        
            
        let range: NSRange = attributeTxt.mutableString.range(of: "\(charRemaining)", options: .caseInsensitive)
                
                attributeTxt.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black , range: range)
                attributeTxt.addAttribute(NSAttributedString.Key.font, value: UIFont.SFProDisplayNormalFont(10), range: range)
         
        self.lblRemaining.text = ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: "\(charRemaining)/100")
        if charCount > 0{
            self.lblRemaining.highlight(searchedText: ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: "\(charRemaining)"), color: UIColor.black , size: UIFont.SFProDisplayBoldFont(12))
        }
        self.btnCross.isHidden = (self.txtNoteView.text?.count == 0)
        
      //  adjustUITextViewHeight(arg : textView)
    }
    func textViewDidChange(_ textView: UITextView) {
        defer {
            if let clouser = self.instructionsText {
                clouser(textView.text)
            }
        }
        self.tblView.beginUpdates()
        self.tblView.endUpdates()
    }
    func textViewDidEndEditing (_ textView: UITextView) {
        if self.controller is MyBasketPlaceOrderVC {
            if textView.text?.count ?? 0 > 0 {
                MixpanelEventLogger.trackCheckoutInstructionAdded(instruction: textView.text ?? "")
            }
        }
        if let clouser = self.instructionsText {
            clouser(textView.text)
        }
//        self.txtInsutrction.text = textView.text
//        let charRemaining = 100 -  textView.text.count
//        self.lblRemaining.text = "\(charRemaining)/100"
       // adjustUITextViewHeight(arg : textView)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        defer {
            if let clouser = self.instructionsText {
                clouser(textView.text)
            }
        }
        
        let charRemaining = textView.text.count + (text.count - range.length)
        self.lblRemaining.text = ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: "\(charRemaining)/100")
        if text.count > 0 {
            self.lblRemaining.highlight(searchedText: ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: "\(charRemaining)"), color: UIColor.black , size: UIFont.SFProDisplayBoldFont(12))
        }
        self.btnCross.isHidden = (self.txtNoteView.text?.count == 0)
        let trimmedString = (self.txtNoteView.text ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if (!(trimmedString.isEmpty)) {
            UserDefaults.setLeaveUsNote(textView.text ?? "")
        }else{
           // UserDefaults.setLeaveUsNote(nil)
        }
        return charRemaining < 100
    }
    
    func adjustUITextViewHeight(arg : UITextView)
    {
        self.btnCross.isHidden = (arg.text?.count == 0)
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
        arg.isScrollEnabled = false
        self.txtNoteView.text = arg.text
    }
    
}
