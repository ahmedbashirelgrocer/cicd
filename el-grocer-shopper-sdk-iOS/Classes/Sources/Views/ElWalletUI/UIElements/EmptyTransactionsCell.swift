//
//  EmptyTransactionsCell.swift
//  ElGrocerShopper
//
//  Created by Salman on 06/05/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

class EmptyTransactionsCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var innerContainerView: UIView!{
        didSet {
            innerContainerView.roundWithShadow(corners: [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner], radius: 8, withShadow: false)
        }
    }
    @IBOutlet var lblNoTransection: UILabel! {
        didSet {
            lblNoTransection.text = NSLocalizedString("txt_no_transection_history", comment: "")
        }
    }
    
    static let reuseId: String = "EmptyTransactionsCell"
    static var nib: UINib {
        return UINib(nibName: "EmptyTransactionsCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
