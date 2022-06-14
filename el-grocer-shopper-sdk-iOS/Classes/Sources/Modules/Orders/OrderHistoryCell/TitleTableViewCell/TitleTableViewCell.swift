//
//  TitleTableViewCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 04/10/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class TitleTableViewCell: UITableViewCell {

    @IBOutlet var lblTitle: UILabel!{
        didSet{
            self.lblTitle.setH3SemiBoldDarkStyle()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureTitle(title: String) {
        self.lblTitle.text = title
    }

}
