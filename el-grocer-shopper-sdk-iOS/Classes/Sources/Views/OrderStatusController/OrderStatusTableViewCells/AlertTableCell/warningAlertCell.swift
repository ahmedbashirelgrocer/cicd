//
//  warningAlertCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 16/06/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

let KWarningAlertCellHeight : CGFloat = 48 + 32

class warningAlertCell: UITableViewCell {

    @IBOutlet var bGView: AWView!{
        didSet{
            bGView.cornarRadius = 8
        }
    }
    @IBOutlet var lblMsg: UILabel!{
        didSet{
            lblMsg.setCaptionOneRegDarkStyle()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ConfigureCell(text: "", highlightedText: "")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureWithOOS(){
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
            self.lblMsg.attributedText =  NSMutableAttributedString().normal(NSLocalizedString("Msg_Cart_total", comment: ""), UIFont.SFProDisplayNormalFont(11), color: .newBlackColor())
        }else{
            self.lblMsg.attributedText =  NSMutableAttributedString().normal(NSLocalizedString("Msg_Cart_Initial", comment: ""), UIFont.SFProDisplayNormalFont(11), color: .newBlackColor()).normal(NSLocalizedString("Msg_Cart_OUTOFSTOCK", comment: ""), UIFont.SFProDisplaySemiBoldFont(11), color: .redInfoColor()).normal(NSLocalizedString("Msg_Cart_ChooseReplacement", comment: ""), UIFont.SFProDisplayNormalFont(11), color: .newBlackColor())
        }
    }
    
    func ConfigureCell(text : String , highlightedText : String){
        
        self.lblMsg.attributedText = setBoldForText(CompleteValue: text, textForAttribute: highlightedText)
        
    }
    
    func configureOutOfStockHeaderView() {

        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
            self.lblMsg.attributedText =  NSMutableAttributedString().normal(NSLocalizedString("Msg_Cart_total", comment: ""), UIFont.SFProDisplayNormalFont(11), color: .newBlackColor())
        }else{
            self.lblMsg.attributedText =  NSMutableAttributedString().normal(NSLocalizedString("Msg_Cart_Initial", comment: ""), UIFont.SFProDisplayNormalFont(11), color: .newBlackColor()).normal(NSLocalizedString("Msg_Cart_OUTOFSTOCK", comment: ""), UIFont.SFProDisplaySemiBoldFont(11), color: .redInfoColor()).normal(NSLocalizedString("Msg_Cart_ChooseReplacement", comment: ""), UIFont.SFProDisplayNormalFont(11), color: .newBlackColor())
        }
       
      
        
        
        
        
        
        
    }
    
    //for setting multiple font in a label
    func setBoldForText(CompleteValue : String , textForAttribute: String) -> NSMutableAttributedString {
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: CompleteValue)
        let range: NSRange = attributedString.mutableString.range(of: textForAttribute, options: .caseInsensitive)
        let attrs = [NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(14), NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()]
        attributedString.addAttributes(attrs, range: range)
        return attributedString
    }

}
