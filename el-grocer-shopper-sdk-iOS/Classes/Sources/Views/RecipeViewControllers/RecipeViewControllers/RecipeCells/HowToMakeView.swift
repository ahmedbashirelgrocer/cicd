//
//  HowToMakeView.swift
//  ElGrocerShopper
//
//  Created by Abubaker Majeed on 25/04/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit

let KHowToMakeHeaderHeight = 60.0
class HowToMakeView: UITableViewHeaderFooterView {

    @IBOutlet weak var lblHowToMake: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func awakeFromNib() {
        self.lblHowToMake.text = NSLocalizedString("lbl_HowToMake", comment: "")
    }

}
