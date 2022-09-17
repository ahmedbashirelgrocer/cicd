//
//  WarningView.swift
//  ElGrocerShopper
//
//  Created by Rashid Khan on 08/09/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

class WarningView: UIView {
    @IBOutlet weak var lblWarningMsg: UILabel! {
        didSet {
            lblWarningMsg.setCaptionOneRegDarkStyle()
        }
    }
    
    override func awakeFromNib() {
        lblWarningMsg.setBody3RegWhiteStyle()
//        let text = NSLocalizedString("click_collect_warning_text", comment: "")
//        let highlightedText = NSLocalizedString("click_collect_warning_text_highlighted", comment: "")
//
//        self.lblWarningMsg.attributedText = NSMutableAttributedString().normal(text, UIFont.SFProDisplayNormalFont(12), color: .newBlackColor()).normal(highlightedText, UIFont.SFProDisplaySemiBoldFont(12), color: .newBlackColor())
        lblWarningMsg.textColor = .newBlackColor()
        lblWarningMsg.text = NSLocalizedString("click_collect_warning_text", comment: "")
        lblWarningMsg.highlight(searchedText: NSLocalizedString("click_collect_warning_text_highlighted", comment: ""), color: .newBlackColor(), size: 12)
    }
}
