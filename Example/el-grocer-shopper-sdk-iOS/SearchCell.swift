//
//  SearchCell.swift
//  el-grocer-shopper-sdk-iOS_Example
//
//  Created by Sarmad Abbas on 22/11/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

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
    
    func setData(_ data : [String: Any]) {
        if let urlString = data["retailer_ImgUrl"] as? String, let url = URL(string: urlString) {
            storeImageView.sd_setImage(with: url)
        }
        storeTitle.text = data["retailer_name"] as? String
    }
}
