//
//  PromoTitleCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 09/05/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

class PromoTitleView: UIView {

    @IBOutlet var bGView: UIView! {
        didSet {
            bGView.roundWithShadow(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 8)
            bGView.backgroundColor = .tableViewBackgroundColor()
        }
    }
    @IBOutlet var lblTitle: UILabel! {
        didSet {
            lblTitle.setH4SemiBoldStyle()
        }
    }
    class func loadFromNib() -> PromoTitleView? {
        return self.loadFromNib(withName: "PromoTitleView")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .tableViewBackgroundColor()
        // Initialization code
    }
    
    func configureView (title: String) {
        self.lblTitle.text = title
    }
    

}
