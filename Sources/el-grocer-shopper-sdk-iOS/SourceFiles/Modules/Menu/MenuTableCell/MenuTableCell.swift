//
//  MenuTableCell.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 03.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

let kMenuTableCellIdentifier = "MenuTableCell"

class MenuTableCell : UITableViewCell {
    
    fileprivate var menuItem: MenuItem?

    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var walletAmount: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var separatorView: UIView!
    
    // MARK: Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        
        setUpLabelAppearance()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        self.backgroundColor = highlighted ? UIColor.unselectedPageControl() : UIColor.clear
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.menuItem = nil
    }
    
    // MARK: Appearance
    
    fileprivate func setUpLabelAppearance() {
        
        self.itemTitle.font = UIFont.SFProDisplaySemiBoldFont(14.0)
        self.itemTitle.textColor = UIColor.black
        
        self.walletAmount.font = UIFont.SFProDisplaySemiBoldFont(12.0)
        self.walletAmount.textColor = UIColor.black
    }
    
    // MARK: Data
    
    func configureCellWithMenuItem(_ menuItem: MenuItem, withImage image:String ,shouldShowNotificationDot:Bool) {
        
        self.menuItem = menuItem
        
        self.itemImage.image = UIImage(name:image)
        self.itemTitle.text = menuItem.title
    }

}
