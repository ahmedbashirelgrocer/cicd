//
//  OutOfStockSelectedOptionCell.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 15/11/2023.
//

import UIKit

class SelectedMissingItemPreference: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSelectedOption: UILabel!
    @IBOutlet weak var viewBG: AWView!
    
    var cellTapHandler: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblTitle.setBodyBoldDarkStyle()
        lblSelectedOption.setCaptionOneRegDarkStyle()
        
        self.viewBG.isUserInteractionEnabled = true
        self.viewBG.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellTap)))
    }

   
    func configure(selectedOption: Reasons?) {
        self.lblSelectedOption.text = selectedOption?.reasonString
    }
    
    @objc func cellTap(_ sender: UITapGestureRecognizer) {
        if let cellTapHandler = cellTapHandler {
            cellTapHandler()
        }
    }
    
}
