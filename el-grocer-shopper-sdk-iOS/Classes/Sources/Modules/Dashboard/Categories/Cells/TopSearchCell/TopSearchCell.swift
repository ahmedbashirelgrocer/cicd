//
//  TopSearchCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 20/02/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import UIKit

let kTopSearchCell = "TopSearchCell"
let kTopSearchCellHeight: CGFloat = 40

class TopSearchCell: UITableViewCell {
    
    
    @IBOutlet weak var titleLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: Data
    func configure(_ title: String){
        self.titleLbl.text = title
    }
}
