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
        
        viewBG.backgroundColor = .tableViewBackgroundColor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
