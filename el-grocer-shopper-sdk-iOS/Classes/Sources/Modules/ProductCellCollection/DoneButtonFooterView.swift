//
//  DoneButtonFooterView.swift
//  ElGrocerShopper
//
//  Created by Abubaker Majeed on 15/05/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit

class DoneButtonFooterView: UITableViewHeaderFooterView {

    @IBOutlet weak var btnDone: UIButton!
     var doneButton: (()->Void)?
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBAction func DoneButtonHandler(_ sender: Any) {
        if let clouser = doneButton {
           clouser()
        }
    }
}
