//
//  WalletHistoryCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 28/02/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import UIKit

let kWalletHistoryCellIdentifier = "WalletHistoryCell"
let kWalletHistoryCellHeight: CGFloat = 50

class WalletHistoryCell: UITableViewCell {
    
    
    @IBOutlet weak var purchaseTitle: UILabel!
    @IBOutlet weak var purchaseDate: UILabel!
    @IBOutlet weak var purchaseAmount: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setUpLabelAppearance()
    }
    
    
    // MARK: Appearance
    
    fileprivate func setUpLabelAppearance() {
        
        self.purchaseTitle.font = UIFont.SFProDisplaySemiBoldFont(13.0)
        self.purchaseTitle.textColor = UIColor.black
        
        self.purchaseDate.font = UIFont.lightFont(11.0)
        self.purchaseDate.textColor = UIColor.lightTextGrayColor()
        
        self.purchaseAmount.font = UIFont.lightFont(11.0)
        self.purchaseAmount.textColor = UIColor.darkGrayTextColor()
    }
    
    
    // MARK: Data
    
    func configureCellWithPurchaseTitle(_ purchaseTitle: String, withPurchaseDate purchaseDate:String, withPurchaseAmount purchaseAmount:String, andWithCurrencyType currenyType:String) {
        
        self.purchaseTitle.text = purchaseTitle
        self.purchaseDate.text = purchaseDate
        
        let dict1 = [NSAttributedString.Key.foregroundColor: ApplicationTheme.currentTheme.labelPrimaryBaseTextColor,NSAttributedString.Key.font:UIFont.SFProDisplaySemiBoldFont(15.0)]
        
        let dict2 = [NSAttributedString.Key.foregroundColor:UIColor.black,NSAttributedString.Key.font:UIFont.SFProDisplaySemiBoldFont(13.0)]
        
        let pricePart = NSMutableAttributedString(string:purchaseAmount, attributes:dict1)
        let currencyPart = NSMutableAttributedString(string:String(format:" %@",currenyType), attributes:dict2)
        
        let attributedStr = NSMutableAttributedString()
        attributedStr.append(pricePart)
        attributedStr.append(currencyPart)
        
        self.purchaseAmount.attributedText = attributedStr
    }
}
