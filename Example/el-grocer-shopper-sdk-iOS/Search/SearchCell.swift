//
//  SearchCell.swift
//  el-grocer-shopper-sdk-iOS_Example
//
//  Created by Sarmad Abbas on 22/11/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import ElgrocerShopperSDK_SPM

class SearchCell: UITableViewCell {
    
    @IBOutlet weak var storeImageView: UIImageView!
    @IBOutlet weak var storeTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(_ data : SearchResult) {
        if let url = data.retailerImgUrl {
            storeImageView.sd_setImage(with: url)
        }
        storeTitle.text = data.retailerName
    }
}
