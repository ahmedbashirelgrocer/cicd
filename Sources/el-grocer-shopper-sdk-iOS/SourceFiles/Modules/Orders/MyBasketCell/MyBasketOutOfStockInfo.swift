//
//  MyBasketOutOfStockInfo.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 04/11/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit

class MyBasketOutOfStockInfo: UIView {
    
    @IBOutlet var lblMessage: UILabel!
    
    class func loadFromNib() -> MyBasketOutOfStockInfo? {
        return self.loadFromNib(withName: "MyBasketOutOfStockInfo")
    }
    
    func configure() {
        self.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
//        "Msg_Cart_Initial" = "Some items in your cart are currently ";
//        "Msg_Cart_OUTOFSTOCK" = "OUT OF STOCK. ";
//        "Msg_Cart_ChooseReplacement" = "Please choose the suitable replacement. ";
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
            lblMessage.text = localizedString("Msg_Cart_total", comment: "")
            lblMessage.highlight(searchedText: localizedString("Msg_Cart_OUTOFSTOCK", comment: ""), color: .redInfoColor(), size: UIFont.SFProDisplayBoldFont(11))
//            self.lblMessage.attributedText =  NSMutableAttributedString().normal(localizedString("Msg_Cart_total", comment: ""), UIFont.SFProDisplayNormalFont(11), color: .newBlackColor())
//            self.lblMessage.attributedText =  NSMutableAttributedString().normal(localizedString("Msg_Cart_Initial", comment: ""), UIFont.SFProDisplayNormalFont(11), color: .newBlackColor()).normal(localizedString("Msg_Cart_OUTOFSTOCK", comment: ""), UIFont.SFProDisplaySemiBoldFont(11), color: .redInfoColor()).normal(localizedString("Msg_Cart_ChooseReplacement", comment: ""), UIFont.SFProDisplayNormalFont(11), color: .newBlackColor())
        }else{
            self.lblMessage.attributedText =  NSMutableAttributedString().normal(localizedString("Msg_Cart_Initial", comment: ""), UIFont.SFProDisplayNormalFont(11), color: .newBlackColor()).normal(localizedString("Msg_Cart_OUTOFSTOCK", comment: ""), UIFont.SFProDisplaySemiBoldFont(11), color: .redInfoColor()).normal(localizedString("Msg_Cart_ChooseReplacement", comment: ""), UIFont.SFProDisplayNormalFont(11), color: .newBlackColor())
        }
       
      
        
        
        
        
        
        
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
