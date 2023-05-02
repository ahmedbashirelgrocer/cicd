//
//  EarnedSmilePointCell.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Abdul Saboor on 01/11/2022.
//

import UIKit

class EarnedSmilePointCell: UITableViewCell {

    @IBOutlet var borderBGView: AWView! {
        didSet {
            borderBGView.cornarRadius = 8
            borderBGView.borderWidth = 1
            borderBGView.borderColor = UIColor.smileBaseColor()
        }
    }
    @IBOutlet var lblSmilePointsEarned: UILabel! {
        didSet {
            lblSmilePointsEarned.setBody3RegDarkStyle()
            lblSmilePointsEarned.text = localizedString("lbl_smile_point_earned", comment: "")
        }
    }
    @IBOutlet var lblSmilePointEarnedValue: UILabel! {
        didSet {
            lblSmilePointEarnedValue.setBody3RegPurpleStyle()
        }
    }
    @IBOutlet var smilesLogoImg: UIImageView! {
        didSet {
            smilesLogoImg.image = UIImage(name: "smilesCellLogo")
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
    
    func configure(points: Double) {
        
        self.lblSmilePointEarnedValue.text = "+" + points.formateDisplayString()
    }

}
