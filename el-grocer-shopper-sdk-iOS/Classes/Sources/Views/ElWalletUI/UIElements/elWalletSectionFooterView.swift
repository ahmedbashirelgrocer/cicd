//
//  elWalletSectionFooterView.swift
//  ElGrocerShopper
//
//  Created by Salman on 29/04/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

class elWalletSectionFooterView: UITableViewHeaderFooterView {

    
    @IBOutlet weak var containerView: UIView!{
        didSet {
            containerView.roundWithShadow(corners: [.layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 8, withShadow: false)
        }
    }
    static let reuseId: String = "elWalletSectionFooterView"
    static var nib: UINib {
        return UINib(nibName: "elWalletSectionFooterView", bundle: .resource)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
