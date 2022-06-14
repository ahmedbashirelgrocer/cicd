//
//  MyBasketInstructionTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 01/11/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
import GrowingTextView


class MyBasketInstructionTableViewCell: UITableViewCell , GrowingTextViewDelegate {

    @IBOutlet var lblYourinstruction: UILabel! {
        didSet{
            lblYourinstruction.text = NSLocalizedString("lbl_insturution_text", comment: "Your instructions to the store")
            //lblYourinstruction.isHidden = true
        }
    }
    @IBOutlet var lblRemaining: UILabel!
    @IBOutlet var txtNoteView: GrowingTextView!
    @IBOutlet var btnCross: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.txtNoteView.placeholder = NSLocalizedString("lbl_placeholder_text", comment: "type to leave us")

//        self.txtNoteView.placeholder = NSLocalizedString("instruction_textview_placeHolder", comment: "type to leave us")
        //self.txtNoteView.placeholderColor = .secondaryBlackColor()
        //self.btnCross.isHidden = (self.txtNoteView.text?.count == 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func crossAction(_ sender: Any) {
        
         self.txtNoteView.text = ""
        self.textViewDidBeginEditing(self.txtNoteView)

    }
    
}
extension MyBasketInstructionTableViewCell : UITextViewDelegate {
    
    
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
    }
    
   
    
    func textViewDidBeginEditing (_ textView: UITextView) {
        let charCount = textView.text.count
        var charRemaining = 100 - charCount
        if charCount == 0 {
            charRemaining = 0
        }
        
        let attributeTxt = NSMutableAttributedString(string: "\(charRemaining)/100")
        
            
        let range: NSRange = attributeTxt.mutableString.range(of: "\(charRemaining)", options: .caseInsensitive)
                
                attributeTxt.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black , range: range)
                attributeTxt.addAttribute(NSAttributedString.Key.font, value: UIFont.SFProDisplayNormalFont(10), range: range)
         
        self.lblRemaining.text = "\(charRemaining)/100"
        if charCount > 0{
            self.lblRemaining.highlight(searchedText: "\(charRemaining)", color: UIColor.black , size: 12)
        }
        self.btnCross.isHidden = (self.txtNoteView.text?.count == 0)
      //  adjustUITextViewHeight(arg : textView)
    }
    func textViewDidEndEditing (_ textView: UITextView) {
//        self.txtInsutrction.text = textView.text
//        let charRemaining = 100 -  textView.text.count
//        self.lblRemaining.text = "\(charRemaining)/100"
       // adjustUITextViewHeight(arg : textView)
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let charRemaining = textView.text.count + (text.count - range.length)
        self.lblRemaining.text = "\(charRemaining)/100"
        if text.count > 0 {
            self.lblRemaining.highlight(searchedText: "\(charRemaining)", color: UIColor.black , size: 12)
        }
        self.btnCross.isHidden = (self.txtNoteView.text?.count == 0)
        let trimmedString = (self.txtNoteView.text ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if (!(trimmedString.isEmpty)) {
            UserDefaults.setLeaveUsNote(textView.text ?? "")
        }else{
           // UserDefaults.setLeaveUsNote(nil)
        }
      //  adjustUITextViewHeight(arg : textView)
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
extension UILabel {
    
    func highlight(searchedText: String?..., color: UIColor = .red , size : CGFloat) {
        guard let txtLabel = self.text else { return }
        
        let attributeTxt = NSMutableAttributedString(string: txtLabel)
        
        searchedText.forEach {
            if let searchedText = $0?.lowercased() {
                let range: NSRange = attributeTxt.mutableString.range(of: searchedText, options: .caseInsensitive)
                
                attributeTxt.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
                attributeTxt.addAttribute(NSAttributedString.Key.font, value: UIFont.SFProDisplayBoldFont(size), range: range)
            }
        }
        
        self.attributedText = attributeTxt
    }
    
}
