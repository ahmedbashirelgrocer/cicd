//
//  EGNewAddressTableViewCell.swift
//  Pods
//
//  Created by M Abubaker Majeed on 01/06/2023.
//

import UIKit

class EGNewAddressTableViewCell: UITableViewCell {
    
    static let identifier = "EGNewAddressTableViewCell"
    
    @IBOutlet weak var imgAddressPin: UIImageView!
    @IBOutlet weak var lblNickName: UILabel!
    @IBOutlet weak var lblAddressDetail: UILabel!
    @IBOutlet weak var lblAddressStyle: UILabel! {
        didSet{
            lblAddressStyle.layer.cornerRadius = 100
            lblAddressStyle.clipsToBounds = true
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
    
}
