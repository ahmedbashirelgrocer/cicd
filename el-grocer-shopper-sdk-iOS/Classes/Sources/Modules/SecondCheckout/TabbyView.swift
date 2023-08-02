//
//  TabbyView.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 26/06/2023.
//

import UIKit

protocol TabbyViewDelegate: AnyObject {
    func helpTap()
    func switchStateChanged(_ tabbyView: TabbyView, _ state: Bool)
}

class TabbyView: UIView {
    @IBOutlet weak var viewBG: AWView!
    @IBOutlet weak var lblTitle: UILabel! {
        didSet {
            lblTitle.setBody3RegDarkStyle()
        }
    }
    @IBOutlet weak var lblDetails: UILabel!
    @IBOutlet weak var tabbySwitch: UISwitch!
    
    weak var delegate: TabbyViewDelegate?
    
    override func awakeFromNib() {
        lblTitle.text = localizedString("tabby_view_title_text", comment: "")
        lblDetails.attributedText = makeStringGreenAndBold(text: localizedString("tabby_view_details_text", comment: ""), changedText: localizedString("tabby_threshold_with_currency", comment: ""))
        
        tabbySwitch.addTarget(self, action: #selector(switchChanged(_ :)), for: UIControl.Event.valueChanged)
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            tabbySwitch.semanticContentAttribute = .forceRightToLeft
        } else {
            tabbySwitch.semanticContentAttribute = .forceLeftToRight
        }
    }
    
    func enableTabbyPayment(status: Bool) {
        self.tabbySwitch.isOn = status
    }
    
    @IBAction func helpButtonTap(_ sender: Any) {
        self.delegate?.helpTap()
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        self.delegate?.switchStateChanged(self, sender.isOn)
    }
    
    func makeStringGreenAndBold(text: String , changedText: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        let totalRange = NSRange(location: 0, length: text.count)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.secondaryBlackColor(), range: totalRange)
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.SFProDisplayRegularItalic(12), range: totalRange)
        
        let range = (text as NSString).range(of: changedText)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.secondaryBlackColor(), range: range)
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.SFProDisplayHeavyItalic(12), range: range)

        return attributedString
    }
}
