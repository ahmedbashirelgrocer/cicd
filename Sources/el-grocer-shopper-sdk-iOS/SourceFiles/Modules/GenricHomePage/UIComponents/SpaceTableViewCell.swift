//
//  SpaceTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 06/08/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit

protocol SpaceTableViewCellViewModelType { }
class SpaceTableViewCellViewModel: SpaceTableViewCellViewModelType, ReusableTableViewCellViewModelType {
    var reusableIdentifier: String { SpaceTableViewCell.defaultIdentifier }
}

class SpaceTableViewCell: RxUITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
