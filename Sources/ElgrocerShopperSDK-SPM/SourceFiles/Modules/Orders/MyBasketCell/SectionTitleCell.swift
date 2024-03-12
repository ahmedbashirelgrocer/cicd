//
//  SectionTitleCell.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 16/11/2023.
//

import UIKit

class SectionTitleCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var cellHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblTitle.setH4SemiBoldStyle()
        
    }

    func configure(title: String, topPadding: Double = 20, bottomPadding: Double = 12) {
        self.lblTitle.text = title
        
        self.cellHeightConstraint.constant = calculateCellHeight(topPadding: topPadding, bottomPadding: bottomPadding)
        self.titleTopConstraint.constant = topPadding
        self.titleBottomConstraint.constant = bottomPadding
    }
    
    private func calculateCellHeight(topPadding: Double, bottomPadding: Double) -> Double {
        let labelHeight = self.lblTitle.text?.heightOfString(usingFont: UIFont.SFProDisplaySemiBoldFont(17)) ?? 24
        return labelHeight + topPadding + bottomPadding
    }
}
