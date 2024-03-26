//
//  EmptyVouchersCell.swift
//  ElGrocerShopper
//
//  Created by Salman on 06/05/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

class EmptyVouchersCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var innerContainerView: AWView!{
        didSet {
            innerContainerView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor        }
    }
    @IBOutlet var lblNoVoucher: UILabel! {
        didSet {
            lblNoVoucher.text = localizedString("txt_no_voucher", comment: "")
        }
    }
    
    static let reuseId: String = "EmptyVouchersCell"
    static var nib: UINib {
        return UINib(nibName: "EmptyVouchersCell", bundle: .resource)
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
