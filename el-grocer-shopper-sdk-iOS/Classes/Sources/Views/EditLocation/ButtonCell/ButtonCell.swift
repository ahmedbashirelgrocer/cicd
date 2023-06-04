//
//  ButtonCell.swift
//  ElGrocerShopper
//
//  Created by Sarmad Abbas on 29/08/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

class ButtonCell: UITableViewCell {

    @IBOutlet weak var button: AWButton! {
        didSet{
            button.backgroundColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
