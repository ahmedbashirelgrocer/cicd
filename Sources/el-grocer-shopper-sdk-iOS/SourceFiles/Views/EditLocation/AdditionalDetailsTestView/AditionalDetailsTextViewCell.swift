//
//  AditionalDetailsTextViewCell.swift
//  ElGrocerShopper
//
//  Created by Sarmad Abbas on 29/08/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit
import GrowingTextView

class AditionalDetailsTextViewCell: UITableViewCell {

    @IBOutlet weak var placeHolder: UILabel!
    @IBOutlet weak var textView: GrowingTextView!
    @IBOutlet weak var lblCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.delegate = self
    }

    @IBAction func btnClosePressed(_ sender: Any) {
        
    }
    
}

extension AditionalDetailsTextViewCell: UITextViewDelegate {
//    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if ( ( (self.textView.text ?? "") as NSString).length < 100) || strcmp(text.cString(using: String.Encoding.utf8), "\\b") == -92 {
            return true
        } else {
            return false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        lblCount.text = "\(self.textView.text.count)/100"
    }
}
