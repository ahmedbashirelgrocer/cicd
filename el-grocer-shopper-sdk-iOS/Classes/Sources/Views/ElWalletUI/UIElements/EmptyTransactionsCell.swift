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
    @IBOutlet weak var innerContainerView: AWView!{
        didSet {
            innerContainerView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
        }
    }
    @IBOutlet var lblNoTransection: UILabel! {
        didSet {
            lblNoTransection.text = localizedString("txt_no_transection_history", comment: "")
        }
    }
    
    static let reuseId: String = "EmptyTransactionsCell"
    static var nib: UINib {
        return UINib(nibName: "EmptyTransactionsCell", bundle: .resource)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.containerView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
