//
//  SeparatorTableViewCell.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 04/05/2023.
//

import UIKit

class SeparatorTableViewCell: UITableViewCell {
    @IBOutlet weak var viewBG: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        viewBG.backgroundColor = .tableViewBackgroundColor()
    }
    
    func configure(backgroundColor: UIColor) {
        self.viewBG.backgroundColor = backgroundColor
    }
}
